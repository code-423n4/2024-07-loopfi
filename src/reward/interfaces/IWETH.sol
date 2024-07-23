// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.19;

interface IWETH {
    function balanceOf(address) external returns (uint256);

    function deposit() external payable;

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function transferFrom(address src, address dst, uint256 wad) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external returns (uint256);
}
