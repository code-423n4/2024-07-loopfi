// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {PRBProxyRegistry} from "prb-proxy/PRBProxyRegistry.sol";
import {PRBProxy} from "prb-proxy/PRBProxy.sol";

import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

import {PermitMaker} from "../utils/PermitMaker.sol";

import {TransferAction, ApprovalType, PermitParams} from "../../proxy/TransferAction.sol";

import {console2 as console} from "forge-std/console2.sol";

contract TransferActionWrapper is TransferAction {

    function transferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount,
        PermitParams memory params
    ) external {
        _transferFrom(address(token), from, to, amount, params);
    }
}

contract TransferActionTest is Test {
    using SafeERC20 for ERC20;
    using SafeERC20 for ERC20Permit;

    ERC20 constant internal DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ERC20 constant internal WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20Permit constant internal USDC = ERC20Permit(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20Permit constant internal USDT = ERC20Permit(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    ISignatureTransfer permit2 = ISignatureTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    TransferActionWrapper wrapper;

    uint256 userPk;
    address user;

    PRBProxy userProxy;
    PRBProxy proxy;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 17055414); // 15/04/2023 20:43:00 UTC

        wrapper = new TransferActionWrapper();

        // make users
        (user, userPk) = makeAddrAndKey("user");

        // deploy proxies
        PRBProxyRegistry prbProxyRegistry = new PRBProxyRegistry();
        userProxy = PRBProxy(payable(address(prbProxyRegistry.deployFor(user))));
        proxy = PRBProxy(payable(address(prbProxyRegistry.deploy())));

    }

    function test_standard_transferFrom() public {
        deal(address(DAI), address(this), 100 ether);
        DAI.approve(address(proxy), 100 ether);

        PermitParams memory params;
        proxy.execute(
            address(wrapper),
            abi.encodeWithSelector(
                wrapper.transferFrom.selector,
                DAI,
                address(this),
                address(proxy),
                100 ether,
                params
            )
        );

        assertEq(DAI.balanceOf(address(this)), 0);
        assertEq(DAI.balanceOf(address(proxy)), 100 ether);
    }

    function test_permit_transferFrom() public {
        uint256 amount = 100 * 1e6;
        uint256 nonce = USDC.nonces(user);
        uint256 deadline = block.timestamp + 100;

        deal(address(USDC), address(user), amount);

        (uint8 v, bytes32 r, bytes32 s) = PermitMaker.getPermitTransferFromSignature(
            address(USDC),
            address(userProxy),
            amount,
            nonce,
            deadline,
            userPk
        );

        PermitParams memory params = PermitParams({
            approvalType: ApprovalType.PERMIT,
            approvalAmount: amount,
            nonce: nonce,
            deadline: deadline,
            v: v,
            r: r,
            s: s
        });

        vm.prank(user);
        userProxy.execute(
            address(wrapper),
            abi.encodeWithSelector(
                wrapper.transferFrom.selector,
                USDC,
                address(user),
                address(userProxy),
                amount,
                params
            )
        );

        assertEq(USDC.balanceOf(user), 0);
        assertEq(USDC.balanceOf(address(userProxy)), amount);
        assertEq(USDC.nonces(user), nonce + 1);
    }

    function test_permit_transferFrom_max_approval() public {
        uint256 amount = 100 * 1e6;
        uint256 approvalAmount = type(uint256).max;
        uint256 nonce = USDC.nonces(user);
        uint256 deadline = block.timestamp + 100;

        deal(address(USDC), address(user), amount);

        (uint8 v, bytes32 r, bytes32 s) = PermitMaker.getPermitTransferFromSignature(
            address(USDC),
            address(userProxy),
            approvalAmount,
            nonce,
            deadline,
            userPk
        );

        PermitParams memory params = PermitParams({
            approvalType: ApprovalType.PERMIT,
            approvalAmount: approvalAmount,
            nonce: nonce,
            deadline: deadline,
            v: v,
            r: r,
            s: s
        });

        vm.prank(user);
        userProxy.execute(
            address(wrapper),
            abi.encodeWithSelector(
                wrapper.transferFrom.selector,
                USDC,
                address(user),
                address(userProxy),
                amount,
                params
            )
        );

        assertEq(USDC.balanceOf(user), 0);
        assertEq(USDC.balanceOf(address(userProxy)), amount);
        assertEq(USDC.nonces(user), nonce + 1);
    }

    function test_permit2_transferFrom() public {
        uint256 amount = 100 ether;
        uint256 nonceWord = 0xF1A7;
        uint256 nonce = nonceWord << 8;
        uint256 deadline = block.timestamp + 100;

        deal(address(WETH), address(user), amount);

        vm.prank(user);
        WETH.approve(address(permit2), type(uint256).max);

        (uint8 v, bytes32 r, bytes32 s) = PermitMaker.getPermit2TransferFromSignature(
            address(WETH),
            address(userProxy),
            amount,
            nonce,
            deadline,
            userPk
        );

        PermitParams memory params = PermitParams({
            approvalType: ApprovalType.PERMIT2,
            approvalAmount: amount,
            nonce: nonce,
            deadline: deadline,
            v: v,
            r: r,
            s: s
        });

        vm.prank(user);
        userProxy.execute(
            address(wrapper),
            abi.encodeWithSelector(
                wrapper.transferFrom.selector,
                WETH,
                address(user),
                address(userProxy),
                amount,
                params
            )
        );

        assertEq(WETH.balanceOf(user), 0);
        assertEq(WETH.balanceOf(address(userProxy)), amount);
        assertEq(permit2.nonceBitmap(user, nonceWord), 1);
    }

    function test_permit2_transferFrom_max_approval() public {
        uint256 amount = 100 ether;
        uint256 approvalAmount = type(uint256).max;
        uint256 nonceWord = 0xF1A7;
        uint256 nonce = nonceWord << 8;
        uint256 deadline = block.timestamp + 100;

        deal(address(WETH), address(user), amount);

        vm.prank(user);
        WETH.approve(address(permit2), type(uint256).max);

        (uint8 v, bytes32 r, bytes32 s) = PermitMaker.getPermit2TransferFromSignature(
            address(WETH),
            address(userProxy),
            approvalAmount,
            nonce,
            deadline,
            userPk
        );

        PermitParams memory params = PermitParams({
            approvalType: ApprovalType.PERMIT2,
            approvalAmount: approvalAmount,
            nonce: nonce,
            deadline: deadline,
            v: v,
            r: r,
            s: s
        });

        vm.prank(user);
        userProxy.execute(
            address(wrapper),
            abi.encodeWithSelector(
                wrapper.transferFrom.selector,
                WETH,
                address(user),
                address(userProxy),
                amount,
                params
            )
        );

        assertEq(WETH.balanceOf(user), 0);
        assertEq(WETH.balanceOf(address(userProxy)), amount);
        assertEq(permit2.nonceBitmap(user, nonceWord), 1);
    }


}