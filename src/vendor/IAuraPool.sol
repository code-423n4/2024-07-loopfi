// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPool {
    function asset() external view returns (address);
    function balanceOf(address) external view returns (uint256);
    function deposit(uint256, address) external returns (uint256);
    function withdraw(uint256, bool) external;
    function withdraw(uint256, address, address) external;
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256);
    function getReward() external returns (bool);
    function extraRewardsLength() external view returns (uint256);
    function rewardToken() external view returns (address);
    function earned(address account) external view returns (uint256);
}
