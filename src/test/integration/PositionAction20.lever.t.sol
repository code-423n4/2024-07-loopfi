// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {PRBProxy} from "prb-proxy/PRBProxy.sol";

import {IntegrationTestBase} from "./IntegrationTestBase.sol";
import {wdiv, WAD} from "../../utils/Math.sol";
import {Permission} from "../../utils/Permission.sol";

import {CDPVault} from "../../CDPVault.sol";

import {PermitParams} from "../../proxy/TransferAction.sol";
import {SwapAction, SwapParams, SwapType, SwapProtocol} from "../../proxy/SwapAction.sol";
import {LeverParams, PositionAction} from "../../proxy/PositionAction.sol";
import {PoolActionParams} from "../../proxy/PoolAction.sol";

import {PositionAction20} from "../../proxy/PositionAction20.sol";

contract PositionAction20_Lever_Test is IntegrationTestBase {
    using SafeERC20 for ERC20;

    // user
    PRBProxy userProxy;
    address user;
    uint256 constant userPk = 0x12341234;

    CDPVault vault;

    // actions
    PositionAction20 positionAction;

    // common variables as state variables to help with stack too deep
    PermitParams emptyPermitParams;
    SwapParams emptySwap;
    PoolActionParams emptyPoolActionParams;

    bytes32[] weightedPoolIdArray;

    function setUp() public override {
        super.setUp();

        // configure permissions and system settings
        setGlobalDebtCeiling(15_000_000 ether);

        // deploy vault
        vault = createCDPVault(
            token, // token
            5_000_000 ether, // debt ceiling
            0, // debt floor
            1.25 ether, // liquidation ratio
            1.0 ether, // liquidation penalty
            1.05 ether // liquidation discount
        );
        createGaugeAndSetGauge(address(vault));
        // setup user and userProxy
        user = vm.addr(0x12341234);
        userProxy = PRBProxy(payable(address(prbProxyRegistry.deployFor(user))));

        vm.prank(address(userProxy));
        token.approve(address(user), type(uint256).max);
        vm.prank(address(userProxy));
        mockWETH.approve(address(user), type(uint256).max);

        // deploy actions
        positionAction = new PositionAction20(
            address(flashlender),
            address(swapAction),
            address(poolAction),
            address(vaultRegistry)
        );

        // configure oracle spot prices
        oracle.updateSpot(address(token), 1 ether);

        weightedPoolIdArray.push(weightedUnderlierPoolId);

        vm.label(address(userProxy), "UserProxy");
        vm.label(address(user), "User");
        vm.label(address(vault), "CDPVault");
        vm.label(address(positionAction), "PositionAction");
    }

    function test_increaseLever() public {
        uint256 upFrontUnderliers = 20_000 ether;
        uint256 borrowAmount = 70_000 ether;
        uint256 amountOutMin = 69_000 ether;

        deal(address(token), user, upFrontUnderliers);

        // build increase lever params
        address[] memory assets = new address[](2);
        assets[0] = address(underlyingToken);
        assets[1] = address(token);

        LeverParams memory leverParams = LeverParams({
            position: address(userProxy),
            vault: address(vault),
            collateralToken: address(token),
            primarySwap: SwapParams({
                swapProtocol: SwapProtocol.BALANCER,
                swapType: SwapType.EXACT_IN,
                assetIn: address(underlyingToken),
                amount: borrowAmount,
                limit: amountOutMin,
                recipient: address(positionAction),
                deadline: block.timestamp + 100,
                args: abi.encode(weightedPoolIdArray, assets)
            }),
            auxSwap: emptySwap,
            auxAction: emptyPoolActionParams
        });

        uint256 expectedAmountOut = _simulateBalancerSwap(leverParams.primarySwap);

        vm.prank(user);
        token.approve(address(userProxy), upFrontUnderliers);

        // call increaseLever
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(token),
                upFrontUnderliers,
                address(user),
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 normalDebt, , , , ) = vault.positions(address(userProxy));

        // assert that collateral is now equal to the upFrontAmount + the amount of token received from the swap
        assertEq(collateral, expectedAmountOut + upFrontUnderliers);

        // assert normalDebt is the same as the amount of stablecoin borrowed
        assertEq(normalDebt, borrowAmount);

        // assert leverAction position is empty
        (uint256 lcollateral, uint256 lnormalDebt, , , , ) = vault.positions(address(positionAction));
        assertEq(lcollateral, 0);
        assertEq(lnormalDebt, 0);
    }

    function test_increaseLever_with_large_rate() public {
        vm.warp(block.timestamp + 10 * 365 days);
        uint256 upFrontUnderliers = 20_000 ether;
        uint256 borrowAmount = 40_000 ether;

        uint256 swapAmountOut = _increaseLever(
            userProxy, // position
            vault, // vault
            upFrontUnderliers,
            borrowAmount,
            39_000 ether // amountOutMin
        );

        (uint256 collateral, uint256 normalDebt, , , , ) = vault.positions(address(userProxy));

        // assert that collateral is now equal to the upFrontAmount + the amount of token received from the swap
        assertEq(collateral, swapAmountOut + upFrontUnderliers);

        // assert normalDebt is the same as the amount of stablecoin borrowed
        assertEq(normalDebt, borrowAmount);

        // assert leverAction position is empty
        (uint256 lcollateral, uint256 lnormalDebt, , , , ) = vault.positions(address(positionAction));
        assertEq(lcollateral, 0);
        assertEq(lnormalDebt, 0);
    }

    function test_increaseLever_zero_upfront() public {
        // lever up first and record the current collateral and normalized debt
        _increaseLever(
            userProxy, // position
            vault,
            20_000 ether, // upFrontUnderliers
            40_000 ether, // borrowAmount
            39_000 ether // amountOutMin
        );
        (uint256 initialCollateral, uint256 initialNormalDebt, , , , ) = vault.positions(address(userProxy));

        // now lever up further without passing any upFrontUnderliers
        uint256 borrowAmount = 5_000 ether; // amount to lever up
        uint256 amountOutMin = 4_950 ether; // min amount of token to receive

        // build increase lever params
        LeverParams memory leverParams;
        {
            SwapParams memory auxSwap;

            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(token);

            leverParams = LeverParams({
                position: address(userProxy),
                vault: address(vault),
                collateralToken: address(token),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(underlyingToken),
                    amount: borrowAmount, // amount of underlying to swap in
                    limit: amountOutMin, // min amount of token to receive
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: auxSwap,
                auxAction: emptyPoolActionParams
            });
        }

        uint256 expectedAmountOut = _simulateBalancerSwap(leverParams.primarySwap);

        PermitParams memory permitParams;

        // call increaseLever
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(0),
                0, // zero up front collateral
                address(0), // collateralizer
                permitParams
            )
        );

        (uint256 collateral, uint256 normalDebt, , , , ) = vault.positions(address(userProxy));

        // assert that collateral is now equal to the initial collateral + the amount of token received from the swap
        assertEq(collateral, initialCollateral + expectedAmountOut);

        // assert normalDebt is the same as the amount of stablecoin borrowed
        assertEq(normalDebt, initialNormalDebt + borrowAmount);
    }

    function test_increaseLever_with_proxy_collateralizer() public {
        uint256 upFrontUnderliers = 20_000 ether;
        uint256 borrowAmount = 70_000 ether;
        uint256 amountOutMin = 69_000 ether;

        // put the tokens directly on the proxy
        deal(address(token), address(userProxy), upFrontUnderliers);

        // build increase lever params
        LeverParams memory leverParams;
        {
            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(token);

            leverParams = LeverParams({
                position: address(userProxy),
                vault: address(vault),
                collateralToken: address(token),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(underlyingToken),
                    amount: borrowAmount,
                    limit: amountOutMin,
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: emptySwap,
                auxAction: emptyPoolActionParams
            });
        }

        uint256 expectedAmountOut = _simulateBalancerSwap(leverParams.primarySwap);

        // call transferAndIncreaseLever
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(token),
                upFrontUnderliers,
                address(userProxy),
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 normalDebt, , , , ) = vault.positions(address(userProxy));

        // verify the collateral amount is the same as the upFrontUnderliers + amount of token returned from swap
        assertEq(collateral, expectedAmountOut + upFrontUnderliers);

        // assert normalDebt is the same as borrowAmount
        assertEq(normalDebt, borrowAmount);
    }

    function test_increaseLever_with_different_EOA_collateralizer() public {
        uint256 upFrontUnderliers = 20_000 ether;
        uint256 borrowAmount = 70_000 ether;
        uint256 amountOutMin = 69_000 ether;

        // this is the EOA collateralizer that is not related to the position
        address alice = vm.addr(0x56785678);
        vm.label(alice, "alice");

        deal(address(token), address(alice), upFrontUnderliers);

        // approve the userProxy to spend the collateral token from alice
        vm.startPrank(alice);
        token.approve(address(userProxy), type(uint256).max);
        vm.stopPrank();

        // build increase lever params
        LeverParams memory leverParams;
        {
            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(token);

            leverParams = LeverParams({
                position: address(userProxy),
                vault: address(vault),
                collateralToken: address(token),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(underlyingToken),
                    amount: borrowAmount,
                    limit: amountOutMin,
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: emptySwap,
                auxAction: emptyPoolActionParams
            });
        }

        uint256 expectedAmountOut = _simulateBalancerSwap(leverParams.primarySwap);

        // call transferAndIncreaseLever
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(token),
                upFrontUnderliers,
                alice,
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 normalDebt, , , , ) = vault.positions(address(userProxy));

        // verify the collateral amount is the same as the upFrontUnderliers + amount of token returned from swap
        assertEq(collateral, expectedAmountOut + upFrontUnderliers);

        // assert normalDebt is the same as borrowAmount
        assertEq(normalDebt, borrowAmount);
    }

    function test_increaseLever_with_permission_agent() public {
        uint256 upFrontUnderliers = 20_000 ether;
        uint256 borrowAmount = 40_000 ether;
        uint256 amountOutMin = 39_000 ether;

        // create 1st position. This is the user(bob) that will lever up the other users (alice) position
        address bob = user;
        PRBProxy bobProxy = userProxy;

        // create 2nd position. This is the user that will be levered up by bob
        address alice = vm.addr(0x56785678);
        PRBProxy aliceProxy = PRBProxy(payable(address(prbProxyRegistry.deployFor(alice))));

        vm.label(alice, "alice");
        vm.label(address(aliceProxy), "aliceProxy");

        // alice creates an initial position
        _increaseLever(aliceProxy, vault, upFrontUnderliers, borrowAmount, amountOutMin);

        // build increaseLever Params
        LeverParams memory leverParams;
        {
            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(token);

            leverParams = LeverParams({
                position: address(aliceProxy),
                vault: address(vault),
                collateralToken: address(token),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(underlyingToken),
                    amount: borrowAmount, // amount of stablecoin to swap in
                    limit: amountOutMin, // min amount of token to receive
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: emptySwap,
                auxAction: emptyPoolActionParams
            });
        }

        deal(address(token), bob, upFrontUnderliers);

        vm.prank(bob);
        token.approve(address(bobProxy), upFrontUnderliers);

        // call increaseLever on alice's position as bob but expect failure because bob does not have permission
        vm.prank(bob);
        vm.expectRevert(Permission.Permission__modifyPermission_notPermitted.selector);
        bobProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(token),
                upFrontUnderliers,
                bob,
                emptyPermitParams
            )
        );

        // call setPermissionAgent as alice to allow bob to modify alice's position
        vm.prank(address(aliceProxy));
        vault.setPermissionAgent(address(bobProxy), true);

        // call increaseLever on alice's position as bob and now expect success
        vm.prank(bob);
        bobProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(token),
                upFrontUnderliers,
                bob,
                emptyPermitParams
            )
        );

        // assert alice's position is levered up once by her and a 2nd time by bob
        (uint256 aliceCollateral, uint256 aliceNormalDebt, , , , ) = vault.positions(address(aliceProxy));
        assertGe(aliceCollateral, amountOutMin * 2 + upFrontUnderliers * 2);
        assertEq(aliceNormalDebt, borrowAmount * 2);

        // assert bob's position is unaffected
        (uint256 bobCollateral, uint256 bobNormalDebt, , , , ) = vault.positions(address(bobProxy));
        assertEq(bobCollateral, 0);
        assertEq(bobNormalDebt, 0);
    }

    function test_decreaseLever() public {
        // lever up first and record the current collateral and normalized debt
        _increaseLever(
            userProxy, // position
            vault,
            20_000 ether, // upFrontUnderliers
            40_000 ether, // borrowAmount
            39_000 ether // amountOutMin
        );
        (uint256 initialCollateral, uint256 initialNormalDebt, , , , ) = vault.positions(address(userProxy));

        emit log_named_uint("initialCollateral", initialCollateral);
        emit log_named_uint("initialNormalDebt", initialNormalDebt);
        emit log_named_uint("underlyingToken balance", underlyingToken.balanceOf(address(userProxy)));

        // build decrease lever params
        uint256 amountOut = 5_000 ether;
        uint256 maxAmountIn = 5_100 ether;

        address[] memory assets = new address[](2);
        assets[0] = address(underlyingToken);
        assets[1] = address(token);

        LeverParams memory leverParams = LeverParams({
            position: address(userProxy),
            vault: address(vault),
            collateralToken: address(token),
            primarySwap: SwapParams({
                swapProtocol: SwapProtocol.BALANCER,
                swapType: SwapType.EXACT_OUT,
                assetIn: address(token),
                amount: amountOut, // exact amount of stablecoin to receive
                limit: maxAmountIn, // max amount of token to pay
                recipient: address(positionAction),
                deadline: block.timestamp + 100,
                args: abi.encode(weightedPoolIdArray, assets)
            }),
            auxSwap: emptySwap,
            auxAction: emptyPoolActionParams
        });

        uint256 expectedAmountIn = _simulateBalancerSwap(leverParams.primarySwap);

        emit log_named_uint("expectedAmountIn", expectedAmountIn);
        emit log_named_uint("START DELEVER", 0);
        // call decreaseLever
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.decreaseLever.selector, // function
                leverParams, // lever params
                maxAmountIn, // collateral to decrease by
                address(userProxy) // residualRecipient
            )
        );

        (uint256 collateral, uint256 normalDebt, , , , ) = vault.positions(address(userProxy));

        // assert new collateral amount is the same as initialCollateral minus the amount of token we swapped for stablecoin
        assertEq(collateral, initialCollateral - maxAmountIn);

        // assert new normalDebt is the same as initialNormalDebt minus the amount of stablecoin we received from swapping token
        assertEq(normalDebt, initialNormalDebt - amountOut);

        // assert that the left over was transfered to the user proxy
        assertEq(maxAmountIn - expectedAmountIn, token.balanceOf(address(userProxy)));

        // ensure there isn't any left over debt or collateral from using leverAction
        (uint256 lcollateral, uint256 lnormalDebt, , , , ) = vault.positions(address(positionAction));
        assertEq(lcollateral, 0);
        assertEq(lnormalDebt, 0);
    }

    function test_decreaseLever_with_interest() public {
        // lever up first and record the current collateral and normalized debt
        _increaseLever(
            userProxy, // position
            vault,
            20_000 ether, // upFrontUnderliers
            40_000 ether, // borrowAmount
            39_000 ether // amountOutMin
        );
        (uint256 initialCollateral, uint256 initialNormalDebt, , , , ) = vault.positions(address(userProxy));

        // accrue interest
        vm.warp(block.timestamp + 365 days);

        // build decrease lever params
        uint256 amountOut = 5_000 ether;
        uint256 maxAmountIn = 5_100 ether;

        address[] memory assets = new address[](2);
        assets[0] = address(underlyingToken);
        assets[1] = address(token);

        LeverParams memory leverParams = LeverParams({
            position: address(userProxy),
            vault: address(vault),
            collateralToken: address(token),
            primarySwap: SwapParams({
                swapProtocol: SwapProtocol.BALANCER,
                swapType: SwapType.EXACT_OUT,
                assetIn: address(token),
                amount: amountOut,
                limit: maxAmountIn,
                recipient: address(positionAction),
                deadline: block.timestamp + 100,
                args: abi.encode(weightedPoolIdArray, assets)
            }),
            auxSwap: emptySwap,
            auxAction: emptyPoolActionParams
        });

        uint256 expectedAmountIn = _simulateBalancerSwap(leverParams.primarySwap);
        (, uint256 accruedInterest, ) = vault.getDebtInfo(address(userProxy));

        // call decreaseLever
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.decreaseLever.selector, // function
                leverParams, // lever params
                maxAmountIn, // collateral to decrease by
                address(userProxy) // residualRecipient
            )
        );

        (uint256 collateral, uint256 normalDebt, , , , ) = vault.positions(address(userProxy));

        // assert new collateral amount is the same as initialCollateral minus the amount of token we swapped for stablecoin
        assertEq(collateral, initialCollateral - maxAmountIn);

        // debt is decreased by amount out minus the accrued interest
        assertEq(normalDebt, initialNormalDebt - amountOut + accruedInterest);

        // assert that the left over was transfered to the user proxy
        assertEq(maxAmountIn - expectedAmountIn, token.balanceOf(address(userProxy)));

        // ensure there isn't any left over debt or collateral from using leverAction
        (uint256 lcollateral, uint256 lnormalDebt, , , , ) = vault.positions(address(positionAction));
        assertEq(lcollateral, 0);
        assertEq(lnormalDebt, 0);
    }

    function test_decreaseLever_with_residual_recipient() public {
        address residualRecipient = address(0x56785678);

        // lever up first and record the current collateral and normalized debt
        _increaseLever(
            userProxy, // position
            vault,
            20_000 ether, // upFrontUnderliers
            40_000 ether, // borrowAmount
            39_000 ether // amountOutMin
        );

        // build decrease lever params
        uint256 amountOut = 5_000 ether;
        uint256 maxAmountIn = 5_100 ether;

        address[] memory assets = new address[](2);
        assets[0] = address(underlyingToken);
        assets[1] = address(token);

        LeverParams memory leverParams = LeverParams({
            position: address(userProxy),
            vault: address(vault),
            collateralToken: address(token),
            primarySwap: SwapParams({
                swapProtocol: SwapProtocol.BALANCER,
                swapType: SwapType.EXACT_OUT,
                assetIn: address(token),
                amount: amountOut,
                limit: maxAmountIn,
                recipient: address(positionAction),
                deadline: block.timestamp + 100,
                args: abi.encode(weightedPoolIdArray, assets)
            }),
            auxSwap: emptySwap,
            auxAction: emptyPoolActionParams
        });

        uint256 expectedAmountIn = _simulateBalancerSwap(leverParams.primarySwap);

        // call decreaseLever
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.decreaseLever.selector, // function
                leverParams, // lever params
                maxAmountIn, // collateral to decrease by
                residualRecipient
            )
        );

        // assert that the left over was transfered to the residualRecipient
        assertEq(maxAmountIn - expectedAmountIn, token.balanceOf(address(residualRecipient)));
    }

    function test_decreaseLever_with_permission_agent() public {
        // create 1st position (this is the user that will lever up the other users position)
        address bob = user;
        PRBProxy bobProxy = userProxy;

        // create 2nd position. This is the user that will be levered up by bob
        address alice = vm.addr(0x56785678);
        PRBProxy aliceProxy = PRBProxy(payable(address(prbProxyRegistry.deployFor(alice))));

        // create alice's initial position
        _increaseLever(
            aliceProxy,
            vault,
            20_000 ether, // upFrontUnderliers
            40_000 ether, // borrowAmount
            39_000 ether // amountOutMin
        );
        (uint256 initialCollateral, uint256 initialNormalDebt, , , , ) = vault.positions(address(aliceProxy));

        uint256 amountOut = 5_000 ether;
        uint256 maxAmountIn = 5_100 ether;
        LeverParams memory leverParams;
        {
            // now decrease alice's leverage as bob
            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(token);

            leverParams = LeverParams({
                position: address(aliceProxy),
                vault: address(vault),
                collateralToken: address(token),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_OUT,
                    assetIn: address(token),
                    amount: amountOut,
                    limit: maxAmountIn,
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: emptySwap,
                auxAction: emptyPoolActionParams
            });
        }

        // call decreaseLever on alice's position as bob and expect failure because alice did not give bob permission
        vm.prank(bob);
        vm.expectRevert(Permission.Permission__modifyPermission_notPermitted.selector);
        bobProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(positionAction.decreaseLever.selector, leverParams, maxAmountIn, address(bob))
        );

        // call setPermissionAgent as alice to allow bob to modify alice's position
        vm.prank(address(aliceProxy));
        vault.setPermissionAgent(address(bobProxy), true);

        // now call decreaseLever on alice's position as bob and expect success because alice gave bob permission
        vm.prank(bob);
        bobProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(positionAction.decreaseLever.selector, leverParams, maxAmountIn, address(bob))
        );

        (uint256 aliceCollateral, uint256 aliceNormalDebt, , , , ) = vault.positions(address(aliceProxy));
        (uint256 bobCollateral, uint256 bobNormalDebt, , , , ) = vault.positions(address(bobProxy));

        // assert alice's position is levered down by bob
        assertEq(aliceCollateral, initialCollateral - maxAmountIn);
        assertEq(aliceNormalDebt, initialNormalDebt - amountOut);

        // assert bob's position is unaffected
        assertEq(bobCollateral, 0);
        assertEq(bobNormalDebt, 0);
    }

    // ERRORS
    function test_increaseLever_invalidSwaps() public {
        uint256 upFrontUnderliers = 20_000 * 1e6;
        uint256 auxAmountOutMin = (upFrontUnderliers * 1e12 * 99) / 100; // allow 1% slippage on aux swap and convert to token decimals
        uint256 borrowAmount = auxAmountOutMin; // we want the amount of stablecoin we borrow to be equal to the amount of underliers we receieve in aux swap
        uint256 amountOutMin = (borrowAmount * 99) / 100;

        LeverParams memory leverParams;
        {
            // mint USDC to user
            deal(address(USDC), user, upFrontUnderliers);

            // build increase lever params
            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(token);

            address[] memory auxAssets = new address[](2);
            auxAssets[0] = address(USDC);
            auxAssets[1] = address(token);

            leverParams = LeverParams({
                position: address(userProxy),
                vault: address(vault),
                collateralToken: address(token),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(underlyingToken),
                    amount: borrowAmount,
                    limit: amountOutMin,
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(USDC),
                    amount: upFrontUnderliers, // amount of USDC to swap in
                    limit: auxAmountOutMin, // min amount of token to receive
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, auxAssets)
                }),
                auxAction: emptyPoolActionParams
            });
        }

        vm.prank(user);
        USDC.approve(address(userProxy), upFrontUnderliers);

        leverParams.primarySwap.recipient = address(userProxy); // this should trigger PositionAction__increaseLever_invalidPrimarySwap
        vm.expectRevert(PositionAction.PositionAction__increaseLever_invalidPrimarySwap.selector);
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(USDC),
                upFrontUnderliers,
                address(user),
                emptyPermitParams
            )
        );
        leverParams.primarySwap.recipient = address(positionAction); // fix the error

        leverParams.auxSwap.recipient = address(userProxy); // this should trigger PositionAction__increaseLever_invalidAuxSwap
        vm.expectRevert(PositionAction.PositionAction__increaseLever_invalidAuxSwap.selector);
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(USDC),
                upFrontUnderliers,
                address(user),
                emptyPermitParams
            )
        );
    }

    function test_decreaseLever_invalidSwaps() public {
        _increaseLever(
            userProxy,
            vault,
            20_000 * 1 ether,
            40_000 ether, // borrowAmount
            (40_000 ether * 99) / 100 // amountOutMin
        );

        // we will completely delever the position so use full collateral and debt amounts
        uint256 collateralAmount;
        uint256 amountOut;
        uint256 maxAmountIn;
        {
            (uint256 initialCollateral, uint256 initialNormalDebt, , , , ) = vault.positions(address(userProxy));
            collateralAmount = initialCollateral; // delever the entire collateral amount
            amountOut = initialNormalDebt; // delever the entire debt amount
            maxAmountIn = (initialNormalDebt * 101) / 100; // allow 1% slippage on primary swap
        }

        // build decrease lever params
        LeverParams memory leverParams;
        uint256 minResidualRate = (1e6 * 99) / 100; // allow 1% slippage on aux swap, rate should be in out token decimals

        {
            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(token);

            address[] memory auxAssets = new address[](2);
            auxAssets[0] = address(token);
            auxAssets[1] = address(USDC);

            leverParams = LeverParams({
                position: address(userProxy),
                vault: address(vault),
                collateralToken: address(token),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_OUT,
                    assetIn: address(token),
                    amount: amountOut, // exact amount of stablecoin to receive
                    limit: maxAmountIn, // max amount of token to pay
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(token),
                    amount: 0,
                    limit: 0,
                    recipient: address(user),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, auxAssets)
                }),
                auxAction: emptyPoolActionParams
            });

            // first simulate the primary swap to calculate values for aux swap
            leverParams.auxSwap.amount = collateralAmount - _simulateBalancerSwap(leverParams.primarySwap);
            leverParams.auxSwap.limit = (leverParams.auxSwap.amount * minResidualRate) / 1 ether;
        }

        // trigger PositionAction__decreaseLever_invalidPrimarySwap
        leverParams.primarySwap.recipient = address(userProxy);
        vm.expectRevert(PositionAction.PositionAction__decreaseLever_invalidPrimarySwap.selector);
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.decreaseLever.selector, // function
                leverParams, // lever params
                collateralAmount, // collateral to decrease by
                address(0) // residualRecipient
            )
        );
        leverParams.primarySwap.recipient = address(positionAction); // fix the error

        // trigger PositionAction__decreaseLever_invalidAuxSwap
        leverParams.auxSwap.swapType = SwapType.EXACT_OUT;
        vm.expectRevert(PositionAction.PositionAction__decreaseLever_invalidAuxSwap.selector);
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.decreaseLever.selector, // function
                leverParams, // lever params
                collateralAmount, // collateral to decrease by
                address(0) // residualRecipient
            )
        );
        leverParams.auxSwap.swapType = SwapType.EXACT_IN; // fix the error

        // trigger PositionAction__decreaseLever_invalidResidualRecipient
        leverParams.auxSwap = emptySwap;
        vm.expectRevert(PositionAction.PositionAction__decreaseLever_invalidResidualRecipient.selector);
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.decreaseLever.selector, // function
                leverParams, // lever params
                collateralAmount, // collateral to decrease by
                address(0) // <=== this should trigger the error
            )
        );
    }

    function test_onFlashLoan_cannotCallDirectly() public {
        vm.expectRevert(PositionAction.PositionAction__onFlashLoan__invalidSender.selector);
        positionAction.onFlashLoan(address(0), address(0), 0, 0, "");
    }

    function test_onCreditFlashLoan_cannotCallDirectly() public {
        vm.expectRevert(PositionAction.PositionAction__onCreditFlashLoan__invalidSender.selector);
        positionAction.onCreditFlashLoan(address(0), 0, 0, "");
    }

    // simple helper function to increase lever
    function _increaseLever(
        PRBProxy proxy,
        CDPVault vault_,
        uint256 upFrontUnderliers,
        uint256 amountToLever,
        uint256 amountToLeverLimit
    ) public returns (uint256 expectedAmountIn) {
        LeverParams memory leverParams;
        {
            address upFrontToken = address(vault_.token());

            address[] memory assets = new address[](2);
            assets[0] = address(underlyingToken);
            assets[1] = address(upFrontToken);

            // mint directly to swap actions for simplicity
            if (upFrontUnderliers > 0) deal(upFrontToken, address(proxy), upFrontUnderliers);

            leverParams = LeverParams({
                position: address(proxy),
                vault: address(vault_),
                collateralToken: address(vault_.token()),
                primarySwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(underlyingToken),
                    amount: amountToLever, // amount of stablecoin to swap in
                    limit: amountToLeverLimit, // min amount of tokens to receive
                    recipient: address(positionAction),
                    deadline: block.timestamp + 100,
                    args: abi.encode(weightedPoolIdArray, assets)
                }),
                auxSwap: emptySwap, // no aux swap
                auxAction: emptyPoolActionParams
            });

            expectedAmountIn = _simulateBalancerSwap(leverParams.primarySwap);
        }

        vm.startPrank(proxy.owner());
        proxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.increaseLever.selector,
                leverParams,
                address(vault_.token()),
                upFrontUnderliers,
                address(proxy),
                emptyPermitParams
            )
        );
        vm.stopPrank();
    }
}
