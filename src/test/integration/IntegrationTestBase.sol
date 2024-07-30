// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {PRBProxyRegistry} from "prb-proxy/PRBProxyRegistry.sol";
import {PRBProxy} from "prb-proxy/PRBProxy.sol";
import {TestBase} from "../TestBase.sol";
import {wmul, wdiv} from "../../utils/Math.sol";
import {SwapAction, SwapParams, SwapType, SwapProtocol} from "../../proxy/SwapAction.sol";
import {PoolAction, PoolActionParams} from "../../proxy/PoolAction.sol";
import {CDPVault} from "../../CDPVault.sol";
import {IVault as IBalancerVault, JoinKind, JoinPoolRequest} from "../../vendor/IBalancerVault.sol";
import {IUniswapV3Router} from "../../vendor/IUniswapV3Router.sol";
import {ICurvePool} from "../../vendor/ICurvePool.sol";
import {IPActionAddRemoveLiqV3} from "pendle/interfaces/IPActionAddRemoveLiqV3.sol";

/// @dev Base class for tests that use LeverActions, sets up the balancer pools and tokens and provides utility functions
contract IntegrationTestBase is TestBase {
    using SafeERC20 for ERC20;

    // swap protocols
    address internal constant ONE_INCH = 0x1111111254EEB25477B68fb85Ed929f73A960582;
    address internal constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant UNISWAP_V3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address internal constant PENDLE_ROUTER = 0x00000000005BBB0EF59571E58418F9a4357b68A0;
    // tokens
    ERC20 internal constant DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ERC20 internal constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 internal constant USDT = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    ERC20 internal constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 internal constant OHM = ERC20(0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5); // needed for eth to dai swap
    ERC20 internal constant WSTETH = ERC20(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);
    ERC20 internal constant PENDLE_LP_STETH = ERC20(0xC374f7eC85F8C7DE3207a10bB1978bA104bdA3B2); // st-ETH 25DEC25

    address internal constant pendleLP_STETH_Holder = 0x3300eebeEA8239b90a435e403B130a853A0d7DfF;
    address internal constant USDC_CHAINLINK_FEED = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
    address internal constant USDT_CHAINLINK_FEED = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;
    address internal constant DAI_CHAINLINK_FEED = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address internal constant LUSD_CHAINLINK_FEED = 0x3D7aE7E594f2f2091Ad8798313450130d0Aba3a0;
    address internal constant STETH_CHAINLINK_FEED = 0xCfE54B5cD566aB89272946F602D76Ea879CAb4a8;
    address internal constant ETH_CHAINLINK_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address internal constant BAL_CHAINLINK_FEED = 0xdF2917806E30300537aEB49A7663062F4d1F2b5F;

    // action contracts
    PRBProxyRegistry internal prbProxyRegistry;
    SwapAction internal swapAction;
    PoolAction internal poolAction;

    // curve 3Pool
    ICurvePool curve3Pool = ICurvePool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);

    // univ3
    IUniswapV3Router univ3Router = IUniswapV3Router(UNISWAP_V3);

    // balancer parameters
    IBalancerVault internal constant balancerVault = IBalancerVault(BALANCER_VAULT);
    IComposableStablePoolFactory internal constant stablePoolFactory =
        IComposableStablePoolFactory(0x8df6EfEc5547e31B0eb7d1291B511FF8a2bf987c);
    IComposableStablePool internal stablePool;

    IWeightedPoolFactory internal constant weightedPoolFactory =
        IWeightedPoolFactory(0x8E9aa87E45e92bad84D5F8DD1bff34Fb92637dE9);
    IComposableStablePool internal weightedPool;
    bytes32 internal weightedPoolId;

    IComposableStablePool internal weightedUnderlierPool;
    IComposableStablePool internal weightedMockWethPool;
    bytes32 internal weightedUnderlierPoolId;
    bytes32 internal weightedMockWethPoolId;

    bytes32 internal constant daiOhmPoolId = 0x76fcf0e8c7ff37a47a799fa2cd4c13cde0d981c90002000000000000000003d2;
    bytes32 internal constant wethOhmPoolId = 0xd1ec5e215e8148d76f4460e4097fd3d5ae0a35580002000000000000000003d3;
    bytes32 internal constant wethDaiPoolId = 0x0b09dea16768f0799065c475be02919503cb2a3500020000000000000000001a;
    bytes32 internal constant wstEthWethPoolId = 0x32296969ef14eb0c6d29669c550d4a0449130230000200000000000000000080;
    bytes32 internal stablePoolId;

    // Empty join params
    PoolActionParams emptyJoin;

    // base rates
    uint256 internal constant BASE_RATE_1_0 = 1 ether; // 0% base rate
    uint256 internal constant BASE_RATE_1_005 = 1000000000157721789; // 0.5% base rate
    uint256 internal constant BASE_RATE_1_025 = 1000000000780858271; // 2.5% base rate

    function setUp() public virtual override {
        vm.createSelectFork(vm.rpcUrl("mainnet"), getForkBlockNumber());
        super.setUp();

        prbProxyRegistry = new PRBProxyRegistry();
        swapAction = new SwapAction(balancerVault, univ3Router, IPActionAddRemoveLiqV3(PENDLE_ROUTER));
        poolAction = new PoolAction(BALANCER_VAULT, PENDLE_ROUTER);

        // configure balancer pools
        stablePool = _createBalancerTokenPool();
        stablePoolId = stablePool.getPoolId();
        weightedPool = _createBalancerTokenWeightedPool();
        weightedPoolId = weightedPool.getPoolId();
        weightedUnderlierPool = _createBalancerUnderlierWeightedPool();
        weightedUnderlierPoolId = weightedUnderlierPool.getPoolId();
        weightedMockWethPool = _createBalancerMockWethWeightedPool();
        weightedMockWethPoolId = weightedMockWethPool.getPoolId();

        vm.label(address(USDC), "USDC");
        vm.label(address(DAI), "DAI");
        vm.label(address(USDT), "USDT");
        vm.label(address(WETH), "WETH");
        vm.label(address(WSTETH), "wstETH");
        vm.label(address(curve3Pool), "Curve3Pool");
        vm.label(address(stablePool), "balancerStablePool");
        vm.label(address(swapAction), "SwapAction");
        vm.label(address(poolAction), "PoolAction");

        vm.label(address(USDC_CHAINLINK_FEED), "USDC Chainlink Feed");
        vm.label(address(USDT_CHAINLINK_FEED), "USDT Chainlink Feed");
        vm.label(address(DAI_CHAINLINK_FEED), "DAI Chainlink Feed");
        vm.label(address(LUSD_CHAINLINK_FEED), "LUSD Chainlink Feed");
    }

    function getForkBlockNumber() internal pure virtual returns (uint256) {
        return 17055414;
    }

    /// @dev perform balancer swap via swapParams in simulated env and return the return amount
    function _simulateBalancerSwap(SwapParams memory swapParams) internal returns (uint256 retAmount) {
        uint256 snapshot = vm.snapshot();
        retAmount = _balancerSwap(swapParams);
        vm.revertTo(snapshot);
    }

    /// @dev perform multiple balancer swaps via swapParams in simulated env and return the return amounts
    function _simulateBalancerSwapMulti(
        SwapParams memory swap1,
        SwapParams memory swap2
    ) internal returns (uint256 retAmount1, uint256 retAmount2) {
        uint256 snapshot = vm.snapshot();
        retAmount1 = _balancerSwap(swap1);
        retAmount2 = _balancerSwap(swap2);
        vm.revertTo(snapshot);
    }

    /// @dev perform balancer swap via swapParams
    function _balancerSwap(SwapParams memory swapParams) internal returns (uint256 retAmount) {
        uint256 amount = swapParams.swapType == SwapType.EXACT_IN ? swapParams.amount : swapParams.limit;

        // mint assetIn to leverActions so we can execute the swap
        deal(swapParams.assetIn, address(swapAction), amount);

        retAmount = swapAction.swap(swapParams);
    }

    /// @dev create a Stablecoin, USDC, DAI stable pool on Balancer with deep liquidity
    function _createBalancerTokenPool() internal returns (IComposableStablePool stablePool_) {
        // mint the liquidity
        deal(address(DAI), address(this), 5_000_000 * 1e18);
        deal(address(USDC), address(this), 5_000_000 * 1e6);
        deal(address(USDT), address(this), 5_000_000 * 1e6);
        token.mint(address(this), 5_000_000 * 1e18);

        uint256[] memory maxAmountsIn = new uint256[](4);
        address[] memory assets = new address[](4);
        assets[0] = address(DAI);
        assets[1] = address(USDC);
        assets[2] = address(USDT);

        // find the position to place token address, list is already sorted smallest to largest
        bool tokenPlaced;
        address tempAsset;
        for (uint256 i; i < assets.length; i++) {
            if (!tokenPlaced) {
                // check if we can to insert stablecoin at this position
                if (uint160(assets[i]) > uint160(address(token))) {
                    // insert stablecoin into list
                    tokenPlaced = true;
                    tempAsset = assets[i];
                    assets[i] = address(token);
                } else if (i == assets.length - 1) {
                    // stablecoin still not inserted, but we are at the end of the list, insert it here
                    assets[i] = address(token);
                }
            } else {
                // stablecoin has been inserted, move every asset index up
                address placeholder = assets[i];
                assets[i] = tempAsset;
                tempAsset = placeholder;
            }
        }

        // set maxAmountIn and approve balancer vault
        for (uint256 i; i < assets.length; i++) {
            maxAmountsIn[i] = ERC20(assets[i]).balanceOf(address(this));
            ERC20(assets[i]).safeApprove(address(balancerVault), maxAmountsIn[i]);
        }

        // create the pool
        stablePool_ = stablePoolFactory.create(
            "Test Token Pool",
            "FUDT",
            assets,
            200,
            3e14, // swapFee (0.03%)
            address(this) // owner
        );

        // send liquidity to the stable pool
        balancerVault.joinPool(
            stablePool_.getPoolId(),
            address(this),
            address(this),
            JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                userData: abi.encode(JoinKind.INIT, maxAmountsIn),
                fromInternalBalance: false
            })
        );
    }

    function _createBalancerTokenWeightedPool() internal returns (IComposableStablePool pool_) {
        uint256 wethLiquidityAmt = 5_000_000_000 ether;
        deal(address(WETH), address(this), wethLiquidityAmt);
        deal(address(token), address(this), wethLiquidityAmt);

        uint256[] memory maxAmountsIn = new uint256[](2);
        address[] memory assets = new address[](2);
        assets[0] = address(WETH);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 500000000000000000;
        weights[1] = 500000000000000000;

        // find the position to place stablecoin address, list is already sorted smallest to largest
        bool tokenPlaced;
        address tempAsset;
        for (uint256 i; i < assets.length; i++) {
            if (!tokenPlaced) {
                // check if we can to insert stablecoin at this position
                if (uint160(assets[i]) > uint160(address(token))) {
                    // insert stablecoin into list
                    tokenPlaced = true;
                    tempAsset = assets[i];
                    assets[i] = address(token);
                } else if (i == assets.length - 1) {
                    // stablecoin still not inserted, but we are at the end of the list, insert it here
                    assets[i] = address(token);
                }
            } else {
                // stablecoin has been inserted, move every asset index up
                address placeholder = assets[i];
                assets[i] = tempAsset;
                tempAsset = placeholder;
            }
        }

        // set maxAmountIn and approve balancer vault
        for (uint256 i; i < assets.length; i++) {
            maxAmountsIn[i] = ERC20(assets[i]).balanceOf(address(this));
            ERC20(assets[i]).safeApprove(address(balancerVault), maxAmountsIn[i]);
        }

        // create the pool
        pool_ = weightedPoolFactory.create(
            "50WETH-50TOKEN",
            "50WETH-50TOKEN",
            assets,
            weights,
            3e14, // swapFee (0.03%)
            address(this) // owner
        );

        // send liquidity to the stable pool
        balancerVault.joinPool(
            pool_.getPoolId(),
            address(this),
            address(this),
            JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                userData: abi.encode(JoinKind.INIT, maxAmountsIn),
                fromInternalBalance: false
            })
        );
    }

    function _createBalancerMockWethWeightedPool() internal returns (IComposableStablePool pool_) {
        uint256 wethLiquidityAmt = 5_000_000_000 ether;
        deal(address(WETH), address(this), wethLiquidityAmt);
        deal(address(underlyingToken), address(this), wethLiquidityAmt);

        uint256[] memory maxAmountsIn = new uint256[](2);
        address[] memory assets = new address[](2);
        assets[0] = address(WETH);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 500000000000000000;
        weights[1] = 500000000000000000;

        // find the position to place stablecoin address, list is already sorted smallest to largest
        bool tokenPlaced;
        address tempAsset;
        for (uint256 i; i < assets.length; i++) {
            if (!tokenPlaced) {
                // check if we can to insert stablecoin at this position
                if (uint160(assets[i]) > uint160(address(underlyingToken))) {
                    // insert stablecoin into list
                    tokenPlaced = true;
                    tempAsset = assets[i];
                    assets[i] = address(underlyingToken);
                } else if (i == assets.length - 1) {
                    // stablecoin still not inserted, but we are at the end of the list, insert it here
                    assets[i] = address(underlyingToken);
                }
            } else {
                // stablecoin has been inserted, move every asset index up
                address placeholder = assets[i];
                assets[i] = tempAsset;
                tempAsset = placeholder;
            }
        }

        // set maxAmountIn and approve balancer vault
        for (uint256 i; i < assets.length; i++) {
            maxAmountsIn[i] = ERC20(assets[i]).balanceOf(address(this));
            ERC20(assets[i]).safeApprove(address(balancerVault), maxAmountsIn[i]);
        }

        // create the pool
        pool_ = weightedPoolFactory.create(
            "50WETH-50TOKEN",
            "50WETH-50TOKEN",
            assets,
            weights,
            3e14, // swapFee (0.03%)
            address(this) // owner
        );

        // send liquidity to the stable pool
        balancerVault.joinPool(
            pool_.getPoolId(),
            address(this),
            address(this),
            JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                userData: abi.encode(JoinKind.INIT, maxAmountsIn),
                fromInternalBalance: false
            })
        );
    }

    function _createBalancerUnderlierWeightedPool() internal returns (IComposableStablePool pool_) {
        uint256 wethLiquidityAmt = 5_000_000_000 ether;
        deal(address(token), address(this), wethLiquidityAmt);
        deal(address(underlyingToken), address(this), wethLiquidityAmt);

        uint256[] memory maxAmountsIn = new uint256[](2);
        address[] memory assets = new address[](2);
        assets[0] = address(token);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 500000000000000000;
        weights[1] = 500000000000000000;

        // find the position to place stablecoin address, list is already sorted smallest to largest
        bool tokenPlaced;
        address tempAsset;
        for (uint256 i; i < assets.length; i++) {
            if (!tokenPlaced) {
                // check if we can to insert stablecoin at this position
                if (uint160(assets[i]) > uint160(address(underlyingToken))) {
                    // insert stablecoin into list
                    tokenPlaced = true;
                    tempAsset = assets[i];
                    assets[i] = address(underlyingToken);
                } else if (i == assets.length - 1) {
                    // stablecoin still not inserted, but we are at the end of the list, insert it here
                    assets[i] = address(underlyingToken);
                }
            } else {
                // stablecoin has been inserted, move every asset index up
                address placeholder = assets[i];
                assets[i] = tempAsset;
                tempAsset = placeholder;
            }
        }

        // set maxAmountIn and approve balancer vault
        for (uint256 i; i < assets.length; i++) {
            maxAmountsIn[i] = ERC20(assets[i]).balanceOf(address(this));
            ERC20(assets[i]).safeApprove(address(balancerVault), maxAmountsIn[i]);
        }

        // create the pool
        pool_ = weightedPoolFactory.create(
            "50TOKEN-50UNDERLIER",
            "50TOKEN-50UNDERLIER",
            assets,
            weights,
            3e14, // swapFee (0.03%)
            address(this) // owner
        );

        // send liquidity to the stable pool
        balancerVault.joinPool(
            pool_.getPoolId(),
            address(this),
            address(this),
            JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                userData: abi.encode(JoinKind.INIT, maxAmountsIn),
                fromInternalBalance: false
            })
        );
    }

    /// @dev returns the current rate of DAI to WETH in the balancer pool in 1e18
    function _getWethRateInDai() internal view returns (uint256) {
        uint256 daiToWeth = uint256(PriceFeed(0x773616E4d11A78F511299002da57A0a94577F1f4).latestAnswer());
        return (1e18 * 1e18) / daiToWeth;
    }

    function _getDaiRateInWeth() internal view returns (uint256) {
        return uint256(PriceFeed(0x773616E4d11A78F511299002da57A0a94577F1f4).latestAnswer());
    }

    function _getWstETHRateInUSD() internal view returns (uint256) {
        uint256 wstethAmount = IWSTETH(address(WSTETH)).tokensPerStEth();
        uint256 stEthPrice = wdiv(
            uint256(PriceFeed(STETH_CHAINLINK_FEED).latestAnswer()),
            10 ** ERC20(STETH_CHAINLINK_FEED).decimals()
        );
        return wmul(wstethAmount, stEthPrice);
    }

    function _getWETHRateInUSD() internal view returns (uint256) {
        return wdiv(uint256(PriceFeed(ETH_CHAINLINK_FEED).latestAnswer()), 10 ** ERC20(ETH_CHAINLINK_FEED).decimals());
    }

    function _getBALRateInUSD() internal view returns (uint256) {
        return wdiv(uint256(PriceFeed(BAL_CHAINLINK_FEED).latestAnswer()), 10 ** ERC20(BAL_CHAINLINK_FEED).decimals());
    }

    function _virtualDebt(CDPVault vault, address position) internal view returns (uint256) {
        return vault.virtualDebt(position);
    }
}

/// ======== WSTETH INTERFACES ======== ///
interface IWSTETH {
    /**
     * @notice Get amount of stETH for a one wstETH
     * @return Amount of stETH for 1 wstETH
     */
    function stEthPerToken() external view returns (uint256);

    /**
     * @notice Get amount of wstETH for a one stETH
     * @return Amount of wstETH for a 1 stETH
     */
    function tokensPerStEth() external view returns (uint256);
}

/// ======== BALANCER INTERFACES ======== ///

interface IComposableStablePool {
    function getPoolId() external returns (bytes32);
}

interface IComposableStablePoolFactory {
    function create(
        string memory name,
        string memory symbol,
        address[] memory tokens,
        uint256 amplificationParameter,
        uint256 swapFeePercentage,
        address owner
    ) external returns (IComposableStablePool);
}

interface IWeightedPoolFactory {
    function create(
        string memory name,
        string memory symbol,
        address[] memory tokens,
        uint256[] memory normalizedWeights,
        uint256 swapFeePercentage,
        address owner
    ) external returns (IComposableStablePool);
}

interface PriceFeed {
    function latestAnswer() external view returns (int256);
}
