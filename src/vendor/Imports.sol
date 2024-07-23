// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PRBProxyRegistry} from "prb-proxy/PRBProxyRegistry.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

import {IAllowanceTransfer} from "permit2/interfaces/IAllowanceTransfer.sol";
