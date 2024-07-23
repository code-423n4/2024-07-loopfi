// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @notice Lightweight interface used to interrogate Curve pools
interface ICurvePool {
    function get_virtual_price() external view returns (uint256);
}
