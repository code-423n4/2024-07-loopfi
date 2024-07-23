// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {TestBase} from "../TestBase.sol";

import {ChainlinkOracle, MANAGER_ROLE} from "../../oracle/ChainlinkOracle.sol";
import {BalancerOracle, KEEPER_ROLE} from "../../oracle/BalancerOracle.sol";
import {IWeightedPool} from "../../vendor/IWeightedPool.sol";
import {IVault} from "../../vendor/IBalancerVault.sol";
import {IOracle} from "../../interfaces/IOracle.sol";

contract BalancerOracleTest is TestBase {
    BalancerOracle internal balancerOracle;

    address internal keeper;

    uint256 internal staleTime = 1 days;
    uint256 internal aggregatorScale = 10 ** 8;
    int256 internal mockPrice = 1e8;

    address pool;
    bytes32 poolId;

    address token0;
    address token1;
    address token2;

    address balancerVault;
    address chainlinkOracle;
    uint256 internal updateWaitWindow = 1 hours;
    uint256 internal stalePeriod = 1 days;

    function setUp() public override {
        super.setUp();

        pool = vm.addr(uint256(keccak256("pool")));
        token0 = vm.addr(uint256(keccak256("token0")));
        token1 = vm.addr(uint256(keccak256("token1")));
        token2 = vm.addr(uint256(keccak256("token2")));
        keeper = vm.addr(uint256(keccak256("keeper")));

        poolId = keccak256("poolId");
        balancerVault = vm.addr(uint256(keccak256("balancerVault")));
        chainlinkOracle = vm.addr(uint256(keccak256("chainlinkOracle")));

        vm.mockCall(pool, abi.encodeWithSelector(IWeightedPool.getPoolId.selector), abi.encode(poolId));

        address[] memory tokens = new address[](3);
        tokens[0] = token0;
        tokens[1] = token1;
        tokens[2] = token2;
        uint256[] memory balances = new uint256[](3);

        vm.mockCall(
            balancerVault,
            abi.encodeWithSelector(IVault.getPoolTokens.selector, poolId),
            abi.encode(tokens, balances, 0)
        );

        balancerOracle = BalancerOracle(
            address(
                new ERC1967Proxy(
                    address(new BalancerOracle(balancerVault, chainlinkOracle, pool, updateWaitWindow, stalePeriod)),
                    abi.encodeWithSelector(BalancerOracle.initialize.selector, address(this), address(this))
                )
            )
        );

        balancerOracle.grantRole(KEEPER_ROLE, keeper);
    }

    function test_deployOracle() public {
        assertTrue(address(balancerOracle) != address(0));
    }

    function test_checkParameters() public {
        assertEq(address(balancerOracle.balancerVault()), balancerVault);
        assertEq(address(balancerOracle.chainlinkOracle()), chainlinkOracle);
        assertEq(balancerOracle.updateWaitWindow(), updateWaitWindow);
        assertEq(balancerOracle.stalePeriod(), stalePeriod);
        assertEq(balancerOracle.pool(), pool);
        assertEq(balancerOracle.poolId(), poolId);
    }

    function test_initialize_accounts(address admin, address manager) public {
        balancerOracle = BalancerOracle(
            address(
                new ERC1967Proxy(
                    address(new BalancerOracle(balancerVault, chainlinkOracle, pool, updateWaitWindow, stalePeriod)),
                    abi.encodeWithSelector(ChainlinkOracle.initialize.selector, admin, manager)
                )
            )
        );

        assertTrue(balancerOracle.hasRole(MANAGER_ROLE, manager));

        assertTrue(balancerOracle.hasRole(balancerOracle.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_getStatus_staleOnInitialState() public {
        // random token address
        address token = vm.addr(uint256(keccak256("token")));
        // Price is stale until it is updated
        assertEq(balancerOracle.getStatus(token), false);
    }

    function test_getStatus_notStaleAfterUpdate() public {
        address token = vm.addr(uint256(keccak256("token")));
        // Price is stale until it is updated
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.warp(block.timestamp + updateWaitWindow);
        balancerOracle.update();
        vm.stopPrank();

        assertEq(balancerOracle.getStatus(token), true);
    }

    function test_getStatus_staleAfterStalePeriod() public {
        address token = vm.addr(uint256(keccak256("token")));
        // Price is stale until it is updated
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.warp(block.timestamp + updateWaitWindow);
        balancerOracle.update();
        vm.stopPrank();

        assertEq(balancerOracle.getStatus(token), true);

        vm.warp(block.timestamp + stalePeriod + 1);

        assertEq(balancerOracle.getStatus(token), false);
    }

    function test_update() public {
        _mockUpdateCalls();
        vm.prank(keeper);
        balancerOracle.update();
    }

    function test_update_currentPriceUpdate() public {
        _mockUpdateCalls();
        vm.prank(keeper);
        balancerOracle.update();

        assertNotEq(balancerOracle.currentPrice(), 0);
    }

    function test_update_safePriceUpdate() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        // First 'update()' does not update the 'safePrice'
        assertEq(balancerOracle.safePrice(), 0);

        vm.warp(block.timestamp + updateWaitWindow);
        balancerOracle.update();

        // 'safePrice' is updated on the second call
        assertNotEq(balancerOracle.safePrice(), 0);

        vm.stopPrank();
    }

    function test_update_returnsSafePrice() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        assertEq(balancerOracle.update(), balancerOracle.safePrice());

        vm.warp(block.timestamp + updateWaitWindow);

        assertEq(balancerOracle.update(), balancerOracle.safePrice());
        vm.stopPrank();
    }

    function test_update_multipleCalls() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.warp(block.timestamp + updateWaitWindow);
        balancerOracle.update();
    }

    function test_update_revertIfNotKeeper() public {
        vm.expectRevert();
        balancerOracle.update();
    }

    function test_update_revertsIfInUpdateWaitWindow() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.expectRevert(abi.encodeWithSelector(BalancerOracle.BalancerOracle__update_InUpdateWaitWindow.selector));
        balancerOracle.update();
        vm.stopPrank();
    }

    function test_getStatus_returnTrueOnValidSafePrice() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.warp(block.timestamp + updateWaitWindow);
        vm.startPrank(keeper);
        // Second update will trigger a safePrice update
        balancerOracle.update();

        assertTrue(balancerOracle.getStatus(address(0)));
    }

    function test_getStatus_returnsFalseOnZeroSafePrice() public {
        assertFalse(balancerOracle.getStatus(address(0)));
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        // Status check fail if the safe price is not updated
        assertFalse(balancerOracle.getStatus(address(0)));
    }

    function test_getStatus_returnFalseOnStaleSafePrice() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.warp(block.timestamp + updateWaitWindow);
        vm.startPrank(keeper);
        // Second update will trigger a safePrice update
        balancerOracle.update();

        assertTrue(balancerOracle.getStatus(address(0)));

        vm.warp(block.timestamp + stalePeriod + 1);

        assertFalse(balancerOracle.getStatus(address(0)));
    }

    function test_spot_returnsSafePrice() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.warp(block.timestamp + updateWaitWindow);
        vm.startPrank(keeper);
        // Second update will trigger a safePrice update
        balancerOracle.update();

        assertEq(balancerOracle.spot(address(0)), balancerOracle.safePrice());
    }

    function test_spot_revertsOnInvalidSafePrice() public {
        vm.expectRevert(abi.encodeWithSelector(BalancerOracle.BalancerOracle__spot_invalidPrice.selector));
        balancerOracle.spot(address(0));
    }

    function test_spot_revertsOnStaleSafePrice() public {
        _mockUpdateCalls();
        vm.startPrank(keeper);
        balancerOracle.update();
        vm.warp(block.timestamp + updateWaitWindow);
        vm.startPrank(keeper);
        // Second update will trigger a safePrice update
        balancerOracle.update();
        assertEq(balancerOracle.spot(address(0)), balancerOracle.safePrice());

        vm.warp(block.timestamp + stalePeriod + 1);

        // Price is stale now, spot() should revert
        vm.expectRevert(abi.encodeWithSelector(BalancerOracle.BalancerOracle__spot_invalidPrice.selector));
        balancerOracle.spot(address(0));
    }

    function test_getTokenPrice_revertsOnInvalidTokenIndex() public {
        _mockUpdateCalls();

        // update the mock weights call to return an unsupported amount
        uint256[] memory weights = new uint256[](4);
        weights[0] = weights[1] = weights[2] = weights[3] = 1 ether / 2;
        vm.mockCall(pool, abi.encodeWithSelector(IWeightedPool.getNormalizedWeights.selector), abi.encode(weights));

        vm.startPrank(keeper);
        vm.expectRevert(abi.encodeWithSelector(BalancerOracle.BalancerOracle__getTokenPrice_invalidIndex.selector));
        balancerOracle.update();
    }

    function _mockUpdateCalls() internal {
        uint256[] memory weights = new uint256[](2);
        weights[0] = weights[1] = 1 ether / 2;
        vm.mockCall(pool, abi.encodeWithSelector(IWeightedPool.getNormalizedWeights.selector), abi.encode(weights));

        uint256 totalSupply = 1 ether;
        vm.mockCall(pool, abi.encodeWithSelector(IWeightedPool.totalSupply.selector), abi.encode(totalSupply));

        uint256 poolInvariant = 1 ether;
        vm.mockCall(pool, abi.encodeWithSelector(IWeightedPool.getInvariant.selector), abi.encode(poolInvariant));

        uint256 token0Price = 1 ether;
        vm.mockCall(chainlinkOracle, abi.encodeWithSelector(IOracle.spot.selector, token0), abi.encode(token0Price));

        uint256 token1Price = 1 ether;
        vm.mockCall(chainlinkOracle, abi.encodeWithSelector(IOracle.spot.selector, token1), abi.encode(token1Price));

        uint256 token2Price = 1 ether;
        vm.mockCall(chainlinkOracle, abi.encodeWithSelector(IOracle.spot.selector, token2), abi.encode(token2Price));
    }
}
