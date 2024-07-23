// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import {RecoverERC20} from "./libraries/RecoverERC20.sol";
import {IChefIncentivesController} from "./interfaces/IChefIncentivesController.sol";
import {IBountyManager} from "./interfaces/IBountyManager.sol";
import {IMultiFeeDistribution, IFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";
import {IMintableToken} from "./interfaces/IMintableToken.sol";
import {LockedBalance, Balances, Reward, EarnedBalance} from "./interfaces/LockedBalance.sol";
import {IPriceProvider} from "./interfaces/IPriceProvider.sol";

/// @title Multi Fee Distribution Contract
/// @author LoopFi
/// @dev Based on Radiant MultiFeeDistribution contract at
/// https://github.com/radiant-capital/v2/blob/cd618877151896415705468f1b2a43c4b75b3c5b/contracts/radiant/staking/MultiFeeDistribution.sol
contract MultiFeeDistribution is
    IMultiFeeDistribution,
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    RecoverERC20
{
    using SafeERC20 for IERC20;
    using SafeERC20 for IMintableToken;

    address private _priceProvider;

    /********************** Constants ***********************/

    uint256 public constant QUART = 25000; //  25%
    uint256 public constant HALF = 65000; //  65%
    uint256 public constant WHOLE = 100000; // 100%

    // Maximum slippage allowed to be set by users (used for compounding).
    uint256 public constant MAX_SLIPPAGE = 9000; //10%
    uint256 public constant PERCENT_DIVISOR = 10000; //100%

    uint256 public constant AGGREGATION_EPOCH = 6 days;

    uint256 public constant RATIO_DIVISOR = 10000;

    /// @notice Proportion of burn amount
    uint256 public burn;

    /// @notice Duration that rewards are streamed over
    uint256 public rewardsDuration;

    /// @notice Duration that rewards loop back
    uint256 public rewardsLookback;

    /// @notice Default lock index
    uint256 public constant DEFAULT_LOCK_INDEX = 1;

    /// @notice Duration of lock/earned penalty period, used for earnings
    uint256 public defaultLockDuration;

    /// @notice Duration of vesting RDNT
    uint256 public vestDuration;

    /// @notice Returns reward converter
    address public rewardConverter;

    /********************** Contract Addresses ***********************/

    /// @notice Address of CIC contract
    IChefIncentivesController public incentivesController;

    /// @notice Address of RDNT
    IMintableToken public rdntToken;

    /// @notice Address of LP token
    address public stakingToken;

    // Address of Lock Zapper
    address internal _lockZap;

    /********************** Lock & Earn Info ***********************/

    // Private mappings for balance data
    mapping(address => Balances) private _balances;
    mapping(address => LockedBalance[]) internal _userLocks;
    mapping(address => LockedBalance[]) private _userEarnings;
    mapping(address => bool) public autocompoundEnabled;
    mapping(address => uint256) public lastAutocompound;

    /// @notice Total locked value
    uint256 public lockedSupply;

    /// @notice Total locked value in multipliers
    uint256 public lockedSupplyWithMultiplier;

    // Time lengths
    uint256[] internal _lockPeriod;

    // Multipliers
    uint256[] internal _rewardMultipliers;

    /********************** Reward Info ***********************/

    /// @notice Reward tokens being distributed
    address[] public rewardTokens;

    /// @notice Reward data per token
    mapping(address => Reward) public rewardData;

    /// @notice user -> reward token -> rpt; RPT for paid amount
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;

    /// @notice user -> reward token -> amount; used to store reward amount
    mapping(address => mapping(address => uint256)) public rewards;

    /********************** Other Info ***********************/

    /// @notice DAO wallet
    address public daoTreasury;

    /// @notice treasury wallet
    address public starfleetTreasury;

    /// @notice Addresses approved to call mint
    mapping(address => bool) public minters;

    // Addresses to relock
    mapping(address => bool) public autoRelockDisabled;

    // Default lock index for relock
    mapping(address => uint256) public defaultLockIndex;

    /// @notice Flag to prevent more minter addings
    bool public mintersAreSet;

    /// @notice Last claim time of the user
    mapping(address => uint256) public lastClaimTime;

    /// @notice Bounty manager contract
    address public bountyManager;

    /// @notice Maximum slippage for each trade excepted by the individual user when performing compound trades
    mapping(address => uint256) public userSlippage;

    /// @notice Reward ratio for operation expenses
    uint256 public operationExpenseRatio;

    /// @notice Account where operational expenses are sent to
    address public operationExpenseReceiver;

    /// @notice Stores whether a token is being destibuted to dLP lockers
    mapping(address => bool) public isRewardToken;

    /********************** Events ***********************/

    event Locked(address indexed user, uint256 amount, uint256 lockedBalance, uint256 indexed lockLength, bool isLP);
    event Withdrawn(
        address indexed user,
        uint256 receivedAmount,
        uint256 lockedBalance,
        uint256 penalty,
        uint256 burn,
        bool isLP
    );
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);
    event Relocked(address indexed user, uint256 amount, uint256 lockIndex);
    event BountyManagerUpdated(address indexed _bounty);
    event RewardConverterUpdated(address indexed _rewardConverter);
    event LockTypeInfoUpdated(uint256[] lockPeriod, uint256[] rewardMultipliers);
    event AddressesUpdated(IChefIncentivesController _controller, address indexed _treasury);
    event LPTokenUpdated(address indexed _stakingToken);
    event RewardAdded(address indexed _rewardToken);
    event LockerAdded(address indexed locker);
    event LockerRemoved(address indexed locker);
    event RevenueEarned(address indexed asset, uint256 assetAmount);
    event OperationExpensesUpdated(address indexed _operationExpenses, uint256 _operationExpenseRatio);
    event NewTransferAdded(address indexed asset, uint256 lpUsdValue);

    /********************** Errors ***********************/
    error AddressZero();
    error AmountZero();
    error InvalidBurn();
    error InvalidRatio();
    error InvalidLookback();
    error MintersSet();
    error InvalidLockPeriod();
    error InsufficientPermission();
    error AlreadyAdded();
    error AlreadySet();
    error InvalidType();
    error ActiveReward();
    error InvalidAmount();
    error InvalidEarned();
    error InvalidTime();
    error InvalidPeriod();
    error UnlockTimeNotFound();
    error InvalidAddress();
    error InvalidAction();

    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer
     *  First reward MUST be the RDNT token or things will break
     *  related to the 50% penalty and distribution to locked balances.
     * @param rdntToken_ RDNT token address
     * @param lockZap_ LockZap contract address
     * @param dao_ DAO address
     * @param priceProvider_ PriceProvider contract address
     * @param rewardsDuration_ Duration that rewards are streamed over
     * @param rewardsLookback_ Duration that rewards loop back
     * @param lockDuration_ lock duration
     * @param burnRatio_ Proportion of burn amount
     * @param vestDuration_ vest duration
     */
    function initialize(
        address rdntToken_,
        address lockZap_,
        address dao_,
        address priceProvider_,
        uint256 rewardsDuration_,
        uint256 rewardsLookback_,
        uint256 lockDuration_,
        uint256 burnRatio_,
        uint256 vestDuration_
    ) public initializer {
        if (rdntToken_ == address(0)) revert AddressZero();
        if (lockZap_ == address(0)) revert AddressZero();
        if (dao_ == address(0)) revert AddressZero();
        if (priceProvider_ == address(0)) revert AddressZero();
        if (rewardsDuration_ == uint256(0)) revert AmountZero();
        if (rewardsLookback_ == uint256(0)) revert AmountZero();
        if (lockDuration_ == uint256(0)) revert AmountZero();
        if (vestDuration_ == uint256(0)) revert AmountZero();
        if (burnRatio_ > WHOLE) revert InvalidBurn();
        if (rewardsLookback_ > rewardsDuration_) revert InvalidLookback();

        __Pausable_init();
        __Ownable_init();

        rdntToken = IMintableToken(rdntToken_);
        _lockZap = lockZap_;
        daoTreasury = dao_;
        _priceProvider = priceProvider_;
        rewardTokens.push(rdntToken_);
        rewardData[rdntToken_].lastUpdateTime = block.timestamp;

        rewardsDuration = rewardsDuration_;
        rewardsLookback = rewardsLookback_;
        defaultLockDuration = lockDuration_;
        burn = burnRatio_;
        vestDuration = vestDuration_;
    }

    /********************** Setters ***********************/

    /**
     * @notice Set minters
     * @param minters_ array of address
     */
    function setMinters(address[] calldata minters_) external onlyOwner {
        uint256 length = minters_.length;
        for (uint256 i; i < length; ) {
            if (minters_[i] == address(0)) revert AddressZero();
            minters[minters_[i]] = true;
            unchecked {
                i++;
            }
        }
        mintersAreSet = true;
    }

    /**
     * @notice Sets bounty manager contract.
     * @param bounty contract address
     */
    function setBountyManager(address bounty) external onlyOwner {
        if (bounty == address(0)) revert AddressZero();
        bountyManager = bounty;
        minters[bounty] = true;
        emit BountyManagerUpdated(bounty);
    }

    /**
     * @notice Sets reward converter contract.
     * @param rewardConverter_ contract address
     */
    function addRewardConverter(address rewardConverter_) external onlyOwner {
        if (rewardConverter_ == address(0)) revert AddressZero();
        rewardConverter = rewardConverter_;
        emit RewardConverterUpdated(rewardConverter_);
    }

    /**
     * @notice Sets lock period and reward multipliers.
     * @param lockPeriod_ lock period array
     * @param rewardMultipliers_ multipliers per lock period
     */
    function setLockTypeInfo(uint256[] calldata lockPeriod_, uint256[] calldata rewardMultipliers_) external onlyOwner {
        if (lockPeriod_.length != rewardMultipliers_.length) revert InvalidLockPeriod();
        delete _lockPeriod;
        delete _rewardMultipliers;
        uint256 length = lockPeriod_.length;
        for (uint256 i; i < length; ) {
            _lockPeriod.push(lockPeriod_[i]);
            _rewardMultipliers.push(rewardMultipliers_[i]);
            unchecked {
                i++;
            }
        }
        emit LockTypeInfoUpdated(lockPeriod_, rewardMultipliers_);
    }

    /**
     * @notice Set CIC, MFD and Treasury.
     * @param controller_ CIC address
     * @param treasury_ address
     */
    function setAddresses(IChefIncentivesController controller_, address treasury_) external onlyOwner {
        if (address(controller_) == address(0)) revert AddressZero();
        if (address(treasury_) == address(0)) revert AddressZero();
        incentivesController = controller_;
        starfleetTreasury = treasury_;
        emit AddressesUpdated(controller_, treasury_);
    }

    /**
     * @notice Set LP token.
     * @param stakingToken_ LP token address
     */
    function setLPToken(address stakingToken_) external onlyOwner {
        if (stakingToken_ == address(0)) revert AddressZero();
        if (stakingToken != address(0)) revert AlreadySet();
        stakingToken = stakingToken_;
        emit LPTokenUpdated(stakingToken_);
    }

    /**
     * @notice Add a new reward token to be distributed to stakers.
     * @param _rewardToken address
     */
    function addReward(address _rewardToken) external {
        if (_rewardToken == address(0)) revert AddressZero();
        if (!minters[msg.sender]) revert InsufficientPermission();
        if (rewardData[_rewardToken].lastUpdateTime != 0) revert AlreadyAdded();
        rewardTokens.push(_rewardToken);

        Reward storage rd = rewardData[_rewardToken];
        rd.lastUpdateTime = block.timestamp;
        rd.periodFinish = block.timestamp;

        isRewardToken[_rewardToken] = true;
        emit RewardAdded(_rewardToken);
    }

    /**
     * @notice Remove an existing reward token.
     * @param _rewardToken address to be removed
     */
    function removeReward(address _rewardToken) external {
        if (!minters[msg.sender]) revert InsufficientPermission();

        bool isTokenFound;
        uint256 indexToRemove;

        uint256 length = rewardTokens.length;
        for (uint256 i; i < length; i++) {
            if (rewardTokens[i] == _rewardToken) {
                isTokenFound = true;
                indexToRemove = i;
                break;
            }
        }

        if (!isTokenFound) revert InvalidAddress();

        // Reward token order is changed, but that doesn't have an impact
        if (indexToRemove < length - 1) {
            rewardTokens[indexToRemove] = rewardTokens[length - 1];
        }

        rewardTokens.pop();

        // Scrub historical reward token data
        Reward storage rd = rewardData[_rewardToken];
        rd.lastUpdateTime = 0;
        rd.periodFinish = 0;
        rd.balance = 0;
        rd.rewardPerSecond = 0;
        rd.rewardPerTokenStored = 0;

        isRewardToken[_rewardToken] = false;
    }

    /**
     * @notice Set default lock type index for user relock.
     * @param index of default lock length
     */
    function setDefaultRelockTypeIndex(uint256 index) external {
        if (index >= _lockPeriod.length) revert InvalidType();
        defaultLockIndex[msg.sender] = index;
    }

    /**
     * @notice Sets option if auto compound is enabled.
     * @param status true if auto compounding is enabled.
     * @param slippage the maximum amount of slippage that the user will incur for each compounding trade
     */
    function setAutocompound(bool status, uint256 slippage) external {
        autocompoundEnabled[msg.sender] = status;
        if (slippage < MAX_SLIPPAGE || slippage >= PERCENT_DIVISOR) {
            revert InvalidAmount();
        }
        userSlippage[msg.sender] = slippage;
    }

    /**
     * @notice Set what slippage to use for tokens traded during the auto compound process on behalf of the user
     * @param slippage the maximum amount of slippage that the user will incur for each compounding trade
     */
    function setUserSlippage(uint256 slippage) external {
        if (slippage < MAX_SLIPPAGE || slippage >= PERCENT_DIVISOR) {
            revert InvalidAmount();
        }
        userSlippage[msg.sender] = slippage;
    }

    /**
     * @notice Toggle a users autocompound status
     */
    function toggleAutocompound() external {
        autocompoundEnabled[msg.sender] = !autocompoundEnabled[msg.sender];
    }

    /**
     * @notice Set relock status
     * @param status true if auto relock is enabled.
     */
    function setRelock(bool status) external virtual {
        autoRelockDisabled[msg.sender] = !status;
    }

    /**
     * @notice Sets the lookback period
     * @param lookback in seconds
     */
    function setLookback(uint256 lookback) external onlyOwner {
        if (lookback == uint256(0)) revert AmountZero();
        if (lookback > rewardsDuration) revert InvalidLookback();

        rewardsLookback = lookback;
    }

    /**
     * @notice Set operation expenses account
     * @param _operationExpenseReceiver Address to receive operation expenses
     * @param _operationExpenseRatio Proportion of operation expense
     */
    function setOperationExpenses(
        address _operationExpenseReceiver,
        uint256 _operationExpenseRatio
    ) external onlyOwner {
        if (_operationExpenseRatio > RATIO_DIVISOR) revert InvalidRatio();
        if (_operationExpenseReceiver == address(0)) revert AddressZero();
        operationExpenseReceiver = _operationExpenseReceiver;
        operationExpenseRatio = _operationExpenseRatio;
        emit OperationExpensesUpdated(_operationExpenseReceiver, _operationExpenseRatio);
    }

    /********************** External functions ***********************/

    /**
     * @notice Stake tokens to receive rewards.
     * @dev Locked tokens cannot be withdrawn for defaultLockDuration and are eligible to receive rewards.
     * @param amount to stake.
     * @param onBehalfOf address for staking.
     * @param typeIndex lock type index.
     */
    function stake(uint256 amount, address onBehalfOf, uint256 typeIndex) external {
        _stake(amount, onBehalfOf, typeIndex, false);
    }

    /**
     * @notice Add to earnings
     * @dev Minted tokens receive rewards normally but incur a 50% penalty when
     *  withdrawn before vestDuration has passed.
     * @param user vesting owner.
     * @param amount to vest.
     * @param withPenalty does this bear penalty?
     */
    function vestTokens(address user, uint256 amount, bool withPenalty) external whenNotPaused {
        if (!minters[msg.sender]) revert InsufficientPermission();
        if (amount == 0) return;

        if (user == address(this)) {
            // minting to this contract adds the new tokens as incentives for lockers
            _notifyReward(address(rdntToken), amount);
            return;
        }

        Balances storage bal = _balances[user];
        bal.total = bal.total + amount;
        if (withPenalty) {
            bal.earned = bal.earned + amount;
            LockedBalance[] storage earnings = _userEarnings[user];

            uint256 currentDay = block.timestamp / 1 days;
            uint256 lastIndex = earnings.length > 0 ? earnings.length - 1 : 0;
            uint256 vestingDurationDays = vestDuration / 1 days;

            // We check if an entry for the current day already exists. If yes, add new amount to that entry
            if (earnings.length > 0 && (earnings[lastIndex].unlockTime / 1 days) == currentDay + vestingDurationDays) {
                earnings[lastIndex].amount = earnings[lastIndex].amount + amount;
            } else {
                // If there is no entry for the current day, create a new one
                uint256 unlockTime = block.timestamp + vestDuration;
                earnings.push(
                    LockedBalance({amount: amount, unlockTime: unlockTime, multiplier: 1, duration: vestDuration})
                );
            }
        } else {
            bal.unlocked = bal.unlocked + amount;
        }
    }

    /**
     * @notice Withdraw tokens from earnings and unlocked.
     * @dev First withdraws unlocked tokens, then earned tokens. Withdrawing earned tokens
     *  incurs a 50% penalty which is distributed based on locked balances.
     * @param amount for withdraw
     */
    function withdraw(uint256 amount) external {
        address _address = msg.sender;
        if (amount == 0) revert AmountZero();

        uint256 penaltyAmount;
        uint256 burnAmount;
        Balances storage bal = _balances[_address];

        if (amount <= bal.unlocked) {
            bal.unlocked = bal.unlocked - amount;
        } else {
            uint256 remaining = amount - bal.unlocked;
            if (bal.earned < remaining) revert InvalidEarned();
            bal.unlocked = 0;
            uint256 sumEarned = bal.earned;
            uint256 i;
            for (i = 0; ; ) {
                uint256 earnedAmount = _userEarnings[_address][i].amount;
                if (earnedAmount == 0) continue;
                (
                    uint256 withdrawAmount,
                    uint256 penaltyFactor,
                    uint256 newPenaltyAmount,
                    uint256 newBurnAmount
                ) = _penaltyInfo(_userEarnings[_address][i]);

                uint256 requiredAmount = earnedAmount;
                if (remaining >= withdrawAmount) {
                    remaining = remaining - withdrawAmount;
                    if (remaining == 0) i++;
                } else {
                    requiredAmount = (remaining * WHOLE) / (WHOLE - penaltyFactor);
                    _userEarnings[_address][i].amount = earnedAmount - requiredAmount;
                    remaining = 0;

                    newPenaltyAmount = (requiredAmount * penaltyFactor) / WHOLE;
                    newBurnAmount = (newPenaltyAmount * burn) / WHOLE;
                }
                sumEarned = sumEarned - requiredAmount;

                penaltyAmount = penaltyAmount + newPenaltyAmount;
                burnAmount = burnAmount + newBurnAmount;

                if (remaining == 0) {
                    break;
                } else {
                    if (sumEarned == 0) revert InvalidEarned();
                }
                unchecked {
                    i++;
                }
            }
            if (i > 0) {
                uint256 length = _userEarnings[_address].length;
                for (uint256 j = i; j < length; ) {
                    _userEarnings[_address][j - i] = _userEarnings[_address][j];
                    unchecked {
                        j++;
                    }
                }
                for (uint256 j = 0; j < i; ) {
                    _userEarnings[_address].pop();
                    unchecked {
                        j++;
                    }
                }
            }
            bal.earned = sumEarned;
        }

        // Update values
        bal.total = bal.total - amount - penaltyAmount;

        _withdrawTokens(_address, amount, penaltyAmount, burnAmount, false);
    }

    /**
     * @notice Withdraw individual unlocked balance and earnings, optionally claim pending rewards.
     * @param claimRewards true to claim rewards when exit
     * @param unlockTime of earning
     */
    function individualEarlyExit(bool claimRewards, uint256 unlockTime) external {
        address onBehalfOf = msg.sender;
        if (unlockTime <= block.timestamp) revert InvalidTime();
        (uint256 amount, uint256 penaltyAmount, uint256 burnAmount, uint256 index) = _ieeWithdrawableBalance(
            onBehalfOf,
            unlockTime
        );

        uint256 length = _userEarnings[onBehalfOf].length;
        for (uint256 i = index + 1; i < length; ) {
            _userEarnings[onBehalfOf][i - 1] = _userEarnings[onBehalfOf][i];
            unchecked {
                i++;
            }
        }
        _userEarnings[onBehalfOf].pop();

        Balances storage bal = _balances[onBehalfOf];
        bal.total = bal.total - amount - penaltyAmount;
        bal.earned = bal.earned - amount - penaltyAmount;

        _withdrawTokens(onBehalfOf, amount, penaltyAmount, burnAmount, claimRewards);
    }

    /**
     * @notice Withdraw full unlocked balance and earnings, optionally claim pending rewards.
     * @param claimRewards true to claim rewards when exit
     */
    function exit(bool claimRewards) external {
        address onBehalfOf = msg.sender;
        (uint256 amount, uint256 penaltyAmount, uint256 burnAmount) = withdrawableBalance(onBehalfOf);

        delete _userEarnings[onBehalfOf];

        Balances storage bal = _balances[onBehalfOf];
        bal.total = bal.total - bal.unlocked - bal.earned;
        bal.unlocked = 0;
        bal.earned = 0;

        _withdrawTokens(onBehalfOf, amount, penaltyAmount, burnAmount, claimRewards);
    }

    /**
     * @notice Claim all pending staking rewards.
     */
    function getAllRewards() external {
        return getReward(rewardTokens);
    }

    /**
     * @notice Withdraw expired locks with options
     * @param address_ for withdraw
     * @param limit_ of lock length for withdraw
     * @param isRelockAction_ option to relock
     * @return withdraw amount
     */
    function withdrawExpiredLocksForWithOptions(
        address address_,
        uint256 limit_,
        bool isRelockAction_
    ) external returns (uint256) {
        if (limit_ == 0) limit_ = _userLocks[address_].length;

        return _withdrawExpiredLocksFor(address_, isRelockAction_, true, limit_);
    }

    /**
     * @notice Zap vesting RDNT tokens to LP
     * @param user address
     * @return zapped amount
     */
    function zapVestingToLp(address user) external returns (uint256 zapped) {
        if (msg.sender != _lockZap) revert InsufficientPermission();

        _updateReward(user);

        uint256 currentTimestamp = block.timestamp;
        LockedBalance[] storage earnings = _userEarnings[user];
        for (uint256 i = earnings.length; i > 0; ) {
            if (earnings[i - 1].unlockTime > currentTimestamp) {
                zapped = zapped + earnings[i - 1].amount;
                earnings.pop();
            } else {
                break;
            }
            unchecked {
                i--;
            }
        }

        rdntToken.safeTransfer(_lockZap, zapped);

        Balances storage bal = _balances[user];
        bal.earned = bal.earned - zapped;
        bal.total = bal.total - zapped;

        IPriceProvider(_priceProvider).update();

        return zapped;
    }

    /**
     * @notice Claim rewards by converter.
     * @dev Rewards are transfered to converter. In the Radiant Capital protocol
     * 		the role of the Converter is taken over by Compounder.sol.
     * @param onBehalf address to claim.
     */
    function claimFromConverter(address onBehalf) external whenNotPaused {
        if (msg.sender != rewardConverter) revert InsufficientPermission();
        _updateReward(onBehalf);
        uint256 length = rewardTokens.length;
        for (uint256 i; i < length; ) {
            address token = rewardTokens[i];
            if (token != address(rdntToken)) {
                _notifyUnseenReward(token);
                uint256 reward = rewards[onBehalf][token] / 1e12;
                if (reward > 0) {
                    rewards[onBehalf][token] = 0;
                    rewardData[token].balance = rewardData[token].balance - reward;

                    IERC20(token).safeTransfer(rewardConverter, reward);
                    emit RewardPaid(onBehalf, token, reward);
                }
            }
            unchecked {
                i++;
            }
        }
        IPriceProvider(_priceProvider).update();
        lastClaimTime[onBehalf] = block.timestamp;
    }

    /**
     * @notice Withdraw and restake assets.
     */
    function relock() external virtual {
        uint256 amount = _withdrawExpiredLocksFor(msg.sender, true, true, _userLocks[msg.sender].length);
        emit Relocked(msg.sender, amount, defaultLockIndex[msg.sender]);
    }

    /**
     * @notice Requalify user
     */
    function requalify() external {
        requalifyFor(msg.sender);
    }

    /**
     * @notice Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders.
     * @param tokenAddress to recover.
     * @param tokenAmount to recover.
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        _recoverERC20(tokenAddress, tokenAmount);
    }

    /********************** External View functions ***********************/

    /**
     * @notice Return lock duration.
     */
    function getLockDurations() external view returns (uint256[] memory) {
        return _lockPeriod;
    }

    /**
     * @notice Return reward multipliers.
     */
    function getLockMultipliers() external view returns (uint256[] memory) {
        return _rewardMultipliers;
    }

    /**
     * @notice Returns all locks of a user.
     * @param user address.
     * @return lockInfo of the user.
     */
    function lockInfo(address user) external view returns (LockedBalance[] memory) {
        return _userLocks[user];
    }

    /**
     * @notice Total balance of an account, including unlocked, locked and earned tokens.
     * @param user address.
     */
    function totalBalance(address user) external view returns (uint256) {
        if (stakingToken == address(rdntToken)) {
            return _balances[user].total;
        }
        return _balances[user].locked;
    }

    /**
     * @notice Returns price provider address
     */
    function getPriceProvider() external view returns (address) {
        return _priceProvider;
    }

    /**
     * @notice Reward amount of the duration.
     * @param rewardToken for the reward
     * @return reward amount for duration
     */
    function getRewardForDuration(address rewardToken) external view returns (uint256) {
        return (rewardData[rewardToken].rewardPerSecond * rewardsDuration) / 1e12;
    }

    /**
     * @notice Total balance of an account, including unlocked, locked and earned tokens.
     * @param user address of the user for which the balances are fetched
     */
    function getBalances(address user) external view returns (Balances memory) {
        return _balances[user];
    }

    /********************** Public functions ***********************/

    /**
     * @notice Claims bounty.
     * @dev Remove expired locks
     * @param user address
     * @param execute true if this is actual execution
     * @return issueBaseBounty true if needs to issue base bounty
     */
    function claimBounty(address user, bool execute) public whenNotPaused returns (bool issueBaseBounty) {
        if (msg.sender != address(bountyManager)) revert InsufficientPermission();

        (, uint256 unlockable, , , ) = lockedBalances(user);
        if (unlockable == 0) {
            return (false);
        } else {
            issueBaseBounty = true;
        }

        if (!execute) {
            return (issueBaseBounty);
        }
        // Withdraw the user's expried locks
        _withdrawExpiredLocksFor(user, false, true, _userLocks[user].length);
    }

    /**
     * @notice Claim all pending staking rewards.
     * @param rewardTokens_ array of reward tokens
     */
    function getReward(address[] memory rewardTokens_) public {
        _updateReward(msg.sender);
        _getReward(msg.sender, rewardTokens_);
        IPriceProvider(_priceProvider).update();
    }

    /**
     * @notice Pause MFD functionalities
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice Resume MFD functionalities
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice Requalify user for reward elgibility
     * @param user address
     */
    function requalifyFor(address user) public {
        incentivesController.afterLockUpdate(user);
    }

    /**
     * @notice Information on a user's lockings
     * @return total balance of locks
     * @return unlockable balance
     * @return locked balance
     * @return lockedWithMultiplier
     * @return lockData which is an array of locks
     */
    function lockedBalances(
        address user
    )
        public
        view
        returns (
            uint256 total,
            uint256 unlockable,
            uint256 locked,
            uint256 lockedWithMultiplier,
            LockedBalance[] memory lockData
        )
    {
        LockedBalance[] storage locks = _userLocks[user];
        uint256 idx;
        uint256 length = locks.length;
        for (uint256 i; i < length; ) {
            if (locks[i].unlockTime > block.timestamp) {
                if (idx == 0) {
                    lockData = new LockedBalance[](locks.length - i);
                }
                lockData[idx] = locks[i];
                idx++;
                locked = locked + locks[i].amount;
                lockedWithMultiplier = lockedWithMultiplier + (locks[i].amount * locks[i].multiplier);
            } else {
                unlockable = unlockable + locks[i].amount;
            }
            unchecked {
                i++;
            }
        }
        total = _balances[user].locked;
    }

    /**
     * @notice Reward locked amount of the user.
     * @param user address
     * @return locked amount
     */
    function lockedBalance(address user) public view returns (uint256 locked) {
        LockedBalance[] storage locks = _userLocks[user];
        uint256 length = locks.length;
        uint256 currentTimestamp = block.timestamp;
        for (uint256 i; i < length; ) {
            if (locks[i].unlockTime > currentTimestamp) {
                locked = locked + locks[i].amount;
            }
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Earnings which are vesting, and earnings which have vested for full duration.
     * @dev Earned balances may be withdrawn immediately, but will incur a penalty between 25-90%, based on a linear schedule of elapsed time.
     * @return totalVesting sum of vesting tokens
     * @return unlocked earnings
     * @return earningsData which is an array of all infos
     */
    function earnedBalances(
        address user
    ) public view returns (uint256 totalVesting, uint256 unlocked, EarnedBalance[] memory earningsData) {
        unlocked = _balances[user].unlocked;
        LockedBalance[] storage earnings = _userEarnings[user];
        uint256 idx;
        uint256 length = earnings.length;
        uint256 currentTimestamp = block.timestamp;
        for (uint256 i; i < length; ) {
            if (earnings[i].unlockTime > currentTimestamp) {
                if (idx == 0) {
                    earningsData = new EarnedBalance[](earnings.length - i);
                }
                (, uint256 penaltyAmount, , ) = _ieeWithdrawableBalance(user, earnings[i].unlockTime);
                earningsData[idx].amount = earnings[i].amount;
                earningsData[idx].unlockTime = earnings[i].unlockTime;
                earningsData[idx].penalty = penaltyAmount;
                idx++;
                totalVesting = totalVesting + earnings[i].amount;
            } else {
                unlocked = unlocked + earnings[i].amount;
            }
            unchecked {
                i++;
            }
        }
        return (totalVesting, unlocked, earningsData);
    }

    /**
     * @notice Final balance received and penalty balance paid by user upon calling exit.
     * @dev This is earnings, not locks.
     * @param user address.
     * @return amount total withdrawable amount.
     * @return penaltyAmount penalty amount.
     * @return burnAmount amount to burn.
     */
    function withdrawableBalance(
        address user
    ) public view returns (uint256 amount, uint256 penaltyAmount, uint256 burnAmount) {
        uint256 earned = _balances[user].earned;
        if (earned > 0) {
            uint256 length = _userEarnings[user].length;
            for (uint256 i; i < length; ) {
                uint256 earnedAmount = _userEarnings[user][i].amount;
                if (earnedAmount == 0) continue;
                (, , uint256 newPenaltyAmount, uint256 newBurnAmount) = _penaltyInfo(_userEarnings[user][i]);
                penaltyAmount = penaltyAmount + newPenaltyAmount;
                burnAmount = burnAmount + newBurnAmount;
                unchecked {
                    i++;
                }
            }
        }
        amount = _balances[user].unlocked + earned - penaltyAmount;
        return (amount, penaltyAmount, burnAmount);
    }

    /**
     * @notice Returns reward applicable timestamp.
     * @param rewardToken for the reward
     * @return end time of reward period
     */
    function lastTimeRewardApplicable(address rewardToken) public view returns (uint256) {
        uint256 periodFinish = rewardData[rewardToken].periodFinish;
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /**
     * @notice Reward amount per token
     * @dev Reward is distributed only for locks.
     * @param rewardToken for reward
     * @return rptStored current RPT with accumulated rewards
     */
    function rewardPerToken(address rewardToken) public view returns (uint256 rptStored) {
        rptStored = rewardData[rewardToken].rewardPerTokenStored;
        if (lockedSupplyWithMultiplier > 0) {
            uint256 newReward = (lastTimeRewardApplicable(rewardToken) - rewardData[rewardToken].lastUpdateTime) *
                rewardData[rewardToken].rewardPerSecond;
            rptStored = rptStored + ((newReward * 1e18) / lockedSupplyWithMultiplier);
        }
    }

    /**
     * @notice Address and claimable amount of all reward tokens for the given account.
     * @param account for rewards
     * @return rewardsData array of rewards
     */
    function claimableRewards(address account) public view returns (IFeeDistribution.RewardData[] memory rewardsData) {
        rewardsData = new IFeeDistribution.RewardData[](rewardTokens.length);

        uint256 length = rewardTokens.length;
        for (uint256 i; i < length; ) {
            rewardsData[i].token = rewardTokens[i];
            rewardsData[i].amount =
                _earned(
                    account,
                    rewardsData[i].token,
                    _balances[account].lockedWithMultiplier,
                    rewardPerToken(rewardsData[i].token)
                ) /
                1e12;
            unchecked {
                i++;
            }
        }
        return rewardsData;
    }

    /********************** Internal functions ***********************/

    /**
     * @notice Stake tokens to receive rewards.
     * @dev Locked tokens cannot be withdrawn for defaultLockDuration and are eligible to receive rewards.
     * @param amount to stake.
     * @param onBehalfOf address for staking.
     * @param typeIndex lock type index.
     * @param isRelock true if this is with relock enabled.
     */
    function _stake(uint256 amount, address onBehalfOf, uint256 typeIndex, bool isRelock) internal whenNotPaused {
        if (amount == 0) return;
        if (bountyManager != address(0)) {
            if (amount < IBountyManager(bountyManager).minDLPBalance()) revert InvalidAmount();
        }
        if (typeIndex >= _lockPeriod.length) revert InvalidType();

        _updateReward(onBehalfOf);

        LockedBalance[] memory userLocks = _userLocks[onBehalfOf];
        uint256 userLocksLength = userLocks.length;

        Balances storage bal = _balances[onBehalfOf];
        bal.total = bal.total + amount;

        bal.locked = bal.locked + amount;
        lockedSupply = lockedSupply + amount;

        uint256 rewardMultiplier = _rewardMultipliers[typeIndex];
        bal.lockedWithMultiplier = bal.lockedWithMultiplier + (amount * rewardMultiplier);
        lockedSupplyWithMultiplier = lockedSupplyWithMultiplier + (amount * rewardMultiplier);

        uint256 lockDurationWeeks = _lockPeriod[typeIndex] / AGGREGATION_EPOCH;
        uint256 unlockTime = block.timestamp + (lockDurationWeeks * AGGREGATION_EPOCH);
        uint256 lockIndex = _binarySearch(userLocks, userLocksLength, unlockTime);
        if (userLocksLength > 0) {
            uint256 indexToAggregate = lockIndex == 0 ? 0 : lockIndex - 1;
            if (
                (indexToAggregate < userLocksLength) &&
                (userLocks[indexToAggregate].unlockTime / AGGREGATION_EPOCH == unlockTime / AGGREGATION_EPOCH) &&
                (userLocks[indexToAggregate].multiplier == rewardMultiplier)
            ) {
                _userLocks[onBehalfOf][indexToAggregate].amount = userLocks[indexToAggregate].amount + amount;
            } else {
                _insertLock(
                    onBehalfOf,
                    LockedBalance({
                        amount: amount,
                        unlockTime: unlockTime,
                        multiplier: rewardMultiplier,
                        duration: _lockPeriod[typeIndex]
                    }),
                    lockIndex,
                    userLocksLength
                );
                emit LockerAdded(onBehalfOf);
            }
        } else {
            _insertLock(
                onBehalfOf,
                LockedBalance({
                    amount: amount,
                    unlockTime: unlockTime,
                    multiplier: rewardMultiplier,
                    duration: _lockPeriod[typeIndex]
                }),
                lockIndex,
                userLocksLength
            );
            emit LockerAdded(onBehalfOf);
        }

        if (!isRelock) {
            IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), amount);
        }

        incentivesController.afterLockUpdate(onBehalfOf);
        emit Locked(
            onBehalfOf,
            amount,
            _balances[onBehalfOf].locked,
            _lockPeriod[typeIndex],
            stakingToken != address(rdntToken)
        );
    }

    /**
     * @notice Update user reward info.
     * @param account address
     */
    function _updateReward(address account) internal {
        uint256 balance = _balances[account].lockedWithMultiplier;
        uint256 length = rewardTokens.length;
        for (uint256 i = 0; i < length; ) {
            address token = rewardTokens[i];
            uint256 rpt = rewardPerToken(token);

            Reward storage r = rewardData[token];
            r.rewardPerTokenStored = rpt;
            r.lastUpdateTime = lastTimeRewardApplicable(token);

            if (account != address(this)) {
                rewards[account][token] = _earned(account, token, balance, rpt);
                userRewardPerTokenPaid[account][token] = rpt;
            }
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Add new reward.
     * @dev If prev reward period is not done, then it resets `rewardPerSecond` and restarts period
     * @param rewardToken address
     * @param reward amount
     */
    function _notifyReward(address rewardToken, uint256 reward) internal {
        address operationExpenseReceiver_ = operationExpenseReceiver;
        uint256 operationExpenseRatio_ = operationExpenseRatio;
        if (operationExpenseReceiver_ != address(0) && operationExpenseRatio_ != 0) {
            uint256 opExAmount = (reward * operationExpenseRatio_) / RATIO_DIVISOR;
            if (opExAmount != 0) {
                IERC20(rewardToken).safeTransfer(operationExpenseReceiver_, opExAmount);
                reward = reward - opExAmount;
            }
        }

        Reward storage r = rewardData[rewardToken];
        if (block.timestamp >= r.periodFinish) {
            r.rewardPerSecond = (reward * 1e12) / rewardsDuration;
        } else {
            uint256 remaining = r.periodFinish - block.timestamp;
            uint256 leftover = (remaining * r.rewardPerSecond) / 1e12;
            r.rewardPerSecond = ((reward + leftover) * 1e12) / rewardsDuration;
        }

        r.lastUpdateTime = block.timestamp;
        r.periodFinish = block.timestamp + rewardsDuration;
        r.balance = r.balance + reward;

        emit RevenueEarned(rewardToken, reward);

        uint256 lpUsdValue = IPriceProvider(_priceProvider).getRewardTokenPrice(rewardToken, reward);
        emit NewTransferAdded(rewardToken, lpUsdValue);
    }

    /**
     * @notice Notify unseen rewards.
     * @dev for rewards other than RDNT token, every 24 hours we check if new
     *  rewards were sent to the contract or accrued via aToken interest.
     * @param token address
     */
    function _notifyUnseenReward(address token) internal {
        if (token == address(0)) revert AddressZero();
        if (token == address(rdntToken)) {
            return;
        }
        Reward storage r = rewardData[token];
        uint256 periodFinish = r.periodFinish;
        if (periodFinish == 0) revert InvalidPeriod();
        if (periodFinish < block.timestamp + rewardsDuration - rewardsLookback) {
            uint256 unseen = IERC20(token).balanceOf(address(this)) - r.balance;
            if (unseen > 0) {
                _notifyReward(token, unseen);
            }
        }
    }

    /**
     * @notice User gets reward
     * @param user address
     * @param rewardTokens_ array of reward tokens
     */
    function _getReward(address user, address[] memory rewardTokens_) internal whenNotPaused {
        uint256 length = rewardTokens_.length;
        IChefIncentivesController chefIncentivesController = incentivesController;
        chefIncentivesController.setEligibilityExempt(user, true);
        for (uint256 i; i < length; ) {
            address token = rewardTokens_[i];
            _notifyUnseenReward(token);
            uint256 reward = rewards[user][token] / 1e12;
            if (reward > 0) {
                rewards[user][token] = 0;
                rewardData[token].balance = rewardData[token].balance - reward;

                IERC20(token).safeTransfer(user, reward);
                emit RewardPaid(user, token, reward);
            }
            unchecked {
                i++;
            }
        }
        chefIncentivesController.setEligibilityExempt(user, false);
        chefIncentivesController.afterLockUpdate(user);
    }

    /**
     * @notice Withdraw tokens from MFD
     * @param onBehalfOf address to withdraw
     * @param amount of withdraw
     * @param penaltyAmount penalty applied amount
     * @param burnAmount amount to burn
     * @param claimRewards option to claim rewards
     */
    function _withdrawTokens(
        address onBehalfOf,
        uint256 amount,
        uint256 penaltyAmount,
        uint256 burnAmount,
        bool claimRewards
    ) internal {
        if (onBehalfOf != msg.sender) revert InsufficientPermission();
        _updateReward(onBehalfOf);

        rdntToken.safeTransfer(onBehalfOf, amount);
        if (penaltyAmount > 0) {
            if (burnAmount > 0) {
                rdntToken.safeTransfer(starfleetTreasury, burnAmount);
            }
            rdntToken.safeTransfer(daoTreasury, penaltyAmount - burnAmount);
        }

        if (claimRewards) {
            _getReward(onBehalfOf, rewardTokens);
            lastClaimTime[onBehalfOf] = block.timestamp;
        }

        IPriceProvider(_priceProvider).update();

        emit Withdrawn(onBehalfOf, amount, _balances[onBehalfOf].locked, penaltyAmount, burnAmount, false);
    }

    /**
     * @notice Withdraw all lockings tokens where the unlock time has passed
     * @param user address
     * @param limit limit for looping operation
     * @return lockAmount withdrawable lock amount
     * @return lockAmountWithMultiplier withdraw amount with multiplier
     */
    function _cleanWithdrawableLocks(
        address user,
        uint256 limit
    ) internal returns (uint256 lockAmount, uint256 lockAmountWithMultiplier) {
        LockedBalance[] storage locks = _userLocks[user];

        if (locks.length != 0) {
            uint256 length = locks.length <= limit ? locks.length : limit;
            uint256 i;
            while (i < length && locks[i].unlockTime <= block.timestamp) {
                lockAmount = lockAmount + locks[i].amount;
                lockAmountWithMultiplier = lockAmountWithMultiplier + (locks[i].amount * locks[i].multiplier);
                i = i + 1;
            }
            uint256 locksLength = locks.length;
            for (uint256 j = i; j < locksLength; ) {
                locks[j - i] = locks[j];
                unchecked {
                    j++;
                }
            }
            for (uint256 j = 0; j < i; ) {
                locks.pop();
                unchecked {
                    j++;
                }
            }
            if (locks.length == 0) {
                emit LockerRemoved(user);
            }
        }
    }

    /**
     * @notice Withdraw all currently locked tokens where the unlock time has passed.
     * @param address_ of the user.
     * @param isRelockAction true if withdraw with relock
     * @param doTransfer true to transfer tokens to user
     * @param limit limit for looping operation
     * @return amount for withdraw
     */
    function _withdrawExpiredLocksFor(
        address address_,
        bool isRelockAction,
        bool doTransfer,
        uint256 limit
    ) internal whenNotPaused returns (uint256 amount) {
        if (isRelockAction && address_ != msg.sender && _lockZap != msg.sender) revert InsufficientPermission();
        _updateReward(address_);

        uint256 amountWithMultiplier;
        Balances storage bal = _balances[address_];
        (amount, amountWithMultiplier) = _cleanWithdrawableLocks(address_, limit);
        bal.locked = bal.locked - amount;
        bal.lockedWithMultiplier = bal.lockedWithMultiplier - amountWithMultiplier;
        bal.total = bal.total - amount;
        lockedSupply = lockedSupply - amount;
        lockedSupplyWithMultiplier = lockedSupplyWithMultiplier - amountWithMultiplier;

        if (isRelockAction || (address_ != msg.sender && !autoRelockDisabled[address_])) {
            _stake(amount, address_, defaultLockIndex[address_], true);
        } else {
            if (doTransfer) {
                IERC20(stakingToken).safeTransfer(address_, amount);
                incentivesController.afterLockUpdate(address_);
                emit Withdrawn(address_, amount, _balances[address_].locked, 0, 0, stakingToken != address(rdntToken));
            } else {
                revert InvalidAction();
            }
        }
        return amount;
    }

    /********************** Internal View functions ***********************/

    /**
     * @notice Returns withdrawable balance at exact unlock time
     * @param user address for withdraw
     * @param unlockTime exact unlock time
     * @return amount total withdrawable amount
     * @return penaltyAmount penalty amount
     * @return burnAmount amount to burn
     * @return index of earning
     */
    function _ieeWithdrawableBalance(
        address user,
        uint256 unlockTime
    ) internal view returns (uint256 amount, uint256 penaltyAmount, uint256 burnAmount, uint256 index) {
        uint256 length = _userEarnings[user].length;
        for (index; index < length; ) {
            if (_userEarnings[user][index].unlockTime == unlockTime) {
                (amount, , penaltyAmount, burnAmount) = _penaltyInfo(_userEarnings[user][index]);
                return (amount, penaltyAmount, burnAmount, index);
            }
            unchecked {
                index++;
            }
        }
        revert UnlockTimeNotFound();
    }

    /**
     * @notice Add new lockings
     * @dev We keep the array to be sorted by unlock time.
     * @param user address to insert lock for.
     * @param newLock new lock info.
     * @param index of where to store the new lock.
     * @param lockLength length of the lock array.
     */
    function _insertLock(address user, LockedBalance memory newLock, uint256 index, uint256 lockLength) internal {
        LockedBalance[] storage locks = _userLocks[user];
        locks.push();
        for (uint256 j = lockLength; j > index; ) {
            locks[j] = locks[j - 1];
            unchecked {
                j--;
            }
        }
        locks[index] = newLock;
    }

    /**
     * @notice Calculate earnings.
     * @param user address of earning owner
     * @param rewardToken address
     * @param balance of the user
     * @param currentRewardPerToken current RPT
     * @return earnings amount
     */
    function _earned(
        address user,
        address rewardToken,
        uint256 balance,
        uint256 currentRewardPerToken
    ) internal view returns (uint256 earnings) {
        earnings = rewards[user][rewardToken];
        uint256 realRPT = currentRewardPerToken - userRewardPerTokenPaid[user][rewardToken];
        earnings = earnings + ((balance * realRPT) / 1e18);
    }

    /**
     * @notice Penalty information of individual earning
     * @param earning earning info.
     * @return amount of available earning.
     * @return penaltyFactor penalty rate.
     * @return penaltyAmount amount of penalty.
     * @return burnAmount amount to burn.
     */
    function _penaltyInfo(
        LockedBalance memory earning
    ) internal view returns (uint256 amount, uint256 penaltyFactor, uint256 penaltyAmount, uint256 burnAmount) {
        if (earning.unlockTime > block.timestamp) {
            // 90% on day 1, decays to 25% on day 90
            penaltyFactor = ((earning.unlockTime - block.timestamp) * HALF) / vestDuration + QUART; // 25% + timeLeft/vestDuration * 65%
            penaltyAmount = (earning.amount * penaltyFactor) / WHOLE;
            burnAmount = (penaltyAmount * burn) / WHOLE;
        }
        amount = earning.amount - penaltyAmount;
    }

    /********************** Private functions ***********************/

    function _binarySearch(
        LockedBalance[] memory locks,
        uint256 length,
        uint256 unlockTime
    ) private pure returns (uint256) {
        uint256 low = 0;
        uint256 high = length;
        while (low < high) {
            uint256 mid = (low + high) / 2;
            if (locks[mid].unlockTime < unlockTime) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return low;
    }
}
