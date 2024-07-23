// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {Permission} from "../../utils/Permission.sol";

contract PermissionedContract is Permission {}

contract PermissionTest is Test {
    PermissionedContract permission;

    address user;
    address otherUser;

    function setUp() public {
        user = makeAddr("user");
        otherUser = makeAddr("otherUser");
        permission = new PermissionedContract();
    }

    function test_modifyPermission() public {
        permission.modifyPermission(user, true);
        assertEq(permission.hasPermission(address(this), user), true);

        permission.modifyPermission(user, false);
        assertEq(permission.hasPermission(address(this), user), false);
    }

    function test_modifyPermission2() public {
        permission.modifyPermission(address(this), user, true);
        assertEq(permission.hasPermission(address(this), user), true);

        permission.modifyPermission(address(this), user, false);
        assertEq(permission.hasPermission(address(this), user), false);
    }

    function test_modifyPermission2_with_permitted_agent() public {
        permission.setPermissionAgent(user, true);

        vm.prank(user);
        permission.modifyPermission(address(this), otherUser, true);
        assertEq(permission.hasPermission(address(this), otherUser), true);

        vm.prank(user);
        permission.modifyPermission(address(this), otherUser, false);
        assertEq(permission.hasPermission(address(this), otherUser), false);
    }

    function test_fail_modifyPermission2_without_permitted_agent() public {
        vm.expectRevert(Permission.Permission__modifyPermission_notPermitted.selector);
        vm.prank(user);
        permission.modifyPermission(address(this), otherUser, true);
    }

    function test_hasPermission() public {
        assertEq(permission.hasPermission(address(this), address(this)), true);
        assertEq(permission.hasPermission(address(this), user), false);
    }
}
