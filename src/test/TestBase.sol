// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {LinearInterestRateModelV3} from "@gearbox-protocol/core-v3/contracts/pool/LinearInterestRateModelV3.sol";
import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

import {ICDM} from "../interfaces/ICDM.sol";
import {ICDPVault, ICDPVaultBase, CDPVaultConfig, CDPVaultConstants} from "../interfaces/ICDPVault.sol";
import {CDPVault} from "../CDPVault.sol";

import {PatchedDeal} from "./utils/PatchedDeal.sol";
import {Flashlender} from "../Flashlender.sol";

import {MockOracle} from "./MockOracle.sol";
import {WAD, wdiv} from "../utils/Math.sol";
import {PoolV3} from "../PoolV3.sol";
import {VaultRegistry} from "../VaultRegistry.sol";

import {ACL} from "@gearbox-protocol/core-v2/contracts/core/ACL.sol";
import {AddressProviderV3} from "@gearbox-protocol/core-v3/contracts/core/AddressProviderV3.sol";
import {ContractsRegister} from "@gearbox-protocol/core-v2/contracts/core/ContractsRegister.sol";
import "@gearbox-protocol/core-v3/contracts/interfaces/IAddressProviderV3.sol";
import {PoolQuotaKeeperMock} from "src/test/PoolQuotaKeeperMock.sol";
import {GaugeV3} from "src/quotas/GaugeV3.sol";
import {PoolQuotaKeeperV3} from "src/quotas/PoolQuotaKeeperV3.sol";
import {MockVoter} from "src/test/MockVoter.sol";
import {StakingLPEth} from "src/StakingLPEth.sol";
import {Silo} from "src/Silo.sol";

contract CreditCreator {
    constructor(ICDM cdm) {
        cdm.modifyPermission(msg.sender, true);
    }
}

contract TestBase is Test {
    address public treasury;

    AddressProviderV3 public addressProvider;
    ACL public acl;
    ContractsRegister public contractsRegister;
    PoolV3 internal liquidityPool;
    ERC20PresetMinterPauser internal mockWETH;

    Flashlender internal flashlender;

    VaultRegistry internal vaultRegistry;

    ERC20PresetMinterPauser internal token;
    ERC20PresetMinterPauser internal underlyingToken;
    MockOracle internal oracle;
    PoolQuotaKeeperV3 internal quotaKeeper;
    GaugeV3 internal gauge;
    MockVoter internal voter;
    StakingLPEth internal stakingLpEth;
    Silo internal silo;
    uint256[] internal timestamps;
    uint256 public currentTimestamp;

    PatchedDeal internal dealManager;
    bool public usePatchedDeal = false;

    uint256 internal constant initialGlobalDebtCeiling = 100_000_000_000 ether;

    CreditCreator private creditCreator;

    struct CDPAccessParams {
        address roleAdmin;
        address vaultAdmin;
        address tickManager;
        address pauseAdmin;
        address vaultUnwinder;
    }

    modifier useCurrentTimestamp() virtual {
        vm.warp(currentTimestamp);
        _;
    }
    
    function setUp() public virtual {
        dealManager = new PatchedDeal();
        setCurrentTimestamp(block.timestamp);

        createAccounts();
        createAssets();
        createOracles();
        createCore();
        createAndSetPoolQuotaKeeper();
        //createGaugeAndSetGauge();
        createStakingLpEth();
        labelContracts();
    }

    function createAccounts() internal virtual {
        treasury = vm.addr(uint256(keccak256("treasury")));
    }

    function createAssets() internal virtual {
        token = new ERC20PresetMinterPauser("TestToken", "TST");
        mockWETH = new ERC20PresetMinterPauser("Pool Underlying WETH", "WETH");
    }

    function createAddressProvider() internal virtual {
        acl = new ACL();
        addressProvider = new AddressProviderV3(address(acl));
        addressProvider.setAddress(AP_WETH_TOKEN, address(mockWETH), false);
        addressProvider.setAddress(AP_TREASURY, treasury, false);
        contractsRegister = new ContractsRegister(address(addressProvider));
        addressProvider.setAddress(AP_CONTRACTS_REGISTER, address(contractsRegister), false);
    }

    function createOracles() internal virtual {
        oracle = new MockOracle();
        setOraclePrice(WAD);
    }

    function createAndSetPoolQuotaKeeper() internal virtual {
        quotaKeeper = new PoolQuotaKeeperV3(address(liquidityPool));
        liquidityPool.setPoolQuotaKeeper(address(quotaKeeper));

        voter = new MockVoter();
        voter.setFirstEpochTimestamp(block.timestamp);
        gauge = new GaugeV3(address(liquidityPool), address(voter));
        quotaKeeper.setGauge(address(gauge));
    }

    function createStakingLpEth() internal virtual {
        stakingLpEth = new StakingLPEth(address(liquidityPool), "StakingLPEth", "sLP-ETH");
        vm.label({account: address(stakingLpEth), newLabel: "StakingLPEth"});
        silo = stakingLpEth.silo();
        vm.label({account: address(silo), newLabel: "Silo"});
    }

    function createGaugeAndSetGauge(address vault) internal virtual {
        address token_ = address(CDPVault(vault).token());
        createGaugeAndSetGauge(vault, token_);
    }

    function createGaugeAndSetGauge(address vault, address token_) internal virtual {
        quotaKeeper.setCreditManager(address(token_), address(vault));
        if (!gauge.isTokenAdded(address(token_))) {
            gauge.addQuotaToken(address(token_), 10, 100);
        }
        gauge.setFrozenEpoch(false);
        vm.warp(block.timestamp + 1 weeks);
        vm.prank(address(gauge));
        quotaKeeper.updateRates();
    }

    function createCore() internal virtual {
        LinearInterestRateModelV3 irm = new LinearInterestRateModelV3({
            U_1: 85_00,
            U_2: 95_00,
            R_base: 10_00,
            R_slope1: 20_00,
            R_slope2: 30_00,
            R_slope3: 40_00,
            _isBorrowingMoreU2Forbidden: false
        });
        createAddressProvider();

        liquidityPool = new PoolV3({
            addressProvider_: address(addressProvider),
            underlyingToken_: address(mockWETH),
            interestRateModel_: address(irm),
            totalDebtLimit_: initialGlobalDebtCeiling,
            name_: "Loop Liquidity Pool",
            symbol_: "lpETH "
        });

        underlyingToken = mockWETH;

        uint256 availableLiquidity = 1_000_000 ether;
        mockWETH.mint(address(this), availableLiquidity);
        mockWETH.approve(address(liquidityPool), availableLiquidity);
        liquidityPool.deposit(availableLiquidity, address(this));

        flashlender = new Flashlender(IPoolV3(address(liquidityPool)), 0); // no fee
        liquidityPool.setCreditManagerDebtLimit(address(flashlender), type(uint256).max);
        vaultRegistry = new VaultRegistry();

    }

    function createCDPVault(
        IERC20 token_,
        uint256 debtCeiling,
        uint128 debtFloor,
        uint64 liquidationRatio,
        uint64 liquidationPenalty,
        uint64 liquidationDiscount
    ) internal returns (CDPVault) {
        return
            createCDPVault(
                CDPVaultConstants({
                    pool: liquidityPool,
                    oracle: oracle,
                    token: token_,
                    tokenScale: 10 ** IERC20Metadata(address(token_)).decimals()
                }),
                CDPVaultConfig({
                    debtFloor: debtFloor,
                    liquidationRatio: liquidationRatio,
                    liquidationPenalty: liquidationPenalty,
                    liquidationDiscount: liquidationDiscount,
                    roleAdmin: address(this),
                    vaultAdmin: address(this),
                    pauseAdmin: address(this)
                }),
                debtCeiling
            );
    }

    function createCDPVault(
        CDPVaultConstants memory constants,
        CDPVaultConfig memory configs,
        uint256 debtCeiling
    ) internal returns (CDPVault vault) {
        vault = new CDPVault(constants, configs);

        if (debtCeiling > 0) {
            constants.pool.setCreditManagerDebtLimit(address(vault), debtCeiling);
        }

        vaultRegistry.addVault(ICDPVault(address(vault)));
        vm.label({account: address(vault), newLabel: "CDPVault"});
    }

    function labelContracts() internal virtual {
        vm.label({account: address(token), newLabel: "CollateralToken"});
        vm.label({account: address(mockWETH), newLabel: "UnderlyingToken"});
        vm.label({account: address(oracle), newLabel: "Oracle"});
    }

    function setCurrentTimestamp(uint256 currentTimestamp_) public {
        timestamps.push(currentTimestamp_);
        currentTimestamp = currentTimestamp_;
    }

    function setGlobalDebtCeiling(uint256 _globalDebtCeiling) public {
        liquidityPool.setTotalDebtLimit(_globalDebtCeiling);
    }

    function setOraclePrice(uint256 price) public {
        oracle.updateSpot(address(token), price);
    }

    function createCredit(address to, uint256 amount) public {
        mockWETH.mint(to, amount);
    }

    function credit(address account) internal view returns (uint256) {
        uint256 balance = mockWETH.balanceOf(account);
        return balance;
    }

    function virtualDebt(CDPVault vault, address position) internal view returns (uint256) {
        return vault.virtualDebt(position);
    }

    // function creditLine(address account) internal view returns (uint256) {
    //     (int256 balance, uint256 debtCeiling) = cdm.accounts(account);
    //     return getCreditLine(balance, debtCeiling);
    // }

    function liquidationPrice(ICDPVaultBase vault_) internal returns (uint256) {
        (, uint64 liquidationRatio_) = vault_.vaultConfig();
        return wdiv(vault_.spotPrice(), uint256(liquidationRatio_));
    }

    function _getDefaultVaultConstants() internal view returns (CDPVaultConstants memory) {
        return
            CDPVaultConstants({
                pool: liquidityPool,
                oracle: oracle,
                token: token,
                tokenScale: 10 ** IERC20Metadata(address(token)).decimals()
            });
    }

    function _getDefaultVaultConfig() internal view returns (CDPVaultConfig memory) {
        return
            CDPVaultConfig({
                debtFloor: 0,
                liquidationRatio: 1.25 ether,
                liquidationPenalty: uint64(WAD),
                liquidationDiscount: uint64(WAD),
                roleAdmin: address(this),
                vaultAdmin: address(this),
                pauseAdmin: address(this)
            });
    }


    function getContracts() public view returns (address[] memory contracts) {
        contracts = new address[](5);
        contracts[0] = address(treasury);
        contracts[1] = address(addressProvider);
        contracts[2] = address(liquidityPool);
        contracts[3] = address(acl);
        contracts[4] = address(mockWETH);
    }

    function deal(address token_, address to, uint256 amount) virtual override internal {
        if (usePatchedDeal) {
            uint256 chainId = block.chainid;
            vm.chainId(1);
            dealManager.deal2(token_, to, amount);
            vm.chainId(chainId);
        } else {
            super.deal(token_, to, amount);
        }
    }
}
