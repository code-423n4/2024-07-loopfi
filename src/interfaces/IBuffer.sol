// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {ICDM} from "./ICDM.sol";

interface IBuffer {
    function cdm() external view returns (ICDM);

    function withdrawCredit(address to, uint256 amount) external;
}
