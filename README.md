# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration.

Your audit will use two repos: 
- **an _audit_ repo** (this one), which is used for scoping your audit and for providing information to wardens
- **a _findings_ repo**, where issues are submitted (shared with you after the audit) 

Ultimately, when we launch the audit, this repo will be made public and will contain the smart contracts to be reviewed and all the information needed for audit participants. The findings repo will be made public after the audit report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the audit sponsor (⭐️)**.

---

# Audit setup

## 🐺 C4: Set up repos
- [ ] Create a new private repo named `YYYY-MM-sponsorname` using this repo as a template.
- [ ] Rename this repo to reflect audit date (if applicable)
- [ ] Rename audit H1 below
- [ ] Update pot sizes
  - [ ] Remove the "Bot race findings opt out" section if there's no bot race.
- [ ] Fill in start and end times in audit bullets below
- [ ] Add link to submission form in audit details below
- [ ] Add the information from the scoping form to the "Scoping Details" section at the bottom of this readme.
- [ ] Add matching info to the Code4rena site
- [ ] Add sponsor to this private repo with 'maintain' level access.
- [ ] Send the sponsor contact the url for this repo to follow the instructions below and add contracts here. 
- [ ] Delete this checklist.

# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Confirm that this repo is a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 48 business hours prior to audit start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)

## ⭐️ Sponsor: Repo checklist

- [ ] Modify the [Overview](#overview) section of this `README.md` file. Describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the auditors should keep in mind when reviewing. (Here are two well-constructed examples: [Ajna Protocol](https://github.com/code-423n4/2023-05-ajna) and [Maia DAO Ecosystem](https://github.com/code-423n4/2023-05-maia))
- [ ] Review the Gas award pool amount, if applicable. This can be adjusted up or down, based on your preference - just flag it for Code4rena staff so we can update the pool totals across all comms channels.
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] [This checklist in Notion](https://code4rena.notion.site/Key-info-for-Code4rena-sponsors-f60764c4c4574bbf8e7a6dbd72cc49b4#0cafa01e6201462e9f78677a39e09746) provides some best practices for Code4rena audit repos.

## ⭐️ Sponsor: Final touches
- [ ] Review and confirm the pull request created by the Scout (technical reviewer) who was assigned to your contest. *Note: any files not listed as "in scope" will be considered out of scope for the purposes of judging, even if the file will be part of the deployed contracts.*
- [ ] Check that images and other files used in this README have been uploaded to the repo as a file and then linked in the README using absolute path (e.g. `https://github.com/code-423n4/yourrepo-url/filepath.png`)
- [ ] Ensure that *all* links and image/file paths in this README use absolute paths, not relative paths
- [ ] Check that all README information is in markdown format (HTML does not render on Code4rena.com)
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# LoopFi audit details
- Total Prize Pool: $100000 in USDC
  - HM awards: $81600 in USDC
  - (remove this line if there is no Analysis pool) Analysis awards: XXX XXX USDC (Notion: Analysis pool)
  - QA awards: $3400 in USDC
  - (remove this line if there is no Bot race) Bot Race awards: XXX XXX USDC (Notion: Bot Race pool)
 
  - Judge awards: $8750 in USDC
  - Validator awards: XXX XXX USDC (Notion: Triage fee - final)
  - Scout awards: $500 in USDC
  - (this line can be removed if there is no mitigation) Mitigation Review: XXX XXX USDC (*Opportunity goes to top 3 backstage wardens based on placement in this audit who RSVP.*)
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-07-loopfi/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts July 24, 2024 20:00 UTC
- Ends August 14, 2024 20:00 UTC

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-07-loopfi/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._
## 🐺 C4: Begin Gist paste here (and delete this line)





# Scope

*See [scope.txt](https://github.com/code-423n4/2024-07-loopfi/blob/main/scope.txt)*

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

### Files out of scope

*See [out_of_scope.txt](https://github.com/code-423n4/2024-07-loopfi/blob/main/out_of_scope.txt)*

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

