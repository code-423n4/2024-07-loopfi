// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

interface IWeightedPool {
    function getNormalizedWeights() external view returns (uint256[] memory);

    function totalSupply() external view returns (uint256);

    function getPoolId() external view returns (bytes32);

    function getInvariant() external view returns (uint256);
}
