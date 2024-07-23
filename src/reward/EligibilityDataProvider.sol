// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IMultiFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";
import {IChefIncentivesController} from "./interfaces/IChefIncentivesController.sol";
import {IPriceProvider} from "./interfaces/IPriceProvider.sol";
import {LockedBalance, Balances} from "./interfaces/LockedBalance.sol";
import {IVaultRegistry} from "../interfaces/IVaultRegistry.sol";

/// @title Eligible Deposit Provider
/// @author LoopFi
/// @dev Based on Radiant EligibilityDataProvider contract at
/// https://github.com/radiant-capital/v2/blob/cd618877151896415705468f1b2a43c4b75b3c5b/contracts/radiant/eligibility/EligibilityDataProvider.sol

contract EligibilityDataProvider is OwnableUpgradeable {
    /********************** Common Info ***********************/

    /// @notice RATIO BASE equal to 100%
    uint256 public constant RATIO_DIVISOR = 10000;

    /// @notice Initial required ratio of TVL to get reward; in bips
    uint256 public constant INITIAL_REQUIRED_DEPOSIT_RATIO = 500;

    /// @notice Initial ratio of the required price to still allow without disqualification; in bips
    uint256 public constant INITIAL_PRICE_TOLERANCE_RATIO = 9000;

    /// @notice Minimum required ratio of TVL to get reward; in bips
    uint256 public constant MIN_PRICE_TOLERANCE_RATIO = 8000;

    IVaultRegistry public vaultRegistry;

    /// @notice Address of CIC
    IChefIncentivesController public chef;

    /// @notice Address of MultiFeeDistribution contract
    IMultiFeeDistribution public multiFeeDistribution;

    /// @notice RDNT + LP price provider
    IPriceProvider public priceProvider;

    /// @notice Required ratio of TVL to get reward; in bips
    uint256 public requiredDepositRatio;

    /// @notice Ratio of the required price to still allow without disqualification; in bips
    uint256 public priceToleranceRatio;

    /// @notice RDNT-ETH LP token
    address public lpToken;

    /********************** Eligible info ***********************/

    /// @notice Last eligible status of the user
    mapping(address => bool) public lastEligibleStatus;

    /// @notice Disqualified time of the user
    mapping(address => uint256) public disqualifiedTime;

    /********************** Events ***********************/

    /// @notice Emitted when CIC is set
    event ChefIncentivesControllerUpdated(IChefIncentivesController indexed _chef);

    /// @notice Emitted when LP token is set
    event LPTokenUpdated(address indexed _lpToken);

    /// @notice Emitted when required TVL ratio is updated
    event RequiredDepositRatioUpdated(uint256 indexed requiredDepositRatio);

    /// @notice Emitted when price tolerance ratio is updated
    event PriceToleranceRatioUpdated(uint256 indexed priceToleranceRatio);

    /// @notice Emitted when DQ time is set
    event DqTimeUpdated(address indexed _user, uint256 _time);

    /********************** Errors ***********************/
    error AddressZero();

    error LPTokenSet();

    error InvalidRatio();

    error OnlyCIC();

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Constructor
     * @param _vaultRegistry Address of lending pool.
     * @param _multiFeeDistribution MultiFeeDistribution contract address.
     * @param _priceProvider PriceProvider address.
     */
    function initialize(
        IVaultRegistry _vaultRegistry,
        IMultiFeeDistribution _multiFeeDistribution,
        IPriceProvider _priceProvider
    ) public initializer {
        if (address(_vaultRegistry) == address(0)) revert AddressZero();
        if (address(_multiFeeDistribution) == address(0)) revert AddressZero();
        if (address(_priceProvider) == address(0)) revert AddressZero();

        vaultRegistry = _vaultRegistry;
        multiFeeDistribution = _multiFeeDistribution;
        priceProvider = _priceProvider;
        requiredDepositRatio = INITIAL_REQUIRED_DEPOSIT_RATIO;
        priceToleranceRatio = INITIAL_PRICE_TOLERANCE_RATIO;
        __Ownable_init();
    }

    /********************** Setters ***********************/

    /**
     * @notice Set CIC
     * @param _chef address.
     */
    function setChefIncentivesController(IChefIncentivesController _chef) external onlyOwner {
        if (address(_chef) == address(0)) revert AddressZero();
        chef = _chef;
        emit ChefIncentivesControllerUpdated(_chef);
    }

    /**
     * @notice Set LP token
     */
    function setLPToken(address _lpToken) external onlyOwner {
        if (_lpToken == address(0)) revert AddressZero();
        if (lpToken != address(0)) revert LPTokenSet();
        lpToken = _lpToken;

        emit LPTokenUpdated(_lpToken);
    }

    /**
     * @notice Sets required tvl ratio. Can only be called by the owner.
     * @param _requiredDepositRatio Ratio in bips.
     */
    function setRequiredDepositRatio(uint256 _requiredDepositRatio) external onlyOwner {
        if (_requiredDepositRatio > RATIO_DIVISOR) revert InvalidRatio();
        requiredDepositRatio = _requiredDepositRatio;

        emit RequiredDepositRatioUpdated(_requiredDepositRatio);
    }

    /**
     * @notice Sets price tolerance ratio. Can only be called by the owner.
     * @param _priceToleranceRatio Ratio in bips.
     */
    function setPriceToleranceRatio(uint256 _priceToleranceRatio) external onlyOwner {
        if (_priceToleranceRatio < MIN_PRICE_TOLERANCE_RATIO || _priceToleranceRatio > RATIO_DIVISOR)
            revert InvalidRatio();
        priceToleranceRatio = _priceToleranceRatio;

        emit PriceToleranceRatioUpdated(_priceToleranceRatio);
    }

    /**
     * @notice Sets DQ time of the user
     * @dev Only callable by CIC
     * @param _user's address
     * @param _time for DQ
     */
    function setDqTime(address _user, uint256 _time) external {
        if (msg.sender != address(chef)) revert OnlyCIC();
        disqualifiedTime[_user] = _time;

        emit DqTimeUpdated(_user, _time);
    }

    /********************** View functions ***********************/

    /**
     * @notice Returns locked RDNT and LP token value in eth
     * @param user's address
     */
    function lockedUsdValue(address user) public view returns (uint256) {
        Balances memory _balances = IMultiFeeDistribution(multiFeeDistribution).getBalances(user);
        return _lockedUsdValue(_balances.locked);
    }

    /**
     * @notice Returns USD value required to be locked
     * @param user's address
     * @return required USD value.
     */
    function requiredUsdValue(address user) public view returns (uint256 required) {
        uint256 totalNormalDebt = vaultRegistry.getUserTotalDebt(user);
        required = (totalNormalDebt * requiredDepositRatio) / RATIO_DIVISOR;
        return _lockedUsdValue(required);
    }

    /**
     * @notice Returns if the user is eligible to receive rewards
     * @param _user's address
     */
    function isEligibleForRewards(address _user) public view returns (bool) {
        uint256 lockedValue = lockedUsdValue(_user);

        uint256 requiredValue = (requiredUsdValue(_user) * priceToleranceRatio) / RATIO_DIVISOR;
        return requiredValue != 0 && lockedValue >= requiredValue;
    }

    /**
     * @notice Returns DQ time of the user
     * @param _user's address
     */
    function getDqTime(address _user) public view returns (uint256) {
        return disqualifiedTime[_user];
    }

    /**
     * @notice Returns last eligible time of the user
     * @dev If user is still eligible, it will return future time
     *  CAUTION: this function only works perfect when the array
     *  is ordered by lock time. This is assured when _stake happens.
     * @param user's address
     * @return lastEligibleTimestamp of the user. Returns 0 if user is not eligible.
     */
    function lastEligibleTime(address user) public view returns (uint256 lastEligibleTimestamp) {
        if (!isEligibleForRewards(user)) {
            return 0;
        }

        uint256 requiredValue = requiredUsdValue(user);

        LockedBalance[] memory lpLockData = IMultiFeeDistribution(multiFeeDistribution).lockInfo(user);

        uint256 lockedLP;
        for (uint256 i = lpLockData.length; i > 0; ) {
            LockedBalance memory currentLockData = lpLockData[i - 1];
            lockedLP += currentLockData.amount;

            if (_lockedUsdValue(lockedLP) >= requiredValue) {
                return currentLockData.unlockTime;
            }
            unchecked {
                i--;
            }
        }
    }

    /********************** Operate functions ***********************/
    /**
     * @notice Refresh token amount for eligibility
     * @param user The address of the user
     * @return currentEligibility The current eligibility status of the user
     */
    function refresh(address user) external returns (bool currentEligibility) {
        if (msg.sender != address(chef)) revert OnlyCIC();
        if (user == address(0)) revert AddressZero();

        updatePrice();
        currentEligibility = isEligibleForRewards(user);
        if (currentEligibility && disqualifiedTime[user] != 0) {
            disqualifiedTime[user] = 0;
        }
        lastEligibleStatus[user] = currentEligibility;
    }

    /**
     * @notice Update token price
     */
    function updatePrice() public {
        priceProvider.update();
    }

    /********************** Internal functions ***********************/

    /**
     * @notice Returns locked RDNT and LP token value in USD
     * @param lockedLP is locked lp amount
     */
    function _lockedUsdValue(uint256 lockedLP) internal view returns (uint256) {
        uint256 lpPrice = priceProvider.getLpTokenPriceUsd();
        return (lockedLP * lpPrice) / 10 ** 18;
    }
}
