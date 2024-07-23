pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "src/Silo.sol";

contract StakingLPEth is ERC4626, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    // Errors //
    /// @notice Error emitted when the shares amount to redeem is greater than the shares balance of the owner
    error ExcessiveRedeemAmount();
    /// @notice Error emitted when the shares amount to withdraw is greater than the shares balance of the owner
    error ExcessiveWithdrawAmount();
    /// @notice Error emitted when cooldown value is invalid
    error InvalidCooldown();
    /// @notice Error emitted when owner is not allowed to perform an operation
    error OperationNotAllowed();
    /// @notice Error emitted when a small non-zero share amount remains, which risks donations attack
    error MinSharesViolation();

    struct UserCooldown {
        uint104 cooldownEnd;
        uint256 underlyingAmount;
    }

    /// @notice Minimum non-zero shares amount to prevent donation attack
    uint256 private constant MIN_SHARES = 0.01 ether;

    Silo public immutable silo;

    mapping(address => UserCooldown) public cooldowns;

    uint24 public MAX_COOLDOWN_DURATION = 30 days;

    uint24 public cooldownDuration;

    // Events //
    /// @notice Event emitted when cooldown duration updates
    event CooldownDurationUpdated(uint24 previousDuration, uint24 newDuration);

    /// @notice ensure cooldownDuration is zero
    modifier ensureCooldownOff() {
        if (cooldownDuration != 0) revert OperationNotAllowed();
        _;
    }

    /// @notice ensure cooldownDuration is gt 0
    modifier ensureCooldownOn() {
        if (cooldownDuration == 0) revert OperationNotAllowed();
        _;
    }

    constructor(
        address _liquidityPool,
        string memory _name,
        string memory _symbol
    ) ERC4626(IERC20(_liquidityPool)) ERC20(_name, _symbol) {
        silo = new Silo(address(this), _liquidityPool);
        cooldownDuration = MAX_COOLDOWN_DURATION;
    }

    /**
     * @dev See {IERC4626-withdraw}.
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address _owner
    ) public virtual override ensureCooldownOff returns (uint256) {
        return super.withdraw(assets, receiver, _owner);
    }

    /**
     * @dev See {IERC4626-redeem}.
     */
    function redeem(
        uint256 shares,
        address receiver,
        address _owner
    ) public virtual override ensureCooldownOff returns (uint256) {
        return super.redeem(shares, receiver, _owner);
    }

    /// @notice Claim the staking amount after the cooldown has finished. The address can only retire the full amount of assets.
    /// @dev unstake can be called after cooldown have been set to 0, to let accounts to be able to claim remaining assets locked at Silo
    /// @param receiver Address to send the assets by the staker
    function unstake(address receiver) external {
        UserCooldown storage userCooldown = cooldowns[msg.sender];
        uint256 assets = userCooldown.underlyingAmount;

        if (block.timestamp >= userCooldown.cooldownEnd || cooldownDuration == 0) {
            userCooldown.cooldownEnd = 0;
            userCooldown.underlyingAmount = 0;

            silo.withdraw(receiver, assets);
        } else {
            revert InvalidCooldown();
        }
    }

    /// @notice redeem assets and starts a cooldown to claim the converted underlying asset
    /// @param assets assets to redeem
    function cooldownAssets(uint256 assets) external ensureCooldownOn returns (uint256 shares) {
        if (assets > maxWithdraw(msg.sender)) revert ExcessiveWithdrawAmount();

        shares = previewWithdraw(assets);

        cooldowns[msg.sender].cooldownEnd = uint104(block.timestamp) + cooldownDuration;
        cooldowns[msg.sender].underlyingAmount += uint152(assets);

        _withdraw(msg.sender, address(silo), msg.sender, assets, shares);
    }

    /// @notice redeem shares into assets and starts a cooldown to claim the converted underlying asset
    /// @param shares shares to redeem
    function cooldownShares(uint256 shares) external ensureCooldownOn returns (uint256 assets) {
        if (shares > maxRedeem(msg.sender)) revert ExcessiveRedeemAmount();

        assets = previewRedeem(shares);

        cooldowns[msg.sender].cooldownEnd = uint104(block.timestamp) + cooldownDuration;
        cooldowns[msg.sender].underlyingAmount += uint152(assets);

        _withdraw(msg.sender, address(silo), msg.sender, assets, shares);
    }

    /// @notice Set cooldown duration. If cooldown duration is set to zero, the StakingLpETH behavior changes to follow ERC4626 standard and disables cooldownShares and cooldownAssets methods. If cooldown duration is greater than zero, the ERC4626 withdrawal and redeem functions are disabled, breaking the ERC4626 standard, and enabling the cooldownShares and the cooldownAssets functions.
    /// @param duration Duration of the cooldown
    function setCooldownDuration(uint24 duration) external onlyOwner {
        if (duration > MAX_COOLDOWN_DURATION) {
            revert InvalidCooldown();
        }

        uint24 previousDuration = cooldownDuration;
        cooldownDuration = duration;
        emit CooldownDurationUpdated(previousDuration, cooldownDuration);
    }

    /// @notice ensures a small non-zero amount of shares does not remain, exposing to donation attack
    function _checkMinShares() internal view {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply > 0 && _totalSupply < MIN_SHARES) revert MinSharesViolation();
    }

    /**
     * @dev Deposit/mint common workflow.
     * @param caller sender of assets
     * @param receiver where to send shares
     * @param assets assets to deposit
     * @param shares shares to mint
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal override nonReentrant {
        super._deposit(caller, receiver, assets, shares);
        _checkMinShares();
    }

    /**
     * @dev Withdraw/redeem common workflow.
     * @param caller tx sender
     * @param receiver where to send assets
     * @param _owner where to burn shares from
     * @param assets asset amount to transfer out
     * @param shares shares to burn
     */
    function _withdraw(
        address caller,
        address receiver,
        address _owner,
        uint256 assets,
        uint256 shares
    ) internal override nonReentrant {
        super._withdraw(caller, receiver, _owner, assets, shares);
        _checkMinShares();
    }
}
