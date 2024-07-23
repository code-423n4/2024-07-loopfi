// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {PRBProxy} from "prb-proxy/PRBProxy.sol";

import {Permission} from "../../utils/Permission.sol";
import {toInt256, WAD} from "../../utils/Math.sol";

import {CDPVault} from "../../CDPVault.sol";

import {IntegrationTestBase} from "./IntegrationTestBase.sol";

import {BaseAction} from "../../proxy/BaseAction.sol";
import {PermitParams} from "../../proxy/TransferAction.sol";
import {SwapAction, SwapParams, SwapType, SwapProtocol} from "../../proxy/SwapAction.sol";
import {PositionAction, CollateralParams, CreditParams} from "../../proxy/PositionAction.sol";
import {PositionAction20} from "../../proxy/PositionAction20.sol";

contract PositionAction20Test is IntegrationTestBase {
    using SafeERC20 for ERC20;

    // user
    PRBProxy userProxy;
    address user;
    uint256 constant userPk = 0x12341234;

    // cdp vaults
    CDPVault vault;

    // actions
    PositionAction20 positionAction;

    // common variables as state variables to help with stack too deep
    PermitParams emptyPermitParams;
    SwapParams emptySwap;
    bytes32[] stablePoolIdArray;

    function setUp() public override {
        super.setUp();

        // configure permissions and system settings
        setGlobalDebtCeiling(15_000_000 ether);

        // deploy vaults
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

        // deploy position actions
        positionAction = new PositionAction20(
            address(flashlender),
            address(swapAction),
            address(poolAction),
            address(vaultRegistry)
        );

        vm.label(user, "user");
        vm.label(address(userProxy), "userProxy");
        vm.label(address(vault), "cdpVault");
        vm.label(address(positionAction), "positionAction");
    }

    function test_deposit() public {
        uint256 depositAmount = 10_000 ether;

        deal(address(token), user, depositAmount);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(token),
            amount: depositAmount,
            collateralizer: address(user),
            auxSwap: emptySwap
        });

        vm.prank(user);
        token.approve(address(userProxy), depositAmount);

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.deposit.selector,
                address(userProxy),
                address(vault),
                collateralParams,
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));

        assertEq(collateral, depositAmount);
        assertEq(debt, 0);
    }

    function test_deposit_vault_with_entry_swap_from_USDC() public {
        uint256 depositAmount = 10_000 * 1e6;
        uint256 amountOutMin = (depositAmount * 1e12 * 98) / 100; // convert 6 decimals to 18 and add 1% slippage

        deal(address(USDC), user, depositAmount);

        // build increase collateral params
        bytes32[] memory poolIds = new bytes32[](1);
        poolIds[0] = stablePoolId;

        address[] memory assets = new address[](2);
        assets[0] = address(USDC);
        assets[1] = address(token);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(USDC),
            amount: 0, // not used for swaps
            collateralizer: address(user),
            auxSwap: SwapParams({
                swapProtocol: SwapProtocol.BALANCER,
                swapType: SwapType.EXACT_IN,
                assetIn: address(USDC),
                amount: depositAmount, // amount to swap in
                limit: amountOutMin, // min amount of collateral token to receive
                recipient: address(userProxy),
                deadline: block.timestamp + 100,
                args: abi.encode(poolIds, assets)
            })
        });

        uint256 expectedCollateral = _simulateBalancerSwap(collateralParams.auxSwap);

        vm.prank(user);
        USDC.approve(address(userProxy), depositAmount);

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.deposit.selector,
                address(userProxy),
                address(vault),
                collateralParams,
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));

        assertEq(collateral, expectedCollateral);
        assertEq(debt, 0);
    }

    function test_deposit_from_proxy_collateralizer() public {
        uint256 depositAmount = 10_000 ether;

        deal(address(token), address(userProxy), depositAmount);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(token),
            amount: depositAmount,
            collateralizer: address(userProxy),
            auxSwap: emptySwap
        });

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.deposit.selector,
                address(userProxy),
                address(vault),
                collateralParams,
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));

        assertEq(collateral, depositAmount);
        assertEq(debt, 0);
    }

    function test_deposit_to_an_unrelated_position() public {
        // create 2nd position
        address alice = vm.addr(0x45674567);
        PRBProxy aliceProxy = PRBProxy(payable(address(prbProxyRegistry.deployFor(alice))));

        uint256 depositAmount = 10_000 ether;

        deal(address(token), user, depositAmount);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(token),
            amount: depositAmount,
            collateralizer: address(user),
            auxSwap: emptySwap // no entry swap
        });

        vm.prank(user);
        token.approve(address(userProxy), depositAmount);

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.deposit.selector,
                address(aliceProxy),
                address(vault),
                collateralParams,
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(aliceProxy));

        assertEq(collateral, depositAmount);
        assertEq(debt, 0);
    }

    function test_deposit_EXACT_OUT() public {
        uint256 depositAmount = 10_000 ether;
        //uint256 amountOutMin = depositAmount * 1e12 * 98 / 100;
        uint256 amountInMax = (depositAmount * 101) / 100e12; // convert 6 decimals to 18 and add 1% slippage

        deal(address(USDC), user, amountInMax);

        // build increase collateral params
        bytes32[] memory poolIds = new bytes32[](1);
        poolIds[0] = stablePoolId;

        address[] memory assets = new address[](2);
        assets[0] = address(token);
        assets[1] = address(USDC);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(USDC),
            amount: 0, // not used for swaps
            collateralizer: address(user),
            auxSwap: SwapParams({
                swapProtocol: SwapProtocol.BALANCER,
                swapType: SwapType.EXACT_OUT,
                assetIn: address(USDC),
                amount: depositAmount, // amount to swap in
                limit: amountInMax, // min amount of collateral token to receive
                recipient: address(userProxy),
                deadline: block.timestamp + 100,
                args: abi.encode(poolIds, assets)
            })
        });

        uint256 expectedAmountIn = _simulateBalancerSwap(collateralParams.auxSwap);

        vm.startPrank(user);
        USDC.approve(address(userProxy), amountInMax);

        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.deposit.selector,
                address(userProxy),
                address(vault),
                collateralParams,
                emptyPermitParams
            )
        );
        vm.stopPrank();

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));

        assertEq(collateral, depositAmount);
        assertEq(debt, 0);
        assertEq(USDC.balanceOf(user), amountInMax - expectedAmountIn); // assert residual is sent to user
    }

    function test_deposit_InvalidAuxSwap() public {
        uint256 depositAmount = 10_000 * 1e6;
        uint256 amountOutMin = (depositAmount * 1e12 * 98) / 100; // convert 6 decimals to 18 and add 1% slippage

        deal(address(USDC), user, depositAmount);

        // build increase collateral params
        bytes32[] memory poolIds = new bytes32[](1);
        poolIds[0] = stablePoolId;

        address[] memory assets = new address[](2);
        assets[0] = address(USDC);
        assets[1] = address(token);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(USDC),
            amount: 0, // not used for swaps
            collateralizer: address(user),
            auxSwap: SwapParams({
                swapProtocol: SwapProtocol.BALANCER,
                swapType: SwapType.EXACT_IN,
                assetIn: address(USDC),
                amount: depositAmount, // amount to swap in
                limit: amountOutMin, // min amount of collateral token to receive
                recipient: address(userProxy),
                deadline: block.timestamp + 100,
                args: abi.encode(poolIds, assets)
            })
        });

        vm.prank(user);
        USDC.approve(address(userProxy), depositAmount);

        // trigger PositionAction__deposit_InvalidAuxSwap
        collateralParams.auxSwap.recipient = user;
        vm.expectRevert(PositionAction.PositionAction__deposit_InvalidAuxSwap.selector);
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.deposit.selector,
                address(userProxy),
                address(vault),
                collateralParams,
                emptyPermitParams
            )
        );
    }

    function test_withdraw() public {
        // deposit tokens to vault
        uint256 initialDeposit = 1_000 ether;
        _deposit(userProxy, address(vault), initialDeposit);

        // build withdraw params
        SwapParams memory auxSwap;
        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(token),
            amount: initialDeposit,
            collateralizer: address(user),
            auxSwap: auxSwap
        });

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.withdraw.selector,
                address(userProxy), // user proxy is the position
                address(vault),
                collateralParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));
        assertEq(collateral, 0);
        assertEq(debt, 0);

        // (int256 balance,) = cdm.accounts(address(userProxy));
        // assertEq(balance, 0);
    }

    function test_withdraw_and_swap() public {
        uint256 initialDeposit = 1_000 ether;
        _deposit(userProxy, address(vault), initialDeposit);

        // build withdraw params
        uint256 expectedAmountOut;
        CollateralParams memory collateralParams;
        {
            bytes32[] memory poolIds = new bytes32[](1);
            poolIds[0] = stablePoolId;

            address[] memory assets = new address[](2);
            assets[0] = address(token);
            assets[1] = address(USDT);

            collateralParams = CollateralParams({
                targetToken: address(token),
                amount: initialDeposit,
                collateralizer: address(user),
                auxSwap: SwapParams({
                    swapProtocol: SwapProtocol.BALANCER,
                    swapType: SwapType.EXACT_IN,
                    assetIn: address(token),
                    amount: initialDeposit,
                    limit: ((initialDeposit / 1e12) * 99) / 100,
                    recipient: address(user),
                    deadline: block.timestamp + 100,
                    args: abi.encode(poolIds, assets)
                })
            });
            expectedAmountOut = _simulateBalancerSwap(collateralParams.auxSwap);
        }

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.withdraw.selector,
                address(userProxy), // user proxy is the position
                address(vault),
                collateralParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));
        assertEq(collateral, 0);
        assertEq(debt, 0);

        // (int256 balance,) = cdm.accounts(address(userProxy));
        // assertEq(balance, 0);
        assertEq(USDT.balanceOf(address(user)), expectedAmountOut);
    }

    function test_borrow_1() public {
        // deposit to vault
        uint256 initialDeposit = 1_000 ether;

        _deposit(userProxy, address(vault), initialDeposit);

        // borrow against deposit
        uint256 borrowAmount = 500 * 1 ether;
        deal(address(token), user, borrowAmount);

        // build borrow params
        CreditParams memory creditParams = CreditParams({
            amount: borrowAmount,
            creditor: user,
            auxSwap: emptySwap // no entry swap
        });

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.borrow.selector,
                address(userProxy), // user proxy is the position
                address(vault),
                creditParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));
        assertEq(collateral, initialDeposit);
        assertEq(debt, borrowAmount);

        // (int256 balance,) = cdm.accounts(address(userProxy));
        // assertEq(balance, 0);
        assertEq(token.balanceOf(user), borrowAmount);
    }

    function test_borrow_with_large_rate() public {
        // accrue interest
        vm.warp(block.timestamp + 10 * 365 days);

        uint256 depositAmount = 10_000 ether;
        uint256 borrowAmount = 5_000 ether;
        _depositAndBorrow(userProxy, address(vault), depositAmount, borrowAmount);

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));

        // assert that collateral is now equal to the upFrontAmount + the amount of DAI received from the swap
        assertEq(collateral, depositAmount);

        // assert debt is the same as the amount of stablecoin borrowed
        assertEq(debt, _virtualDebt(vault, address(userProxy)));

        // assert that debt is minted to the user
        assertEq(underlyingToken.balanceOf(user), borrowAmount);
    }

    // REPAY TESTS

    function test_repay() public {
        uint256 depositAmount = 1_000 * 1 ether;
        uint256 borrowAmount = 500 * 1 ether;
        _depositAndBorrow(userProxy, address(vault), depositAmount, borrowAmount);

        // build repay params
        SwapParams memory auxSwap;
        CreditParams memory creditParams = CreditParams({
            amount: borrowAmount,
            creditor: user,
            auxSwap: auxSwap // no entry swap
        });

        vm.startPrank(user);
        underlyingToken.approve(address(userProxy), borrowAmount);
        underlyingToken.approve(address(liquidityPool), borrowAmount);

        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.repay.selector,
                address(userProxy), // user proxy is the position
                address(vault),
                creditParams,
                emptyPermitParams
            )
        );
        vm.stopPrank();

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));
        uint256 creditAmount = credit(address(userProxy));

        assertEq(collateral, depositAmount);
        assertEq(debt, 0);
        assertEq(creditAmount, 0);
        assertEq(underlyingToken.balanceOf(user), 0);
    }

    function test_repay_with_interest() public {
        uint256 depositAmount = 1_000 * 1 ether;
        uint256 borrowAmount = 500 * 1 ether;
        _depositAndBorrow(userProxy, address(vault), depositAmount, borrowAmount);

        // accrue interest
        vm.warp(block.timestamp + 365 days);

        uint256 totalDebt = _virtualDebt(vault, address(userProxy));
        deal(address(underlyingToken), user, totalDebt);

        // build repay params
        SwapParams memory auxSwap;
        CreditParams memory creditParams = CreditParams({
            amount: totalDebt,
            creditor: user,
            auxSwap: auxSwap // no entry swap
        });

        vm.startPrank(user);
        underlyingToken.approve(address(userProxy), totalDebt);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.repay.selector,
                address(userProxy), // user proxy is the position
                address(vault),
                creditParams,
                emptyPermitParams
            )
        );
        vm.stopPrank();

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));
        uint256 creditAmount = credit(address(userProxy));

        assertEq(collateral, depositAmount);
        assertEq(debt, 0);
        assertEq(creditAmount, 0);
        assertEq(underlyingToken.balanceOf(user), 0);
    }

    function test_withdrawAndRepay() public {
        uint256 depositAmount = 5_000 * 1 ether;
        uint256 borrowAmount = 2_500 * 1 ether;

        // deposit and borrow
        _depositAndBorrow(userProxy, address(vault), depositAmount, borrowAmount);

        // build withdraw and repay params
        CollateralParams memory collateralParams;
        CreditParams memory creditParams;
        {
            collateralParams = CollateralParams({
                targetToken: address(token),
                amount: depositAmount,
                collateralizer: user,
                auxSwap: emptySwap
            });
            creditParams = CreditParams({amount: borrowAmount, creditor: user, auxSwap: emptySwap});
        }

        vm.startPrank(user);
        underlyingToken.approve(address(userProxy), borrowAmount);

        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.withdrawAndRepay.selector,
                address(userProxy), // user proxy is the position
                address(vault),
                collateralParams,
                creditParams,
                emptyPermitParams
            )
        );
        vm.stopPrank();

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));
        uint256 creditAmount = credit(address(userProxy));

        assertEq(collateral, 0);
        assertEq(debt, 0);
        assertEq(creditAmount, 0);
        assertEq(underlyingToken.balanceOf(user), 0);
        assertEq(token.balanceOf(user), depositAmount);
    }

    function test_depositAndBorrow() public {
        uint256 upFrontUnderliers = 10_000 * 1 ether;
        uint256 borrowAmount = 5_000 * 1 ether;

        deal(address(token), user, upFrontUnderliers);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(token),
            amount: upFrontUnderliers,
            collateralizer: address(user),
            auxSwap: emptySwap // no entry swap
        });
        CreditParams memory creditParams = CreditParams({
            amount: borrowAmount,
            creditor: user,
            auxSwap: emptySwap // no exit swap
        });

        vm.prank(user);
        token.approve(address(userProxy), upFrontUnderliers);

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.depositAndBorrow.selector,
                address(userProxy),
                address(vault),
                collateralParams,
                creditParams,
                emptyPermitParams
            )
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));

        assertEq(collateral, upFrontUnderliers);
        assertEq(debt, borrowAmount);

        assertEq(underlyingToken.balanceOf(user), borrowAmount);
    }

    // MULTISEND

    // send a direct call to multisend and expect revert
    function test_multisend_no_direct_call() public {
        address[] memory targets = new address[](1);
        targets[0] = address(token);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeWithSelector(token.balanceOf.selector, user);

        bool[] memory delegateCall = new bool[](1);
        delegateCall[0] = false;

        vm.expectRevert(PositionAction.PositionAction__onlyDelegatecall.selector);
        positionAction.multisend(targets, data, delegateCall);
    }

    function test_multisend_revert_on_inner_revert() public {
        address[] memory targets = new address[](1);
        targets[0] = address(token);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeWithSelector(PositionAction.multisend.selector); // random selector

        bool[] memory delegateCall = new bool[](1);
        delegateCall[0] = false;

        vm.expectRevert(BaseAction.Action__revertBytes_emptyRevertBytes.selector);
        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(positionAction.multisend.selector, targets, data, delegateCall)
        );
    }

    function test_multisend_simple_delegatecall() public {
        uint256 depositAmount = 1_000 ether;
        uint256 borrowAmount = 500 ether;

        deal(address(token), address(userProxy), depositAmount);

        CollateralParams memory collateralParams = CollateralParams({
            targetToken: address(token),
            amount: depositAmount,
            collateralizer: address(userProxy),
            auxSwap: emptySwap
        });

        CreditParams memory creditParams = CreditParams({
            amount: borrowAmount,
            creditor: address(userProxy),
            auxSwap: emptySwap
        });

        address[] memory targets = new address[](2);
        targets[0] = address(positionAction);
        targets[1] = address(vault);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(
            positionAction.depositAndBorrow.selector,
            address(userProxy),
            address(vault),
            collateralParams,
            creditParams,
            emptyPermitParams
        );
        data[1] = abi.encodeWithSelector(
            CDPVault.modifyCollateralAndDebt.selector,
            address(userProxy),
            address(userProxy),
            address(userProxy),
            0,
            0
        );

        bool[] memory delegateCall = new bool[](2);
        delegateCall[0] = true;
        delegateCall[1] = false;

        vm.prank(user);
        userProxy.execute(
            address(positionAction),
            abi.encodeWithSelector(positionAction.multisend.selector, targets, data, delegateCall)
        );

        (uint256 collateral, uint256 debt, , , , ) = vault.positions(address(userProxy));
        assertEq(collateral, depositAmount);
        assertEq(debt, borrowAmount);
    }

    // function test_multisend_deposit() public {
    //     uint256 depositAmount = 10_000 ether;

    //     deal(address(DAI), user, depositAmount);

    //     CollateralParams memory collateralParams = CollateralParams({
    //         targetToken: address(DAI),
    //         amount: depositAmount,
    //         collateralizer: address(user),
    //         auxSwap: emptySwap
    //     });

    //     vm.prank(user);
    //     DAI.approve(address(userProxy), depositAmount);

    //     address[] memory targets = new address[](2);
    //     targets[0] = address(positionAction);
    //     targets[1] = address(daiVault);

    //     bytes[] memory data = new bytes[](2);
    //     data[0] = abi.encodeWithSelector(positionAction.deposit.selector, address(userProxy), daiVault, collateralParams, emptyPermitParams);
    //     data[1] = abi.encodeWithSelector(
    //         daiVault.modifyCollateralAndDebt.selector,
    //         address(userProxy),
    //         address(userProxy),
    //         address(userProxy),
    //         0,
    //         toInt256(100 ether)
    //     );

    //     bool[] memory delegateCall = new bool[](2);
    //     delegateCall[0] = true;
    //     delegateCall[1] = false;

    //     vm.prank(user);
    //     userProxy.execute(
    //         address(positionAction),
    //         abi.encodeWithSelector(
    //             positionAction.multisend.selector,
    //             targets,
    //             data,
    //             delegateCall
    //         )
    //     );

    //     (uint256 collateral, uint256 debt) = daiVault.positions(address(userProxy));

    //     assertEq(collateral, depositAmount);
    //     assertEq(debt, 100 ether);
    // }

    // HELPER FUNCTIONS

    function _deposit(PRBProxy proxy, address vault_, uint256 amount) internal {
        CDPVault cdpVault = CDPVault(vault_);
        address token = address(cdpVault.token());

        // mint vault token to position
        deal(token, address(proxy), amount);

        // build collateral params
        CollateralParams memory collateralParams = CollateralParams({
            targetToken: token,
            amount: amount,
            collateralizer: address(proxy),
            auxSwap: emptySwap
        });

        vm.prank(proxy.owner());
        proxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.deposit.selector,
                address(userProxy), // user proxy is the position
                vault,
                collateralParams,
                emptyPermitParams
            )
        );
    }

    function _depositAndBorrow(PRBProxy proxy, address vault_, uint256 depositAmount, uint256 borrowAmount) internal {
        CDPVault cdpVault = CDPVault(vault_);
        address token = address(cdpVault.token());

        // mint vault token to position
        deal(token, address(proxy), depositAmount);

        // build add collateral params
        SwapParams memory auxSwap;
        CollateralParams memory collateralParams = CollateralParams({
            targetToken: token,
            amount: depositAmount,
            collateralizer: address(proxy),
            auxSwap: auxSwap // no entry swap
        });
        CreditParams memory creditParams = CreditParams({
            amount: borrowAmount,
            creditor: proxy.owner(),
            auxSwap: auxSwap // no exit swap
        });

        vm.startPrank(proxy.owner());
        proxy.execute(
            address(positionAction),
            abi.encodeWithSelector(
                positionAction.depositAndBorrow.selector,
                address(proxy), // user proxy is the position
                vault,
                collateralParams,
                creditParams,
                emptyPermitParams
            )
        );
        vm.stopPrank();
    }
}
