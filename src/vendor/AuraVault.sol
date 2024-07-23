// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {AggregatorV3Interface} from "../vendor/AggregatorV3Interface.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {wdiv, wmul} from "../utils/Math.sol";
import {IPool} from "./IAuraPool.sol";
import {IOracle} from "../interfaces/IOracle.sol";
import {IVault, BatchSwapStep, FundManagement, SwapKind} from "../vendor/IBalancerVault.sol";
import {IPriceOracle} from "./IPriceOracle.sol";

// Authenticated Roles
bytes32 constant VAULT_ADMIN_ROLE = keccak256("VAULT_ADMIN_ROLE");

bytes32 constant VAULT_CONFIG_ROLE = keccak256("VAULT_CONFIG_ROLE");

/// @title AuraVault
/// @notice `A 4626 vault that compounds rewards from an Aura RewardsPool
contract AuraVault is IERC4626, ERC4626, AccessControl {
    /*//////////////////////////////////////////////////////////////
                                LIBRARIES
    //////////////////////////////////////////////////////////////*/
    using SafeERC20 for IERC20;
    using Math for uint256;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The Aura pool distributing rewards
    address public immutable rewardPool;

    /// @notice The max permitted claimer incentive
    uint32 public immutable maxClaimerIncentive;

    /// @notice The max permitted locker incentive
    uint32 public immutable maxLockerIncentive;

    /// @notice The incentive rates denomination
    uint256 private constant INCENTIVE_BASIS = 10000;

    /// @notice The BAL token
    address private constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;

    address private constant BAL_CHAINLINK_FEED = 0xdF2917806E30300537aEB49A7663062F4d1F2b5F;
    uint256 private constant BAL_CHAINLINK_DECIMALS = 1e8;

    address private constant ETH_CHAINLINK_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    uint256 private constant ETH_CHAINLINK_DECIMALS = 1e8;

    /// @notice The AURA token
    address private constant AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;

    // Utilities for AURA mining calcs
    uint256 private constant EMISSIONS_MAX_SUPPLY = 5e25; // 50m
    uint256 private constant INIT_MINT_AMOUNT = 5e25; // 50m
    uint256 private constant TOTAL_CLIFFS = 500;
    uint256 private constant REDUCTION_PER_CLIFF = 1e23;
    uint256 private constant INFLATION_PROTECTION_TIME = 1749120350;

    /// @notice The feed providing USD prices for asset, rewardToken and secondaryRewardToken
    address public feed;

    /// @notice The Oracle providing the AURA token price
    address public auraPriceOracle;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    struct VaultConfig {
        /// @notice The incentive sent to claimer (in bps)
        uint32 claimerIncentive;
        /// @notice The incentive sent to lockers (in bps)
        uint32 lockerIncentive;
        /// @notice The locker rewards distributor
        address lockerRewards;
    }
    /// @notice CDPVault configuration
    VaultConfig public vaultConfig;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice `caller` has exchanged `shares`, owned by `owner`, for
    ///         `assets`, and transferred those `assets` to `receiver`.
    event Claimed(
        address indexed caller,
        uint256 rewardTokenClaimed,
        uint256 secondaryRewardTokenClaimed,
        uint256 lpTokenCompounded
    );

    event SetParameter(bytes32 parameter, uint256 data);

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error AuraVault__setParameter_unrecognizedParameter();
    error AuraVault__chainlinkSpot_invalidPrice();
    error AuraVault__fetchAggregator_invalidToken();
    error AuraVault__setVaultConfig_invalidClaimerIncentive();
    error AuraVault__setVaultConfig_invalidLockerIncentive();
    error AuraVault__setVaultConfig_invalidLockerRewards();

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    // TODO: check inputs
    constructor(
        address rewardPool_,
        address asset_,
        address feed_,
        address auraPriceOracle_,
        uint32 maxClaimerIncentive_,
        uint32 maxLockerIncentive_,
        string memory tokenName_,
        string memory tokenSymbol_
    ) ERC4626(IERC20(asset_)) ERC20(tokenName_, tokenSymbol_) {
        rewardPool = rewardPool_;
        feed = feed_;
        auraPriceOracle = auraPriceOracle_;
        maxClaimerIncentive = maxClaimerIncentive_;
        maxLockerIncentive = maxLockerIncentive_;
    }

    /*//////////////////////////////////////////////////////////////
                             CONFIGURATION
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets various variables for this contract
    /// @dev Sender has to be allowed to call this method
    /// @param parameter Name of the variable to set
    /// @param data New value to set for the variable [wad]
    function setParameter(bytes32 parameter, uint256 data) external onlyRole(VAULT_CONFIG_ROLE) {
        if (parameter == "feed") feed = address(uint160(data));
        else if (parameter == "auraPriceOracle") auraPriceOracle = address(uint160(data));
        else revert AuraVault__setParameter_unrecognizedParameter();
        emit SetParameter(parameter, data);
    }

    function setVaultConfig(
        uint32 _claimerIncentive,
        uint32 _lockerIncentive,
        address _lockerRewards
    ) public onlyRole(VAULT_ADMIN_ROLE) returns (bool) {
        if (_claimerIncentive > maxClaimerIncentive) revert AuraVault__setVaultConfig_invalidClaimerIncentive();
        if (_lockerIncentive > maxLockerIncentive) revert AuraVault__setVaultConfig_invalidLockerIncentive();
        if (_lockerRewards == address(0x0)) revert AuraVault__setVaultConfig_invalidLockerRewards();

        vaultConfig = VaultConfig({
            claimerIncentive: _claimerIncentive,
            lockerIncentive: _lockerIncentive,
            lockerRewards: _lockerRewards
        });

        return true;
    }

    /* ========== 4626 Vault ========== */

    /**
     * @notice Total amount of the underlying asset that is "managed" by Vault.
     */
    function totalAssets() public view virtual override(IERC4626, ERC4626) returns (uint256) {
        return IPool(rewardPool).balanceOf(address(this));
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual override returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual override returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    /**
     * @notice Mints `shares` Vault shares to `receiver`.
     * @dev Because `asset` is not actually what is collected here, first wrap to required token in the booster.
     *
     * TODO: account for unclaimed rewards
     */
    function deposit(uint256 assets, address receiver) public virtual override(IERC4626, ERC4626) returns (uint256) {
        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        // Deposit  in reward pool
        IERC20(asset()).safeApprove(rewardPool, assets);
        IPool(rewardPool).deposit(assets, address(this));

        return shares;
    }

    /**
     * @notice Mints exactly `shares` Vault shares to `receiver`
     * by depositing `assets` of underlying tokens.
     *
     * TODO: account for unclaimed rewards
     */
    function mint(uint256 shares, address receiver) public virtual override(IERC4626, ERC4626) returns (uint256) {
        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        // Deposit assets in reward pool
        IERC20(asset()).safeApprove(rewardPool, assets);
        IPool(rewardPool).deposit(assets, address(this));

        return assets;
    }

    /**
     * @notice Redeems `shares` from `owner` and sends `assets`
     * of underlying tokens to `receiver`.
     *
     * TODO: account for unclaimed rewards
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual override(IERC4626, ERC4626) returns (uint256) {
        require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");

        uint256 shares = previewWithdraw(assets);

        // Withdraw assets from Aura reward pool and send to "receiver"
        IPool(rewardPool).withdraw(assets, address(this), address(this));

        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /**
     * @notice Redeems `shares` from `owner` and sends `assets`
     * of underlying tokens to `receiver`.
     *
     * TODO account for unclaimed rewards
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual override(IERC4626, ERC4626) returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

        // Redeem assets from Aura reward pool and send to "receiver"
        uint256 assets = IPool(rewardPool).redeem(shares, address(this), address(this));

        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /*//////////////////////////////////////////////////////////////
                             REWARD COMPOUNDING
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Allows anyone to claim accumulated rewards by depositing WETH instead
     * @param amounts An array of reward amounts to be claimed ordered as [rewardToken, secondaryRewardToken]
     * @param maxAmountIn The max amount of WETH to be sent to the Vault
     */
    function claim(uint256[] memory amounts, uint256 maxAmountIn) external returns (uint256 amountIn) {
        // Claim rewards from Aura reward pool
        IPool(rewardPool).getReward();

        // Compute assets amount to be sent to the Vault
        VaultConfig memory _config = vaultConfig;
        amountIn = _previewReward(amounts[0], amounts[1], _config);

        // Transfer assets to Vault
        require(amountIn <= maxAmountIn, "!Slippage");
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), amountIn);

        // Compound assets into "asset" balance
        IERC20(asset()).safeApprove(rewardPool, amountIn);
        IPool(rewardPool).deposit(amountIn, address(this));

        // Distribute BAL rewards
        IERC20(BAL).safeTransfer(_config.lockerRewards, (amounts[0] * _config.lockerIncentive) / INCENTIVE_BASIS);
        IERC20(BAL).safeTransfer(msg.sender, amounts[0]);

        // Distribute AURA rewards
        if (block.timestamp <= INFLATION_PROTECTION_TIME) {
            IERC20(AURA).safeTransfer(_config.lockerRewards, (amounts[1] * _config.lockerIncentive) / INCENTIVE_BASIS);
            IERC20(AURA).safeTransfer(msg.sender, amounts[1]);
        } else {
            // after INFLATION_PROTECTION_TIME
            IERC20(AURA).safeTransfer(_config.lockerRewards, IERC20(AURA).balanceOf(address(this)));
        }

        emit Claimed(msg.sender, amounts[0], amounts[1], amountIn);
    }

    /**
     * @dev Assumes 0 AURA rewards after INFLATION_PROTECTION_TIME since amount minted is unkown
     */
    function previewReward() public view returns (uint256 amount) {
        VaultConfig memory config = vaultConfig;
        uint256 balReward = IPool(rewardPool).earned(address(this)) + IERC20(BAL).balanceOf(address(this));
        // No AURA rewards after INFLATION_PROTECTION_TIME
        uint256 auraReward = (block.timestamp > INFLATION_PROTECTION_TIME)
            ? 0
            : _previewMining(balReward) + IERC20(AURA).balanceOf(address(this));
        amount = _previewReward(balReward, auraReward, config);
    }

    function _previewReward(
        uint256 balReward,
        uint256 auraReward,
        VaultConfig memory config
    ) private view returns (uint256 amount) {
        amount = (balReward * _chainlinkSpot()) / IOracle(feed).spot(asset());
        amount = amount + (auraReward * _getAuraSpot()) / IOracle(feed).spot(asset());
        amount = (amount * (INCENTIVE_BASIS - config.claimerIncentive)) / INCENTIVE_BASIS;
    }

    /**
     * @dev Calculates the amount of AURA to mint based on the BAL supply schedule
     * Should not be used after INFLATION_PROTECTION_TIME since minterMinted is unknown
     * See https://etherscan.io/token/0xc0c293ce456ff0ed870add98a0828dd4d2903dbf#code
     */
    function _previewMining(uint256 _amount) private view returns (uint256 amount) {
        uint256 supply = IERC20(AURA).totalSupply();
        uint256 minterMinted = 0; // Cannot fetch because private in AURA
        uint256 emissionsMinted = supply - INIT_MINT_AMOUNT - minterMinted;

        uint256 cliff = emissionsMinted / REDUCTION_PER_CLIFF;

        // e.g. 100 < 500
        if (cliff < TOTAL_CLIFFS) {
            // e.g. (new) reduction = (500 - 100) * 2.5 + 700 = 1700;
            // e.g. (new) reduction = (500 - 250) * 2.5 + 700 = 1325;
            // e.g. (new) reduction = (500 - 400) * 2.5 + 700 = 950;
            uint256 reduction = ((TOTAL_CLIFFS - cliff) * 5) / 2 + 700;
            // e.g. (new) amount = 1e19 * 1700 / 500 =  34e18;
            // e.g. (new) amount = 1e19 * 1325 / 500 =  26.5e18;
            // e.g. (new) amount = 1e19 * 950 / 500  =  19e17;
            amount = (_amount * reduction) / TOTAL_CLIFFS;
            // e.g. amtTillMax = 5e25 - 1e25 = 4e25
            uint256 amtTillMax = EMISSIONS_MAX_SUPPLY - emissionsMinted;
            if (amount > amtTillMax) {
                amount = amtTillMax;
            }
        }
    }

    function _chainlinkSpot() private view returns (uint256 price) {
        bool isValid;
        try AggregatorV3Interface(BAL_CHAINLINK_FEED).latestRoundData() returns (
            uint80 /*roundId*/,
            int256 answer,
            uint256 /*startedAt*/,
            uint256 /*updatedAt*/,
            uint80 /*answeredInRound*/
        ) {
            price = wdiv(uint256(answer), BAL_CHAINLINK_DECIMALS);
            isValid = (price > 0);
        } catch {}

        if (!isValid) revert AuraVault__chainlinkSpot_invalidPrice();
    }

    function _getAuraSpot() internal view returns (uint256 price) {
        uint256 ethPrice;
        (, int256 answer, , , ) = AggregatorV3Interface(ETH_CHAINLINK_FEED).latestRoundData();
        ethPrice = wdiv(uint256(answer), ETH_CHAINLINK_DECIMALS);

        IPriceOracle.OracleAverageQuery[] memory queries = new IPriceOracle.OracleAverageQuery[](1);
        queries[0] = IPriceOracle.OracleAverageQuery(IPriceOracle.Variable.PAIR_PRICE, 1800, 0);
        uint256[] memory results = IPriceOracle(auraPriceOracle).getTimeWeightedAverage(queries);

        price = wmul(results[0], ethPrice);
    }

    /*//////////////////////////////////////////////////////////////
                             REWARD COMPOUNDING
    //////////////////////////////////////////////////////////////*/
}
