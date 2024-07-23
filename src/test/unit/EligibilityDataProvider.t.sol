// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {TestBase} from "../TestBase.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {WAD} from "../../utils/Math.sol";
import {IVaultRegistry} from "../../interfaces/IVaultRegistry.sol";
import {EligibilityDataProvider} from "../../reward/EligibilityDataProvider.sol";
import {IMultiFeeDistribution} from "../../reward/interfaces/IMultiFeeDistribution.sol";
import {IPriceProvider} from "../../reward/interfaces/IPriceProvider.sol";
import {IChefIncentivesController} from "../../reward/interfaces/IChefIncentivesController.sol";
import {LockedBalance, Balances} from "../../reward/interfaces/LockedBalance.sol";

contract EligibilityDataProviderTest is TestBase {
    EligibilityDataProvider internal eligibilityDataProvider;

    address internal mockVaultRegistry;
    address internal mockMultiFeeDistribution;
    address internal mockPriceProvider;

    function setUp() public virtual override {
        super.setUp();
        mockVaultRegistry = vm.addr(uint256(keccak256("mockVaultRegistry")));
        mockMultiFeeDistribution = vm.addr(uint256(keccak256("mockMultiFeeDistribution")));
        mockPriceProvider = vm.addr(uint256(keccak256("mockPriceProvider")));

        eligibilityDataProvider = EligibilityDataProvider(
            address(
                new ERC1967Proxy(
                    address(new EligibilityDataProvider()),
                    abi.encodeWithSelector(
                        EligibilityDataProvider.initialize.selector,
                        IVaultRegistry(address(mockVaultRegistry)),
                        IMultiFeeDistribution(address(mockMultiFeeDistribution)),
                        IPriceProvider(address(mockPriceProvider))
                    )
                )
            )
        );

        _mockLPPrice(WAD);
    }

    function _mockBalances(address user, uint256 lockedAmount) internal {
        Balances memory _balance = Balances({
            total: lockedAmount,
            locked: lockedAmount,
            unlocked: 0,
            lockedWithMultiplier: 0,
            earned: 0
        });

        vm.mockCall(
            mockMultiFeeDistribution,
            abi.encodeWithSelector(IMultiFeeDistribution.getBalances.selector, user),
            abi.encode(_balance)
        );
    }

    function _mockLPPrice(uint256 price) internal {
        vm.mockCall(
            mockPriceProvider,
            abi.encodeWithSelector(IPriceProvider.getLpTokenPriceUsd.selector),
            abi.encode(price)
        );
    }

    function _mockTotalNormalDebt(address user, uint256 totalNormalDebt) internal {
        vm.mockCall(
            mockVaultRegistry,
            abi.encodeWithSelector(IVaultRegistry.getUserTotalDebt.selector, user),
            abi.encode(totalNormalDebt)
        );
    }

    function test_deploy() public {
        assertEq(address(eligibilityDataProvider.vaultRegistry()), address(mockVaultRegistry));
        assertEq(address(eligibilityDataProvider.multiFeeDistribution()), address(mockMultiFeeDistribution));
        assertEq(address(eligibilityDataProvider.priceProvider()), address(mockPriceProvider));
        assertEq(eligibilityDataProvider.requiredDepositRatio(), 500);
        assertEq(eligibilityDataProvider.priceToleranceRatio(), 9000);
    }

    function test_setChefIncentivesController(address cic) public {
        vm.assume(cic != address(0));
        eligibilityDataProvider.setChefIncentivesController(IChefIncentivesController(cic));
        assertEq(address(eligibilityDataProvider.chef()), cic);

        vm.prank(address(0x123));
        vm.expectRevert("Ownable: caller is not the owner");
        eligibilityDataProvider.setChefIncentivesController(IChefIncentivesController(cic));
    }

    function test_setLPToken(address token) public {
        vm.assume(token != address(0));
        eligibilityDataProvider.setLPToken(token);
        assertEq(eligibilityDataProvider.lpToken(), token);

        vm.prank(address(0x123));
        vm.expectRevert("Ownable: caller is not the owner");
        eligibilityDataProvider.setLPToken(token);

        vm.expectRevert(EligibilityDataProvider.LPTokenSet.selector);
        eligibilityDataProvider.setLPToken(token);
    }

    function test_setRequiredDepositRatio(uint256 ratio) public {
        uint256 max = eligibilityDataProvider.RATIO_DIVISOR();
        ratio = ratio % max;
        eligibilityDataProvider.setRequiredDepositRatio(ratio);
        assertEq(eligibilityDataProvider.requiredDepositRatio(), ratio);

        vm.prank(address(0x123));
        vm.expectRevert("Ownable: caller is not the owner");
        eligibilityDataProvider.setRequiredDepositRatio(ratio);

        vm.expectRevert(EligibilityDataProvider.InvalidRatio.selector);
        eligibilityDataProvider.setRequiredDepositRatio(max + 1);
    }

    function test_setPriceToleranceRatio(uint256 tolerationRatio) public {
        uint256 max = eligibilityDataProvider.RATIO_DIVISOR();
        uint256 min = eligibilityDataProvider.MIN_PRICE_TOLERANCE_RATIO();
        tolerationRatio = bound(tolerationRatio, min, max);

        eligibilityDataProvider.setPriceToleranceRatio(tolerationRatio);
        assertEq(eligibilityDataProvider.priceToleranceRatio(), tolerationRatio);

        vm.prank(address(0x123));
        vm.expectRevert("Ownable: caller is not the owner");
        eligibilityDataProvider.setPriceToleranceRatio(tolerationRatio);

        vm.expectRevert(EligibilityDataProvider.InvalidRatio.selector);
        eligibilityDataProvider.setPriceToleranceRatio(max + 1);

        vm.expectRevert(EligibilityDataProvider.InvalidRatio.selector);
        eligibilityDataProvider.setPriceToleranceRatio(min - 1);
    }

    function test_setDqTime(address user, uint256 time) public {
        vm.expectRevert(EligibilityDataProvider.OnlyCIC.selector);
        eligibilityDataProvider.setDqTime(user, time);

        address cic = address(0x123);
        eligibilityDataProvider.setChefIncentivesController(IChefIncentivesController(cic));
        vm.prank(cic);
        eligibilityDataProvider.setDqTime(user, time);
    }

    function test_getDqTime(address user, uint256 time) public {
        address cic = address(0x123);
        eligibilityDataProvider.setChefIncentivesController(IChefIncentivesController(cic));
        vm.prank(cic);
        eligibilityDataProvider.setDqTime(user, time);
        assertEq(eligibilityDataProvider.getDqTime(user), time);
    }

    function test_lockedUsdValue(address user, uint128 lockedAmount) public {
        _mockBalances(user, lockedAmount);
        _mockLPPrice(WAD);

        assertEq(eligibilityDataProvider.lockedUsdValue(user), lockedAmount);
    }

    function test_requiredUsdValue(address user, uint128 lockedAmount) public {
        _mockBalances(user, lockedAmount);
        _mockLPPrice(WAD);
        uint256 totalNormalDebt = uint256(lockedAmount) * 20;
        _mockTotalNormalDebt(user, totalNormalDebt);

        uint256 ratio = eligibilityDataProvider.requiredDepositRatio();
        uint256 divisor = eligibilityDataProvider.RATIO_DIVISOR();
        uint256 required = (totalNormalDebt * ratio) / divisor;

        assertEq(eligibilityDataProvider.requiredUsdValue(user), required);
    }

    function test_isEligibleForRewards(address user) public {
        uint256 totalNormalDebt = 100 ether;
        _mockLPPrice(WAD);
        _mockTotalNormalDebt(user, totalNormalDebt);

        uint256 ratio = eligibilityDataProvider.requiredDepositRatio();
        uint256 divisor = eligibilityDataProvider.RATIO_DIVISOR();
        uint256 required = (totalNormalDebt * ratio) / divisor;

        uint256 lockedAmount = required;
        _mockBalances(user, uint128(lockedAmount));
        assertTrue(eligibilityDataProvider.isEligibleForRewards(user));

        // Event if we have less than required, we are still eligible because of
        // the price tolerance ratio
        lockedAmount = required - 1;
        _mockBalances(user, uint128(lockedAmount));
        assertTrue(eligibilityDataProvider.isEligibleForRewards(user));

        // Set the price tolerance ratio so there is no tolerance
        uint256 ratioDivisor = eligibilityDataProvider.RATIO_DIVISOR();
        eligibilityDataProvider.setPriceToleranceRatio(ratioDivisor);

        // Now we are not eligible
        _mockBalances(user, uint128(lockedAmount));
        assertFalse(eligibilityDataProvider.isEligibleForRewards(user));
    }

    function test_lastEligibleTime_returnsZeroIfNotEligible(address user) public {
        _mockTotalNormalDebt(user, 100 ether);
        _mockBalances(user, 0);

        assertEq(eligibilityDataProvider.lastEligibleTime(user), 0);
    }

    function test_lastEligibleTime_returnsTimestamp(address user) public {
        _mockTotalNormalDebt(user, 100 ether);
        uint256 required = eligibilityDataProvider.requiredUsdValue(user);
        _mockBalances(user, required);

        LockedBalance[] memory lockedBalances = new LockedBalance[](1);
        uint256 unlockTime = block.timestamp + 100;

        lockedBalances[0] = LockedBalance({amount: required, unlockTime: unlockTime, multiplier: 1, duration: 100});
        vm.mockCall(
            mockMultiFeeDistribution,
            abi.encodeWithSelector(IMultiFeeDistribution.lockInfo.selector, user),
            abi.encode(lockedBalances)
        );

        // If user is still eligible, it will return future time
        assertEq(eligibilityDataProvider.lastEligibleTime(user), unlockTime);
    }

    function test_lastEligibleTime_multiple_returnsTimestamp(address user) public {
        _mockTotalNormalDebt(user, 100 ether);
        uint256 required = eligibilityDataProvider.requiredUsdValue(user);
        _mockBalances(user, required);

        LockedBalance[] memory lockedBalances = new LockedBalance[](3);

        uint256 unlockTime = block.timestamp + 100;
        uint256 half = required / 2;
        lockedBalances[0] = LockedBalance({amount: half, unlockTime: unlockTime + 50, multiplier: 1, duration: 100});

        lockedBalances[1] = LockedBalance({amount: half, unlockTime: unlockTime, multiplier: 1, duration: 100});

        lockedBalances[2] = LockedBalance({amount: half, unlockTime: unlockTime - 50, multiplier: 1, duration: 100});

        vm.mockCall(
            mockMultiFeeDistribution,
            abi.encodeWithSelector(IMultiFeeDistribution.lockInfo.selector, user),
            abi.encode(lockedBalances)
        );

        // If user is still eligible, it will return future time
        assertEq(eligibilityDataProvider.lastEligibleTime(user), unlockTime);
    }

    function test_refresh(address user) public {
        vm.assume(user != address(0));
        vm.expectRevert(EligibilityDataProvider.OnlyCIC.selector);
        eligibilityDataProvider.refresh(user);

        vm.mockCall(mockPriceProvider, abi.encodeWithSelector(IPriceProvider.update.selector), abi.encode());

        uint256 totalNormalDebt = 1000 ether;
        _mockTotalNormalDebt(user, totalNormalDebt);
        _mockBalances(user, eligibilityDataProvider.requiredUsdValue(user));

        bool isEligible = eligibilityDataProvider.isEligibleForRewards(user);
        assertTrue(isEligible);

        // Last eligible status is false because we have not called refresh
        assertEq(eligibilityDataProvider.lastEligibleStatus(user), false);

        address cic = address(0x123);
        eligibilityDataProvider.setChefIncentivesController(IChefIncentivesController(cic));
        vm.prank(cic);

        eligibilityDataProvider.refresh(user);

        // Last eligible status is true because we have called refresh
        assertEq(eligibilityDataProvider.disqualifiedTime(user), 0);
        assertEq(eligibilityDataProvider.lastEligibleStatus(user), true);
    }

    function test_refresh_updatesDisqualifyData(address user) public {
        vm.assume(user != address(0));
        vm.expectRevert(EligibilityDataProvider.OnlyCIC.selector);
        eligibilityDataProvider.refresh(user);

        vm.mockCall(mockPriceProvider, abi.encodeWithSelector(IPriceProvider.update.selector), abi.encode());

        uint256 totalNormalDebt = 1000 ether;
        _mockTotalNormalDebt(user, totalNormalDebt);
        _mockBalances(user, eligibilityDataProvider.requiredUsdValue(user));

        address cic = address(0x123);
        eligibilityDataProvider.setChefIncentivesController(IChefIncentivesController(cic));

        vm.prank(cic);
        eligibilityDataProvider.refresh(user);

        assertEq(eligibilityDataProvider.lastEligibleStatus(user), true);

        _mockBalances(user, 0);

        vm.startPrank(cic);
        eligibilityDataProvider.setDqTime(user, block.timestamp);
        eligibilityDataProvider.refresh(user);
        assertEq(eligibilityDataProvider.lastEligibleStatus(user), false);
        assertEq(eligibilityDataProvider.disqualifiedTime(user), block.timestamp);
    }
}
