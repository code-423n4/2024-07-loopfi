// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ICDPVault} from "../interfaces/ICDPVault.sol";

import {PositionAction, LeverParams} from "./PositionAction.sol";

/// @title PositionAction20
/// @notice ERC20 implementation of PositionAction base contract
contract PositionAction20 is PositionAction {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(
        address flashlender_,
        address swapAction_,
        address poolAction_, 
        address vaultRegistry_
    ) PositionAction(flashlender_, swapAction_, poolAction_, vaultRegistry_) {}

    /*//////////////////////////////////////////////////////////////
                         VIRTUAL IMPLEMENTATION
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit collateral into the vault
    /// @param vault Address of the vault
    /// @param amount Amount of collateral to deposit [CDPVault.tokenScale()]
    /// @return Amount of collateral deposited [wad]
    function _onDeposit(address vault, address position, address /*src*/, uint256 amount) internal override returns (uint256) {
        address collateralToken = address(ICDPVault(vault).token());
        IERC20(collateralToken).forceApprove(vault, amount);
        return ICDPVault(vault).deposit(position, amount);
    }

    /// @notice Withdraw collateral from the vault
    /// @param vault Address of the vault
    /// @param position Address of the position
    /// @param amount Amount of collateral to withdraw [wad]
    /// @return Amount of collateral withdrawn [CDPVault.tokenScale()]
    function _onWithdraw(address vault, address position, address /*dst*/, uint256 amount) internal override returns (uint256) {
        return ICDPVault(vault).withdraw(position, amount);
    }

    /// @notice Hook to increase lever by depositing collateral into the CDPVault
    /// @param leverParams LeverParams struct
    /// @param upFrontAmount the amount of tokens passed up front [CDPVault.tokenScale()]
    /// @param swapAmountOut the amount of tokens received from the stablecoin flash loan swap [CDPVault.tokenScale()]
    /// @return Amount of collateral added to CDPVault position [wad]
    function _onIncreaseLever(
        LeverParams memory leverParams,
        address /*upFrontToken*/,
        uint256 upFrontAmount,
        uint256 swapAmountOut
    ) internal override returns (uint256) {
        // for standard erc20 cdps treat the upFrontAmount and swapAmountOut as the collateral token
        uint256 addCollateralAmount = swapAmountOut + upFrontAmount;

        // allow deposit into the CDP Vault
        IERC20(leverParams.collateralToken).forceApprove(leverParams.vault, addCollateralAmount);
        return addCollateralAmount;
    }

    /// @notice Hook to decrease lever by withdrawing collateral from the CDPVault
    /// @param leverParams LeverParams struct
    /// @param subCollateral Amount of collateral to subtract in CDPVault decimals [wad]
    /// @return Amount of underlying token withdrawn from CDPVault [CDPVault.tokenScale()]
    function _onDecreaseLever(
        LeverParams memory leverParams,
        uint256 subCollateral
    ) internal override returns (uint256) {
        return _onWithdraw(leverParams.vault, leverParams.position, address(0), subCollateral);
    }
}
