// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {ICDM} from "./ICDM.sol";
import {IStablecoin} from "./IStablecoin.sol";

interface IMinter {
    function cdm() external view returns (ICDM);

    function stablecoin() external view returns (IStablecoin);

    function enter(address user, uint256 amount) external;

    function exit(address user, uint256 amount) external;
}
