// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {TestBase} from "../TestBase.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {WAD} from "../../utils/Math.sol";
import {IVaultRegistry} from "../../interfaces/IVaultRegistry.sol";
import {MultiFeeDistribution} from "../../reward/MultiFeeDistribution.sol";
import {IMultiFeeDistribution} from "../../reward/interfaces/IMultiFeeDistribution.sol";
import {IPriceProvider} from "../../reward/interfaces/IPriceProvider.sol";
import {IChefIncentivesController} from "../../reward/interfaces/IChefIncentivesController.sol";
import {LockedBalance, Balances} from "../../reward/interfaces/LockedBalance.sol";
import {Reward} from "../../reward/interfaces/LockedBalance.sol";

contract MultiFeeDistributionTest is TestBase {
    using SafeERC20 for IERC20;

    MultiFeeDistribution internal multiFeeDistribution;
    ERC20Mock public loopToken;
    ERC20Mock public stakeToken;

    address internal mockPriceProvider;
    address internal mockLockZap;
    address internal mockDao;

    uint256 public rewardsDuration = 30 days;
    uint256 public rewardsLookback = 5 days;
    uint256 public lockDuration = 30 days;
    uint256 public burnRatio = 50000; // 50%
    uint256 public vestDuration = 30 days;

    function setUp() public virtual override {
        super.setUp();

        mockPriceProvider = vm.addr(uint256(keccak256("mockPriceProvider")));
        mockLockZap = vm.addr(uint256(keccak256("lockZap")));
        mockDao = vm.addr(uint256(keccak256("dao")));

        loopToken = new ERC20Mock();
        stakeToken = new ERC20Mock();

        multiFeeDistribution = MultiFeeDistribution(
            address(
                new ERC1967Proxy(
                    address(new MultiFeeDistribution()),
                    abi.encodeWithSelector(
                        MultiFeeDistribution.initialize.selector,
                        address(loopToken),
                        mockLockZap,
                        mockDao,
                        mockPriceProvider,
                        rewardsDuration,
                        rewardsLookback,
                        lockDuration,
                        burnRatio,
                        vestDuration
                    )
                )
            )
        );
    }

    function _addLockDurations() internal returns (uint256 len) {
        len = 4;
        uint256[] memory lockDurations = new uint256[](len);
        uint256[] memory rewardMultipliers = new uint256[](len);
        lockDurations[0] = 2592000;
        lockDurations[1] = 7776000;
        lockDurations[2] = 15552000;
        lockDurations[3] = 31104000;

        rewardMultipliers[0] = 1;
        rewardMultipliers[1] = 4;
        rewardMultipliers[2] = 10;
        rewardMultipliers[3] = 25;

        multiFeeDistribution.setLockTypeInfo(lockDurations, rewardMultipliers);
    }

    function test_deploy() public {
        assertNotEq(address(multiFeeDistribution), address(0));
        assertEq(address(loopToken), address(multiFeeDistribution.rdntToken()));
        assertEq(mockDao, multiFeeDistribution.daoTreasury());
        assertEq(rewardsDuration, multiFeeDistribution.rewardsDuration());
        assertEq(rewardsLookback, multiFeeDistribution.rewardsLookback());
        assertEq(lockDuration, multiFeeDistribution.defaultLockDuration());
        assertEq(burnRatio, multiFeeDistribution.burn());
        assertEq(vestDuration, multiFeeDistribution.vestDuration());
    }

    function test_setMinters(address minter1, address minter2) public {
        vm.assume(minter1 != address(0) && minter2 != address(0));
        address[] memory minters = new address[](2);
        minters[0] = minter1;
        minters[1] = minter2;

        multiFeeDistribution.setMinters(minters);
        assertTrue(multiFeeDistribution.minters(minter1));
        assertTrue(multiFeeDistribution.minters(minter2));

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x1));
        multiFeeDistribution.setMinters(minters);

        minters[0] = address(0);
        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.setMinters(minters);
    }

    function test_setBountyManager(address bountyManager) public {
        vm.assume(bountyManager != address(0));
        multiFeeDistribution.setBountyManager(bountyManager);
        assertEq(bountyManager, multiFeeDistribution.bountyManager());

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x1));
        multiFeeDistribution.setBountyManager(bountyManager);

        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.setBountyManager(address(0));
    }

    function test_addRewardConverter(address converter) public {
        vm.assume(converter != address(0));
        multiFeeDistribution.addRewardConverter(converter);
        assertEq(multiFeeDistribution.rewardConverter(), converter);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x1));
        multiFeeDistribution.addRewardConverter(converter);

        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.addRewardConverter(address(0));
    }

    function test_setLockTypeInfo() public {
        uint256 len = _addLockDurations();

        uint256[] memory lockDurations = multiFeeDistribution.getLockDurations();
        assertEq(lockDurations.length, len);
        assertEq(lockDurations[0], 2592000);
        assertEq(lockDurations[1], 7776000);
        assertEq(lockDurations[2], 15552000);
        assertEq(lockDurations[3], 31104000);

        uint256[] memory rewardMultipliers = multiFeeDistribution.getLockMultipliers();
        assertEq(rewardMultipliers.length, 4);
        assertEq(rewardMultipliers[0], 1);
        assertEq(rewardMultipliers[1], 4);
        assertEq(rewardMultipliers[2], 10);
        assertEq(rewardMultipliers[3], 25);
    }

    function test_setAddresses(address controller, address treasury) public {
        vm.assume(controller != address(0) && treasury != address(0));
        multiFeeDistribution.setAddresses(IChefIncentivesController(controller), treasury);
        assertEq(controller, address(multiFeeDistribution.incentivesController()));
        assertEq(treasury, address(multiFeeDistribution.starfleetTreasury()));

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x1));
        multiFeeDistribution.setAddresses(IChefIncentivesController(controller), treasury);

        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.setAddresses(IChefIncentivesController(address(0)), treasury);

        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.setAddresses(IChefIncentivesController(controller), address(0));
    }

    function test_setLPToken(address lpToken) public {
        vm.assume(lpToken != address(0));
        multiFeeDistribution.setLPToken(lpToken);
        assertEq(lpToken, multiFeeDistribution.stakingToken());

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x1));
        multiFeeDistribution.setLPToken(lpToken);

        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.setLPToken(address(0));

        vm.expectRevert(MultiFeeDistribution.AlreadySet.selector);
        multiFeeDistribution.setLPToken(lpToken);
    }

    function test_addReward() public {
        address rewardToken = address(0x123);

        // we are not a minter
        vm.expectRevert(MultiFeeDistribution.InsufficientPermission.selector);
        multiFeeDistribution.addReward(rewardToken);

        // add minter
        address[] memory minters = new address[](1);
        minters[0] = address(this);
        multiFeeDistribution.setMinters(minters);

        assertFalse(multiFeeDistribution.isRewardToken(rewardToken));
        // add the reward token
        multiFeeDistribution.addReward(rewardToken);
        assertTrue(multiFeeDistribution.isRewardToken(rewardToken));

        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.addReward(address(0));
    }

    function test_addReward_updatesRewardData() public {
        address rewardToken = address(0x123);
        address[] memory minters = new address[](1);
        minters[0] = address(this);
        multiFeeDistribution.setMinters(minters);
        multiFeeDistribution.addReward(rewardToken);

        (uint256 periodFinish, , uint256 lastUpdateTime, , ) = multiFeeDistribution.rewardData(rewardToken);
        assertEq(lastUpdateTime, block.timestamp);
        assertEq(periodFinish, block.timestamp);
    }

    function test_removeReward() public {
        address rewardToken = address(0x123);

        vm.expectRevert(MultiFeeDistribution.InsufficientPermission.selector);
        multiFeeDistribution.removeReward(rewardToken);

        // add minter
        address[] memory minters = new address[](1);
        minters[0] = address(this);
        multiFeeDistribution.setMinters(minters);

        multiFeeDistribution.addReward(rewardToken);
        assertTrue(multiFeeDistribution.isRewardToken(rewardToken));

        multiFeeDistribution.removeReward(rewardToken);
        assertFalse(multiFeeDistribution.isRewardToken(rewardToken));

        // token is already removed
        vm.expectRevert(MultiFeeDistribution.InvalidAddress.selector);
        multiFeeDistribution.removeReward(rewardToken);
    }

    function test_removeReward_removesRewardData(address rewardToken) public {
        vm.assume(rewardToken != address(0));
        address[] memory minters = new address[](1);
        minters[0] = address(this);
        multiFeeDistribution.setMinters(minters);
        multiFeeDistribution.addReward(rewardToken);

        multiFeeDistribution.removeReward(rewardToken);
        (
            uint256 periodFinish,
            uint256 rewardPerSecond,
            uint256 lastUpdateTime,
            uint256 rewardPerTokenStored,
            uint256 balance
        ) = multiFeeDistribution.rewardData(rewardToken);

        assertEq(periodFinish, 0);
        assertEq(rewardPerSecond, 0);
        assertEq(lastUpdateTime, 0);
        assertEq(rewardPerTokenStored, 0);
        assertEq(balance, 0);
    }

    function test_setDefaultRelockTypeIndex(address sender, uint256 index) public {
        uint256 len = _addLockDurations();
        index = index % len;

        vm.prank(sender);
        multiFeeDistribution.setDefaultRelockTypeIndex(index);
        assertEq(index, multiFeeDistribution.defaultLockIndex(sender));

        vm.expectRevert(MultiFeeDistribution.InvalidType.selector);
        vm.prank(sender);
        multiFeeDistribution.setDefaultRelockTypeIndex(len);
    }

    function test_setAutocompound(address sender, bool value, uint256 slippage) public {
        // constant could be renamed
        uint256 minSlippage = multiFeeDistribution.MAX_SLIPPAGE();

        // exclude the PERCENT_DIVISOR() value from the maxSlippage
        uint256 maxSlippage = multiFeeDistribution.PERCENT_DIVISOR() - 1;

        slippage = bound(slippage, minSlippage, maxSlippage);

        vm.prank(sender);
        multiFeeDistribution.setAutocompound(value, slippage);

        assertEq(value, multiFeeDistribution.autocompoundEnabled(sender));
        assertEq(slippage, multiFeeDistribution.userSlippage(sender));

        vm.expectRevert(MultiFeeDistribution.InvalidAmount.selector);
        vm.prank(sender);
        multiFeeDistribution.setAutocompound(value, minSlippage - 1);

        vm.expectRevert(MultiFeeDistribution.InvalidAmount.selector);
        vm.prank(sender);
        multiFeeDistribution.setAutocompound(value, maxSlippage + 1);
    }

    function test_setUserSlippage(address user, uint256 slippage) public {
        uint256 minSlippage = multiFeeDistribution.MAX_SLIPPAGE();
        uint256 maxSlippage = multiFeeDistribution.PERCENT_DIVISOR() - 1;
        slippage = bound(slippage, minSlippage, maxSlippage);

        vm.prank(user);
        multiFeeDistribution.setUserSlippage(slippage);
        assertEq(slippage, multiFeeDistribution.userSlippage(user));

        vm.expectRevert(MultiFeeDistribution.InvalidAmount.selector);
        vm.prank(user);
        multiFeeDistribution.setUserSlippage(minSlippage - 1);

        vm.expectRevert(MultiFeeDistribution.InvalidAmount.selector);
        vm.prank(user);
        multiFeeDistribution.setUserSlippage(maxSlippage + 1);
    }

    function test_toggleAutocompound(address sender) public {
        vm.prank(sender);
        multiFeeDistribution.toggleAutocompound();
        assertTrue(multiFeeDistribution.autocompoundEnabled(sender));

        vm.prank(sender);
        multiFeeDistribution.toggleAutocompound();
        assertFalse(multiFeeDistribution.autocompoundEnabled(sender));
    }

    function test_setRelock(address sender, bool status) public {
        vm.prank(sender);
        multiFeeDistribution.setRelock(status);
        assertEq(status, !multiFeeDistribution.autoRelockDisabled(sender));
    }

    function test_setLookback(uint256 lookback) public {
        uint256 duration = multiFeeDistribution.rewardsDuration();
        lookback = bound(lookback, 1, duration);

        multiFeeDistribution.setLookback(lookback);
        assertEq(lookback, multiFeeDistribution.rewardsLookback());

        vm.expectRevert(MultiFeeDistribution.InvalidLookback.selector);
        multiFeeDistribution.setLookback(duration + 1);

        vm.expectRevert(MultiFeeDistribution.AmountZero.selector);
        multiFeeDistribution.setLookback(0);

        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        multiFeeDistribution.setLookback(lookback);
    }

    function test_setOperationExpenses(address receiver, uint256 expenseRatio) public {
        vm.assume(receiver != address(0));
        uint256 maxRatio = multiFeeDistribution.RATIO_DIVISOR();
        expenseRatio = bound(expenseRatio, 0, maxRatio);

        multiFeeDistribution.setOperationExpenses(receiver, expenseRatio);
        assertEq(expenseRatio, multiFeeDistribution.operationExpenseRatio());
        assertEq(receiver, multiFeeDistribution.operationExpenseReceiver());

        vm.expectRevert(MultiFeeDistribution.InvalidRatio.selector);
        multiFeeDistribution.setOperationExpenses(receiver, maxRatio + 1);

        vm.expectRevert(MultiFeeDistribution.AddressZero.selector);
        multiFeeDistribution.setOperationExpenses(address(0), expenseRatio);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x1));
        multiFeeDistribution.setOperationExpenses(receiver, expenseRatio);
    }

    function test_stake(address onBehalfOf, uint256 typeIndex) public {
        uint256 amount = 10 ether;
        uint256 len = _addLockDurations();
        typeIndex = typeIndex % len;
        vm.assume(onBehalfOf != address(0));

        stakeToken.mint(address(this), amount);
        multiFeeDistribution.setLPToken(address(stakeToken));

        address incentivesController = vm.addr(uint256(keccak256("incentivesController")));
        address treasury = vm.addr(uint256(keccak256("treasury")));
        multiFeeDistribution.setAddresses(IChefIncentivesController(incentivesController), treasury);

        vm.mockCall(
            incentivesController,
            abi.encodeWithSelector(IChefIncentivesController.afterLockUpdate.selector, onBehalfOf),
            abi.encode(true)
        );

        stakeToken.approve(address(multiFeeDistribution), amount);
        multiFeeDistribution.stake(amount, onBehalfOf, typeIndex);
    }

    function test_vestTokens(address user, uint256 amount, bool withPenalty) public {
        vm.assume(user != address(0));
        amount = amount % 1000 ether;
        loopToken.mint(address(this), amount);
        loopToken.approve(address(multiFeeDistribution), amount);

        vm.expectRevert(MultiFeeDistribution.InsufficientPermission.selector);
        multiFeeDistribution.vestTokens(user, amount, withPenalty);

        address[] memory minters = new address[](1);
        minters[0] = address(this);
        multiFeeDistribution.setMinters(minters);
        multiFeeDistribution.vestTokens(user, amount, withPenalty);
    }
}
