// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICDPVault} from "./ICDPVault.sol";

/// @title IVaultRegistry
/// @notice Interface for the VaultRegistry contract managing vault registrations.
interface IVaultRegistry {
    /// @notice Adds a new vault to the registry.
    /// @param vault The address of the vault to add.
    function addVault(ICDPVault vault) external;

    /// @notice Removes a vault from the registry.
    /// @param vault The address of the vault to remove.
    function removeVault(ICDPVault vault) external;

    /// @notice Returns the list of all registered vaults.
    /// @return An array of registered vault addresses.
    function getVaults() external view returns (ICDPVault[] memory);

    /// @notice Returns the total normal debt of a user.
    /// @param user The position owner
    function getUserTotalDebt(address user) external view returns (uint256 totalNormalDebt);

    /// @notice Returns if a vault is registered.
    /// @param vault The address of the vault to check.
    function isVaultRegistered(address vault) external view returns (bool);
}
