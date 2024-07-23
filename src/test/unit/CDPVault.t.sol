// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {TestBase, ERC20PresetMinterPauser} from "../TestBase.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IOracle} from "../../interfaces/IOracle.sol";
import {ICDPVaultBase} from "../../interfaces/ICDPVault.sol";
import {CDPVaultConstants, CDPVaultConfig} from "../../interfaces/ICDPVault.sol";
import {IPermission} from "../../interfaces/IPermission.sol";

import {WAD, wmul, wdiv, wpow, toInt256} from "../../utils/Math.sol";
import {CDPVault, VAULT_CONFIG_ROLE} from "../../CDPVault.sol";
import {console} from "forge-std/console.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract MockTokenScaled is ERC20PresetMinterPauser {
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals_) ERC20PresetMinterPauser(name, symbol) {
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
import {CDPVault, VAULT_CONFIG_ROLE} from "../../CDPVault.sol";
import {console} from "forge-std/console.sol";

contract CDPVaultWrapper is CDPVault {
    constructor(CDPVaultConstants memory constants, CDPVaultConfig memory config) CDPVault(constants, config) {}
}

contract PositionOwner {
    constructor(IPermission vault) {
        // Allow deployer to modify Position
        vault.modifyPermission(msg.sender, true);
    }
}

contract CDPVaultTest is TestBase {
    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _depositCollateral(CDPVault vault, uint256 amount) internal {
        token.mint(address(this), amount);
        (uint256 collateralBefore, , , , , ) = vault.positions(address(this));
        token.approve(address(vault), amount);
        vault.deposit(address(this), amount);
        (uint256 collateralAfter, , , , , ) = vault.positions(address(this));
        assertEq(collateralAfter, collateralBefore + amount);
    }

    function _modifyCollateralAndDebt(CDPVault vault, int256 collateral, int256 debt) internal {
        if (debt < 0) {
            mockWETH.mint(address(this), uint256(-debt));
            mockWETH.approve(address(vault), uint256(-debt));
        }

        if (collateral > 0) {
            token.mint(address(this), uint256(collateral));
            token.approve(address(vault), uint256(collateral));
        }

        (uint256 collateralBefore, uint256 debtBefore, , , , ) = vault.positions(address(this));
        uint256 virtualDebtBefore = virtualDebt(vault, address(this));
        uint256 vaultCreditBefore = credit(address(this));

        vault.modifyCollateralAndDebt(address(this), address(this), address(this), collateral, debt);
        {
            (uint256 collateralAfter, uint256 debtAfter, , , , ) = vault.positions(address(this));
            assertEq(toInt256(collateralAfter), toInt256(collateralBefore) + collateral);
            assertEq(toInt256(debtAfter), toInt256(debtBefore) + debt);
        }

        uint256 virtualDebtAfter = virtualDebt(vault, address(this));
        int256 deltaDebt = toInt256(virtualDebtAfter) - toInt256(virtualDebtBefore);
        {
            uint256 tokensAfter = credit(address(this));
            assertEq(toInt256(tokensAfter), toInt256(vaultCreditBefore) + deltaDebt);
        }

        uint256 vaultCreditAfter = credit(address(this));
        assertEq(toInt256(vaultCreditBefore + virtualDebtAfter), toInt256(vaultCreditAfter + virtualDebtBefore));
        assertEq(toInt256(vaultCreditBefore + virtualDebtAfter), toInt256(vaultCreditAfter + virtualDebtBefore));
    }

    function _updateSpot(uint256 price) internal {
        oracle.updateSpot(address(token), price);
    }

    function _collateralizationRatio(CDPVault vault) internal view returns (uint256) {
        (uint256 collateral, , , , , ) = vault.positions(address(this));
        if (collateral == 0) return type(uint256).max;
        return wdiv(wmul(collateral, vault.spotPrice()), virtualDebt(vault, address(this)));
    }

    function _createVaultWrapper(uint256 liquidationRatio) private returns (CDPVaultWrapper vault) {
        CDPVaultConstants memory constants = _getDefaultVaultConstants();
        CDPVaultConfig memory config = _getDefaultVaultConfig();
        config.liquidationRatio = uint64(liquidationRatio);

        vault = new CDPVaultWrapper(constants, config);
    }

    function _setDebtCeiling(CDPVault vault, uint256 debtCeiling) internal {
        // cdm.setParameter(address(vault), "debtCeiling", debtCeiling);
        liquidityPool.setCreditManagerDebtLimit(address(vault), debtCeiling);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function test_deploy() public {
        CDPVault vault = createCDPVault(token, 0, 0, 1 ether, 1 ether, 0);

        assertNotEq(address(vault), address(0));
        assertEq(address(vault.pool()), address(liquidityPool));
        assertEq(address(vault.oracle()), address(oracle));
        assertEq(address(vault.token()), address(token));
        assertEq(vault.tokenScale(), 10 ** IERC20Metadata(address(token)).decimals());
    }

    function test_setParameter() public {
        CDPVault vault = createCDPVault(token, 0, 0, 1 ether, 1 ether, 0);
        vault.setParameter("debtFloor", 100 ether);
        vault.setParameter("liquidationRatio", 1.25 ether);

        (uint128 debtFloor, uint64 liquidationRatio) = vault.vaultConfig();
        assertEq(debtFloor, 100 ether);
        assertEq(liquidationRatio, 1.25 ether);
    }

    function test_setParameter_revertsOnUnrecognizedParam() public {
        CDPVault vault = createCDPVault(token, 0, 0, 1 ether, 1 ether, 0);
        vm.expectRevert(CDPVault.CDPVault__setParameter_unrecognizedParameter.selector);
        vault.setParameter("unknown parameter", 100 ether);
    }

    function test_deposit() public {
        CDPVault vault = createCDPVault(token, 150 ether, 10 ether, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));
        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);
        address position = address(new PositionOwner(vault));
        vault.deposit(position, 100 ether);

        (uint256 collateral, , , , , ) = vault.positions(position);
        assertEq(collateral, 100 ether);
    }

    function test_borrow() public {
        CDPVault vault = createCDPVault(token, 150 ether, 10 ether, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));
        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);
        address position = address(new PositionOwner(vault));
        vault.deposit(position, 100 ether);
        vault.borrow(address(this), position, 50 ether);
        uint256 credit = credit(address(this));
        assertEq(credit, 50 ether);
    }

    function test_modifyCollateralAndDebt_depositCollateralAndDrawDebt() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));
        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);
        address position = address(new PositionOwner(vault));
        // vault.deposit(address(this), 100 ether);

        vault.modifyCollateralAndDebt(position, address(this), address(this), 100 ether, 80 ether);

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(position);
        assertEq(collateral, 100 ether);
        assertEq(debt, 80 ether);
        uint256 credit = credit(address(this));
        assertEq(credit, 80 ether);
    }

    function test_modifyCollateralAndDebt_emptyCall() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));
        address position = address(new PositionOwner(vault));

        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);

        vault.modifyCollateralAndDebt(position, address(this), address(this), 100 ether, 80 ether);

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(position);
        vault.modifyCollateralAndDebt(position, address(this), address(this), 0, 0);
        (uint256 collateralAfter, uint256 debtAfter, , , , ) = vault.positions(position);

        assertEq(collateral, collateralAfter);
        assertEq(debt, debtAfter);
    }

    function test_modifyCollateralAndDebt_repayPositionAndWithdraw() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);
        address position = address(new PositionOwner(vault));
        vault.modifyCollateralAndDebt(position, address(this), address(this), 100 ether, 80 ether);

        mockWETH.approve(address(vault), 80 ether);
        vault.modifyCollateralAndDebt(position, address(this), address(this), -100 ether, -80 ether);
    }

    function test_modifyCollateralAndDebt_revertsOnUnsafePosition() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);
        address position = address(new PositionOwner(vault));

        vm.expectRevert(CDPVault.CDPVault__modifyCollateralAndDebt_notSafe.selector);
        vault.modifyCollateralAndDebt(position, address(this), address(this), 100 ether, 100 ether);
    }

    function test_modifyCollateralAndDebt_revertsOnDebtFloor() public {
        CDPVault vault = createCDPVault(token, 150 ether, 10 ether, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);
        address position = address(new PositionOwner(vault));

        vm.expectRevert(CDPVault.CDPVault__modifyPosition_debtFloor.selector);
        vault.modifyCollateralAndDebt(position, address(this), address(this), 100 ether, 5 ether);
    }

    function test_pool_interest() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        // create position
        token.mint(address(this), 100 ether);
        token.approve(address(vault), 100 ether);
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 100 ether, 80 ether);
        assertEq(credit(address(this)), 80 ether);

        assertEq(virtualDebt(vault, address(this)), 80 ether);
        vm.warp(block.timestamp + 365 days);
        assertGt(virtualDebt(vault, address(this)), 80 ether);
    }

    function test_closePosition() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        // create position
        token.mint(address(this), 200 ether);
        token.approve(address(vault), 200 ether);
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 200 ether, 150 ether);
        assertEq(credit(address(this)), 150 ether);

        (, uint256 accruedInterest, uint256 cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        assertEq(accruedInterest, 0, "accruedInterest before");
        assertEq(cumulativeQuotaInterest, 0, "cumulativeQuotaInterest before");
        assertEq(virtualDebt(vault, address(this)), 150 ether + accruedInterest, "Not correct");
        console.log(vault.quotasInterest(address(this)));
        assertEq(liquidityPool.quotaRevenue(), liquidityPool.totalBorrowed() / 1000, "quotaRevenue before");

        vm.warp(block.timestamp + 95 days);
        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        assertGt(accruedInterest, 0, "accruedInterest after 100 days");
        assertGt(cumulativeQuotaInterest, 0, "cumulativeQuotaInterest after 100 days");
        assertEq(liquidityPool.quotaRevenue(), liquidityPool.totalBorrowed() / 1000, "quotaRevenue after 100 days");
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 1000,
            "quotaRevenue after 100 days and updating rates (no rate change)"
        );
        vm.prank(address(voter));
        bytes memory data = abi.encode(address(token), true); // increase
        gauge.vote(address(this), 10, data);
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 100,
            "quotaRevenue after 100 days and updating rates (no time passed)"
        );
        vm.warp(block.timestamp + 265 days);

        uint256 virtualDebt = virtualDebt(vault, address(this));

        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 100,
            "quotaRevenue after 365 days and updating rates 265 days passed"
        );
        assertGt(virtualDebt, 150 ether);
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 365 days");
        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));

        console.log(accruedInterest, "accruedInterest after 1 year");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 1 year");
        mockWETH.approve(address(vault), virtualDebt);
        // obtain additional credit to repay interest
        createCredit(address(this), virtualDebt - 150 ether);

        // repay debt
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), -200 ether, -toInt256(virtualDebt));

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(this));
        assertEq(collateral, 0);
        assertEq(debt, 0);
        assertEq(liquidityPool.quotaRevenue(), 0, "quotaRevenue after repaying");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after repaying");
    }

    function test_closePosition_Quotas() public {
        // Quota Rate is set at 0.1%
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        assertEq(
            liquidityPool.calcAccruedQuotaInterest(),
            0,
            "total quota interest before updating rates before a borrow"
        );
        // create position
        token.mint(address(this), 200 ether);
        token.approve(address(vault), 200 ether);
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 200 ether, 150 ether);
        assertEq(credit(address(this)), 150 ether);
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 1000,
            "quotaRevenue before updating rates after a borrow"
        );
        assertEq(
            liquidityPool.calcAccruedQuotaInterest(),
            0,
            "total quota interest before updating rates after a borrow at time zero"
        );
        // Update rates and quota revenue
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 1000,
            "quotaRevenue after updating rates after a borrow"
        );
        console.log(
            liquidityPool.calcAccruedQuotaInterest(),
            "total quota interest after updating rates after a borrow"
        );
        (, uint256 accruedInterest, uint256 cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        assertEq(accruedInterest, 0, "accruedInterest right after a borrow");
        console.log(accruedInterest, "accruedInterest before");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest before");
        assertEq(vault.virtualDebt(address(this)), 150 ether + accruedInterest, "Not correct");
        console.log(vault.quotasInterest(address(this)), "quota interest user before");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue before");
        vm.warp(block.timestamp + 365 days);
        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        console.log(accruedInterest, "accruedInterest after 1 year before updating rates");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 1 year before updating rates");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 1 year before updating rates");
        console.log(vault.quotasInterest(address(this)), "quota interest user after 1 year before updating rates");
        // Rate is increased to 1%
        vm.prank(address(voter));
        bytes memory data = abi.encode(address(token), true); // increase
        gauge.vote(address(this), 10, data);
        vm.prank(address(gauge));
        quotaKeeper.updateRates();

        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        console.log(accruedInterest, "accruedInterest after 1 year after updating rates");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 1 year after updating rates");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 1 year after updating rates");
        console.log(vault.quotasInterest(address(this)), "quota interest user after 1 year after updating rates");

        console.log("REPAY HALF DEBT AFTER 1 YEAR");
        // Repay half debt

        uint256 virtualDebt = vault.virtualDebt(address(this));
        mockWETH.approve(address(vault), virtualDebt);
        // obtain additional credit to repay interest
        createCredit(address(this), virtualDebt - 150 ether);
        uint256 amountToRepay = virtualDebt / 2;
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 0, -toInt256(amountToRepay));
        uint debt;
        (debt, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        console.log(debt, "debt after 1 year after updating rates and repaying half debt");
        console.log(accruedInterest, "accruedInterest after 1 year after updating rates and repaying half debt");
        console.log(
            cumulativeQuotaInterest,
            "cumulativeQuotaInterest after 1 year after updating rates and repaying half debt"
        );
        console.log(
            liquidityPool.quotaRevenue(),
            "quotaRevenue after 1 year after updating rates and repaying half debt"
        );
        console.log(
            vault.quotasInterest(address(this)),
            "quota interest user after 1 year after updating rates and repaying half debt"
        );
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        // console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 365 days");
        vm.warp(block.timestamp + 365 days);

        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        console.log(accruedInterest, "accruedInterest after 2 years after updating rates");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 2 years after updating rates");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 2 years after updating rates");
        console.log(vault.quotasInterest(address(this)), "quota interest user after 2 years after updating rates");

        virtualDebt = vault.virtualDebt(address(this));
        console.log(virtualDebt, "virtualDebt");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 365 days");
        assertGt(virtualDebt, 150 ether - amountToRepay);
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 365 days");
        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));

        console.log(accruedInterest, "accruedInterest after 1 year");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 1 year");
        mockWETH.approve(address(vault), virtualDebt);
        // obtain additional credit to repay interest
        createCredit(address(this), virtualDebt);

        // repay debt
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), -200 ether, -toInt256(virtualDebt));
        uint256 collateral;
        (collateral, debt, , , , ) = vault.positions(address(this));
        assertEq(collateral, 0);
        assertEq(debt, 0);
        assertEq(liquidityPool.quotaRevenue(), 0, "quotaRevenue after repaying");
    }

    function test_closePosition_Quotas_2Users() public {
        // Quota Rate is set at 0.1%
        CDPVault vault = createCDPVault(token, 300 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        console.log(
            liquidityPool.calcAccruedQuotaInterest(),
            "total quota interest before updating rates before a borrow"
        );
        // create position
        token.mint(address(this), 200 ether);
        token.approve(address(vault), 200 ether);
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 200 ether, 150 ether);
        assertEq(credit(address(this)), 150 ether);
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 1000,
            "quotaRevenue before updating rates after a borrow"
        );
        assertEq(
            liquidityPool.calcAccruedQuotaInterest(),
            0,
            "total quota interest before updating rates after a borrow at time zero"
        );

        // create a second position
        address user2 = address(0x23);

        token.mint(user2, 200 ether);
        vm.startPrank(user2);
        token.approve(address(vault), 200 ether);
        vault.modifyCollateralAndDebt(user2, user2, user2, 200 ether, 150 ether);
        vm.stopPrank();
        assertEq(credit(user2), 150 ether);
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 1000,
            "quotaRevenue before updating rates after a borrow"
        );
        assertEq(
            liquidityPool.calcAccruedQuotaInterest(),
            0,
            "total quota interest before updating rates after a borrow at time zero"
        );

        // Update rates and quota revenue
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 1000,
            "quotaRevenue after updating rates after a borrow"
        );

        assertEq(
            liquidityPool.calcAccruedQuotaInterest(),
            0,
            "total quota interest before updating rates after a borrow at time zero"
        );

        (, uint256 accruedInterest, uint256 cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        assertEq(accruedInterest, 0, "accruedInterest right after a borrow");
        assertEq(cumulativeQuotaInterest, 0, "cumulativeQuotaInterest before");
        assertEq(virtualDebt(vault, address(this)), 150 ether + accruedInterest, "Not correct");
        assertEq(vault.quotasInterest(user2), 0, "quota interest user 2 before");
        assertEq(vault.quotasInterest(address(this)), 0, "quota interest user before");

        vm.warp(block.timestamp + 365 days);
        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        console.log(accruedInterest, "accruedInterest after 1 year before updating rates");
        assertGt(accruedInterest, 0, "accruedInterest after 1 year before updating rates");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 1 year before updating rates");
        assertEq(
            cumulativeQuotaInterest,
            150 ether / 1000,
            "cumulativeQuotaInterest after 1 year before updating rates"
        );
        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(user2);
        console.log(accruedInterest, "accruedInterest after 1 year before updating rates");
        assertGt(accruedInterest, 0, "accruedInterest after 1 year before updating rates");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 1 year before updating rates");
        assertEq(
            cumulativeQuotaInterest,
            150 ether / 1000,
            "cumulativeQuotaInterest after 1 year before updating rates"
        );
        assertEq(liquidityPool.quotaRevenue(), cumulativeQuotaInterest * 2, "quotaRevenue before updating rates");

        console.log("RATES UPDATED TO 1%");
        // Rate is increased to 1%
        vm.prank(address(voter));
        bytes memory data = abi.encode(address(token), true); // increase
        gauge.vote(address(this), 10, data);
        vm.prank(address(gauge));
        quotaKeeper.updateRates();

        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        console.log(accruedInterest, "accruedInterest after 1 year after updating rates");
        console.log(cumulativeQuotaInterest, "cumulativeQuotaInterest after 1 year after updating rates");
        //  console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 1 year after updating rates");
        assertEq(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 100,
            "quotaRevenue after 1 year after updating rates"
        );
        assertGt(
            liquidityPool.quotaRevenue(),
            cumulativeQuotaInterest * 2,
            "quotaRevenue after 1 year after updating rates"
        );

        assertEq(
            vault.quotasInterest(address(this)),
            150 ether / 1000, // still previous quota interest (0.1%)
            "quota interest user after 1 year after updating rates"
        );
        console.log("REPAY HALF DEBT AFTER 1 YEAR");
        // Repay half debt for user (not user2)

        uint256 virtualDebt = virtualDebt(vault, address(this));
        mockWETH.approve(address(vault), virtualDebt);
        // obtain additional credit to repay interest
        createCredit(address(this), virtualDebt - 150 ether);
        uint256 amountToRepay = virtualDebt / 2;
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 0, -toInt256(amountToRepay));

        uint debt;
        (debt, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        console.log(debt, "debt after 1 year after updating rates and repaying half debt");
        assertEq(accruedInterest, 0, "accruedInterest after 1 year after updating rates and repaying half debt");
        assertEq(
            cumulativeQuotaInterest,
            0,
            "cumulativeQuotaInterest after 1 year after updating rates and repaying half debt"
        );
        assertGt(
            liquidityPool.quotaRevenue(),
            liquidityPool.totalBorrowed() / 100,
            "quotaRevenue after 1 year after updating rates and repaying half debt"
        );
        console.log(
            liquidityPool.quotaRevenue(),
            "quotaRevenue after 1 year after updating rates and repaying half debt"
        );
        console.log(
            vault.quotasInterest(address(this)),
            "quota interest user after 1 year after updating rates and repaying half debt"
        );
        // Update quota revenue
        vm.prank(address(gauge));
        quotaKeeper.updateRates();

        vm.warp(block.timestamp + 365 days);

        (debt, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(address(this));
        assertGt(accruedInterest, 0, "accruedInterest after 2 years after updating rates");
        assertGt(cumulativeQuotaInterest, 0, "cumulativeQuotaInterest after 2 years after updating rates");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 2 years after updating rates");
        console.log(vault.quotasInterest(address(this)), "quota interest user after 2 years after updating rates");
        console.log("USER2 FINAL");
        (, accruedInterest, cumulativeQuotaInterest) = vault.getDebtInfo(user2);
        assertGt(accruedInterest, 0, "accruedInterest after 2 years after updating rates");
        assertGt(cumulativeQuotaInterest, 0, "cumulativeQuotaInterest after 2 years after updating rates");
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after 2 years after updating rates");
        console.log(vault.quotasInterest(user2), "quota interest user after 2 years after updating rates");

        uint userVirtualDebt = vault.virtualDebt(address(this));
        mockWETH.approve(address(vault), userVirtualDebt);
        // obtain additional credit to repay interest
        createCredit(address(this), userVirtualDebt);

        // repay debt
        vault.modifyCollateralAndDebt(
            address(this),
            address(this),
            address(this),
            -200 ether,
            -toInt256(userVirtualDebt)
        );
        uint256 collateral;
        (collateral, debt, , , , ) = vault.positions(address(this));
        assertEq(collateral, 0);
        assertEq(debt, 0);
        console.log(liquidityPool.quotaRevenue(), "quotaRevenue after repaying");

        userVirtualDebt = vault.virtualDebt(user2);
        vm.prank(user2);
        mockWETH.approve(address(vault), userVirtualDebt);
        // obtain additional credit to repay interest
        createCredit(user2, userVirtualDebt);

        // repay debt
        vm.prank(user2);
        vault.modifyCollateralAndDebt(user2, user2, user2, -200 ether, -toInt256(userVirtualDebt));

        (collateral, debt, , , , ) = vault.positions(user2);
        assertEq(collateral, 0);
        assertEq(debt, 0);

        vm.prank(address(gauge));
        quotaKeeper.updateRates();
        assertEq(liquidityPool.quotaRevenue(), 0, "quotaRevenue after repaying");
    }

    function test_closePosition_revertOnIncompleteRepay() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        // create position
        token.mint(address(this), 200 ether);
        token.approve(address(vault), 200 ether);

        uint256 debt = 150 ether;
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 200 ether, toInt256(debt));
        assertEq(credit(address(this)), debt);

        assertEq(virtualDebt(vault, address(this)), debt);
        vm.warp(block.timestamp + 365 days);
        uint256 virtualDebt = virtualDebt(vault, address(this));
        assertGt(virtualDebt, debt);

        mockWETH.approve(address(vault), virtualDebt);
        // obtain additional credit to repay interest
        createCredit(address(this), virtualDebt - debt);

        // repay debt
        vm.expectRevert(CDPVault.CDPVault__modifyCollateralAndDebt_notSafe.selector);
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), -200 ether, -toInt256(debt));
    }

    function test_closePosition_revertOnDebtFloor() public {
        CDPVault vault = createCDPVault(token, 150 ether, 5 ether, 1.25 ether, 1.0 ether, 0);
        createGaugeAndSetGauge(address(vault));

        // create position
        token.mint(address(this), 200 ether);
        token.approve(address(vault), 200 ether);

        uint256 debt = 150 ether;
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 200 ether, toInt256(debt));
        assertEq(credit(address(this)), debt);

        assertEq(virtualDebt(vault, address(this)), debt);
        vm.warp(block.timestamp + 30 days);
        uint256 virtualDebt = virtualDebt(vault, address(this));
        assertGt(virtualDebt, debt);

        mockWETH.approve(address(vault), debt);
        // repay debt
        vm.expectRevert(CDPVault.CDPVault__modifyPosition_debtFloor.selector);
        vault.modifyCollateralAndDebt(address(this), address(this), address(this), 0, -toInt256(debt));
    }

    // /*//////////////////////////////////////////////////////////////
    //                         LIQUIDATION FUNCTIONS
    // //////////////////////////////////////////////////////////////*/

    function test_liquidatePosition_revertOnSafePosition() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        address position = address(this);
        uint256 repayAmount = 40 ether;

        vm.expectRevert(CDPVault.CDPVault__liquidatePosition_notUnsafe.selector);
        vault.liquidatePosition(position, repayAmount);
    }

    function test_liquidatePosition_revertOnInvalidSpotPrice() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 40 ether;
        _updateSpot(0);
        vm.expectRevert(CDPVault.CDPVault__liquidatePosition_invalidSpotPrice.selector);
        vault.liquidatePosition(position, repayAmount);
    }

    function test_liquidatePosition_revertsOnInvalidArguments() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 0 ether;
        vm.expectRevert(CDPVault.CDPVault__liquidatePosition_invalidParameters.selector);
        vault.liquidatePosition(position, repayAmount);
    }

    // /*//////////////////////////////////////////////////////////////
    //          SCENARIO: PARTIAL LIQUIDATION OF VAULT
    // //////////////////////////////////////////////////////////////*/

    // Case 1: Fraction of maxDebtToRecover is repaid
    function test_liquidate_partial_1() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 40 ether;
        _updateSpot(0.80 ether);
        mockWETH.approve(address(vault), repayAmount);

        uint256 creditBefore = credit(address(this));
        uint256 virtualDebtBefore = virtualDebt(vault, position);
        vault.liquidatePosition(position, repayAmount);
        uint256 creditAfter = credit(address(this));

        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);

        assertEq(debtAfter, virtualDebtBefore - repayAmount); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 40 ether);
        assertEq(collateral, 50 ether);
        assertEq(token.balanceOf(address(vault)), 50 ether);
    }

    // // Case 2: Same as Case 1 but multiple liquidation calls
    function test_liquidate_partial_2() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        uint256 creditBefore = credit(address(this));
        // liquidate position
        address position = address(this);
        _updateSpot(0.80 ether);
        mockWETH.approve(address(vault), 80 ether);
        vault.liquidatePosition(position, 10 ether);
        vault.liquidatePosition(position, 30 ether);

        uint256 creditAfter = credit(address(this));

        uint256 virtualDebtAfter = virtualDebt(vault, position);
        assertEq(virtualDebtAfter, 40 ether); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 80 ether - 40 ether);
        assertEq(creditAfter, 40 ether); // creditBefore - repayAmount
        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);

        assertEq(collateral, 50 ether);
        assertEq(debtAfter, 40 ether);
    }

    // Case 3: Same as Case 1 but liquidationDiscount is applied
    function test_liquidate_partial_3() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 0.95 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 40 ether;
        _updateSpot(0.80 ether);
        mockWETH.approve(address(vault), repayAmount);
        uint256 creditBefore = credit(address(this));
        vault.liquidatePosition(position, repayAmount);
        uint256 creditAfter = credit(address(this));

        uint256 collateralReceived = wdiv(repayAmount, wmul(vault.spotPrice(), uint256(95 * 10 ** 16)));

        uint256 virtualDebtAfter = virtualDebt(vault, position);
        assertEq(virtualDebtAfter, 80 ether - repayAmount); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 80 ether - repayAmount);
        assertEq(creditAfter, repayAmount); // creditBefore - repayAmount
        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);
        assertEq(collateral, 100 ether - collateralReceived);
        assertEq(debtAfter, 40 ether);
    }

    function test_deposit_collateral_decimals() public {
        uint8 digits = 9;
        MockTokenScaled tokenScaled = new MockTokenScaled("TestToken", "TST", digits);
        CDPVault mockVault = createCDPVault(tokenScaled, 150 ether, 0, 1.25 ether, 1 ether, 0.95 ether);
        createGaugeAndSetGauge(address(mockVault), address(tokenScaled));
        uint256 amount = 200 * 10 ** digits;
        tokenScaled.mint(address(this), amount);
        (uint256 collateralBefore, , , , , ) = mockVault.positions(address(this));
        tokenScaled.approve(address(mockVault), amount);
        mockVault.deposit(address(this), amount);
        (uint256 collateralAfter, , , , , ) = mockVault.positions(address(this));

        uint256 scaledAmount = wdiv(amount, mockVault.tokenScale());
        assertEq(collateralAfter, collateralBefore + scaledAmount);
    }

    function test_withdraw_collateral_decimals() public {
        uint8 digits = 9;
        MockTokenScaled tokenScaled = new MockTokenScaled("TestToken", "TST", digits);
        CDPVault mockVault = createCDPVault(tokenScaled, 150 ether, 0, 1.25 ether, 1 ether, 0.95 ether);
        createGaugeAndSetGauge(address(mockVault), address(tokenScaled));
        uint256 amount = 200 * 10 ** digits;
        tokenScaled.mint(address(this), amount);
        (uint256 collateral1, , , , , ) = mockVault.positions(address(this));
        tokenScaled.approve(address(mockVault), amount);
        mockVault.deposit(address(this), amount);
        (uint256 collateral2, , , , , ) = mockVault.positions(address(this));

        uint256 scaledAmount = wdiv(amount, mockVault.tokenScale());
        assertEq(collateral2, collateral1 + scaledAmount);

        mockVault.withdraw(address(this), amount);
        (uint256 collateral3, , , , , ) = mockVault.positions(address(this));
        assertEq(collateral3, 0);
    }

    // /*//////////////////////////////////////////////////////////////
    //           SCENARIO: FULL LIQUIDATION OF VAULT
    // //////////////////////////////////////////////////////////////*/

    // // Case 1: Entire debt is repaid and no bad debt has accrued (no fee - self liquidation)
    function test_liquidate_full_1_No_Bad_Debt() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 80 ether;
        mockWETH.mint(address(this), repayAmount);
        _updateSpot(0.8 ether);
        mockWETH.approve(address(vault), repayAmount);
        console.log(vault.totalDebt(), "totalDebt");
        uint256 creditBefore = credit(address(this));
        uint256 virtualDebtBefore = virtualDebt(vault, position);
        vault.liquidatePosition(position, repayAmount);
        uint256 creditAfter = credit(address(this));

        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);

        assertEq(debtAfter, virtualDebtBefore - repayAmount); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 80 ether);
        assertEq(collateral, 0, "collateral");
        assertEq(token.balanceOf(address(vault)), 0);
        assertEq(vault.totalDebt(), 0, "totalDebt");
    }

    function test_liquidate_full_1_Bad_Debt() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));
        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 80 ether;
        _updateSpot(0.7 ether);
        mockWETH.approve(address(vault), repayAmount);
        console.log(vault.totalDebt(), "totalDebt");
        uint256 creditBefore = credit(address(this));
        uint256 virtualDebtBefore = virtualDebt(vault, position);
        vault.liquidatePositionBadDebt(position, repayAmount);
        uint256 creditAfter = credit(address(this));

        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);

        assertEq(debtAfter, virtualDebtBefore - repayAmount); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 70 ether);
        assertEq(collateral, 0);
        assertEq(token.balanceOf(address(vault)), 0);
        assertEq(vault.totalDebt(), 0, "totalDebt");
    }

    // Bad debt has accrued but no interest is accrued
    function test_liquidate_full_2() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 80 ether;
        _updateSpot(0.8 ether);
        mockWETH.approve(address(vault), repayAmount);
        console.log(vault.totalDebt(), "totalDebt");
        uint256 creditBefore = credit(address(this));
        uint256 virtualDebtBefore = virtualDebt(vault, position);
        vault.liquidatePosition(position, repayAmount);
        uint256 creditAfter = credit(address(this));
        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);

        assertEq(debtAfter, virtualDebtBefore - repayAmount); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 80 ether);
        assertEq(collateral, 0);
        assertEq(token.balanceOf(address(vault)), 0);
        assertEq(vault.totalDebt(), 0, "totalDebt");
    }

    // Bad debt has accrued and interest has accrued (loss) but there are no shares into treasury so no shares are burned
    function test_liquidate_full_3_no_treasury_shares() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 80 ether;
        _updateSpot(0.1 ether);
        mockWETH.approve(address(vault), repayAmount);
        vm.warp(block.timestamp + 365 days);
        console.log(vault.totalDebt(), "totalDebt");
        uint256 creditBefore = credit(address(this));
        uint256 sharesBefore = liquidityPool.totalSupply();
        assertGt(sharesBefore, 0);

        vault.liquidatePositionBadDebt(position, repayAmount);
        uint256 creditAfter = credit(address(this));
        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);
        assertEq(liquidityPool.totalSupply(), sharesBefore, "pool shares");
        assertEq(debtAfter, 0, "debt left"); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 10 ether);
        assertEq(collateral, 0);
        assertEq(token.balanceOf(address(vault)), 0);
        assertEq(vault.totalDebt(), 0, "totalDebt");
    }

    function test_liquidate_full_4_with_enough_treasury_shares() public {
        CDPVault vault = createCDPVault(token, 150 ether, 0, 1.25 ether, 1 ether, 1 ether);
        createGaugeAndSetGauge(address(vault));

        // create position
        _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

        // liquidate position
        address position = address(this);
        uint256 repayAmount = 80 ether;
        _updateSpot(0.1 ether);
        mockWETH.approve(address(vault), repayAmount);
        vm.warp(block.timestamp + 365 days);
        console.log(vault.totalDebt(), "totalDebt");
        uint256 creditBefore = credit(address(this));
        uint256 sharesBefore = liquidityPool.totalSupply();
        assertGt(sharesBefore, 0);
        // Transfer some shares to treasury to allow burning
        liquidityPool.transfer(liquidityPool.treasury(), sharesBefore);

        vault.liquidatePositionBadDebt(position, repayAmount);
        uint256 creditAfter = credit(address(this));
        (uint256 collateral, uint256 debtAfter, , , , ) = vault.positions(position);
        assertGt(sharesBefore, liquidityPool.totalSupply(), "pool shares");
        assertEq(debtAfter, 0, "debt left"); // debt - repayAmount
        assertEq(creditBefore - creditAfter, 10 ether);
        assertEq(collateral, 0);
        assertEq(token.balanceOf(address(vault)), 0);
        assertEq(vault.totalDebt(), 0, "totalDebt");
    }

    // function test_liquidate_full_1() public {
    //     CDPVault vault = createCDPVault(
    //         token,
    //         150 ether,
    //         0,
    //         1.25 ether,
    //         1 ether,
    //         1 ether,
    //         WAD
    //     );

    //     // create position
    //     _depositCollateral(vault, 100 ether);
    //     _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

    //     // liquidate position
    //     address position = address(this);
    //     uint256 repayAmount = 80 ether;
    //     _updateSpot(0.80 ether);
    //     vault.liquidatePosition(position, repayAmount);

    //     assertEq(debt(address(vault)), 0 ether);

    //     assertEq(vault.cash(address(this)), 100 ether);
    //     assertEq(credit(address(this)), 0); // creditBefore - repayAmount

    //     (uint256 collateral, uint256 normalDebt, , , ) = vault.positions(
    //         position
    //     );
    //     assertEq(collateral, 0);
    //     assertEq(normalDebt, 0);
    // }

    // // Case 2: Entire debt is repaid and bad debt has accrued
    // function test_liquidate_full_2() public {
    //     CDPVault vault = createCDPVault(
    //         token,
    //         150 ether,
    //         0,
    //         1.25 ether,
    //         1 ether,
    //         1 ether,
    //         WAD
    //     );

    //     // create position
    //     _depositCollateral(vault, 100 ether);
    //     _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

    //     // liquidate position
    //     address position = address(this);
    //     uint256 repayAmount = 80 ether;
    //     _updateSpot(0.1 ether);
    //     vault.liquidatePosition(position, repayAmount);

    //     assertEq(debt(address(vault)), 70 ether); // debt - collateralValue (since no discount)
    //     assertEq(vault.cash(address(this)), 100 ether); // all collateral

    //     (uint256 collateral, uint256 normalDebt, , , ) = vault.positions(
    //         position
    //     );
    //     assertEq(collateral, 0);
    //     assertEq(normalDebt, 0);
    // }

    // // Case 3: Entire debt is repaid and bad debt has accrued - with discount
    // function test_liquidate_full_3() public {
    //     CDPVault vault = createCDPVault(
    //         token,
    //         150 ether,
    //         0,
    //         1.25 ether,
    //         1 ether,
    //         0.95 ether,
    //         WAD
    //     );

    //     // create position
    //     _depositCollateral(vault, 100 ether);
    //     _modifyCollateralAndDebt(vault, 100 ether, 80 ether);

    //     // liquidate position
    //     address position = address(this);
    //     uint256 repayAmount = 80 ether;
    //     _updateSpot(0.5 ether);
    //     vault.liquidatePosition(position, repayAmount);

    //     assertEq(debt(address(vault)), 80 ether - 47.5 ether); // debt - discounted collateral value

    //     assertEq(vault.cash(address(this)), 100 ether); // collateral received
    //     assertEq(credit(address(this)), 80 ether - 47.5 ether); // creditBefore - discounted collateral value

    //     (uint256 collateral, uint256 normalDebt, , , ) = vault.positions(
    //         position
    //     );
    //     assertEq(collateral, 0);
    //     assertEq(normalDebt, 0);
    // }

    // // Case 4: Entire debt is repaid and debt floor is not met - reverts
    // function test_liquidate_full_4() public {
    //     CDPVault vault = createCDPVault(
    //         token,
    //         150 ether,
    //         10 ether,
    //         1.5 ether,
    //         1 ether,
    //         1 ether,
    //         WAD
    //     );

    //     // create position
    //     _depositCollateral(vault, 15 ether);
    //     _modifyCollateralAndDebt(vault, 15 ether, 10 ether);

    //     // liquidate position
    //     address position = address(this);
    //     uint256 repayAmount = 10 ether - 1;
    //     _updateSpot(1.0 ether - 1);

    //     vm.expectRevert(CDPVault.CDPVault__modifyPosition_debtFloor.selector);
    //     vault.liquidatePosition(position, repayAmount);

    //     assertEq(debt(address(vault)), 10 ether);
    //     assertEq(credit(address(this)), 10 ether); // credit before
    //     assertEq(vault.cash(address(this)), 0); // still used as collateral since not liquidated

    //     (uint256 collateral, uint256 normalDebt, , , ) = vault.positions(
    //         position
    //     );
    //     assertEq(collateral, 15 ether);
    //     assertEq(normalDebt, 10 ether);
    // }
}
