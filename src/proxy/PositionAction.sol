// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";
import {IPermission} from "../interfaces/IPermission.sol";
import {ICDPVault} from "../interfaces/ICDPVault.sol";
import {toInt256, wmul, min} from "../utils/Math.sol";
import {TransferAction, PermitParams} from "./TransferAction.sol";
import {BaseAction} from "./BaseAction.sol";
import {SwapAction, SwapParams, SwapType} from "./SwapAction.sol";
import {PoolAction, PoolActionParams} from "./PoolAction.sol";
import {IVaultRegistry} from "../interfaces/IVaultRegistry.sol";

import {IFlashlender, IERC3156FlashBorrower, ICreditFlashBorrower} from "../interfaces/IFlashlender.sol";

/// @notice Struct containing parameters used for adding or removing a position's collateral
///         and optionally swapping an arbitrary token to the collateral token
struct CollateralParams {
    // token passed in or received by the caller
    address targetToken;
    // amount of collateral to add in CDPVault.tokenScale() or to remove in WAD
    uint256 amount;
    // address that will transfer the collateral or receive the collateral
    address collateralizer;
    // optional swap from `targetToken` to collateral, or collateral to `targetToken`
    SwapParams auxSwap;
}

/// @notice Struct containing parameters used for borrowing or repaying underlying token
///         and optionally swapping underlying token to an arbitrary token or vice versa
struct CreditParams {
    // amount of debt to increase by or the amount of normal debt to decrease by [wad]
    uint256 amount;
    // address that will transfer the debt to repay or receive the debt to borrow
    address creditor;
    // optional swap from underlying token to arbitrary token
    SwapParams auxSwap;
}

/// @notice General parameters relevant for both increasing and decreasing leverage
struct LeverParams {
    // position to lever
    address position;
    // the vault to lever
    address vault;
    // the vault's token
    address collateralToken;
    // the swap parameters to swap collateral to underlying token or vice versa
    SwapParams primarySwap;
    // optional swap parameters to swap an arbitrary token to the collateral token or vice versa
    SwapParams auxSwap;
    // optional action parameters
    PoolActionParams auxAction;
}

/// @title PositionAction
/// @notice Base contract for interacting with CDPVaults via a proxy
/// @dev This contract is designed to be called via a proxy contract and can be dangerous to call directly
///      This contract does not support fee-on-transfer tokens
abstract contract PositionAction is IERC3156FlashBorrower, ICreditFlashBorrower, TransferAction, BaseAction {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    bytes32 public constant CALLBACK_SUCCESS_CREDIT = keccak256("CreditFlashBorrower.onCreditFlashLoan");

    /// @notice The VaultRegistry contract
    IVaultRegistry public immutable vaultRegistry;

    /// @notice The flashloan contract
    IFlashlender public immutable flashlender;
    /// @notice The Pool contract
    IPoolV3 public immutable pool;
    /// @notice The Pool token
    IERC20 public immutable underlyingToken;
    /// @notice The address of this contract
    address public immutable self;
    /// @notice The SwapAction contract
    SwapAction public immutable swapAction;
    /// @notice The PoolAction contract
    PoolAction public immutable poolAction;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error PositionAction__constructor_InvalidParam();
    error PositionAction__deposit_InvalidAuxSwap();
    error PositionAction__borrow_InvalidAuxSwap();
    error PositionAction__repay_InvalidAuxSwap();
    error PositionAction__increaseLever_invalidPrimarySwap();
    error PositionAction__increaseLever_invalidAuxSwap();
    error PositionAction__decreaseLever_invalidPrimarySwap();
    error PositionAction__decreaseLever_invalidAuxSwap();
    error PositionAction__decreaseLever_invalidResidualRecipient();
    error PositionAction__onFlashLoan__invalidSender();
    error PositionAction__onFlashLoan__invalidInitiator();
    error PositionAction__onCreditFlashLoan__invalidSender();
    error PositionAction__onlyDelegatecall();
    error PositionAction__unregisteredVault();

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(address flashlender_, address swapAction_, address poolAction_, address vaultRegistry_) {
        if (flashlender_ == address(0) || swapAction_ == address(0) || poolAction_ == address(0) || vaultRegistry_ == address(0))
            revert PositionAction__constructor_InvalidParam();
        
        flashlender = IFlashlender(flashlender_);
        pool = flashlender.pool();
        vaultRegistry = IVaultRegistry(vaultRegistry_);
        underlyingToken = IERC20(pool.underlyingToken());
        self = address(this);
        swapAction = SwapAction(swapAction_);
        poolAction = PoolAction(poolAction_);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Reverts if not called via delegatecall, this is to prevent users from calling the contract directly
    modifier onlyDelegatecall() {
        if (address(this) == self) revert PositionAction__onlyDelegatecall();
        _;
    }

    modifier onlyRegisteredVault(address vault) {
        if (!vaultRegistry.isVaultRegistered(vault)) revert PositionAction__unregisteredVault();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                VIRTUAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Hook to deposit collateral into CDPVault, handles any CDP specific actions
    /// @param vault The CDP Vault
    /// @param position The CDP Vault position
    /// @param src Token passed in by the caller
    /// @param amount The amount of collateral to deposit [CDPVault.tokenScale()]
    /// @return Amount of collateral deposited [wad]
    function _onDeposit(address vault, address position, address src, uint256 amount) internal virtual returns (uint256);

    /// @notice Hook to withdraw collateral from CDPVault, handles any CDP specific actions
    /// @param vault The CDP Vault
    /// @param position The CDP Vault position
    /// @param dst Token the caller expects to receive
    /// @param amount The amount of collateral to deposit [wad]
    /// @return Amount of collateral (or dst) withdrawn [CDPVault.tokenScale()]
    function _onWithdraw(address vault, address position, address dst, uint256 amount) internal virtual returns (uint256);

    /// @notice Hook to increase lever by depositing collateral into the CDPVault, handles any CDP specific actions
    /// @param leverParams LeverParams struct
    /// @param upFrontToken the token passed up front
    /// @param upFrontAmount the amount of `upFrontToken` (or amount received from the aux swap)[CDPVault.tokenScale()]
    /// @param swapAmountOut the amount of tokens received from the underlying token flash loan swap [CDPVault.tokenScale()]
    /// @return Amount of collateral added to CDPVault [wad]
    function _onIncreaseLever(
        LeverParams memory leverParams,
        address upFrontToken,
        uint256 upFrontAmount,
        uint256 swapAmountOut
    ) internal virtual returns (uint256);

    /// @notice Hook to decrease lever by withdrawing collateral from the CDPVault, handles any CDP specific actions
    /// @param leverParams LeverParams struct
    /// @param subCollateral Amount of collateral to decrease by [wad]
    /// @return Amount of underlying token withdrawn from CDPVault [CDPVault.tokenScale()]
    function _onDecreaseLever(LeverParams memory leverParams, uint256 subCollateral) internal virtual returns (uint256);

    /*//////////////////////////////////////////////////////////////
                             ENTRY POINTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Adds collateral to a CDP Vault
    /// @param position The CDP Vault position
    /// @param vault The CDP Vault
    /// @param collateralParams The collateral parameters
    function deposit(
        address position,
        address vault,
        CollateralParams calldata collateralParams,
        PermitParams calldata permitParams
    ) external onlyRegisteredVault(vault) onlyDelegatecall {
        _deposit(vault, position, collateralParams, permitParams);
    }

    /// @notice Removes collateral from a CDP Vault
    /// @param position The CDP Vault position
    /// @param vault The CDP Vault
    /// @param collateralParams The collateral parameters
    function withdraw(
        address position,
        address vault,
        CollateralParams calldata collateralParams
    ) external onlyRegisteredVault(vault) onlyDelegatecall {
        _withdraw(vault, position, collateralParams);
    }

    /// @notice Adds debt to a CDP Vault by borrowing underlying token (and optionally swaps underlying token to an arbitrary token)
    /// @param position The CDP Vault position
    /// @param vault The CDP Vault
    /// @param creditParams The borrow parameters
    function borrow(address position, address vault, CreditParams calldata creditParams) external onlyRegisteredVault(vault) onlyDelegatecall {
        _borrow(vault, position, creditParams);
    }

    /// @notice Repays debt to a CDP Vault via underlying token (optionally swapping an arbitrary token to underlying token)
    /// @param position The CDP Vault position
    /// @param vault The CDP Vault
    /// @param creditParams The credit parameters
    /// @param permitParams The permit parameters
    function repay(
        address position,
        address vault,
        CreditParams calldata creditParams,
        PermitParams calldata permitParams
    ) external onlyRegisteredVault(vault) onlyDelegatecall {
        _repay(vault, position, creditParams, permitParams);
    }

    /// @notice Adds collateral and debt to a CDP Vault
    /// @param position The CDP Vault position
    /// @param vault The CDP Vault
    /// @param collateralParams The collateral parameters
    /// @param creditParams The credit parameters
    function depositAndBorrow(
        address position,
        address vault,
        CollateralParams calldata collateralParams,
        CreditParams calldata creditParams,
        PermitParams calldata permitParams
    ) external onlyRegisteredVault(vault) onlyDelegatecall {
        _deposit(vault, position, collateralParams, permitParams);
        _borrow(vault, position, creditParams);
    }

    /// @notice Removes collateral and debt from a CDP Vault
    /// @param position The CDP Vault position
    /// @param vault The CDP Vault
    /// @param collateralParams The collateral parameters
    /// @param creditParams The credit parameters
    /// @param permitParams The permit parameters
    function withdrawAndRepay(
        address position,
        address vault,
        CollateralParams calldata collateralParams,
        CreditParams calldata creditParams,
        PermitParams calldata permitParams
    ) external onlyRegisteredVault(vault) onlyDelegatecall {
        _repay(vault, position, creditParams, permitParams);
        _withdraw(vault, position, collateralParams);
    }

    /// @notice Allows for multiple calls to be made to cover use cases not covered by the other functions
    /// @param targets The addresses to call
    /// @param data The encoded data to call each address with
    /// @param delegateCall Whether or not to use delegatecall or call
    function multisend(
        address[] calldata targets,
        bytes[] calldata data,
        bool[] calldata delegateCall
    ) external onlyDelegatecall {
        uint256 totalTargets = targets.length;
        for (uint256 i; i < totalTargets; ) {
            if (delegateCall[i]) {
                _delegateCall(targets[i], data[i]);
            } else {
                (bool success, bytes memory response) = targets[i].call(data[i]);
                if (!success) _revertBytes(response);
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Increase the leverage of a position by taking out a flash loan and buying underlying token
    /// @param leverParams The parameters for the lever action,
    /// `primarySwap` - parameters to swap underlying token provided by the flash loan into the collateral token
    /// `auxSwap` - parameters to swap the `upFrontToken` to the collateral token
    /// @param upFrontToken The token to transfer up front to the LeverAction contract
    /// @param upFrontAmount The amount of `upFrontToken` to transfer to the LeverAction contract [upFrontToken-Scale]
    /// @param collateralizer The address to transfer `upFrontToken` from
    /// @param permitParams The permit parameters for the `collateralizer` to transfer `upFrontToken`
    function increaseLever(
        LeverParams calldata leverParams,
        address upFrontToken,
        uint256 upFrontAmount,
        address collateralizer,
        PermitParams calldata permitParams
    ) external onlyDelegatecall {
        // validate the primary swap
        if (
            leverParams.primarySwap.swapType != SwapType.EXACT_IN ||
            leverParams.primarySwap.assetIn != address(underlyingToken) ||
            leverParams.primarySwap.recipient != self
        ) revert PositionAction__increaseLever_invalidPrimarySwap();

        // validate aux swap if it exists
        if (
            leverParams.auxSwap.assetIn != address(0) &&
            (leverParams.auxSwap.swapType != SwapType.EXACT_IN ||
                leverParams.auxSwap.assetIn != upFrontToken ||
                leverParams.auxSwap.recipient != self)
        ) revert PositionAction__increaseLever_invalidAuxSwap();

        // transfer any up front amount to the LeverAction contract
        if (upFrontAmount > 0) {
            if (collateralizer == address(this)) {
                IERC20(upFrontToken).safeTransfer(self, upFrontAmount); // if tokens are on the proxy then just transfer
            } else {
                _transferFrom(upFrontToken, collateralizer, self, upFrontAmount, permitParams);
            }
        }

        // take out flash loan
        IPermission(leverParams.vault).modifyPermission(leverParams.position, self, true);
        flashlender.flashLoan(
            IERC3156FlashBorrower(self),
            address(underlyingToken),
            leverParams.primarySwap.amount,
            abi.encode(leverParams, upFrontToken, upFrontAmount)
        );
        IPermission(leverParams.vault).modifyPermission(leverParams.position, self, false);
    }

    /// @notice Decrease the leverage of a position by taking out a credit flash loan to withdraw and sell collateral
    /// @param leverParams The parameters for the lever action:
    /// `primarySwap` swap parameters to swap the collateral withdrawn from the CDPVault using the flash loan to
    /// underlying token `auxSwap` swap parameters to swap the collateral not used to payback the flash loan
    /// @param subCollateral The amount of collateral to withdraw from the position [wad]
    /// @param residualRecipient Optional parameter that must be provided if an `auxSwap` *is not* provided
    /// This parameter is the address to send the residual collateral to
    function decreaseLever(
        LeverParams calldata leverParams,
        uint256 subCollateral,
        address residualRecipient
    ) external onlyDelegatecall {
        // validate the primary swap
        if (leverParams.primarySwap.swapType != SwapType.EXACT_OUT || leverParams.primarySwap.recipient != self)
            revert PositionAction__decreaseLever_invalidPrimarySwap();

        // validate aux swap if it exists
        if (leverParams.auxSwap.assetIn != address(0) && (leverParams.auxSwap.swapType != SwapType.EXACT_IN))
            revert PositionAction__decreaseLever_invalidAuxSwap();

        /// validate residual recipient is provided if no aux swap is provided
        if (leverParams.auxSwap.assetIn == address(0) && residualRecipient == address(0))
            revert PositionAction__decreaseLever_invalidResidualRecipient();

        // take out credit flash loan
        IPermission(leverParams.vault).modifyPermission(leverParams.position, self, true);
        uint loanAmount = leverParams.primarySwap.amount;
        flashlender.creditFlashLoan(
            ICreditFlashBorrower(self),
            loanAmount,
            abi.encode(leverParams, subCollateral, residualRecipient)
        );
        IPermission(leverParams.vault).modifyPermission(leverParams.position, self, false);
    }

    /*//////////////////////////////////////////////////////////////
                          FLASHLOAN CALLBACKS
    //////////////////////////////////////////////////////////////*/

    /// @notice Callback function for the flash loan taken out in increaseLever
    /// @param data The encoded bytes that were passed into the flash loan
    function onFlashLoan(
        address /*initiator*/,
        address /*token*/,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        if (msg.sender != address(flashlender)) revert PositionAction__onFlashLoan__invalidSender();

        (LeverParams memory leverParams, address upFrontToken, uint256 upFrontAmount) = abi.decode(
            data,
            (LeverParams, address, uint256)
        );

        // perform a pre swap from arbitrary token to collateral token if necessary
        if (leverParams.auxSwap.assetIn != address(0)) {
            bytes memory auxSwapData = _delegateCall(
                address(swapAction),
                abi.encodeWithSelector(swapAction.swap.selector, leverParams.auxSwap)
            );
            upFrontAmount = abi.decode(auxSwapData, (uint256));
        }

        // handle the flash loan swap
        bytes memory swapData = _delegateCall(
            address(swapAction),
            abi.encodeWithSelector(swapAction.swap.selector, leverParams.primarySwap)
        );
        uint256 swapAmountOut = abi.decode(swapData, (uint256));

        // deposit collateral and handle any CDP specific actions
        uint256 collateral = _onIncreaseLever(leverParams, upFrontToken, upFrontAmount, swapAmountOut);

        // derive the amount of normal debt from the swap amount out
        uint256 addDebt = amount + fee;

        // add collateral and debt
        ICDPVault(leverParams.vault).modifyCollateralAndDebt(
            leverParams.position,
            address(this),
            address(this),
            toInt256(collateral),
            toInt256(addDebt)
        );

        underlyingToken.forceApprove(address(flashlender), addDebt);

        return CALLBACK_SUCCESS;
    }

    /// @notice Callback function for the credit flash loan taken out in decreaseLever
    /// @param data The encoded bytes that were passed into the credit flash loan
    function onCreditFlashLoan(
        address /*initiator*/,
        uint256 /*amount*/,
        uint256 /*fee*/,
        bytes calldata data
    ) external returns (bytes32) {
        if (msg.sender != address(flashlender)) revert PositionAction__onCreditFlashLoan__invalidSender();
        (
            LeverParams memory leverParams,
            uint256 subCollateral,
            address residualRecipient
        ) = abi.decode(data,(LeverParams, uint256, address));

        uint256 subDebt = leverParams.primarySwap.amount;

        underlyingToken.forceApprove(address(leverParams.vault), subDebt);
        // sub collateral and debt
        ICDPVault(leverParams.vault).modifyCollateralAndDebt(
            leverParams.position,
            address(this),
            address(this),
            0,
            -toInt256(subDebt)
        );

        // withdraw collateral and handle any CDP specific actions
        uint256 withdrawnCollateral = _onDecreaseLever(leverParams, subCollateral);

        bytes memory swapData = _delegateCall(
            address(swapAction),
            abi.encodeWithSelector(
                swapAction.swap.selector,
                leverParams.primarySwap
            )
        );
        uint256 swapAmountIn = abi.decode(swapData, (uint256));

        // swap collateral to stablecoin and calculate the amount leftover
        uint256 residualAmount = withdrawnCollateral - swapAmountIn;

        // send left over collateral that was not needed to payback the flash loan to `residualRecipient`
        if (residualAmount > 0) {

            // perform swap from collateral to arbitrary token if necessary
            if (leverParams.auxSwap.assetIn != address(0)) {
                _delegateCall(
                    address(swapAction),
                    abi.encodeWithSelector(
                        swapAction.swap.selector,
                        leverParams.auxSwap
                    )
                );
            } else {
                // otherwise just send the collateral to `residualRecipient`
                IERC20(leverParams.primarySwap.assetIn).safeTransfer(residualRecipient, residualAmount);
            }
        }

        underlyingToken.forceApprove(address(flashlender), subDebt);

        return CALLBACK_SUCCESS_CREDIT;
    }

    /*//////////////////////////////////////////////////////////////
                             INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposits collateral into CDPVault (optionally transfer and swaps an arbitrary token to collateral)
    /// @param vault The CDP Vault
    /// @param collateralParams The collateral parameters
    /// @return The amount of collateral deposited [wad]
    function _deposit(
        address vault,
        address position,
        CollateralParams calldata collateralParams,
        PermitParams calldata permitParams
    ) internal returns (uint256) {
        uint256 amount = collateralParams.amount;

        if (collateralParams.auxSwap.assetIn != address(0)) {
            if (
                collateralParams.auxSwap.assetIn != collateralParams.targetToken ||
                collateralParams.auxSwap.recipient != address(this)
            ) revert PositionAction__deposit_InvalidAuxSwap();
            amount = _transferAndSwap(collateralParams.collateralizer, collateralParams.auxSwap, permitParams);
        } else if (collateralParams.collateralizer != address(this)) {
            _transferFrom(
                collateralParams.targetToken,
                collateralParams.collateralizer,
                address(this),
                amount,
                permitParams
            );
        }

        return _onDeposit(vault, position, collateralParams.targetToken, amount);
    }

    /// @notice Withdraws collateral from CDPVault (optionally swaps collateral to an arbitrary token)
    /// @param vault The CDP Vault
    /// @param collateralParams The collateral parameters
    /// @return The amount of collateral withdrawn [token.decimals()]
    function _withdraw(address vault, address position, CollateralParams calldata collateralParams) internal returns (uint256) {
        uint256 collateral = _onWithdraw(vault, position, collateralParams.targetToken, collateralParams.amount);

        // perform swap from collateral to arbitrary token
        if (collateralParams.auxSwap.assetIn != address(0)) {
            _delegateCall(
                address(swapAction),
                abi.encodeWithSelector(swapAction.swap.selector, collateralParams.auxSwap)
            );
        } else {
            // otherwise just send the collateral to `collateralizer`
            IERC20(collateralParams.targetToken).safeTransfer(collateralParams.collateralizer, collateral);
        }
        return collateral;
    }

    /// @notice Borrows underlying token and optionally swaps underlying token to an arbitrary token
    /// @param vault The CDP Vault
    /// @param position The CDP Vault
    /// @param creditParams The credit parameters
    function _borrow(address vault, address position, CreditParams calldata creditParams) internal {
        ICDPVault(vault).modifyCollateralAndDebt(position, address(this), address(this), 0, toInt256(creditParams.amount));
        if (creditParams.auxSwap.assetIn == address(0)) {
            underlyingToken.forceApprove(address(this), creditParams.amount);
            underlyingToken.safeTransferFrom(address(this), creditParams.creditor, creditParams.amount);
        } else {
            // handle exit swap
            if (creditParams.auxSwap.assetIn != address(underlyingToken)) revert PositionAction__borrow_InvalidAuxSwap();
            _delegateCall(address(swapAction), abi.encodeWithSelector(swapAction.swap.selector, creditParams.auxSwap));
        }
    }

    /// @notice Repays debt by redeeming underlying token and optionally swaps an arbitrary token to underlying token
    /// @param vault The CDP Vault
    /// @param creditParams The credit parameters
    /// @param permitParams The permit parameters
    function _repay(address vault, address position, CreditParams calldata creditParams, PermitParams calldata permitParams) internal {
        // transfer arbitrary token and swap to underlying token
        uint256 amount;
        if (creditParams.auxSwap.assetIn != address(0)) {
            if (creditParams.auxSwap.recipient != address(this)) revert PositionAction__repay_InvalidAuxSwap();

            amount = _transferAndSwap(creditParams.creditor, creditParams.auxSwap, permitParams);
        } else {
            if (creditParams.creditor != address(this)) {
                // transfer directly from creditor
                _transferFrom(address(underlyingToken), creditParams.creditor, address(this), creditParams.amount, permitParams);
            }
        }

        underlyingToken.forceApprove(address(vault), creditParams.amount);
        ICDPVault(vault).modifyCollateralAndDebt(
            position,
            address(this),
            address(this),
            0,
            -toInt256(creditParams.amount)
        );
    }

    /// @dev Sends remaining tokens back to `sender` instead of leaving them on the proxy
    function _transferAndSwap(
        address sender,
        SwapParams calldata swapParams,
        PermitParams calldata permitParams
    ) internal returns (uint256 amountOut) {
        bytes memory response = _delegateCall(
            address(swapAction),
            abi.encodeWithSelector(swapAction.transferAndSwap.selector, sender, permitParams, swapParams)
        );
        uint256 retAmount = abi.decode(response, (uint256));

        // if this is an exact out swap then transfer the remainder to the `sender`
        if (swapParams.swapType == SwapType.EXACT_OUT) {
            uint256 remainder = swapParams.limit - retAmount;
            if (remainder > 0) {
                IERC20(swapParams.assetIn).safeTransfer(sender, remainder);
            }
            amountOut = swapParams.amount;
        } else {
            amountOut = retAmount;
        }
    }
}
