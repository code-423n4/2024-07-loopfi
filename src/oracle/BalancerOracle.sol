// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {wdiv, WAD, wpow, wmul} from "../utils/Math.sol";
import {IOracle, MANAGER_ROLE} from "../interfaces/IOracle.sol";
import {IVault} from "../vendor/IBalancerVault.sol";
import {IWeightedPool} from "../vendor/IWeightedPool.sol";

bytes32 constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

contract BalancerOracle is IOracle, AccessControlUpgradeable, UUPSUpgradeable {
    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Balancer v2 Vault
    IVault public immutable balancerVault;

    IOracle public immutable chainlinkOracle;

    /// @notice Update period in seconds
    uint256 public immutable updateWaitWindow;

    /// @notice Stale period in seconds
    uint256 public immutable stalePeriod;

    /// @notice Balancer Pool address
    address public immutable pool;

    /// @notice Balancer Pool ID
    bytes32 public immutable poolId;

    /// @notice Balancer Pool tokens
    address internal immutable token0;

    address internal immutable token1;

    address internal immutable token2;

    // todo: can be packed in a single struct
    uint256 public safePrice;
    uint256 public currentPrice;
    uint256 public lastUpdate;

    /*//////////////////////////////////////////////////////////////
                              STORAGE GAP
    //////////////////////////////////////////////////////////////*/

    uint256[47] private __gap;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error BalancerOracle__authorizeUpgrade_validStatus();
    error BalancerOracle__update_InUpdateWaitWindow();
    error BalancerOracle__spot_invalidPrice();
    error BalancerOracle__getTokenPrice_invalidIndex();

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(
        address balancerVault_,
        address chainlinkOracle_,
        address pool_,
        uint256 updateWaitWindow_,
        uint256 stalePeriod_
    ) initializer {
        balancerVault = IVault(balancerVault_);
        updateWaitWindow = updateWaitWindow_;
        stalePeriod = stalePeriod_;
        chainlinkOracle = IOracle(chainlinkOracle_);
        pool = pool_;
        poolId = IWeightedPool(pool).getPoolId();

        (address[] memory tokens, , ) = balancerVault.getPoolTokens(poolId);

        // store the tokens
        uint256 len = tokens.length;
        token0 = (len > 0) ? tokens[0] : address(0);
        token1 = (len > 1) ? tokens[1] : address(0);
        token2 = (len > 2) ? tokens[2] : address(0);
    }

    /*//////////////////////////////////////////////////////////////
                             UPGRADEABILITY
    //////////////////////////////////////////////////////////////*/

    /// @notice Initialize method called by the proxy contract
    /// @param admin The address of the admin
    /// @param manager The address of the manager who can authorize upgrades
    function initialize(address admin, address manager) external initializer {
        // init. Access Control
        __AccessControl_init();
        // Role Admin
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        // Credit Manager
        _grantRole(MANAGER_ROLE, manager);
    }

    /// @notice Authorizes an upgrade
    /// @param /*implementation*/ The address of the new implementation
    /// @dev reverts if the caller is not a manager or if the status check succeeds
    function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {
        if (_getStatus()) revert BalancerOracle__authorizeUpgrade_validStatus();
    }

    function update() external virtual onlyRole(KEEPER_ROLE) returns (uint256 safePrice_) {
        if (block.timestamp - lastUpdate < updateWaitWindow) revert BalancerOracle__update_InUpdateWaitWindow();
        // update the safe price first
        safePrice = safePrice_ = currentPrice;
        lastUpdate = block.timestamp;

        uint256[] memory weights = IWeightedPool(pool).getNormalizedWeights();
        uint256 totalSupply = IWeightedPool(pool).totalSupply();

        uint256 totalPi = WAD;
        uint256[] memory prices = new uint256[](weights.length);
        // update balances in 18 decimals
        for (uint256 i = 0; i < weights.length; i++) {
            // reverts if the price is invalid or stale
            prices[i] = _getTokenPrice(i);
            uint256 val = wdiv(prices[i], weights[i]);
            uint256 indivPi = uint256(wpow(int256(val), int256(weights[i])));

            totalPi = wmul(totalPi, indivPi);
        }

        currentPrice = wdiv(wmul(totalPi, IWeightedPool(pool).getInvariant()), totalSupply);
    }

    /*//////////////////////////////////////////////////////////////
                                PRICING
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the status of the oracle
    /// @param /*token*/ Token address, ignored for this oracle
    /// @dev The status is valid if the price is validated and not stale
    function getStatus(address /*token*/) public view virtual override returns (bool status) {
        // add stale check?
        return _getStatus();
    }

    function _getStatus() internal view returns (bool status) {
        status = (safePrice != 0) && block.timestamp - lastUpdate < stalePeriod;
    }

    /// @notice Returns the latest price for the asset
    /// @param /*token*/ Token address
    /// @return price Asset price [WAD]
    /// @dev reverts if the price is invalid
    function spot(address /*token*/) external view virtual override returns (uint256 price) {
        if (!_getStatus()) {
            revert BalancerOracle__spot_invalidPrice();
        }
        return safePrice;
    }

    function _getTokenPrice(uint256 index) internal view returns (uint256 price) {
        address token;
        if (index == 0) token = token0;
        else if (index == 1) token = token1;
        else if (index == 2) token = token2;
        else revert BalancerOracle__getTokenPrice_invalidIndex();

        return chainlinkOracle.spot(token);
    }
}
