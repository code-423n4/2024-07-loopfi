// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {TestBase} from "../TestBase.sol";

import {ChainlinkOracle, MANAGER_ROLE} from "../../oracle/ChainlinkOracle.sol";

import {AggregatorV3Interface} from "../../vendor/AggregatorV3Interface.sol";

contract MockAggregator is AggregatorV3Interface {
    uint80 public roundId;
    int256 public answer;
    uint256 public startedAt;
    uint256 public updatedAt;
    uint80 public answeredInRound;
    uint256 public override version;

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "mock aggregator";
    }

    function getRoundData(
        uint80 /*roundId*/
    )
        external
        view
        override
        returns (uint80 roundId_, int256 answer_, uint256 startedAt_, uint256 updatedAt_, uint80 answeredInRound_)
    {
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId_, int256 answer_, uint256 startedAt_, uint256 updatedAt_, uint80 answeredInRound_)
    {
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }

    function setRoundValue(int256 value) public {
        answer = value;
    }

    function setRoundId(uint80 roundId_, uint80 answeredInRound_) public {
        roundId = roundId_;
        answeredInRound = answeredInRound_;
    }

    function setTimestamp(uint256 startedAt_, uint256 updatedAt_) public {
        startedAt = startedAt_;
        updatedAt = updatedAt_;
    }

    function setVersion(uint256 version_) public {
        version = version_;
    }
}

contract ChainlinkOracleTest is TestBase {
    MockAggregator internal aggregator;
    ChainlinkOracle internal chainlinkOracle;

    uint256 internal staleTime = 1 days;
    uint256 internal aggregatorScale = 10 ** 8;
    int256 internal mockPrice = 1e8;

    function setUp() public override {
        super.setUp();

        aggregator = new MockAggregator();
        aggregator.setRoundValue(mockPrice);
        aggregator.setRoundId(1, 1);
        aggregator.setVersion(1);
        aggregator.setTimestamp(block.timestamp, block.timestamp);

        chainlinkOracle = ChainlinkOracle(
            address(
                new ERC1967Proxy(
                    address(new ChainlinkOracle()),
                    abi.encodeWithSelector(ChainlinkOracle.initialize.selector, address(this), address(this))
                )
            )
        );
        ChainlinkOracle.Oracle[] memory oracles = new ChainlinkOracle.Oracle[](1);
        ChainlinkOracle.Oracle memory oracle = ChainlinkOracle.Oracle({
            aggregator: aggregator,
            stalePeriod: staleTime,
            aggregatorScale: aggregatorScale
        });
        oracles[0] = oracle;
        address[] memory tokens = new address[](1);
        tokens[0] = address(0x1);
        chainlinkOracle.setOracles(tokens, oracles);
    }

    function test_deployOracle() public {
        assertTrue(address(chainlinkOracle) != address(0));
    }

    function test_initialize_accounts(address admin, address manager) public {
        chainlinkOracle = ChainlinkOracle(
            address(
                new ERC1967Proxy(
                    address(new ChainlinkOracle()),
                    abi.encodeWithSelector(ChainlinkOracle.initialize.selector, admin, manager)
                )
            )
        );

        assertTrue(chainlinkOracle.hasRole(MANAGER_ROLE, manager));

        assertTrue(chainlinkOracle.hasRole(chainlinkOracle.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_spot() public {
        uint256 expectedSpot = 1 ether;
        assertTrue(chainlinkOracle.spot(address(0x1)) == expectedSpot);
    }

    function test_spot_revertsOnStaleRound() public {
        vm.warp(block.timestamp + staleTime + 1);

        vm.expectRevert(ChainlinkOracle.ChainlinkOracle__spot_invalidValue.selector);
        chainlinkOracle.spot(address(0x1));
    }

    function test_spot_revertsOnInvalidValue() public {
        aggregator.setRoundValue(0);
        vm.expectRevert(ChainlinkOracle.ChainlinkOracle__spot_invalidValue.selector);
        chainlinkOracle.spot(address(0x1));
    }
}
