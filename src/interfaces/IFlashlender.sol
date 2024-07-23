// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC3156FlashBorrower {
    /// @dev Receive `amount` of `token` from the flash lender
    /// @param initiator The initiator of the loan
    /// @param token The loan currency
    /// @param amount The amount of tokens lent
    /// @param fee The additional amount of tokens to repay
    /// @param data Arbitrary data structure, intended to contain user-defined parameters
    /// @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IERC3156FlashLender {
    /// @dev The amount of currency available to be lent
    /// @param token The loan currency
    /// @return The amount of `token` that can be borrowed
    function maxFlashLoan(address token) external view returns (uint256);

    /// @dev The fee to be charged for a given loan
    /// @param token The loan currency
    /// @param amount The amount of tokens lent
    /// @return The amount of `token` to be charged for the loan, on top of the returned principal
    function flashFee(address token, uint256 amount) external view returns (uint256);

    /// @dev Initiate a flash loan
    /// @param receiver The receiver of the tokens in the loan, and the receiver of the callback
    /// @param token The loan currency
    /// @param amount The amount of tokens lent
    /// @param data Arbitrary data structure, intended to contain user-defined parameters
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

interface ICreditFlashBorrower {
    /// @dev Receives `amount` of internal Credit from the Credit flash lender
    /// @param initiator The initiator of the loan
    /// @param amount The amount of tokens lent [wad]
    /// @param fee The additional amount of tokens to repay [wad]
    /// @param data Arbitrary data structure, intended to contain user-defined parameters.
    /// @return The keccak256 hash of "ICreditFlashLoanReceiver.onCreditFlashLoan"
    function onCreditFlashLoan(
        address initiator,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface ICreditFlashLender {
    /// @notice Flashlender lends internal Credit to `receiver`
    /// @dev Reverts if `Flashlender` gets reentered in the same transaction
    /// @param receiver Address of the receiver of the flash loan [ICreditFlashBorrower]
    /// @param amount Amount of `token` to borrow [wad]
    /// @param data Arbitrary data structure, intended to contain user-defined parameters
    /// @return true if flash loan
    function creditFlashLoan(
        ICreditFlashBorrower receiver,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}
interface IFlashlender is IERC3156FlashLender, ICreditFlashLender {
    function pool() external view returns (IPoolV3);

    function underlyingToken() external view returns (IERC20);

    function CALLBACK_SUCCESS() external view returns (bytes32);

    function CALLBACK_SUCCESS_CREDIT() external view returns (bytes32);

    function maxFlashLoan(address token) external view override returns (uint256);

    function flashFee(address token, uint256 amount) external view override returns (uint256);

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
    function creditFlashLoan(
        ICreditFlashBorrower receiver,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

abstract contract FlashLoanReceiverBase is ICreditFlashBorrower, IERC3156FlashBorrower {
    IFlashlender public immutable flashlender;

    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    bytes32 public constant CALLBACK_SUCCESS_CREDIT = keccak256("CreditFlashBorrower.onCreditFlashLoan");

    constructor(address flashlender_) {
        flashlender = IFlashlender(flashlender_);
    }

    function approvePayback(uint256 amount) internal {
        // Lender takes back the Stablecoin as per ERC3156 spec
        flashlender.underlyingToken().approve(address(flashlender), amount);
    }
}
