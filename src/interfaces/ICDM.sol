// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IPermission} from "./IPermission.sol";

interface ICDM is IPermission {
    function globalDebt() external view returns (uint256);

    function globalDebtCeiling() external view returns (uint256);

    function accounts(address account) external view returns (int256 balance, uint256 debtCeiling);

    function setParameter(bytes32 parameter, uint256 data) external;

    function setParameter(address debtor, bytes32 parameter, uint256 data) external;

    function creditLine(address account) external view returns (uint256);

    function modifyBalance(address from, address to, uint256 amount) external;
}
