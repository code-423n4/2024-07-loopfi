// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

import {ICDM} from "./ICDM.sol";
import {IOracle} from "./IOracle.sol";
import {IBuffer} from "./IBuffer.sol";
import {IPause} from "./IPause.sol";
import {IPermission} from "./IPermission.sol";
import {IInterestRateModel} from "./IInterestRateModel.sol";
import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

// Deployment related structs
struct CDPVaultConstants {
    IPoolV3 pool;
    IOracle oracle;
    IERC20 token;
    uint256 tokenScale;
}

struct CDPVaultConfig {
    uint128 debtFloor;
    uint64 liquidationRatio;
    uint64 liquidationPenalty;
    uint64 liquidationDiscount;
    address roleAdmin;
    address vaultAdmin;
    address pauseAdmin;
}

/// @title ICDPVaultBase
/// @notice Interface for the CDPVault without `paused` to avoid unnecessary overriding of `paused` in CDPVault
interface ICDPVaultBase is IAccessControl, IPause, IPermission {
    function pool() external view returns (IPoolV3);

    function oracle() external view returns (IOracle);

    function token() external view returns (IERC20);

    function tokenScale() external view returns (uint256);

    function vaultConfig() external view returns (uint128 debtFloor, uint64 liquidationRatio);

    function totalDebt() external view returns (uint256);

    function positions(
        address owner
    )
        external
        view
        returns (
            uint256 collateral,
            uint256 debt,
            uint256 lastDebtUpdate,
            uint256 cumulativeIndexLastUpdate,
            uint192 cumulativeQuotaIndexLU,
            uint128 cumulativeQuotaInterest
        );

    function deposit(address to, uint256 amount) external returns (uint256);

    function withdraw(address to, uint256 amount) external returns (uint256);

    function spotPrice() external returns (uint256);

    function modifyCollateralAndDebt(
        address owner,
        address collateralizer,
        address creditor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external;
}

/// @title ICDPVault
/// @notice Interface for the CDPVault
interface ICDPVault is ICDPVaultBase {
    function paused() external view returns (bool);

    function virtualDebt(address position) external view returns (uint256);

    function getAccruedInterest(address position) external view returns (uint256 accruedInterest);

}
