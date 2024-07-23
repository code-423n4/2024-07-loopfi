// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

import {PRBProxy} from "prb-proxy/PRBProxy.sol";

import {WAD} from "../../utils/Math.sol";

import {IntegrationTestBase} from "./IntegrationTestBase.sol";

import {PermitParams} from "../../proxy/TransferAction.sol";
import {PoolAction, PoolActionParams, Protocol} from "../../proxy/PoolAction.sol";

import {ApprovalType, PermitParams} from "../../proxy/TransferAction.sol";
import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";
import {PermitMaker} from "../utils/PermitMaker.sol";
import {PositionAction4626} from "../../proxy/PositionAction4626.sol";

import {IVault, JoinKind, JoinPoolRequest} from "../../vendor/IBalancerVault.sol";

contract PoolActionTest is IntegrationTestBase {
    using SafeERC20 for ERC20;

    address wstETH_bb_a_WETH_BPTl = 0x41503C9D499ddbd1dCdf818a1b05e9774203Bf46;
    bytes32 poolId = 0x41503c9d499ddbd1dcdf818a1b05e9774203bf46000000000000000000000594;

    address constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address constant bbaweth = 0xbB6881874825E60e1160416D6C426eae65f2459E;

    // user
    PRBProxy userProxy;
    address internal user;
    uint256 internal userPk;
    uint256 internal constant NONCE = 0;

    PermitParams emptyPermitParams;
    bytes32[] weightedPoolIdArray;

    // Permit2
    ISignatureTransfer internal constant permit2 = ISignatureTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    function setUp() public override {
        super.setUp();

        vm.label(BALANCER_VAULT, "balancer");
        vm.label(wstETH, "wstETH");
        vm.label(bbaweth, "bbaweth");
        vm.label(wstETH_bb_a_WETH_BPTl, "wstETH-bb-a-WETH-BPTl");

        // setup user and userProxy
        userPk = 0x12341234;
        user = vm.addr(userPk);
        userProxy = PRBProxy(payable(address(prbProxyRegistry.deployFor(user))));

        vm.startPrank(user);
        ERC20(wstETH).approve(address(permit2), type(uint256).max);
        ERC20(bbaweth).approve(address(permit2), type(uint256).max);
        vm.stopPrank();

        // setup state variables to avoid stack too deep
        weightedPoolIdArray.push(weightedPoolId); 
    }

    function test_transferAndJoin() public {
        uint256 depositAmount = 1000 ether;

        deal(wstETH, user, depositAmount);
        deal(bbaweth, user, depositAmount);

        PoolActionParams memory poolActionParams;
        PermitParams memory permitParams;

        uint256 deadline = block.timestamp + 100;
        (uint8 v, bytes32 r, bytes32 s) = PermitMaker.getPermit2TransferFromSignature(
            address(wstETH),
            address(userProxy),
            depositAmount,
            NONCE,
            deadline,
            userPk
        );
         
        permitParams = PermitParams({
            approvalType: ApprovalType.PERMIT2,
            approvalAmount: depositAmount,
            nonce: NONCE,
            deadline: deadline,
            v: v,
            r: r,
            s: s
        });

        address[] memory tokens = new address[](3);
        tokens[0] = wstETH_bb_a_WETH_BPTl;
        tokens[1] = wstETH;
        tokens[2] = bbaweth;

        uint256[] memory maxAmountsIn = new uint256[](3);
        maxAmountsIn[0] = 0;
        maxAmountsIn[1] = depositAmount;
        maxAmountsIn[2] = 0;

        PermitParams[] memory permitParamsArray = new PermitParams[](3);
        permitParamsArray[1] = permitParams;

        uint256[] memory tokensIn = new uint256[](2);
        tokensIn[0] = depositAmount;
        tokensIn[1] = 0;

        poolActionParams = PoolActionParams({
            protocol: Protocol.BALANCER,
            minOut: 0,
            recipient: user,
            args: abi.encode(
                poolId,
                tokens,
                tokensIn,
                maxAmountsIn
            )
        });


        vm.startPrank(user);
        userProxy.execute(
            address(poolAction),
            abi.encodeWithSelector(
                PoolAction.transferAndJoin.selector,
                user,
                permitParamsArray,
                poolActionParams
            )
        );
    }

    function test_join_multipleTokens() public {
        uint256 wstETHAmount = 1000 ether;
        uint256 bbawethAmount = 1000 ether;

        deal(wstETH, user, wstETHAmount);
        deal(bbaweth, user, bbawethAmount);

        PoolActionParams memory poolActionParams;

        // transfer the tokens to the proxy and call join on the PoolAction
        vm.startPrank(user);
        ERC20(wstETH).transfer(address(userProxy), wstETHAmount);
        ERC20(bbaweth).transfer(address(userProxy), bbawethAmount);
        vm.stopPrank();

        address[] memory tokens = new address[](3);
        tokens[0] = wstETH_bb_a_WETH_BPTl;
        tokens[1] = wstETH;
        tokens[2] = bbaweth;

        uint256[] memory maxAmountsIn = new uint256[](3);
        maxAmountsIn[0] = 0;
        maxAmountsIn[1] = wstETHAmount;
        maxAmountsIn[2] = bbawethAmount;

        uint256[] memory tokensIn = new uint256[](2);
        tokensIn[0] = wstETHAmount;
        tokensIn[1] = bbawethAmount;

        poolActionParams = PoolActionParams({
            protocol: Protocol.BALANCER,
            minOut: 0,
            recipient: user,
            args: abi.encode(
                poolId,
                tokens,
                tokensIn,
                maxAmountsIn
            )
        });

        vm.startPrank(user);
        ERC20(wstETH_bb_a_WETH_BPTl).approve(address(userProxy), wstETHAmount + bbawethAmount);
        vm.stopPrank();

        address[] memory targets = new address[](2);
        targets[0] = address(poolAction);

        vm.startPrank(user);
        userProxy.execute(
            address(poolAction),
            abi.encodeWithSelector(
                PoolAction.join.selector,
                poolActionParams
            )
        );
    }
    
    function getForkBlockNumber() internal virtual override(IntegrationTestBase) pure returns (uint256){
        return 17870449; // Aug-08-2023 01:17:35 PM +UTC
    }
}