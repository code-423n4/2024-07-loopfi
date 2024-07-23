// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

// Authenticated Roles
bytes32 constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

interface IOracle {
    function spot(address token) external view returns (uint256);
    function getStatus(address token) external view returns (bool);
}
