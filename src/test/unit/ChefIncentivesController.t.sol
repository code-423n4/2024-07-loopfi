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
import {IMultiFeeDistribution} from "../../reward/interfaces/IMultiFeeDistribution.sol";
import {IPriceProvider} from "../../reward/interfaces/IPriceProvider.sol";
import {IChefIncentivesController} from "../../reward/interfaces/IChefIncentivesController.sol";
import {IEligibilityDataProvider} from "../../reward/interfaces/IEligibilityDataProvider.sol";
import {EligibilityDataProvider} from "../../reward/EligibilityDataProvider.sol";
import {ChefIncentivesController} from "../../reward/ChefIncentivesController.sol";

contract ChefIncentivesControllerTest is TestBase {
    ChefIncentivesController public incentivesController;
    ERC20Mock public loopToken;

    address public mockEligibilityDataProvider;
    address public mockMultiFeeDistribution;

    uint256 public rewardsPerSecond = 0.01 ether;
    uint256 public endingTimeCadence = 2 days;

    function setUp() public virtual override {
        super.setUp();
        loopToken = new ERC20Mock();
        mockEligibilityDataProvider = vm.addr(uint256(keccak256("mockEligibilityDataProvider")));
        mockMultiFeeDistribution = vm.addr(uint256(keccak256("mockMultiFeeDistribution")));

        incentivesController = ChefIncentivesController(
            address(
                new ERC1967Proxy(
                    address(new ChefIncentivesController()),
                    abi.encodeWithSelector(
                        ChefIncentivesController.initialize.selector,
                        address(this),
                        mockEligibilityDataProvider,
                        IMultiFeeDistribution(mockMultiFeeDistribution),
                        rewardsPerSecond,
                        address(loopToken),
                        endingTimeCadence
                    )
                )
            )
        );

        vm.label(mockEligibilityDataProvider, "mockEligibilityDataProvider");
        vm.label(mockMultiFeeDistribution, "mockMultiFeeDistribution");
        vm.label(address(incentivesController), "incentivesController");
        vm.label(address(loopToken), "loopToken");
    }

    function _excludeContracts(address contract_) internal view {
        vm.assume(
            contract_ != mockEligibilityDataProvider &&
                contract_ != mockMultiFeeDistribution &&
                contract_ != address(incentivesController) &&
                contract_ != address(loopToken) &&
                contract_ != address(0)
        );
    }

    function test_deploy() public {
        assertEq(incentivesController.owner(), address(this));
        assertEq(address(incentivesController.eligibleDataProvider()), mockEligibilityDataProvider);
        assertEq(address(incentivesController.mfd()), mockMultiFeeDistribution);
        assertEq(incentivesController.rewardsPerSecond(), rewardsPerSecond);
        assertEq(incentivesController.rdntToken(), address(loopToken));
        assertTrue(incentivesController.persistRewardsPerSecond());
    }

    function test_poolLength() public {
        assertEq(incentivesController.poolLength(), 0);
    }

    function test_setBountyManager(address bountyManager) public {
        _excludeContracts(bountyManager);
        incentivesController.setBountyManager(bountyManager);
        assertEq(incentivesController.bountyManager(), bountyManager);

        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.setBountyManager(bountyManager);
    }

    function test_setEligibilityMode() public {
        ChefIncentivesController.EligibilityModes mode = ChefIncentivesController.EligibilityModes.FULL;
        incentivesController.setEligibilityMode(mode);
        assertEq(uint256(incentivesController.eligibilityMode()), uint256(mode));

        mode = ChefIncentivesController.EligibilityModes.LIMITED;
        incentivesController.setEligibilityMode(mode);
        assertEq(uint256(incentivesController.eligibilityMode()), uint256(mode));

        mode = ChefIncentivesController.EligibilityModes.DISABLED;
        incentivesController.setEligibilityMode(mode);
        assertEq(uint256(incentivesController.eligibilityMode()), uint256(mode));

        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.setEligibilityMode(mode);
    }

    function test_start() public {
        assertEq(incentivesController.startTime(), 0);

        incentivesController.start();

        assertEq(incentivesController.startTime(), block.timestamp);

        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.start();

        vm.expectRevert(ChefIncentivesController.AlreadyStarted.selector);
        incentivesController.start();
    }

    function test_addPool(address token, uint256 allocPoint) public {
        _excludeContracts(token);
        assertEq(incentivesController.poolLength(), 0);
        incentivesController.addPool(token, allocPoint);
        assertEq(incentivesController.poolLength(), 1);
        (
            uint256 totalSupply,
            uint256 _allocPoint,
            uint256 lastRewardTime,
            uint256 accRewardPerShare
        ) = incentivesController.vaultInfo(token);

        assertEq(totalSupply, 0);
        assertEq(_allocPoint, allocPoint);
        assertEq(lastRewardTime, block.timestamp);
        assertEq(accRewardPerShare, 0);

        vm.prank(address(0x1));
        vm.expectRevert(ChefIncentivesController.NotAllowed.selector);
        incentivesController.addPool(token, allocPoint);

        vm.expectRevert(ChefIncentivesController.PoolExists.selector);
        incentivesController.addPool(token, allocPoint);

        assertEq(incentivesController.totalAllocPoint(), allocPoint);
    }

    function test_addPool_multiple() public {
        uint256 totalAllocPoint = 1000;

        incentivesController.addPool(address(0x1), totalAllocPoint / 2);
        incentivesController.addPool(address(0x2), totalAllocPoint / 2);

        assertEq(incentivesController.poolLength(), 2);
        assertEq(incentivesController.totalAllocPoint(), totalAllocPoint);
    }

    function test_batchUpdateAllocPoint() public {
        uint256 totalAllocPoint = 1000;
        address vault1 = address(0x1);
        address vault2 = address(0x2);
        incentivesController.addPool(vault1, totalAllocPoint / 2);
        incentivesController.addPool(vault2, totalAllocPoint / 2);

        assertEq(incentivesController.totalAllocPoint(), totalAllocPoint);

        address[] memory vaults = new address[](2);
        vaults[0] = vault1;
        vaults[1] = vault2;
        uint256[] memory allocPoints = new uint256[](2);
        allocPoints[0] = totalAllocPoint / 4;
        allocPoints[1] = totalAllocPoint / 4;

        incentivesController.batchUpdateAllocPoint(vaults, allocPoints);

        assertEq(incentivesController.totalAllocPoint(), totalAllocPoint / 2);

        (
            uint256 totalSupply,
            uint256 _allocPoint,
            uint256 lastRewardTime,
            uint256 accRewardPerShare
        ) = incentivesController.vaultInfo(address(0x1));

        assertEq(_allocPoint, totalAllocPoint / 4);

        (totalSupply, _allocPoint, lastRewardTime, accRewardPerShare) = incentivesController.vaultInfo(address(0x2));

        assertEq(_allocPoint, totalAllocPoint / 4);

        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.batchUpdateAllocPoint(vaults, allocPoints);

        vaults = new address[](1);
        vaults[0] = vault1;

        vm.expectRevert(ChefIncentivesController.ArrayLengthMismatch.selector);
        incentivesController.batchUpdateAllocPoint(vaults, allocPoints);
    }

    function test_setRewardsPerSecond(uint256 rewardPerSecond, bool persist) public {
        incentivesController.setRewardsPerSecond(rewardPerSecond, persist);
        assertEq(incentivesController.rewardsPerSecond(), rewardPerSecond);
        assertEq(incentivesController.persistRewardsPerSecond(), persist);

        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.setRewardsPerSecond(rewardPerSecond, persist);
    }

    function test_setEmissionSchedule() public {
        uint256[] memory startTimeOffets = new uint256[](3);
        startTimeOffets[0] = 0;
        startTimeOffets[1] = block.timestamp + 1 days;
        startTimeOffets[2] = block.timestamp + 2 days;
        uint256[] memory rewardsPerSeconds = new uint256[](3);
        rewardsPerSeconds[0] = 0.01 ether;
        rewardsPerSeconds[1] = 0.02 ether;
        rewardsPerSeconds[2] = 0.03 ether;

        incentivesController.setEmissionSchedule(startTimeOffets, rewardsPerSeconds);

        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.setEmissionSchedule(startTimeOffets, rewardsPerSeconds);

        startTimeOffets[0] = uint256(type(uint128).max) + 1;
        vm.expectRevert(ChefIncentivesController.ExceedsMaxInt.selector);
        incentivesController.setEmissionSchedule(startTimeOffets, rewardsPerSeconds);
        startTimeOffets[0] = 0;

        rewardsPerSeconds[0] = uint256(type(uint128).max) + 1;
        vm.expectRevert(ChefIncentivesController.ExceedsMaxInt.selector);
        incentivesController.setEmissionSchedule(startTimeOffets, rewardsPerSeconds);
        rewardsPerSeconds[0] = 0.01 ether;

        vm.expectRevert(ChefIncentivesController.DuplicateSchedule.selector);
        incentivesController.setEmissionSchedule(startTimeOffets, rewardsPerSeconds);

        startTimeOffets = new uint256[](2);
        startTimeOffets[0] = block.timestamp + 4 days;
        startTimeOffets[1] = block.timestamp + 3 days;

        rewardsPerSeconds = new uint256[](2);
        rewardsPerSeconds[0] = 0.01 ether;
        rewardsPerSeconds[1] = 0.02 ether;

        vm.expectRevert(ChefIncentivesController.NotAscending.selector);
        incentivesController.setEmissionSchedule(startTimeOffets, rewardsPerSeconds);

        startTimeOffets = new uint256[](2);
        rewardsPerSeconds = new uint256[](1);

        vm.expectRevert(ChefIncentivesController.ArrayLengthMismatch.selector);
        incentivesController.setEmissionSchedule(startTimeOffets, rewardsPerSeconds);
    }

    function test_recoverERC20( uint256 tokenAmount) public {
        address tokenAddress = address(0x1);
        _excludeContracts(tokenAddress);

        vm.mockCall(
            tokenAddress,
            abi.encodeWithSelector(IERC20.transfer.selector, address(this), tokenAmount),
            abi.encode(true)
        );
        incentivesController.recoverERC20(tokenAddress, tokenAmount);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x1));
        incentivesController.recoverERC20(tokenAddress, tokenAmount);
    }

    function test_pendingRewards(address user) public {
        _excludeContracts(user);
        address vault = address(0x1);
        uint256 totalAllocPoint = 1000;
        incentivesController.addPool(vault, totalAllocPoint);

        address[] memory vaults = new address[](1);
        vaults[0] = vault;

        uint256[] memory rewards = incentivesController.pendingRewards(user, vaults);
        assertEq(rewards.length, 1);
        assertEq(rewards[0], 0);
    }

    function test_claim(address user) public {
        _excludeContracts(user);

        address vault = address(0x1);
        uint256 totalAllocPoint = 1000;
        incentivesController.addPool(vault, totalAllocPoint);

        loopToken.mint(address(incentivesController), 1000 ether);
        uint256 rewardAmount = 1000 ether;
        incentivesController.registerRewardDeposit(rewardAmount);

        incentivesController.start();

        vm.warp(block.timestamp + 30 days);

        address[] memory vaults = new address[](1);
        vaults[0] = vault;

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.isEligibleForRewards.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.getDqTime.selector, user),
            abi.encode(0)
        );

        vm.expectRevert(ChefIncentivesController.NothingToVest.selector);
        incentivesController.claim(user, vaults);

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(IEligibilityDataProvider.lastEligibleStatus.selector, user),
            abi.encode(true)
        );
        vm.prank(vault);
        incentivesController.handleActionAfter(user, 500 ether, 1000 ether);

        vm.warp(block.timestamp + 30 days);

        vm.mockCall(
            mockMultiFeeDistribution,
            abi.encodeWithSelector(IMultiFeeDistribution.vestTokens.selector, user, 1000 ether),
            abi.encode(true)
        );
        incentivesController.claim(user, vaults);
    }

    function test_setEligibilityExempt(address contract_, bool value) public {
        _excludeContracts(contract_);
        incentivesController.setEligibilityExempt(contract_, value);
        assertEq(incentivesController.eligibilityExempt(contract_), value);

        address caller = address(0x1);
        vm.prank(caller);
        vm.expectRevert(ChefIncentivesController.InsufficientPermission.selector);
        incentivesController.setEligibilityExempt(contract_, value);

        incentivesController.setContractAuthorization(caller, true);

        vm.prank(caller);
        incentivesController.setEligibilityExempt(contract_, value);

        incentivesController.setEligibilityMode(ChefIncentivesController.EligibilityModes.LIMITED);
        address caller2 = address(0x2);
        vm.prank(caller2);
        // Eligibility checks for the setEligibilityExempt are skipped if the mode is not FULL
        incentivesController.setEligibilityExempt(contract_, value);
    }

    function test_setContractAuthorization(address contract_) public {
        _excludeContracts(contract_);
        bool value = !incentivesController.authorizedContracts(contract_);
        incentivesController.setContractAuthorization(contract_, value);
        assertEq(incentivesController.authorizedContracts(contract_), value);

        address caller = address(0x1);
        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.setContractAuthorization(contract_, value);

        vm.expectRevert(ChefIncentivesController.AuthorizationAlreadySet.selector);
        incentivesController.setContractAuthorization(contract_, value);
    }

    function test_handleActionAfter_calledByVault(address user, uint256 balance, uint256 totalSupply) public {
        _excludeContracts(user);
        address vault = address(0x1);
        uint256 totalAllocPoint = 1000;
        incentivesController.addPool(vault, totalAllocPoint);

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(IEligibilityDataProvider.lastEligibleStatus.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(true)
        );

        balance = bound(balance, 0, totalSupply);
        vm.prank(vault);
        incentivesController.handleActionAfter(user, balance, totalSupply);
    }

    function test_handleActionAfter_calledByMFD(address user, uint256 balance, uint256 totalSupply) public {
        _excludeContracts(user);

        address vault = address(0x1);
        uint256 totalAllocPoint = 1000;
        incentivesController.addPool(vault, totalAllocPoint);

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(IEligibilityDataProvider.lastEligibleStatus.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(true)
        );

        balance = bound(balance, 0, totalSupply);

        vm.expectRevert(ChefIncentivesController.UnknownPool.selector);
        vm.prank(mockMultiFeeDistribution);
        incentivesController.handleActionAfter(user, balance, totalSupply);

        // simulate non eligible user
        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(false)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.getDqTime.selector, user),
            abi.encode(block.timestamp)
        );

        vm.prank(mockMultiFeeDistribution);
        incentivesController.handleActionAfter(user, balance, totalSupply);
    }

    function test_handleActionAfter_calledByOther(address user) public {
        _excludeContracts(user);
        address caller = address(0x1);
        vm.prank(caller);
        vm.expectRevert(ChefIncentivesController.NotRTokenOrMfd.selector);
        incentivesController.handleActionAfter(user, 0, 0);
    }

    function test_afterLockUpdate(address user) public {
        _excludeContracts(user);
        vm.expectRevert(ChefIncentivesController.NotMFD.selector);
        incentivesController.afterLockUpdate(user);

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(true)
        );
        vm.prank(mockMultiFeeDistribution);
        incentivesController.afterLockUpdate(user);

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(false)
        );
        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.getDqTime.selector, user),
            abi.encode(block.timestamp)
        );
        vm.prank(mockMultiFeeDistribution);
        incentivesController.afterLockUpdate(user);
    }

    function test_hasEligibleDeposits(address user, uint256 balance, uint256 totalSupply) public {
        _excludeContracts(user);
        vm.assume(totalSupply > 1);
        address vault = address(0x1);
        uint256 totalAllocPoint = 1000;
        incentivesController.addPool(vault, totalAllocPoint);

        bool hasEligibleDeposits = incentivesController.hasEligibleDeposits(user);
        assertFalse(hasEligibleDeposits);

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(IEligibilityDataProvider.lastEligibleStatus.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(true)
        );

        balance = bound(balance, 1, totalSupply);
        vm.prank(vault);
        incentivesController.handleActionAfter(user, balance, totalSupply);

        hasEligibleDeposits = incentivesController.hasEligibleDeposits(user);
        assertTrue(hasEligibleDeposits);
    }

    function test_claimBounty(address user) public {
        _excludeContracts(user);
        address vault = address(0x1);
        uint256 totalAllocPoint = 1000;
        incentivesController.addPool(vault, totalAllocPoint);

        address bountyManager = address(0x1);
        incentivesController.setBountyManager(bountyManager);

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(IEligibilityDataProvider.lastEligibleStatus.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.getDqTime.selector, user),
            abi.encode(0)
        );

        vm.prank(bountyManager);
        bool issueBounty = incentivesController.claimBounty(user, true);
        assertFalse(issueBounty);

        vm.prank(vault);
        incentivesController.handleActionAfter(user, 100 ether, 100 ether);

        assertTrue(incentivesController.hasEligibleDeposits(user));

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(IEligibilityDataProvider.lastEligibleStatus.selector, user),
            abi.encode(true)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.refresh.selector, user),
            abi.encode(false)
        );

        vm.mockCall(
            mockEligibilityDataProvider,
            abi.encodeWithSelector(EligibilityDataProvider.getDqTime.selector, user),
            abi.encode(0)
        );

        vm.prank(bountyManager);
        // user was eligible but is no longer eligible and was not disqualified yet
        issueBounty = incentivesController.claimBounty(user, true);
        assertTrue(issueBounty);
    }

    function test_pause() public {
        incentivesController.pause();
        assertTrue(incentivesController.paused());
        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.pause();
    }

    function test_unpause() public {
        incentivesController.pause();
        assertTrue(incentivesController.paused());
        incentivesController.unpause();
        assertFalse(incentivesController.paused());
        vm.prank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        incentivesController.unpause();
    }
}
