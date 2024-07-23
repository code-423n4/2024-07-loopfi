// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

interface IPause {
    function pausedAt() external view returns (uint256);

    function pause() external;

    function unpause() external;
}
