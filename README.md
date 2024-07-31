# LoopFi audit details

- Total Prize Pool: $100,000 in USDC
  - HM awards: $81,600 in USDC
  - QA awards: $3,400 in USDC
  - Judge awards: $8,750 in USDC
  - Validator awards: $5,750 in USDC
  - Scout awards: $500 in USDC
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-07-loopfi/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts July 25, 2024 20:00 UTC
- Ends August 15, 2024 20:00 UTC

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-07-loopfi/blob/main/4naly3er-report.md).

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

All of the previous findings from the previous audit reports from Watchpug

# Overview

**Loop - boosted restaking yield and points**

Loop is a novel lending protocol that allows

- Loopers to get boosted exposure towards restaking yield and points
- Lenders to earn yield on their ETH
- LOOP LPs to participate in DAO governance and earn platform fees

## Links

- **Previous audits:**  
  - Report #1 <https://notes.watchpug.com/p/18ea3089e2esgBHp>
  - Report #2 <https://notes.watchpug.com/p/1909aa8a565HVvGe>
  - Report #3 <https://notes.watchpug.com/p/190becc04cemgrXz>
  - Report #4 <https://notes.watchpug.com/p/190c8fbf44ek5zZ4>
  - Report #5 <https://notes.watchpug.com/p/190dd9d39acrEJAv>
- **Documentation:** <https://docs.loopfi.xyz/>
- **Website:** <https://www.loopfi.xyz/>
- **X/Twitter:** <https://twitter.com/loopfixyz>
- **Discord:** <https://discord.gg/mVqf2Q5Whg>

---

## Scoping Q &amp; A

### General questions

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |      **PoolV3** will use **WETH** (_0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2_) <br>**CDPVault** will use **PendleLP** tokens (e.g: _0x464F5A15Aca6Fe787Cf54fCF1E8AF6207939d297_, _0xb9e8bb1105382b018c6adfd95fd9272542cc1776_) <br>**Pool** and **swap** actions can use **any ERC-20** to perform swaps|
| Test coverage                           | 69%                       |
| ERC721 used  by the protocol            |          None          |
| ERC777 used by the protocol             |          None           |
| ERC1155 used by the protocol            |          None          |
| Chains the protocol will be deployed on | Ethereum |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      |   Out of scope  |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  |  Out of scope  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) | Out of scope    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 |   Out of scope  |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              | Out of scope    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      | Out of scope    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              | Out of scope    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            | Out of scope    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    | Out of scope    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    | Out of scope    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    | Out of scope    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  | Out of scope    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |  Out of scope   |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | Out of scope    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 |   Out of scope  |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              | Out of scope    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                | Out of scope    |

### External integrations (e.g., Uniswap) behavior in scope

| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  No   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |

### EIP compliance checklist

N/A

# Additional context

## Main invariants

Debt >= Borrowed

## Attack ideas (where to focus for bugs)

- Leverage system
- Interest and quotas debt and repayment
- Liquidations

## All trusted roles in the protocol

Admin roles

## Describe any novel or unique curve logic or mathematical models implemented in the contracts

N/A

## Running tests

```bash
git clone --recurse https://github.com/code-423n4/2024-07-loopfi.git
cd 2024-07-loopfi
cp example.env .env
```

Fill the `MAINNET_RPC_URL` field with your own Alchemy RPC URL in the `.env` file (or try to use a public one like <https://eth.llamarpc.com>)

```bash
forge test
forge coverage
```

# Scope

_See [scope.txt](https://github.com/code-423n4/2024-07-loopfi/blob/main/scope.txt)_

### Files in scope

| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/CDPVault.sol | 1| 1 | 426 | |@openzeppelin/contracts/access/AccessControl.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol<br>@openzeppelin/contracts/utils/math/SafeCast.sol<br>@gearbox-protocol/core-v3/contracts/libraries/CreditLogic.sol<br>@gearbox-protocol/core-v3/contracts/libraries/QuotasLogic.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol|
| /src/Flashlender.sol | 1| **** | 57 | |@openzeppelin/contracts/security/ReentrancyGuard.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol|
| /src/PoolV3.sol | 1| **** | 465 | |@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/interfaces/IERC4626.sol<br>@openzeppelin/contracts/interfaces/IERC20Metadata.sol<br>@openzeppelin/contracts/token/ERC20/ERC20.sol<br>@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol<br>@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol<br>@openzeppelin/contracts/utils/math/Math.sol<br>@openzeppelin/contracts/utils/math/SafeCast.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IAddressProviderV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/ICreditManagerV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/ILinearInterestRateModelV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol<br>@gearbox-protocol/core-v3/contracts/libraries/CreditLogic.sol<br>@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol<br>@gearbox-protocol/core-v3/contracts/traits/ContractsRegisterTrait.sol<br>@gearbox-protocol/core-v2/contracts/libraries/Constants.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol|
| /src/Silo.sol | 1| **** | 20 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol|
| /src/StakingLPEth.sol | 1| **** | 90 | |@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol<br>@openzeppelin/contracts/security/ReentrancyGuard.sol<br>@openzeppelin/contracts/access/Ownable.sol<br>src/Silo.sol|
| /src/VaultRegistry.sol | 1| **** | 60 | |@openzeppelin/contracts/access/AccessControl.sol|
| /src/oracle/BalancerOracle.sol | 1| **** | 91 | |@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol<br>@openzeppelin/contracts/token/ERC20/ERC20.sol|
| /src/oracle/ChainlinkOracle.sol | 1| **** | 53 | |@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol|
| /src/proxy/BaseAction.sol | 1| **** | 17 | ||
| /src/proxy/ERC165Plugin.sol | 1| **** | 12 | |@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol<br>@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol<br>prb-proxy/interfaces/IPRBProxyPlugin.sol|
| /src/proxy/PoolAction.sol | 1| **** | 147 | |@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol|
| /src/proxy/PositionAction.sol | 1| **** | 303 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol|
| /src/proxy/PositionAction20.sol | 1| **** | 30 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol|
| /src/proxy/PositionAction4626.sol | 1| **** | 77 | |@openzeppelin/contracts/interfaces/IERC20.sol<br>@openzeppelin/contracts/interfaces/IERC4626.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol|
| /src/proxy/SwapAction.sol | 1| **** | 176 | |@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol|
| /src/proxy/TransferAction.sol | 1| **** | 51 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>permit2/interfaces/ISignatureTransfer.sol|
| /src/quotas/GaugeV3.sol | 1| **** | 160 | |@gearbox-protocol/core-v3/contracts/interfaces/IGaugeV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IGearStakingV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol<br>@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol|
| /src/quotas/PoolQuotaKeeperV3.sol | 1| **** | 130 | |@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol<br>@gearbox-protocol/core-v3/contracts/traits/ContractsRegisterTrait.sol<br>@gearbox-protocol/core-v3/contracts/libraries/QuotasLogic.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol<br>src/interfaces/IPoolQuotaKeeperV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IGaugeV3.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/ICreditManagerV3.sol<br>@gearbox-protocol/core-v2/contracts/libraries/Constants.sol<br>@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol|
| /src/quotas/QuotasLogic.sol | 1| **** | 28 | |@openzeppelin/contracts/utils/math/SafeCast.sol<br>@gearbox-protocol/core-v2/contracts/libraries/Constants.sol|
| /src/reward/ChefIncentivesController.sol | 1| **** | 576 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol|
| /src/reward/EligibilityDataProvider.sol | 1| **** | 124 | |@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol|
| /src/reward/MultiFeeDistribution.sol | 1| **** | 872 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol|
| /src/reward/RecoverERC20.sol | 1| **** | 11 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol|
| /src/utils/Math.sol | ****| **** | 228 | ||
| /src/utils/Pause.sol | 1| **** | 19 | |@openzeppelin/contracts/access/AccessControl.sol<br>@openzeppelin/contracts/security/Pausable.sol|
| /src/utils/Permission.sol | 1| **** | 26 | ||
| /src/vendor/AggregatorV3Interface.sol | ****| 1 | 3 | ||
| /src/vendor/AuraVault.sol | 1| **** | 194 | |@openzeppelin/contracts/token/ERC20/ERC20.sol<br>@openzeppelin/contracts/interfaces/IERC20.sol<br>@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol<br>@openzeppelin/contracts/interfaces/IERC4626.sol<br>@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts/access/AccessControl.sol<br>@openzeppelin/contracts/utils/math/Math.sol|
| /src/vendor/IAuraPool.sol | ****| 1 | 3 | ||
| /src/vendor/IBalancerVault.sol | ****| 1 | 52 | ||
| /src/vendor/ICurvePool.sol | ****| 1 | 3 | ||
| /src/vendor/IPriceOracle.sol | ****| 1 | 17 | ||
| /src/vendor/IUniswapV3Router.sol | ****| 1 | 33 | ||
| /src/vendor/IWeightedPool.sol | ****| 1 | 3 | ||
| /src/vendor/Imports.sol | ****| **** | 5 | |prb-proxy/PRBProxyRegistry.sol<br>@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol<br>@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol<br>permit2/interfaces/IAllowanceTransfer.sol|
| **Totals** | **26** | **8** | **4562** | | |

Files added to the scope after the start of the contest:

| File   | SLOC | 
| ------ | ---- |
| /src/oracle/PendleLPOracle.sol   | 75 |
| /src/proxy/PositionActionPendle.sol   | 44 |
| **Totals** | **119** |

### Files out of scope

_See [out_of_scope.txt](https://github.com/code-423n4/2024-07-loopfi/blob/main/out_of_scope.txt)_

| File         |
| ------------ |
| ./src/interfaces/IBuffer.sol |
| ./src/interfaces/ICDM.sol |
| ./src/interfaces/ICDPVault.sol |
| ./src/interfaces/ICDPVault_Deployer.sol |
| ./src/interfaces/IFlashlender.sol |
| ./src/interfaces/IInterestRateModel.sol |
| ./src/interfaces/IMinter.sol |
| ./src/interfaces/IOracle.sol |
| ./src/interfaces/IPause.sol |
| ./src/interfaces/IPermission.sol |
| ./src/interfaces/IPoolQuotaKeeperV3.sol |
| ./src/interfaces/IPoolV3.sol |
| ./src/interfaces/IStablecoin.sol |
| ./src/interfaces/IVaultRegistry.sol |
| ./src/reward/interfaces/IBountyManager.sol |
| ./src/reward/interfaces/IChefIncentivesController.sol |
| ./src/reward/interfaces/IEligibilityDataProvider.sol |
| ./src/reward/interfaces/IFeeDistribution.sol |
| ./src/reward/interfaces/IMintableToken.sol |
| ./src/reward/interfaces/IMultiFeeDistribution.sol |
| ./src/reward/interfaces/IPriceProvider.sol |
| ./src/reward/interfaces/IWETH.sol |
| ./src/reward/interfaces/LockedBalance.sol |
| ./src/reward/interfaces/balancer/IWeightedPoolFactory.sol |
| ./src/reward/libraries/RecoverERC20.sol |
| ./src/test/MockOracle.sol |
| ./src/test/MockVoter.sol |
| ./src/test/PoolQuotaKeeperMock.sol |
| ./src/test/TestBase.sol |
| ./src/test/integration/IntegrationTestBase.sol |
| ./src/test/integration/PoolAction.t.sol |
| ./src/test/integration/PositionAction20.lever.t.sol |
| ./src/test/integration/PositionAction20.t.sol |
| ./src/test/integration/SwapAction.t.sol |
| ./src/test/integration/Tokenomics.t.sol |
| ./src/test/integration/TransferAction.t.sol |
| ./src/test/unit/BalancerOracle.t.sol |
| ./src/test/unit/CDPVault.t.sol |
| ./src/test/unit/ChainlinkOracle.t.sol |
| ./src/test/unit/ChefIncentivesController.t.sol |
| ./src/test/unit/EligibilityDataProvider.t.sol |
| ./src/test/unit/Flashlender.t.sol |
| ./src/test/unit/Math.t.sol |
| ./src/test/unit/MultiFeeDistribution.t.sol |
| ./src/test/unit/Pause.t.sol |
| ./src/test/unit/Permission.t.sol |
| ./src/test/unit/Proxy.t.sol |
| ./src/test/unit/StakingLP.t.sol |
| ./src/test/utils/PermitMaker.sol |
| Totals: 49 |

...and everything not explicitly marked in scope

## Miscellaneous

Employees of LoopFi and employees' family members are ineligible to participate in this audit.
