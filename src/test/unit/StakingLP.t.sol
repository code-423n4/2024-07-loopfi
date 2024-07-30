// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {TestBase, ERC20PresetMinterPauser} from "../TestBase.sol";

import {console} from "forge-std/console.sol";
import {StakingLPEth} from "src/StakingLPEth.sol";

contract StakingLPEthTest is TestBase {
    address user1 = address(0x23);
    address user2 = address(0x24);
    address user3 = address(0x25);

    function setUp() public override {
        super.setUp();
        liquidityPool.transfer(user1, 0.1 ether);
        liquidityPool.transfer(user2, 0.1 ether);
        liquidityPool.transfer(user3, 0.1 ether);
        stakingLpEth.setCooldownDuration(0);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function test_deploy() public {
        assertEq(stakingLpEth.decimals(), 18);
        assertEq(stakingLpEth.totalSupply(), 0);
        assertEq(stakingLpEth.asset(), address(liquidityPool));
        assertEq(stakingLpEth.name(), "StakingLPEth");
        assertEq(stakingLpEth.symbol(), "sLP-ETH");
    }

    function _sendRewards() private {
        uint256 amount = 0.1 ether;
        liquidityPool.transfer(address(stakingLpEth), amount);
    }

    function test_deposit_user1() public {
        vm.startPrank(user1);
        liquidityPool.approve(address(stakingLpEth), 0.1 ether);
        stakingLpEth.deposit(0.1 ether, user1);
        vm.stopPrank();
        assertEq(stakingLpEth.balanceOf(user1), 0.1 ether);
        assertEq(stakingLpEth.totalSupply(), 0.1 ether);
        assertEq(liquidityPool.balanceOf(address(stakingLpEth)), 0.1 ether);
        assertEq(liquidityPool.balanceOf(user1), 0);
    }

    function test_rewards_1_user() public {
        test_deposit_user1();
        _sendRewards();
        vm.startPrank(user1);
        stakingLpEth.approve(address(stakingLpEth), 0.1 ether);
        stakingLpEth.redeem(0.1 ether, user1, user1);
        assertApproxEqAbs(liquidityPool.balanceOf(user1), 0.2 ether, 1);
    }

    function test_deposit_2_users() public {
        test_deposit_user1();
        vm.startPrank(user2);
        liquidityPool.approve(address(stakingLpEth), 0.1 ether);
        stakingLpEth.deposit(0.1 ether, user2);
        vm.stopPrank();
        assertEq(stakingLpEth.balanceOf(user2), 0.1 ether);
    }

    function test_rewards_2_users() public {
        test_deposit_user1();
        _sendRewards();
        // User 2 deposits after some rewards are already present, receives less shares
        vm.startPrank(user2);
        liquidityPool.approve(address(stakingLpEth), 0.1 ether);
        stakingLpEth.deposit(0.1 ether, user2);
        vm.stopPrank();
        assertEq(stakingLpEth.balanceOf(user2), 0.05 ether);

        _sendRewards();
        vm.startPrank(user1);
        stakingLpEth.approve(address(stakingLpEth), 0.1 ether);
        stakingLpEth.redeem(0.1 ether, user1, user1);
        vm.stopPrank();
        assertApproxEqAbs(liquidityPool.balanceOf(user1), 0.266666666666666666 ether, 1);

        vm.startPrank(user2);
        stakingLpEth.approve(address(stakingLpEth), 0.05 ether);
        stakingLpEth.redeem(0.05 ether, user2, user2);
        vm.stopPrank();
        assertApproxEqAbs(liquidityPool.balanceOf(user2), 0.133333333333333333 ether, 1);
    }

    function test_cooldown_withdraw() public {
        stakingLpEth.setCooldownDuration(7 days);
        test_deposit_user1();
        _sendRewards();
        vm.startPrank(user1);
        stakingLpEth.cooldownShares(stakingLpEth.balanceOf(user1));
        vm.expectRevert(StakingLPEth.InvalidCooldown.selector);
        stakingLpEth.unstake(user1);
        vm.warp(block.timestamp + 7 days);
        stakingLpEth.unstake(user1);
        assertApproxEqAbs(liquidityPool.balanceOf(user1), 0.199999999999999999 ether, 1);
    }

    function test_cooldown_redeem() public {
        stakingLpEth.setCooldownDuration(7 days);
        test_deposit_user1();
        _sendRewards();
        vm.startPrank(user1);
        stakingLpEth.cooldownAssets(stakingLpEth.previewRedeem(stakingLpEth.balanceOf(user1)));
        vm.expectRevert(StakingLPEth.InvalidCooldown.selector);
        stakingLpEth.unstake(user1);
        vm.warp(block.timestamp + 7 days);
        stakingLpEth.unstake(user1);
        assertApproxEqAbs(liquidityPool.balanceOf(user1), 0.199999999999999999 ether, 1);
    }
}
