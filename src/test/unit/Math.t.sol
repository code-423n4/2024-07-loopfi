// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {WAD, add, wmul, wdiv, Math__add_overflow_signed, Math__mul_overflow, Math__div_overflow} from "../../utils/Math.sol";

// Wrapper contract to allow us to use try catch while fuzzing
contract Wrapper {
    function _add(uint256 x, int256 y) external pure returns (uint256) {
        return add(x, y);
    }

    function _wmul(uint256 x, uint256 y) external pure returns (uint256) {
        return wmul(x, y);
    }

    function _wdiv(uint256 x, uint256 y) external pure returns (uint256) {
        return wdiv(x, y);
    }
}

contract MathTest is Test {
    Wrapper wrapper;

    function setUp() public {
        wrapper = new Wrapper();
    }

    function test_add(uint256 x, int256 y) public {
        try wrapper._add(x, y) returns (uint256 z) {
            uint256 expected;
            assembly {
                expected := add(x, y)
            }
            assertEq(z, expected);
        } catch {
            vm.expectRevert(Math__add_overflow_signed.selector);
            add(x, y);
        }
    }

    function test_wmul(uint256 x, uint256 y) public {
        try wrapper._wmul(x, y) returns (uint256 z) {
            assertEq(z, (x * y) / WAD);
        } catch {
            vm.expectRevert(Math__mul_overflow.selector);
            wmul(x, y);
        }
    }

    function test_wdiv(uint256 x, uint256 y) public {
        if (y == 0) return; // don't allow divide by zero

        try wrapper._wdiv(x, y) returns (uint256 z) {
            assertEq(z, (x * WAD) / y);
        } catch {
            vm.expectRevert(Math__div_overflow.selector);
            wdiv(x, y);
        }
    }
}
