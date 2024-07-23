// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../interfaces/IOracle.sol";

contract MockOracle is IOracle {
    mapping(address token => uint256 spot) private _spot;

    function updateSpot(address token, uint256 spot_) external {
        _spot[token] = spot_;
    }

    function spot(address token) external view returns (uint256) {
        return _spot[token];
    }

    function getStatus(address /*token*/) public pure returns (bool) {
        return true;
    }
}
