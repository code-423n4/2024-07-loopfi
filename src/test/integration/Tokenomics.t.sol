// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {IVaultRegistry} from "../../interfaces/IVaultRegistry.sol";
import {IMultiFeeDistribution} from "../../reward/interfaces/IMultiFeeDistribution.sol";
import {IPriceProvider} from "../../reward/interfaces/IPriceProvider.sol";
import {IChefIncentivesController} from "../../reward/interfaces/IChefIncentivesController.sol";
import {wdiv} from "../../utils/Math.sol";
import {IVault as IBalancerVault, JoinKind, JoinPoolRequest} from "../../vendor/IBalancerVault.sol";
import {IntegrationTestBase, IComposableStablePool} from "../integration/IntegrationTestBase.sol";
import {CDPVault} from "../../CDPVault.sol";
import {ICDPVault} from "../../interfaces/ICDPVault.sol";
import {ChefIncentivesController} from "../../reward/ChefIncentivesController.sol";
import {EligibilityDataProvider} from "../../reward/EligibilityDataProvider.sol";
import {MultiFeeDistribution} from "../../reward/MultiFeeDistribution.sol";
import {LockedBalance, EarnedBalance} from "../../reward/interfaces/LockedBalance.sol";
import {VaultRegistry} from "../../VaultRegistry.sol";

contract MockPriceProvider is IPriceProvider {
    // Returns the latest price in ether.
    function getTokenPrice() external pure returns (uint256) {
        return 1e18;
    }

    // Returns the latest price in usd.
    function getTokenPriceUsd() external pure returns (uint256) {
        return 2400 ether;
    }

    function getLpTokenPrice() external pure returns (uint256) {
        return 1e18;
    }

    function getLpTokenPriceUsd() external pure returns (uint256) {
        return 2400 ether;
    }

    function getStablecoinUsd() external pure returns (uint256) {
        return 2400 ether;
    }

    function decimals() external pure returns (uint256) {
        return 18;
    }

    function update() external {}

    function getRewardTokenPrice(address /*rewardToken*/, uint256 /*amount*/) external pure returns (uint256) {
        return 1e18;
    }

    function baseAssetChainlinkAdapter() external view returns (address) {}
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

interface IWETH {
    function deposit() external payable;
}

contract RadiantDeployHelper {
    event LoopTokenDeployed(address indexed tokenAddress);
    event PriceProviderDeployed(address indexed priceProviderAddress);
    event WeightedPoolDeployed(address indexed poolAddress);

    using SafeERC20 for ERC20;

    address internal constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    ERC20 internal constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IBalancerVault internal constant balancerVault = IBalancerVault(BALANCER_VAULT);
    IWeightedPoolFactory internal constant weightedPoolFactory =
        IWeightedPoolFactory(0x8E9aa87E45e92bad84D5F8DD1bff34Fb92637dE9);

    address public loopToken;
    IWETH public weth = IWETH(address(WETH));

    uint256 public loopIndex = 0;
    uint256 public wethIndex = 1;

    function deployLoopToken(uint256 mintAmount) external returns (ERC20Mock loopToken_) {
        loopToken_ = new ERC20Mock();
        loopToken_.mint(address(this), mintAmount);
        loopToken = address(loopToken_);
        emit LoopTokenDeployed(loopToken);
    }

    function wrapETH(uint256 amount) external {
        weth.deposit{value: amount}();
    }

    function deployPriceProvider() external returns (MockPriceProvider priceProvider_) {
        priceProvider_ = new MockPriceProvider();
        emit PriceProviderDeployed(address(priceProvider_));
    }

    // Assumes we have WETH and loopToken, will join the whole balance of the contract
    function createWeightedPool() external returns (IComposableStablePool pool_) {
        uint256[] memory maxAmountsIn = new uint256[](2);
        address[] memory assets = new address[](2);
        assets[0] = address(WETH);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 500000000000000000;
        weights[1] = 500000000000000000;

        bool loopTokenPlaced;
        address tempAsset;
        for (uint256 i; i < assets.length; i++) {
            if (!loopTokenPlaced) {
                // check if we can to insert at this position
                if (uint160(assets[i]) > uint160(loopToken)) {
                    loopTokenPlaced = true;
                    tempAsset = assets[i];
                    assets[i] = address(loopToken);
                } else if (i == assets.length - 1) {
                    // still not inserted, but we are at the end of the list, insert it here
                    assets[i] = loopToken;
                }
            } else {
                // token has been inserted, move every asset index up
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

        loopIndex = assets[0] == address(loopToken) ? 0 : 1;
        wethIndex = loopIndex == 0 ? 1 : 0;

        // create the pool
        pool_ = weightedPoolFactory.create(
            "50WETH-50LOOP",
            "50WETH-50LOOP",
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
        emit WeightedPoolDeployed(address(pool_));
    }

    receive() external payable {}
}

contract TokenomicsTest is IntegrationTestBase {
    using SafeERC20 for ERC20;

    CDPVault public vault;
    ChefIncentivesController public incentivesController;
    EligibilityDataProvider public eligibilityDataProvider;
    MultiFeeDistribution public multiFeeDistribution;
    MockPriceProvider public priceProvider;

    ERC20Mock public loopToken;

    RadiantDeployHelper public radiantDeployHelper;

    // mocked contracts
    address public lockZap;
    address public dao;

    // MultiFeeDistribution params
    uint256 public rewardsDuration = 30 days;
    uint256 public rewardsLookback = 5 days;
    uint256 public lockDuration = 30 days;
    uint256 public burnRatio = 50000; // 50%
    uint256 public vestDuration = 30 days;

    //ChefIncentivesController params
    uint256 public rewardsPerSecond = 0.01 ether;
    uint256 public endingTimeCadence = 2 days;

    IComposableStablePool internal govWeightedPool;
    bytes32 internal govWeightedPoolId;
    ERC20 internal lpToken;

    function setUp() public virtual override {
        super.setUp();

        radiantDeployHelper = new RadiantDeployHelper();
        loopToken = radiantDeployHelper.deployLoopToken(5_000_000 ether);

        priceProvider = radiantDeployHelper.deployPriceProvider();

        setOraclePrice(2400 ether);

        treasury = vm.addr(uint256(keccak256("treasury")));
        lockZap = vm.addr(uint256(keccak256("lockZap")));
        dao = vm.addr(uint256(keccak256("dao")));

        deal(address(WETH), address(radiantDeployHelper), 5_000_000 ether);
        govWeightedPool = radiantDeployHelper.createWeightedPool();
        govWeightedPoolId = govWeightedPool.getPoolId();
        lpToken = ERC20(address(govWeightedPool));

        // setup the vault registry
        vault = createCDPVault(token, 100_000 ether, 10 ether, 1 ether, 1 ether, 0);
        createGaugeAndSetGauge(address(vault));

        multiFeeDistribution = MultiFeeDistribution(
            address(
                new ERC1967Proxy(
                    address(new MultiFeeDistribution()),
                    abi.encodeWithSelector(
                        MultiFeeDistribution.initialize.selector,
                        address(loopToken),
                        lockZap,
                        dao,
                        address(priceProvider),
                        rewardsDuration,
                        rewardsLookback,
                        lockDuration,
                        burnRatio,
                        vestDuration
                    )
                )
            )
        );

        eligibilityDataProvider = EligibilityDataProvider(
            address(
                new ERC1967Proxy(
                    address(new EligibilityDataProvider()),
                    abi.encodeWithSelector(
                        EligibilityDataProvider.initialize.selector,
                        IVaultRegistry(address(vaultRegistry)),
                        IMultiFeeDistribution(address(multiFeeDistribution)),
                        IPriceProvider(address(priceProvider))
                    )
                )
            )
        );

        incentivesController = ChefIncentivesController(
            address(
                new ERC1967Proxy(
                    address(new ChefIncentivesController()),
                    abi.encodeWithSelector(
                        ChefIncentivesController.initialize.selector,
                        address(this),
                        address(eligibilityDataProvider),
                        IMultiFeeDistribution(address(multiFeeDistribution)),
                        rewardsPerSecond,
                        address(loopToken),
                        endingTimeCadence
                    )
                )
            )
        );

        uint256 _allocPoint = 100;
        incentivesController.addPool(address(vault), _allocPoint);
        eligibilityDataProvider.setChefIncentivesController(IChefIncentivesController(address(incentivesController)));
        vault.setParameter("rewardController", address(incentivesController));
        _setupMultiFeeDistribution();

        incentivesController.start();

        vm.label(address(vault), "vault");
        vm.label(address(incentivesController), "incentivesController");
        vm.label(address(multiFeeDistribution), "multiFeeDistribution");
        vm.label(address(eligibilityDataProvider), "eligibilityDataProvider");
        vm.label(address(vaultRegistry), "vaultRegistry");
        vm.label(address(priceProvider), "priceProvider");
        vm.label(address(loopToken), "loopToken");
        vm.label(lockZap, "lockZap");
        vm.label(dao, "dao");
        vm.label(treasury, "treasury");
        vm.label(address(lpToken), "stakingToken");
    }

    function _setupMultiFeeDistribution() internal {
        uint256[] memory lockDurations = new uint256[](4);
        uint256[] memory rewardMultipliers = new uint256[](4);
        lockDurations[0] = 2592000;
        lockDurations[1] = 7776000;
        lockDurations[2] = 15552000;
        lockDurations[3] = 31104000;

        rewardMultipliers[0] = 1;
        rewardMultipliers[1] = 4;
        rewardMultipliers[2] = 10;
        rewardMultipliers[3] = 25;

        multiFeeDistribution.setLockTypeInfo(lockDurations, rewardMultipliers);
        multiFeeDistribution.setAddresses(IChefIncentivesController(address(incentivesController)), treasury);
        multiFeeDistribution.setLPToken(address(govWeightedPool));

        address[] memory minters = new address[](1);
        minters[0] = address(incentivesController);
        multiFeeDistribution.setMinters(minters);
    }

    function _registerRewards(uint256 rewardAmount) internal {
        loopToken.mint(address(this), rewardAmount);
        loopToken.transfer(address(incentivesController), rewardAmount);
        incentivesController.registerRewardDeposit(rewardAmount);
    }

    function _borrow(address user, uint256 collateral, uint256 normalDebt) internal {
        token.mint(user, collateral);
        vm.startPrank(user);
        token.approve(address(vault), collateral);
        vault.modifyCollateralAndDebt(user, user, user, int256(collateral), int256(normalDebt));
        vm.stopPrank();
    }

    function _depositInPool(address user, uint256 amount) internal {
        loopToken.mint(user, amount);

        uint256 wethLiquidityAmt = amount;
        deal(address(WETH), user, wethLiquidityAmt);
        address[] memory assets = new address[](2);

        assets[radiantDeployHelper.wethIndex()] = address(WETH);
        assets[radiantDeployHelper.loopIndex()] = address(loopToken);

        uint256[] memory maxAmountsIn = new uint256[](2);
        maxAmountsIn[radiantDeployHelper.wethIndex()] = wethLiquidityAmt;
        maxAmountsIn[radiantDeployHelper.loopIndex()] = amount;

        vm.startPrank(user);
        loopToken.approve(address(balancerVault), amount);
        WETH.approve(address(balancerVault), wethLiquidityAmt);

        balancerVault.joinPool(
            govWeightedPoolId,
            address(user),
            address(user),
            JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                userData: abi.encode(JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, maxAmountsIn),
                fromInternalBalance: false
            })
        );
        vm.stopPrank();
    }

    function test_deploy() public {
        assertNotEq(address(loopToken), address(0));
        assertNotEq(address(vaultRegistry), address(0));
        assertNotEq(address(multiFeeDistribution), address(0));
        assertNotEq(address(eligibilityDataProvider), address(0));
        assertNotEq(address(incentivesController), address(0));
    }

    function test_registerRewards() public {
        uint256 rewardAmount = 1_000_000 ether;
        _registerRewards(rewardAmount);
        assertEq(rewardAmount, incentivesController.depositedRewards());
        assertEq(0, incentivesController.accountedRewards());
        assertEq(rewardAmount, loopToken.balanceOf(address(incentivesController)));
    }

    function test_borrow() public {
        uint256 rewardAmount = 1_000_000 ether;
        _registerRewards(rewardAmount);
        address user = vm.addr(uint256(keccak256("user")));
        uint256 collateral = 100 ether;
        uint256 debt = 50 ether;

        _borrow(user, collateral, debt);

        bool isEligible = eligibilityDataProvider.isEligibleForRewards(user);
        assertEq(isEligible, false);
    }

    function test_borrow_withRewards() public {
        uint256 rewardAmount = 1_000_000 ether;
        _registerRewards(rewardAmount);

        address user = vm.addr(uint256(keccak256("user")));
        uint256 collateral = 100 ether;
        uint256 debt = 50 ether;
        _borrow(user, collateral, debt);

        uint256 requiredUSD = eligibilityDataProvider.requiredUsdValue(user);
        emit log_named_uint("requiredUSD", requiredUSD);

        uint256 depositNeededForReward = 2.51 ether / 2;
        _depositInPool(user, depositNeededForReward);

        uint256 balance = ERC20(address(govWeightedPool)).balanceOf(user);
        emit log_named_uint("lp balance", balance);
        emit log_named_uint("lp balance USD", balance * 2400);

        vm.startPrank(user);
        ERC20(address(govWeightedPool)).approve(address(multiFeeDistribution), balance);
        multiFeeDistribution.stake(balance, user, 0);
        vm.stopPrank();

        uint256 lockedUSD = eligibilityDataProvider.lockedUsdValue(user);
        emit log_named_uint("lockedUSD", lockedUSD);

        eligibilityDataProvider.setPriceToleranceRatio(8000);

        uint256 priceToleranceRatio = eligibilityDataProvider.priceToleranceRatio();
        uint256 requiredValue = (requiredUSD * priceToleranceRatio) / 10000;
        emit log_named_uint("requiredValue", requiredValue);

        bool isEligible = eligibilityDataProvider.isEligibleForRewards(user);
        assertEq(isEligible, true);

        uint256 pendingRewards = incentivesController.allPendingRewards(user);
        assertEq(pendingRewards, 0);
        emit log_named_uint("1 pendingRewards", pendingRewards);

        vm.warp(block.timestamp + 30 days);

        pendingRewards = incentivesController.allPendingRewards(user);
        address[] memory vaults = new address[](1);
        vaults[0] = address(vault);
        uint256[] memory vaultPendingRewards = incentivesController.pendingRewards(user, vaults);
        assertEq(vaultPendingRewards.length, 1);
        assertEq(pendingRewards, vaultPendingRewards[0]);
    }

    function test_claimRewards() public {
        address user = vm.addr(uint256(keccak256("user")));
        _registerRewards(1_000_000 ether);
        _borrow(user, 100 ether, 50 ether);

        uint256 depositNeededForReward = 2.51 ether / 2;
        _depositInPool(user, depositNeededForReward);

        vm.startPrank(user);

        LockedBalance[] memory lockInfo = multiFeeDistribution.lockInfo(user);
        assertEq(lockInfo.length, 0);

        uint256 balance = ERC20(address(govWeightedPool)).balanceOf(user);
        ERC20(address(govWeightedPool)).approve(address(multiFeeDistribution), balance);
        multiFeeDistribution.stake(balance, user, 0);

        vm.warp(block.timestamp + 30 days);
        address[] memory vaults = new address[](1);
        vaults[0] = address(vault);
        uint256 pendingRewards = incentivesController.allPendingRewards(user);
        //uint256[] memory pendingRewards = incentivesController.pendingRewards(user, vaults);

        vm.stopPrank();

        lockInfo = multiFeeDistribution.lockInfo(user);
        assertEq(lockInfo.length, 1);

        // can be called by anyone
        incentivesController.claim(user, vaults);

        (uint256 totalVesting, uint256 unlocked, EarnedBalance[] memory earnedBalances) = multiFeeDistribution
            .earnedBalances(user);

        assertEq(totalVesting, pendingRewards);
        assertEq(unlocked, 0);

        vm.warp(earnedBalances[0].unlockTime + 1);

        vm.startPrank(user);
        uint256 balanceBefore = loopToken.balanceOf(user);
        multiFeeDistribution.withdraw(totalVesting);
        uint256 balanceAfter = loopToken.balanceOf(user);
        vm.stopPrank();
        assertEq(balanceAfter - balanceBefore, totalVesting);
    }

    function test_multipleLocks() public {
        address user = vm.addr(uint256(keccak256("user")));
        _registerRewards(1_000_000 ether);
        _borrow(user, 100 ether, 50 ether);

        uint256 depositNeededForReward = 10 ether;
        _depositInPool(user, depositNeededForReward);

        vm.startPrank(user);

        LockedBalance[] memory lockInfo = multiFeeDistribution.lockInfo(user);
        assertEq(lockInfo.length, 0);

        uint256 totalBalance = ERC20(address(govWeightedPool)).balanceOf(user);

        uint256 lockAmount = totalBalance / 4;
        ERC20(address(govWeightedPool)).approve(address(multiFeeDistribution), lockAmount);
        multiFeeDistribution.stake(lockAmount, user, 0);

        lockInfo = multiFeeDistribution.lockInfo(user);
        assertEq(lockInfo.length, 1);

        ERC20(address(govWeightedPool)).approve(address(multiFeeDistribution), lockAmount);
        multiFeeDistribution.stake(lockAmount, user, 0);

        // we should still have 1 lock because they should be merged
        lockInfo = multiFeeDistribution.lockInfo(user);
        assertEq(lockInfo.length, 1);

        // create a new lock on the same block but with a different type
        ERC20(address(govWeightedPool)).approve(address(multiFeeDistribution), lockAmount);
        multiFeeDistribution.stake(lockAmount, user, 1);

        // we should have 2 locks now because of different end times caused by the different lock types
        lockInfo = multiFeeDistribution.lockInfo(user);
        assertEq(lockInfo.length, 2);

        vm.warp(block.timestamp + multiFeeDistribution.AGGREGATION_EPOCH());

        ERC20(address(govWeightedPool)).approve(address(multiFeeDistribution), lockAmount);
        multiFeeDistribution.stake(lockAmount, user, 1);

        lockInfo = multiFeeDistribution.lockInfo(user);
        assertEq(lockInfo.length, 3);
    }

    function test_rugRewards() public {
        _registerRewards(1_000_000 ether);
        address rugger = vm.addr(uint256(keccak256("rugger")));

        address[] memory minters = new address[](1);
        minters[0] = rugger;
        multiFeeDistribution.setMinters(minters);

        address randomUser;
        for (uint i = 0; i < 20; ++i) {
            randomUser = vm.addr(uint256(keccak256(abi.encode("user", i))));
            uint256 randomUserStake = 20 ether;
            _borrow(randomUser, 1_000 ether, 500 ether);
            _depositInPool(randomUser, randomUserStake);

            vm.startPrank(randomUser);
            uint256 balance = ERC20(address(govWeightedPool)).balanceOf(randomUser);
            ERC20(address(govWeightedPool)).approve(address(multiFeeDistribution), balance);
            multiFeeDistribution.stake(balance, randomUser, 3);
            vm.stopPrank();
            assertEq(eligibilityDataProvider.isEligibleForRewards(randomUser), true);
        }

        LockedBalance[] memory lockInfo = multiFeeDistribution.lockInfo(randomUser);
        uint256 unlockTime = lockInfo[0].unlockTime;
        uint256 lockedAmount = lockInfo[0].amount;

        vm.warp(block.timestamp + unlockTime);

        address[] memory vaults = new address[](1);
        vaults[0] = address(vault);

        for (uint i = 0; i < 20; ++i) {
            randomUser = vm.addr(uint256(keccak256(abi.encode("user", i))));
            incentivesController.claim(randomUser, vaults);
        }

        uint256 totalBalance = loopToken.balanceOf(address(multiFeeDistribution));

        vm.startPrank(rugger);
        multiFeeDistribution.vestTokens(rugger, totalBalance, false);
        (uint256 rugAmount, , ) = multiFeeDistribution.withdrawableBalance(rugger);
        multiFeeDistribution.withdraw(rugAmount);
        assertEq(rugAmount, totalBalance);
        vm.stopPrank();

        for (uint i = 0; i < 20; ++i) {
            randomUser = vm.addr(uint256(keccak256(abi.encode("user", i))));
            (uint256 amount, , ) = multiFeeDistribution.withdrawableBalance(randomUser);
            vm.startPrank(randomUser);
            vm.expectRevert("ERC20: transfer amount exceeds balance");
            multiFeeDistribution.withdraw(amount);

            uint256 balanceBefore = lpToken.balanceOf(randomUser);
            lockInfo = multiFeeDistribution.lockInfo(randomUser);
            lockedAmount = lockInfo[0].amount;
            multiFeeDistribution.withdrawExpiredLocksForWithOptions(randomUser, 0, false);
            uint256 balanceAfter = lpToken.balanceOf(randomUser);
            assertEq(balanceAfter - balanceBefore, lockedAmount);
            vm.stopPrank();
        }
    }
}
