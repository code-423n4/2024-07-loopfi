// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFlashlender, IERC3156FlashBorrower, ICreditFlashBorrower} from "./interfaces/IFlashlender.sol";
import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";
import {wmul} from "./utils/Math.sol";

/// @title Flashlender
/// @notice `Flashlender` enables flashlender minting / borrowing of Stablecoin and internal Credit
/// Uses DssFlash.sol from DSS (MakerDAO) as a blueprint
contract Flashlender is IFlashlender, ReentrancyGuard {
    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    // ERC3156 Callbacks
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    bytes32 public constant CALLBACK_SUCCESS_CREDIT = keccak256("CreditFlashBorrower.onCreditFlashLoan");


    /// @notice The Pool contract
    IPoolV3 public immutable pool;
    /// @notice The flash loan fee, where WAD is 100%
    uint256 public immutable protocolFee;
    IERC20 public immutable underlyingToken;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event FlashLoan(address indexed receiver, address token, uint256 amount, uint256 fee);
    event CreditFlashLoan(address indexed receiver, uint256 amount, uint256 fee);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Flash__flashFee_unsupportedToken();
    error Flash__flashLoan_unsupportedToken();
    error Flash__flashLoan_callbackFailed();
    error Flash__creditFlashLoan_callbackFailed();
    error Flash__creditFlashLoan_unsupportedToken();

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(IPoolV3 pool_, uint256 protocolFee_) {
        pool = pool_;
        underlyingToken = IERC20(pool.underlyingToken());
        protocolFee = protocolFee_;
    }

    /*//////////////////////////////////////////////////////////////
                               FLASHLOAN
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the maximum borrowable amount for `token`
    /// @dev If `token` is not Stablecoin then 0 is returned
    /// @param token Address of the token to borrow (has to be the address of Stablecoin)
    /// @return max maximum borrowable amount [wad]
    function maxFlashLoan(address token) external view override returns (uint256 max) {
        if (token == address(underlyingToken)) {
            max = pool.creditManagerBorrowable(address(this));
        }
    }

    /// @notice Returns the current borrow fee for borrowing `amount` of `token`
    /// @dev If `token` is not Stablecoin then this method will revert
    /// @param token Address of the token to borrow (has to be the address of Stablecoin)
    /// @param *amount Amount to borrow [wad]
    /// @return fee to borrow `amount` of `token`
    function flashFee(address token, uint256 amount) external view override returns (uint256) {
        if (token != address(underlyingToken)) revert Flash__flashFee_unsupportedToken();
        return wmul(amount, protocolFee);
    }

    /// @notice Flashlender lends `token` to `receiver`
    /// @dev Reverts if `Flashlender` gets reentered in the same transaction or if token is not Stablecoin
    /// @param receiver Address of the receiver of the flash loan
    /// @param token Address of the token to borrow (has to be the address of Stablecoin)
    /// @param amount Amount of `token` to borrow [wad]
    /// @param data Arbitrary data structure, intended to contain user-defined parameters
    /// @return true if flash loan
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override nonReentrant returns (bool) {
        if (token != address(underlyingToken)) revert Flash__flashLoan_unsupportedToken();
        uint256 fee = wmul(amount, protocolFee);
        uint256 total = amount + fee;

        pool.lendCreditAccount(amount, address(receiver));

        emit FlashLoan(address(receiver), token, amount, fee);

        if (receiver.onFlashLoan(msg.sender, token, amount, fee, data) != CALLBACK_SUCCESS)
            revert Flash__flashLoan_callbackFailed();

        // reverts if not enough Stablecoin have been send back
        underlyingToken.transferFrom(address(receiver), address(pool), total);
        pool.repayCreditAccount(total - fee, fee, 0);

        return true;
    }

    /// @notice Flashlender lends ICreditFlashBorrower Credit to `receiver`
    /// @dev Reverts if `Flashlender` gets reentered in the same transaction
    /// @param receiver Address of the receiver of the flash loan [ICreditFlashBorrower]
    /// @param amount Amount of `token` to borrow [wad]
    /// @param data Arbitrary data structure, intended to contain user-defined parameters
    /// @return true if flash loan
    function creditFlashLoan(
        ICreditFlashBorrower receiver,
        uint256 amount,
        bytes calldata data
    ) external override nonReentrant returns (bool) {
        uint256 fee = wmul(amount, protocolFee);
        uint256 total = amount + fee;

        pool.lendCreditAccount(amount, address(receiver));

        emit CreditFlashLoan(address(receiver), amount, fee);

        if (receiver.onCreditFlashLoan(msg.sender, amount, fee, data) != CALLBACK_SUCCESS_CREDIT)
            revert Flash__creditFlashLoan_callbackFailed();

        // reverts if not enough Stablecoin have been send back
        underlyingToken.transferFrom(address(receiver), address(pool), total);
        pool.repayCreditAccount(total - fee, fee, 0);

        return true;
    }
}
