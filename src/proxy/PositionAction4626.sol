// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ICDPVault} from "../interfaces/ICDPVault.sol";

import {PositionAction, LeverParams, PoolActionParams} from "./PositionAction.sol";

/// @title PositionAction4626
/// @notice Generic ERC4626 implementation of PositionAction base contract
contract PositionAction4626 is PositionAction {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(
        address flashlender_,
        address swapActions_,
        address poolAction_,
        address vaultRegistry_
    ) PositionAction(flashlender_, swapActions_, poolAction_, vaultRegistry_) {}

    /*//////////////////////////////////////////////////////////////
                         VIRTUAL IMPLEMENTATION
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit collateral into the vault
    /// @param vault Address of the vault
    /// @param src Token passed in by the caller
    /// @param amount Amount of collateral to deposit [CDPVault.tokenScale()]
    /// @return Amount of collateral deposited [wad]
    function _onDeposit(address vault, address /*position*/, address src, uint256 amount) internal override returns (uint256) {
        address collateral = address(ICDPVault(vault).token());

        // if the src is not the collateralToken, we need to deposit the underlying into the ERC4626 vault
        if (src != collateral) {
            address underlying = IERC4626(collateral).asset();
            IERC20(underlying).forceApprove(collateral, amount);
            amount = IERC4626(collateral).deposit(amount, address(this));
        }

        IERC20(collateral).forceApprove(vault, amount);
        return ICDPVault(vault).deposit(address(this), amount);
    }

    /// @notice Withdraw collateral from the vault
    /// @param vault Address of the vault
    /// @param /*position*/ Address of the position
    /// @param dst Token the caller expects to receive
    /// @param amount Amount of collateral to withdraw [wad]
    /// @return Amount of collateral withdrawn [CDPVault.tokenScale()]
    function _onWithdraw(address vault, address /*position*/, address dst, uint256 amount) internal override returns (uint256) {
        uint256 collateralWithdrawn = ICDPVault(vault).withdraw(address(this), amount);

        // if collateral is not the dst token, we need to withdraw the underlying from the ERC4626 vault
        address collateral = address(ICDPVault(vault).token());
        if (dst != collateral) {
            collateralWithdrawn = IERC4626(collateral).redeem(collateralWithdrawn, address(this), address(this));
        }

        return collateralWithdrawn;
    }

    /// @notice Hook to decrease lever by depositing collateral into the Yearn Vault and the Yearn Vault
    /// @param leverParams LeverParams struct
    /// @param upFrontToken the token passed up front
    /// @param upFrontAmount the amount of tokens passed up front [IYVault.decimals()]
    /// @param swapAmountOut the amount of tokens received from the stablecoin flash loan swap [IYVault.decimals()]
    /// @return Amount of collateral added to CDPVault position [wad]
    function _onIncreaseLever(
        LeverParams memory leverParams,
        address upFrontToken,
        uint256 upFrontAmount,
        uint256 swapAmountOut
    ) internal override returns (uint256) {
        uint256 upFrontCollateral;
        uint256 addCollateralAmount = swapAmountOut;
        if (leverParams.collateralToken == upFrontToken && leverParams.auxSwap.assetIn == address(0)) {
            // if there was no aux swap then treat this amount as the ERC4626 token
            upFrontCollateral = upFrontAmount;
        } else {
            // otherwise treat as the ERC4626 underlying
            addCollateralAmount += upFrontAmount;
        }

        address underlyingToken = IERC4626(leverParams.collateralToken).asset();
        // join into the pool if needed
        if (leverParams.auxAction.args.length != 0) {
            address joinToken = swapAction.getSwapToken(leverParams.primarySwap);
            address joinUpfrontToken = upFrontToken;

            if (leverParams.auxSwap.assetIn != address(0)) {
                joinUpfrontToken = swapAction.getSwapToken(leverParams.auxSwap);
            }

            // update the join parameters with the new amounts
            PoolActionParams memory poolActionParams = poolAction.updateLeverJoin(
                leverParams.auxAction,
                joinToken,
                joinUpfrontToken,
                swapAmountOut,
                upFrontAmount,
                underlyingToken
            );

            _delegateCall(address(poolAction), abi.encodeWithSelector(poolAction.join.selector, poolActionParams));

            // retrieve the total amount of collateral after the join
            addCollateralAmount = IERC20(underlyingToken).balanceOf(address(this));
        }

        // deposit into the ERC4626 vault
        IERC20(underlyingToken).forceApprove(leverParams.collateralToken, addCollateralAmount);
        addCollateralAmount =
            IERC4626(leverParams.collateralToken).deposit(addCollateralAmount, address(this)) +
            upFrontCollateral;

        // deposit into the CDP vault
        IERC20(leverParams.collateralToken).forceApprove(leverParams.vault, addCollateralAmount);
        return ICDPVault(leverParams.vault).deposit(address(this), addCollateralAmount);
    }

    /// @notice Hook to decrease lever by withdrawing collateral from the CDPVault and the ERC4626 Vault
    /// @param leverParams LeverParams struct
    /// @param subCollateral Amount of collateral to withdraw in CDPVault decimals [wad]
    /// @return tokenOut Amount of underlying token withdrawn from the ERC4626 vault [CDPVault.tokenScale()]
    function _onDecreaseLever(
        LeverParams memory leverParams,
        uint256 subCollateral
    ) internal override returns (uint256 tokenOut) {
        // withdraw collateral from vault
        uint256 withdrawnCollateral = ICDPVault(leverParams.vault).withdraw(address(this), subCollateral);

        // withdraw collateral from the ERC4626 vault and return underlying assets
        tokenOut = IERC4626(leverParams.collateralToken).redeem(withdrawnCollateral, address(this), address(this));

        if (leverParams.auxAction.args.length != 0) {
            bytes memory exitData = _delegateCall(
                address(poolAction),
                abi.encodeWithSelector(poolAction.exit.selector, leverParams.auxAction)
            );

            tokenOut = abi.decode(exitData, (uint256));
        }
    }
}
