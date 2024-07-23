// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

interface IPermission {
    function hasPermission(address owner, address caller) external view returns (bool);

    function modifyPermission(address caller, bool allowed) external;

    function modifyPermission(address owner, address caller, bool allowed) external;
}
