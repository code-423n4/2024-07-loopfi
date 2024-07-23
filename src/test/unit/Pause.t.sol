// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {Pause, PAUSER_ROLE} from "../../utils/Pause.sol";

// Pausable contract for testing
contract PausableContract is Pause {
    constructor(address pauser) {
        _grantRole(PAUSER_ROLE, pauser);
    }
}

contract PauseTest is Test {
    PausableContract public pausableContract;

    function setUp() public {
        pausableContract = new PausableContract(address(this));
    }

    function test_deploy() public {
        assertTrue(address(pausableContract) != address(0));
    }

    function test_pause() public {
        pausableContract.pause();
        assertTrue(pausableContract.paused());
    }

    function test_pause_updateTimestamp() public {
        pausableContract.pause();
        assertEq(pausableContract.pausedAt(), block.timestamp);
    }

    function test_pause_onlyPauser() public {
        address unauthorizedUser = address(0x1234);
        vm.prank(unauthorizedUser);
        vm.expectRevert();
        pausableContract.pause();
    }

    function test_pause_revertIfPaused() public {
        pausableContract.pause();
        vm.expectRevert();
        pausableContract.pause();
    }

    function test_unpause() public {
        pausableContract.pause();
        pausableContract.unpause();
        assertTrue(!pausableContract.paused());
    }

    function test_unpause_updateTimestamp() public {
        pausableContract.pause();
        pausableContract.unpause();
        assertEq(pausableContract.pausedAt(), 0);
    }

    function test_unpause_revertIfNotPaused() public {
        vm.expectRevert();
        pausableContract.unpause();
    }

    function test_unpause_onlyPauser() public {
        pausableContract.pause();
        address unauthorizedUser = address(0x1234);
        vm.prank(unauthorizedUser);
        vm.expectRevert();
        pausableContract.unpause();
    }
}
