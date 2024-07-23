// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC20Mintable {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
}

interface IStablecoin is IERC20Mintable, IERC20Metadata, IERC20Permit {}
