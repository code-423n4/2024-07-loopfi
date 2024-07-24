# Report

- [Report](#report)
  - [Gas Optimizations](#gas-optimizations)
    - [\[GAS-1\] Don't use `_msgSender()` if not supporting EIP-2771](#gas-1-dont-use-_msgsender-if-not-supporting-eip-2771)
    - [\[GAS-2\] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)](#gas-2-a--a--b-is-more-gas-effective-than-a--b-for-state-variables-excluding-arrays-and-mappings)
    - [\[GAS-3\] Use assembly to check for `address(0)`](#gas-3-use-assembly-to-check-for-address0)
    - [\[GAS-4\] `array[index] += amount` is cheaper than `array[index] = array[index] + amount` (or related variants)](#gas-4-arrayindex--amount-is-cheaper-than-arrayindex--arrayindex--amount-or-related-variants)
    - [\[GAS-5\] Using bools for storage incurs overhead](#gas-5-using-bools-for-storage-incurs-overhead)
    - [\[GAS-6\] Cache array length outside of loop](#gas-6-cache-array-length-outside-of-loop)
    - [\[GAS-7\] State variables should be cached in stack variables rather than re-reading them from storage](#gas-7-state-variables-should-be-cached-in-stack-variables-rather-than-re-reading-them-from-storage)
    - [\[GAS-8\] Use calldata instead of memory for function arguments that do not get mutated](#gas-8-use-calldata-instead-of-memory-for-function-arguments-that-do-not-get-mutated)
    - [\[GAS-9\] For Operations that will not overflow, you could use unchecked](#gas-9-for-operations-that-will-not-overflow-you-could-use-unchecked)
    - [\[GAS-10\] Use Custom Errors instead of Revert Strings to save Gas](#gas-10-use-custom-errors-instead-of-revert-strings-to-save-gas)
    - [\[GAS-11\] Avoid contract existence checks by using low level calls](#gas-11-avoid-contract-existence-checks-by-using-low-level-calls)
    - [\[GAS-12\] Stack variable used as a cheaper cache for a state variable is only used once](#gas-12-stack-variable-used-as-a-cheaper-cache-for-a-state-variable-is-only-used-once)
    - [\[GAS-13\] State variables only set in the constructor should be declared `immutable`](#gas-13-state-variables-only-set-in-the-constructor-should-be-declared-immutable)
    - [\[GAS-14\] Functions guaranteed to revert when called by normal users can be marked `payable`](#gas-14-functions-guaranteed-to-revert-when-called-by-normal-users-can-be-marked-payable)
    - [\[GAS-15\] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)](#gas-15-i-costs-less-gas-compared-to-i-or-i--1-same-for---i-vs-i---or-i---1)
    - [\[GAS-16\] Using `private` rather than `public` for constants, saves gas](#gas-16-using-private-rather-than-public-for-constants-saves-gas)
    - [\[GAS-17\] Use shift right/left instead of division/multiplication if possible](#gas-17-use-shift-rightleft-instead-of-divisionmultiplication-if-possible)
    - [\[GAS-18\] Increments/decrements can be unchecked in for-loops](#gas-18-incrementsdecrements-can-be-unchecked-in-for-loops)
    - [\[GAS-19\] Use != 0 instead of \> 0 for unsigned integer comparison](#gas-19-use--0-instead-of--0-for-unsigned-integer-comparison)
    - [\[GAS-20\] `internal` functions not called by the contract should be removed](#gas-20-internal-functions-not-called-by-the-contract-should-be-removed)
  - [Non Critical Issues](#non-critical-issues)
    - [\[NC-1\] Replace `abi.encodeWithSignature` and `abi.encodeWithSelector` with `abi.encodeCall` which keeps the code typo/type safe](#nc-1-replace-abiencodewithsignature-and-abiencodewithselector-with-abiencodecall-which-keeps-the-code-typotype-safe)
    - [\[NC-2\] Missing checks for `address(0)` when assigning values to address state variables](#nc-2-missing-checks-for-address0-when-assigning-values-to-address-state-variables)
    - [\[NC-3\] Array indices should be referenced via `enum`s rather than via numeric literals](#nc-3-array-indices-should-be-referenced-via-enums-rather-than-via-numeric-literals)
    - [\[NC-4\] Constants should be in CONSTANT\_CASE](#nc-4-constants-should-be-in-constant_case)
    - [\[NC-5\] `constant`s should be defined rather than using magic numbers](#nc-5-constants-should-be-defined-rather-than-using-magic-numbers)
    - [\[NC-6\] Control structures do not follow the Solidity Style Guide](#nc-6-control-structures-do-not-follow-the-solidity-style-guide)
    - [\[NC-7\] Critical Changes Should Use Two-step Procedure](#nc-7-critical-changes-should-use-two-step-procedure)
    - [\[NC-8\] Default Visibility for constants](#nc-8-default-visibility-for-constants)
    - [\[NC-9\] Consider disabling `renounceOwnership()`](#nc-9-consider-disabling-renounceownership)
    - [\[NC-10\] Draft Dependencies](#nc-10-draft-dependencies)
    - [\[NC-11\] Unused `error` definition](#nc-11-unused-error-definition)
    - [\[NC-12\] Event is never emitted](#nc-12-event-is-never-emitted)
    - [\[NC-13\] Event missing indexed field](#nc-13-event-missing-indexed-field)
    - [\[NC-14\] Events that mark critical parameter changes should contain both the old and the new value](#nc-14-events-that-mark-critical-parameter-changes-should-contain-both-the-old-and-the-new-value)
    - [\[NC-15\] Function ordering does not follow the Solidity style guide](#nc-15-function-ordering-does-not-follow-the-solidity-style-guide)
    - [\[NC-16\] Functions should not be longer than 50 lines](#nc-16-functions-should-not-be-longer-than-50-lines)
    - [\[NC-17\] Change int to int256](#nc-17-change-int-to-int256)
    - [\[NC-18\] Change uint to uint256](#nc-18-change-uint-to-uint256)
    - [\[NC-19\] Interfaces should be defined in separate files from their usage](#nc-19-interfaces-should-be-defined-in-separate-files-from-their-usage)
    - [\[NC-20\] Lack of checks in setters](#nc-20-lack-of-checks-in-setters)
    - [\[NC-21\] Lines are too long](#nc-21-lines-are-too-long)
    - [\[NC-22\] Missing Event for critical parameters change](#nc-22-missing-event-for-critical-parameters-change)
    - [\[NC-23\] NatSpec is completely non-existent on functions that should have them](#nc-23-natspec-is-completely-non-existent-on-functions-that-should-have-them)
    - [\[NC-24\] Incomplete NatSpec: `@param` is missing on actually documented functions](#nc-24-incomplete-natspec-param-is-missing-on-actually-documented-functions)
    - [\[NC-25\] Incomplete NatSpec: `@return` is missing on actually documented functions](#nc-25-incomplete-natspec-return-is-missing-on-actually-documented-functions)
    - [\[NC-26\] File's first line is not an SPDX Identifier](#nc-26-files-first-line-is-not-an-spdx-identifier)
    - [\[NC-27\] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor](#nc-27-use-a-modifier-instead-of-a-requireif-statement-for-a-special-msgsender-actor)
    - [\[NC-28\] Constant state variables defined more than once](#nc-28-constant-state-variables-defined-more-than-once)
    - [\[NC-29\] Consider using named mappings](#nc-29-consider-using-named-mappings)
    - [\[NC-30\] `address`s shouldn't be hard-coded](#nc-30-addresss-shouldnt-be-hard-coded)
    - [\[NC-31\] Variable names that consist of all capital letters should be reserved for `constant`/`immutable` variables](#nc-31-variable-names-that-consist-of-all-capital-letters-should-be-reserved-for-constantimmutable-variables)
    - [\[NC-32\] Owner can renounce while system is paused](#nc-32-owner-can-renounce-while-system-is-paused)
    - [\[NC-33\] Adding a `return` statement when the function defines a named return variable, is redundant](#nc-33-adding-a-return-statement-when-the-function-defines-a-named-return-variable-is-redundant)
    - [\[NC-34\] Take advantage of Custom Error's return value property](#nc-34-take-advantage-of-custom-errors-return-value-property)
    - [\[NC-35\] Use scientific notation (e.g. `1e18`) rather than exponentiation (e.g. `10**18`)](#nc-35-use-scientific-notation-eg-1e18-rather-than-exponentiation-eg-1018)
    - [\[NC-36\] Use scientific notation for readability reasons for large multiples of ten](#nc-36-use-scientific-notation-for-readability-reasons-for-large-multiples-of-ten)
    - [\[NC-37\] Avoid the use of sensitive terms](#nc-37-avoid-the-use-of-sensitive-terms)
    - [\[NC-38\] Contract does not follow the Solidity style guide's suggested layout ordering](#nc-38-contract-does-not-follow-the-solidity-style-guides-suggested-layout-ordering)
    - [\[NC-39\] Use Underscores for Number Literals (add an underscore every 3 digits)](#nc-39-use-underscores-for-number-literals-add-an-underscore-every-3-digits)
    - [\[NC-40\] Internal and private variables and functions names should begin with an underscore](#nc-40-internal-and-private-variables-and-functions-names-should-begin-with-an-underscore)
    - [\[NC-41\] Event is missing `indexed` fields](#nc-41-event-is-missing-indexed-fields)
    - [\[NC-42\] Constants should be defined rather than using magic numbers](#nc-42-constants-should-be-defined-rather-than-using-magic-numbers)
    - [\[NC-43\] `public` functions not called by the contract should be declared `external` instead](#nc-43-public-functions-not-called-by-the-contract-should-be-declared-external-instead)
    - [\[NC-44\] Variables need not be initialized to zero](#nc-44-variables-need-not-be-initialized-to-zero)
  - [Low Issues](#low-issues)
    - [\[L-1\] `approve()`/`safeApprove()` may revert if the current approval is not zero](#l-1-approvesafeapprove-may-revert-if-the-current-approval-is-not-zero)
    - [\[L-2\] Use a 2-step ownership transfer pattern](#l-2-use-a-2-step-ownership-transfer-pattern)
    - [\[L-3\] Some tokens may revert when zero value transfers are made](#l-3-some-tokens-may-revert-when-zero-value-transfers-are-made)
    - [\[L-4\] Missing checks for `address(0)` when assigning values to address state variables](#l-4-missing-checks-for-address0-when-assigning-values-to-address-state-variables)
    - [\[L-5\] `decimals()` is not a part of the ERC-20 standard](#l-5-decimals-is-not-a-part-of-the-erc-20-standard)
    - [\[L-6\] Do not use deprecated library functions](#l-6-do-not-use-deprecated-library-functions)
    - [\[L-7\] `safeApprove()` is deprecated](#l-7-safeapprove-is-deprecated)
    - [\[L-8\] Deprecated \_setupRole() function](#l-8-deprecated-_setuprole-function)
    - [\[L-9\] Do not leave an implementation contract uninitialized](#l-9-do-not-leave-an-implementation-contract-uninitialized)
    - [\[L-10\] Division by zero not prevented](#l-10-division-by-zero-not-prevented)
    - [\[L-11\] External calls in an un-bounded `for-`loop may result in a DOS](#l-11-external-calls-in-an-un-bounded-for-loop-may-result-in-a-dos)
    - [\[L-12\] External call recipient may consume all transaction gas](#l-12-external-call-recipient-may-consume-all-transaction-gas)
    - [\[L-13\] Initializers could be front-run](#l-13-initializers-could-be-front-run)
    - [\[L-14\] Signature use at deadlines should be allowed](#l-14-signature-use-at-deadlines-should-be-allowed)
    - [\[L-15\] Prevent accidentally burning tokens](#l-15-prevent-accidentally-burning-tokens)
    - [\[L-16\] Owner can renounce while system is paused](#l-16-owner-can-renounce-while-system-is-paused)
    - [\[L-17\] Possible rounding issue](#l-17-possible-rounding-issue)
    - [\[L-18\] Loss of precision](#l-18-loss-of-precision)
    - [\[L-19\] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`](#l-19-solidity-version-0820-may-not-work-on-other-chains-due-to-push0)
    - [\[L-20\] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`](#l-20-use-ownable2steptransferownership-instead-of-ownabletransferownership)
    - [\[L-21\] File allows a version of solidity that is susceptible to an assembly optimizer bug](#l-21-file-allows-a-version-of-solidity-that-is-susceptible-to-an-assembly-optimizer-bug)
    - [\[L-22\] Sweeping may break accounting if tokens with multiple addresses are used](#l-22-sweeping-may-break-accounting-if-tokens-with-multiple-addresses-are-used)
    - [\[L-23\] Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting](#l-23-consider-using-openzeppelins-safecast-library-to-prevent-unexpected-overflows-when-downcasting)
    - [\[L-24\] Unsafe ERC20 operation(s)](#l-24-unsafe-erc20-operations)
    - [\[L-25\] Unsafe solidity low-level call can cause gas grief attack](#l-25-unsafe-solidity-low-level-call-can-cause-gas-grief-attack)
    - [\[L-26\] Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions](#l-26-upgradeable-contract-is-missing-a-__gap50-storage-variable-to-allow-for-new-storage-variables-in-later-versions)
    - [\[L-27\] Upgradeable contract not initialized](#l-27-upgradeable-contract-not-initialized)
  - [Medium Issues](#medium-issues)
    - [\[M-1\] Contracts are vulnerable to fee-on-transfer accounting-related issues](#m-1-contracts-are-vulnerable-to-fee-on-transfer-accounting-related-issues)
    - [\[M-2\] `block.number` means different things on different L2s](#m-2-blocknumber-means-different-things-on-different-l2s)
    - [\[M-3\] Centralization Risk for trusted owners](#m-3-centralization-risk-for-trusted-owners)
      - [Impact](#impact)
    - [\[M-4\] Chainlink's `latestRoundData` might return stale or incorrect results](#m-4-chainlinks-latestrounddata-might-return-stale-or-incorrect-results)
    - [\[M-5\] Missing checks for whether the L2 Sequencer is active](#m-5-missing-checks-for-whether-the-l2-sequencer-is-active)
    - [\[M-6\] Return values of `transfer()`/`transferFrom()` not checked](#m-6-return-values-of-transfertransferfrom-not-checked)
    - [\[M-7\] Unsafe use of `transfer()`/`transferFrom()` with `IERC20`](#m-7-unsafe-use-of-transfertransferfrom-with-ierc20)

## Gas Optimizations

| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Don't use `_msgSender()` if not supporting EIP-2771 | 4 |
| [GAS-2](#GAS-2) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 23 |
| [GAS-3](#GAS-3) | Use assembly to check for `address(0)` | 50 |
| [GAS-4](#GAS-4) | `array[index] += amount` is cheaper than `array[index] = array[index] + amount` (or related variants) | 2 |
| [GAS-5](#GAS-5) | Using bools for storage incurs overhead | 18 |
| [GAS-6](#GAS-6) | Cache array length outside of loop | 8 |
| [GAS-7](#GAS-7) | State variables should be cached in stack variables rather than re-reading them from storage | 32 |
| [GAS-8](#GAS-8) | Use calldata instead of memory for function arguments that do not get mutated | 22 |
| [GAS-9](#GAS-9) | For Operations that will not overflow, you could use unchecked | 794 |
| [GAS-10](#GAS-10) | Use Custom Errors instead of Revert Strings to save Gas | 3 |
| [GAS-11](#GAS-11) | Avoid contract existence checks by using low level calls | 10 |
| [GAS-12](#GAS-12) | Stack variable used as a cheaper cache for a state variable is only used once | 9 |
| [GAS-13](#GAS-13) | State variables only set in the constructor should be declared `immutable` | 39 |
| [GAS-14](#GAS-14) | Functions guaranteed to revert when called by normal users can be marked `payable` | 41 |
| [GAS-15](#GAS-15) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 41 |
| [GAS-16](#GAS-16) | Using `private` rather than `public` for constants, saves gas | 21 |
| [GAS-17](#GAS-17) | Use shift right/left instead of division/multiplication if possible | 2 |
| [GAS-18](#GAS-18) | Increments/decrements can be unchecked in for-loops | 4 |
| [GAS-19](#GAS-19) | Use != 0 instead of > 0 for unsigned integer comparison | 34 |
| [GAS-20](#GAS-20) | `internal` functions not called by the contract should be removed | 7 |

### <a name="GAS-1"></a>[GAS-1] Don't use `_msgSender()` if not supporting EIP-2771

Use `msg.sender` if the code does not implement [EIP-2771 trusted forwarder](https://eips.ethereum.org/EIPS/eip-2771) support

*Instances (4)*:

```solidity
File: src/vendor/AuraVault.sol

201:         _deposit(_msgSender(), receiver, assets, shares);

218:         _deposit(_msgSender(), receiver, assets, shares);

245:         _withdraw(_msgSender(), receiver, owner, assets, shares);

266:         _withdraw(_msgSender(), receiver, owner, assets, shares);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-2"></a>[GAS-2] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)

This saves **16 gas per instance.**

*Instances (23)*:

```solidity
File: src/CDPVault.sol

476:         cdd.cumulativeQuotaInterest += position.cumulativeQuotaInterest;

480:         cdd.accruedInterest += cdd.cumulativeQuotaInterest;

670:                 profit += cumulativeQuotaInterest; // U:[CL-3]

676:                 profit += amountToRepay; // U:[CL-3]

695:                 profit += interestAccrued;

700:                 profit += amountToRepay; // U:[CL-3]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

729:             _expectedLiquidityLU += _calcQuotaRevenueAccrued(timestampLU).toUint128(); // U:[LP-20]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

110:         cooldowns[msg.sender].underlyingAmount += uint152(assets);

123:         cooldowns[msg.sender].underlyingAmount += uint152(assets);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

70:             totalNormalDebt += debt;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/proxy/PoolAction.sol

164:                 joinAmount += upfrontAmount;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction4626.sol

92:             addCollateralAmount += upFrontAmount;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction4626.sol)

```solidity
File: src/quotas/GaugeV3.sol

153:             qp.totalVotesLpSide += votes; // U:[GA-12]

154:             uv.votesLpSide += votes; // U:[GA-12]

156:             qp.totalVotesCaSide += votes; // U:[GA-12]

157:             uv.votesCaSide += votes; // U:[GA-12]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

147:             quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR;

210:             quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR; // U:[PQK-7]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

884:                 extra +=

956:             pending += claimable[i];

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

232:             lockedLP += currentLockData.amount;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/utils/Math.sol

358:         r += 16597577552685614221487285958193947469193820559219878177908093499208371 * (159 - t);

360:         r += 600920179829731861736702779321621459595472258049074101567377883020018308;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

### <a name="GAS-3"></a>[GAS-3] Use assembly to check for `address(0)`

*Saves 6 gas per instance*

*Instances (50)*:

```solidity
File: src/CDPVault.sol

335:         if (address(rewardController) != address(0)) {

511:         if (owner == address(0) || repayAmount == 0) revert CDPVault__liquidatePosition_invalidParameters();

581:         if (owner == address(0) || repayAmount == 0) revert CDPVault__liquidatePosition_invalidParameters();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/proxy/PositionAction.sol

115:         if (flashlender_ == address(0) || swapAction_ == address(0) || poolAction_ == address(0) || vaultRegistry_ == address(0))

115:         if (flashlender_ == address(0) || swapAction_ == address(0) || poolAction_ == address(0) || vaultRegistry_ == address(0))

115:         if (flashlender_ == address(0) || swapAction_ == address(0) || poolAction_ == address(0) || vaultRegistry_ == address(0))

312:             leverParams.auxSwap.assetIn != address(0) &&

355:         if (leverParams.auxSwap.assetIn != address(0) && (leverParams.auxSwap.swapType != SwapType.EXACT_IN))

359:         if (leverParams.auxSwap.assetIn == address(0) && residualRecipient == address(0))

394:         if (leverParams.auxSwap.assetIn != address(0)) {

475:             if (leverParams.auxSwap.assetIn != address(0)) {

510:         if (collateralParams.auxSwap.assetIn != address(0)) {

537:         if (collateralParams.auxSwap.assetIn != address(0)) {

555:         if (creditParams.auxSwap.assetIn == address(0)) {

572:         if (creditParams.auxSwap.assetIn != address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/PositionAction4626.sol

87:         if (leverParams.collateralToken == upFrontToken && leverParams.auxSwap.assetIn == address(0)) {

101:             if (leverParams.auxSwap.assetIn != address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction4626.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

242:         if (_poolConfigurator == address(0)) revert AddressZero();

243:         if (_rdntToken == address(0)) revert AddressZero();

244:         if (address(_eligibleDataProvider) == address(0)) revert AddressZero();

245:         if (address(_mfd) == address(0)) revert AddressZero();

814:         if (_user == address(0)) revert AddressZero();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

100:         if (address(_vaultRegistry) == address(0)) revert AddressZero();

101:         if (address(_multiFeeDistribution) == address(0)) revert AddressZero();

102:         if (address(_priceProvider) == address(0)) revert AddressZero();

119:         if (address(_chef) == address(0)) revert AddressZero();

128:         if (_lpToken == address(0)) revert AddressZero();

129:         if (lpToken != address(0)) revert LPTokenSet();

251:         if (user == address(0)) revert AddressZero();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

232:         if (rdntToken_ == address(0)) revert AddressZero();

233:         if (lockZap_ == address(0)) revert AddressZero();

234:         if (dao_ == address(0)) revert AddressZero();

235:         if (priceProvider_ == address(0)) revert AddressZero();

236:         if (rewardsDuration_ == uint256(0)) revert AmountZero();

237:         if (rewardsLookback_ == uint256(0)) revert AmountZero();

238:         if (lockDuration_ == uint256(0)) revert AmountZero();

239:         if (vestDuration_ == uint256(0)) revert AmountZero();

269:             if (minters_[i] == address(0)) revert AddressZero();

283:         if (bounty == address(0)) revert AddressZero();

294:         if (rewardConverter_ == address(0)) revert AddressZero();

325:         if (address(controller_) == address(0)) revert AddressZero();

326:         if (address(treasury_) == address(0)) revert AddressZero();

337:         if (stakingToken_ == address(0)) revert AddressZero();

338:         if (stakingToken != address(0)) revert AlreadySet();

348:         if (_rewardToken == address(0)) revert AddressZero();

453:         if (lookback == uint256(0)) revert AmountZero();

469:         if (_operationExpenseReceiver == address(0)) revert AddressZero();

1082:         if (bountyManager != address(0)) {

1190:         if (operationExpenseReceiver_ != address(0) && operationExpenseRatio_ != 0) {

1224:         if (token == address(0)) revert AddressZero();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="GAS-4"></a>[GAS-4] `array[index] += amount` is cheaper than `array[index] = array[index] + amount` (or related variants)

When updating a value in an array with arithmetic, using `array[index] += amount` is cheaper than `array[index] = array[index] + amount`.

This is because you avoid an additional `mload` when the array is stored in memory, and an `sload` when the array is stored in storage.

This can be applied for any arithmetic operation including `+=`, `-=`,`/=`,`*=`,`^=`,`&=`, `%=`, `<<=`,`>>=`, and `>>>=`.

This optimization can be particularly significant if the pattern occurs during a loop.

*Saves 28 gas for a storage array, 38 for a memory array*

*Instances (2)*:

```solidity
File: src/reward/ChefIncentivesController.sol

645:                 userBaseClaimable[_user] = userBaseClaimable[_user] + pending;

828:                     userBaseClaimable[_user] = userBaseClaimable[_user] + pending;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

### <a name="GAS-5"></a>[GAS-5] Using bools for storage incurs overhead

Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (18)*:

```solidity
File: src/PoolV3.sol

82:     bool public locked;

107:     mapping(address => bool) internal _allowed;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/VaultRegistry.sol

17:     mapping(ICDPVault => bool) private registeredVaults;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/quotas/GaugeV3.sol

47:     bool public override epochFrozen;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

142:     bool public persistRewardsPerSecond;

161:     mapping(address => bool) private validRTokens;

173:     mapping(address => bool) public eligibilityExempt;

206:     mapping(address => bool) public authorizedContracts;

209:     mapping(address => bool) public whitelist;

211:     bool public whitelistActive;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

54:     mapping(address => bool) public lastEligibleStatus;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

90:     mapping(address => bool) public autocompoundEnabled;

128:     mapping(address => bool) public minters;

131:     mapping(address => bool) public autoRelockDisabled;

137:     bool public mintersAreSet;

155:     mapping(address => bool) public isRewardToken;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Permission.sol

26:     mapping(address owner => mapping(address caller => bool permitted)) private _permitted;

29:     mapping(address owner => mapping(address manager => bool permitted)) private _permittedAgents;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

### <a name="GAS-6"></a>[GAS-6] Cache array length outside of loop

If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (8)*:

```solidity
File: src/oracle/BalancerOracle.sol

126:         for (uint256 i = 0; i < weights.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

46:         for (uint256 i = 0; i < _tokens.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PoolAction.sol

81:                 for (uint256 i = 0; i < assets.length; ) {

116:         for (uint256 i = 0; i < assets.length; ) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

230:         for (uint256 i = lpLockData.length; i > 0; ) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

696:         for (uint256 i = earnings.length; i > 0; ) {

754:         uint256 amount = _withdrawExpiredLocksFor(msg.sender, true, true, _userLocks[msg.sender].length);

857:         _withdrawExpiredLocksFor(user, false, true, _userLocks[user].length);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="GAS-7"></a>[GAS-7] State variables should be cached in stack variables rather than re-reading them from storage

The instances below point to the second+ access of a state variable within a function. Caching of a state variable replaces each Gwarmaccess (100 gas) with a much cheaper stack read. Other less obvious fixes/optimizations include having local memory caches of state variable structs, or having local caches of state variable contracts/addresses.

*Saves 100 gas per instance*

*Instances (32)*:

```solidity
File: src/CDPVault.sol

441:             uint256 amount = wmul(abs(deltaCollateral), tokenScale);

457:             IPoolV3(pool).updateQuotaRevenue(quotaRevenueChange); // U:[PQK-15]

568:         poolUnderlying.safeTransferFrom(msg.sender, address(pool), penalty);

569:         IPoolV3Loop(address(pool)).mintProfit(penalty);

572:             IPoolV3(pool).updateQuotaRevenue(_calcQuotaRevenueChange(-int(debtData.debt - newDebt))); // U:[PQK-15]

630:             IPoolV3(pool).updateQuotaRevenue(quotaRevenueChange); // U:[PQK-15]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

421:                 IERC20(underlyingToken).safeTransfer({to: treasury, value: assetsSent - amountToUser}); // U:[LP-8,9]

551:             address treasury_ = treasury;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

137:         emit CooldownDurationUpdated(previousDuration, cooldownDuration);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/oracle/BalancerOracle.sol

121:         uint256 totalSupply = IWeightedPool(pool).totalSupply();

135:         currentPrice = wdiv(wmul(totalPi, IWeightedPool(pool).getInvariant()), totalSupply);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/proxy/PositionAction.sol

323:                 _transferFrom(upFrontToken, collateralizer, self, upFrontAmount, permitParams);

328:         IPermission(leverParams.vault).modifyPermission(leverParams.position, self, true);

330:             IERC3156FlashBorrower(self),

331:             address(underlyingToken),

335:         IPermission(leverParams.vault).modifyPermission(leverParams.position, self, false);

366:             ICreditFlashBorrower(self),

370:         IPermission(leverParams.vault).modifyPermission(leverParams.position, self, false);

404:             address(swapAction),

424:         underlyingToken.forceApprove(address(flashlender), addDebt);

477:                     address(swapAction),

489:         underlyingToken.forceApprove(address(flashlender), subDebt);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/SwapAction.sol

322:             (, address[] memory primarySwapPath) = abi.decode(swapParams.args, (bytes32[], address[]));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

219:         IPoolV3(pool).setQuotaRevenue(quotaRevenue); // U:[PQK-7]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

599:         if (_user == address(mfd) || eligibilityExempt[_user]) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

1204:             r.rewardPerSecond = ((reward + leftover) * 1e12) / rewardsDuration;

1208:         r.periodFinish = block.timestamp + rewardsDuration;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

205:         IPool(rewardPool).deposit(assets, address(this));

222:         IPool(rewardPool).deposit(assets, address(this));

293:         IERC20(asset()).safeApprove(rewardPool, amountIn);

294:         IPool(rewardPool).deposit(amountIn, address(this));

331:         amount = amount + (auraReward * _getAuraSpot()) / IOracle(feed).spot(asset());

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-8"></a>[GAS-8] Use calldata instead of memory for function arguments that do not get mutated

When a function with a `memory` array is called externally, the `abi.decode()` step has to use a for-loop to copy each index of the `calldata` to the `memory` index. Each iteration of this for-loop costs at least 60 gas (i.e. `60 * <mem_array>.length`). Using `calldata` directly bypasses this loop.

If the array is passed to an `internal` function which passes the array to another internal function where the array is modified and therefore `memory` is used in the `external` call, it's still more gas-efficient to use `calldata` when the `external` function uses modifiers, since the modifiers may prevent the internal functions from being called. Structs have the same overhead as an array of length one.

 *Saves 60 gas per instance*

*Instances (22)*:

```solidity
File: src/proxy/PoolAction.sol

100:     function join(PoolActionParams memory poolActionParams) public {

146:         PoolActionParams memory poolActionParams,

195:     function exit(PoolActionParams memory poolActionParams) public returns (uint256 retAmount) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/SwapAction.sol

98:     function swap(SwapParams memory swapParams) public returns (uint256 retAmount) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

493:     function pendingRewards(address _user, address[] memory _tokens) public view returns (uint256[] memory) {

518:     function claim(address _user, address[] memory _tokens) public whenNotPaused {

813:     function manualStopEmissionsFor(address _user, address[] memory _tokens) public isWhitelisted {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

864:     function getReward(address[] memory rewardTokens_) public {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

280:     function claim(uint256[] memory amounts, uint256 maxAmountIn) external returns (uint256 amountIn) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IBalancerVault.sol

126:         SingleSwap memory singleSwap,

127:         FundManagement memory funds,

163:         BatchSwapStep[] memory swaps,

164:         address[] memory assets,

165:         FundManagement memory funds,

166:         int256[] memory limits,

206:         JoinPoolRequest memory request

248:         ExitPoolRequest memory request

286:         BatchSwapStep[] memory swaps,

287:         address[] memory assets,

288:         FundManagement memory funds

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IBalancerVault.sol)

```solidity
File: src/vendor/IPriceOracle.sol

51:         OracleAverageQuery[] memory queries

85:         OracleAccumulatorQuery[] memory queries

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IPriceOracle.sol)

### <a name="GAS-9"></a>[GAS-9] For Operations that will not overflow, you could use unchecked

*Instances (794)*:

```solidity
File: src/CDPVault.sol

4: import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

5: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

6: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

8: import {ICDPVaultBase, CDPVaultConstants, CDPVaultConfig} from "./interfaces/ICDPVault.sol";

9: import {IOracle} from "./interfaces/IOracle.sol";

11: import {WAD, toInt256, toUint64, max, min, add, sub, wmul, wdiv, wmulUp, abs} from "./utils/Math.sol";

12: import {Permission} from "./utils/Permission.sol";

13: import {Pause, PAUSER_ROLE} from "./utils/Pause.sol";

15: import {IChefIncentivesController} from "./reward/interfaces/IChefIncentivesController.sol";

16: import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

17: import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

18: import {CreditLogic} from "@gearbox-protocol/core-v3/contracts/libraries/CreditLogic.sol";

19: import {QuotasLogic} from "@gearbox-protocol/core-v3/contracts/libraries/QuotasLogic.sol";

20: import {IPoolQuotaKeeperV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol";

59:     uint256 constant INDEX_PRECISION = 10 ** 9;

97:         uint256 collateral; // [wad]

98:         uint256 debt; // [wad]

99:         uint256 lastDebtUpdate; // [timestamp]

241:         int256 deltaCollateral = -toInt256(tokenAmount);

273:         int256 deltaDebt = -toInt256(amount);

316:         position.debt = newDebt; // U:[CM-10,11]

317:         position.cumulativeIndexLastUpdate = newCumulativeIndex; // U:[CM-10,11]

318:         position.lastDebtUpdate = uint64(block.number); // U:[CM-10,11]

329:             totalDebt_ = totalDebt_ + (newDebt - currentDebt);

331:             totalDebt_ = totalDebt_ - (currentDebt - newDebt);

393:                 uint256(deltaDebt), // delta debt

395:                 debtData.cumulativeIndexNow, // current cumulative base interest index in Ray

397:             ); // U:[CM-10]

401:             pool.lendCreditAccount(uint256(deltaDebt), creditor); // F:[CM-20]

406:                 amount = maxRepayment; // U:[CM-11]

407:                 deltaDebt = -toInt256(maxRepayment);

420:                     amount, // delta debt

422:                     debtData.cumulativeIndexNow, // current cumulative base interest index in Ray

427:             quotaRevenueChange = _calcQuotaRevenueChange(-int(debtData.debt - newDebt));

428:             pool.repayCreditAccount(debtData.debt - newDebt, profit, 0); // U:[CM-11]

457:             IPoolV3(pool).updateQuotaRevenue(quotaRevenueChange); // U:[PQK-15]

476:         cdd.cumulativeQuotaInterest += position.cumulativeQuotaInterest;

480:         cdd.accruedInterest += cdd.cumulativeQuotaInterest;

494:         outstandingQuotaInterest = outstandingInterestDelta; // U:[CM-24]

531:         uint256 penalty = wmul(repayAmount, WAD - liqConfig_.liquidationPenalty);

539:         poolUnderlying.safeTransferFrom(msg.sender, address(pool), repayAmount - penalty);

552:                 deltaDebt, // delta debt

554:                 debtData.cumulativeIndexNow, // current cumulative base interest index in Ray

561:         position = _modifyPosition(owner, position, newDebt, newCumulativeIndex, -toInt256(takeCollateral), totalDebt);

563:         pool.repayCreditAccount(debtData.debt - newDebt, profit, 0); // U:[CM-11]

571:         if (debtData.debt - newDebt != 0) {

572:             IPoolV3(pool).updateQuotaRevenue(_calcQuotaRevenueChange(-int(debtData.debt - newDebt))); // U:[PQK-15]

607:         uint256 loss = calcTotalDebt(debtData) - repayAmount;

620:             -toInt256(takeCollateral),

624:         pool.repayCreditAccount(debtData.debt, 0, loss); // U:[CM-11]

628:         int256 quotaRevenueChange = _calcQuotaRevenueChange(-int(debtData.debt));

630:             IPoolV3(pool).updateQuotaRevenue(quotaRevenueChange); // U:[PQK-15]

669:                 amountToRepay -= cumulativeQuotaInterest; // U:[CL-3]

670:                 profit += cumulativeQuotaInterest; // U:[CL-3]

672:                 newCumulativeQuotaInterest = 0; // U:[CL-3]

675:                 uint256 quotaInterestPaid = amountToRepay; // U:[CL-3]

676:                 profit += amountToRepay; // U:[CL-3]

677:                 amountToRepay = 0; // U:[CL-3]

679:                 newCumulativeQuotaInterest = uint128(cumulativeQuotaInterest - quotaInterestPaid); // U:[CL-3]

693:                 amountToRepay -= interestAccrued;

695:                 profit += interestAccrued;

700:                 profit += amountToRepay; // U:[CL-3]

701:                 amountToRepay = 0; // U:[CL-3]

704:                     (INDEX_PRECISION * cumulativeIndexNow * cumulativeIndexLastUpdate) /

705:                     (INDEX_PRECISION *

706:                         cumulativeIndexNow -

707:                         (INDEX_PRECISION * profit * cumulativeIndexLastUpdate) /

708:                         debt); // U:[CL-3]

713:         newDebt = debt - amountToRepay;

723:         return (amount * cumulativeIndexNow) / cumulativeIndexLastUpdate - amount;

736:         return debtData.debt + debtData.accruedInterest; //+ debtData.accruedFees;

741:         return IPoolV3(pool).poolQuotaKeeper(); // U:[CM-47]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

4: import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

5: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

6: import {IFlashlender, IERC3156FlashBorrower, ICreditFlashBorrower} from "./interfaces/IFlashlender.sol";

7: import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

8: import {wmul} from "./utils/Math.sol";

95:         uint256 total = amount + fee;

106:         pool.repayCreditAccount(total - fee, fee, 0);

123:         uint256 total = amount + fee;

134:         pool.repayCreditAccount(total - fee, fee, 0);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

7: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

9: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

10: import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

11: import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

12: import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

13: import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

14: import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

16: import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

17: import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

18: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

21: import {IAddressProviderV3, AP_TREASURY, NO_VERSION_CONTROL} from "@gearbox-protocol/core-v3/contracts/interfaces/IAddressProviderV3.sol";

22: import {ICreditManagerV3} from "@gearbox-protocol/core-v3/contracts/interfaces/ICreditManagerV3.sol";

23: import {ILinearInterestRateModelV3} from "@gearbox-protocol/core-v3/contracts/interfaces/ILinearInterestRateModelV3.sol";

24: import {IPoolQuotaKeeperV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol";

25: import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

28: import {CreditLogic} from "@gearbox-protocol/core-v3/contracts/libraries/CreditLogic.sol";

29: import {ACLNonReentrantTrait} from "@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol";

30: import {ContractsRegisterTrait} from "@gearbox-protocol/core-v3/contracts/traits/ContractsRegisterTrait.sol";

33: import {RAY, MAX_WITHDRAW_FEE, SECONDS_PER_YEAR, PERCENTAGE_FACTOR} from "@gearbox-protocol/core-v2/contracts/libraries/Constants.sol";

35: import {ICDM} from "./interfaces/ICDM.sol";

38: import "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

131:         if (msg.sender != poolQuotaKeeper) revert CallerNotPoolQuotaKeeperException(); // U:[LP-2C]

137:             revert CallerNotCreditManagerException(); // U:[PQK-4]

142:         if (locked) revert PoolV3LockedException(); // U:[LP-2C]

160:         ACLNonReentrantTrait(addressProvider_) // U:[LP-1A]

162:         ERC4626(IERC20(underlyingToken_)) // U:[LP-1B]

163:         ERC20(name_, symbol_) // U:[LP-1B]

164:         ERC20Permit(name_) // U:[LP-1B]

165:         nonZeroAddress(underlyingToken_) // U:[LP-1A]

166:         nonZeroAddress(interestRateModel_) // U:[LP-1A]

168:         addressProvider = addressProvider_; // U:[LP-1B]

169:         underlyingToken = underlyingToken_; // U:[LP-1B]

174:         }); // U:[LP-1B]

176:         lastBaseInterestUpdate = uint40(block.timestamp); // U:[LP-1B]

177:         _baseInterestIndexLU = uint128(RAY); // U:[LP-1B]

179:         interestRateModel = interestRateModel_; // U:[LP-1B]

180:         emit SetInterestRateModel(interestRateModel_); // U:[LP-1B]

188:         _setTotalDebtLimit(totalDebtLimit_); // U:[LP-1B]

203:         return IERC20(underlyingToken).balanceOf(address(this)); // U:[LP-3]

209:         return _expectedLiquidityLU + _calcBaseInterestAccrued() + _calcQuotaRevenueAccrued(); // U:[LP-4]

237:         whenNotPaused // U:[LP-2A]

238:         nonReentrant // U:[LP-2B]

239:         nonZeroAddress(receiver) // U:[LP-5]

242:         uint256 assetsReceived = _amountMinusFee(assets); // U:[LP-6]

243:         shares = _convertToShares(assetsReceived); // U:[LP-6]

244:         _deposit(receiver, assets, assetsReceived, shares); // U:[LP-6]

253:         shares = deposit(assets, receiver); // U:[LP-2A,2B,5,6]

254:         emit Refer(receiver, referralCode, assets); // U:[LP-6]

267:         whenNotPaused // U:[LP-2A]

268:         nonReentrant // U:[LP-2B]

269:         nonZeroAddress(receiver) // U:[LP-5]

272:         uint256 assetsReceived = _convertToAssets(shares); // U:[LP-7]

273:         assets = _amountWithFee(assetsReceived); // U:[LP-7]

274:         _deposit(receiver, assets, assetsReceived, shares); // U:[LP-7]

283:         assets = mint(shares, receiver); // U:[LP-2A,2B,5,7]

284:         emit Refer(receiver, referralCode, assets); // U:[LP-7]

299:         whenNotPaused // U:[LP-2A]

301:         nonReentrant // U:[LP-2B]

302:         nonZeroAddress(receiver) // U:[LP-5]

306:         uint256 assetsSent = _amountWithWithdrawalFee(assetsToUser); // U:[LP-8]

307:         shares = _convertToShares(assetsSent); // U:[LP-8]

308:         _withdraw(receiver, owner, assetsSent, assets, assetsToUser, shares); // U:[LP-8]

323:         whenNotPaused // U:[LP-2A]

325:         nonReentrant // U:[LP-2B]

326:         nonZeroAddress(receiver) // U:[LP-5]

329:         uint256 assetsSent = _convertToAssets(shares); // U:[LP-9]

331:         assets = _amountMinusFee(assetsToUser); // U:[LP-9]

332:         _withdraw(receiver, owner, assetsSent, assets, assetsToUser, shares); // U:[LP-9]

337:         shares = _convertToShares(_amountMinusFee(assets)); // U:[LP-10]

342:         return _amountWithFee(_convertToAssets(shares)); // U:[LP-10]

347:         return _convertToShares(_amountWithWithdrawalFee(_amountWithFee(assets))); // U:[LP-10]

352:         return _amountMinusFee(_amountMinusWithdrawalFee(_convertToAssets(shares))); // U:[LP-10]

357:         return paused() ? 0 : type(uint256).max; // U:[LP-11]

362:         return paused() ? 0 : type(uint256).max; // U:[LP-11]

372:                 ); // U:[LP-11]

377:         return paused() ? 0 : Math.min(balanceOf(owner), _convertToShares(availableLiquidity())); // U:[LP-11]

385:         IERC20(underlyingToken).safeTransferFrom({from: msg.sender, to: address(this), value: assetsSent}); // U:[LP-6,7]

391:         }); // U:[LP-6,7]

393:         _mint(receiver, shares); // U:[LP-6,7]

394:         emit Deposit(msg.sender, receiver, assetsSent, shares); // U:[LP-6,7]

409:         if (msg.sender != owner) _spendAllowance({owner: owner, spender: msg.sender, amount: shares}); // U:[LP-8,9]

410:         _burn(owner, shares); // U:[LP-8,9]

413:             expectedLiquidityDelta: -assetsSent.toInt256(),

414:             availableLiquidityDelta: -assetsSent.toInt256(),

416:         }); // U:[LP-8,9]

418:         IERC20(underlyingToken).safeTransfer({to: receiver, value: amountToUser}); // U:[LP-8,9]

421:                 IERC20(underlyingToken).safeTransfer({to: treasury, value: assetsSent - amountToUser}); // U:[LP-8,9]

424:         emit Withdraw(msg.sender, receiver, owner, assetsReceived, shares); // U:[LP-8,9]

431:         return assets; //(assets == 0 || supply == 0) ? assets : assets.mulDiv(supply, totalAssets(), rounding);

438:         return shares; //(supply == 0) ? shares : shares.mulDiv(totalAssets(), supply, rounding);

467:         borrowable = _borrowable(_totalDebt); // U:[LP-12]

468:         if (borrowable == 0) return 0; // U:[LP-12]

470:         borrowable = Math.min(borrowable, _borrowable(_creditManagerDebt[creditManager])); // U:[LP-12]

471:         if (borrowable == 0) return 0; // U:[LP-12]

476:         }); // U:[LP-12]

478:         borrowable = Math.min(borrowable, available); // U:[LP-12]

490:         creditManagerOnly // U:[LP-2C]

491:         whenNotPaused // U:[LP-2A]

492:         nonReentrant // U:[LP-2B]

497:         uint128 totalBorrowed_ = _totalDebt.borrowed + borrowedAmountU128;

498:         uint128 cmBorrowed_ = cmDebt.borrowed + borrowedAmountU128;

500:             revert CreditManagerCantBorrowException(); // U:[LP-2C,13A]

505:             availableLiquidityDelta: -borrowedAmount.toInt256(),

507:         }); // U:[LP-13B]

509:         cmDebt.borrowed = cmBorrowed_; // U:[LP-13B]

510:         _totalDebt.borrowed = totalBorrowed_; // U:[LP-13B]

512:         IERC20(underlyingToken).safeTransfer({to: creditAccount, value: borrowedAmount}); // U:[LP-13B]

513:         emit Borrow(msg.sender, creditAccount, borrowedAmount); // U:[LP-13B]

536:         creditManagerOnly // U:[LP-2C]

537:         whenNotPaused // U:[LP-2A]

538:         nonReentrant // U:[LP-2B]

545:             revert CallerNotCreditManagerException(); // U:[LP-2C,14A]

549:             _mint(treasury, convertToShares(profit)); // U:[LP-14B]

558:                         loss: convertToAssets(sharesToBurn - sharesInTreasury)

559:                     }); // U:[LP-14D]

563:             _burn(treasury_, sharesToBurn); // U:[LP-14C,14D]

567:             expectedLiquidityDelta: -loss.toInt256(),

570:         }); // U:[LP-14B,14C,14D]

572:         _totalDebt.borrowed -= repaidAmountU128; // U:[LP-14B,14C,14D]

573:         cmDebt.borrowed = cmBorrowed - repaidAmountU128; // U:[LP-14B,14C,14D]

575:         emit Repay(msg.sender, repaidAmount, profit, loss); // U:[LP-14B,14C,14D]

587:             return limit - borrowed;

608:             ((baseInterestRate_ * _totalDebt.borrowed) * (PERCENTAGE_FACTOR - withdrawFee)) /

609:             PERCENTAGE_FACTOR /

610:             assets; // U:[LP-15]

616:         if (block.timestamp == timestampLU) return _baseInterestIndexLU; // U:[LP-16]

617:         return _calcBaseInterestIndex(timestampLU); // U:[LP-16]

628:         if (block.timestamp == timestampLU) return 0; // U:[LP-17]

629:         return _calcBaseInterestAccrued(timestampLU); // U:[LP-17]

647:         uint256 expectedLiquidity_ = (expectedLiquidity().toInt256() + expectedLiquidityDelta).toUint256();

648:         uint256 availableLiquidity_ = (availableLiquidity().toInt256() + availableLiquidityDelta).toUint256();

652:             _baseInterestIndexLU = _calcBaseInterestIndex(lastBaseInterestUpdate_).toUint128(); // U:[LP-18]

657:             lastQuotaRevenueUpdate = uint40(block.timestamp); // U:[LP-18]

660:         _expectedLiquidityLU = expectedLiquidity_.toUint128(); // U:[LP-18]

667:             .toUint128(); // U:[LP-18]

672:         return (_totalDebt.borrowed * baseInterestRate().calcLinearGrowth(timestamp)) / RAY;

677:         return (_baseInterestIndexLU * (RAY + baseInterestRate().calcLinearGrowth(timestamp))) / RAY;

696:         nonReentrant // U:[LP-2B]

700:         _setQuotaRevenue(uint256(quotaRevenue().toInt256() + quotaRevenueDelta)); // U:[LP-19]

710:         nonReentrant // U:[LP-2B]

711:         poolQuotaKeeperOnly // U:[LP-2C]

713:         _setQuotaRevenue(newQuotaRevenue); // U:[LP-20]

719:         if (block.timestamp == timestampLU) return 0; // U:[LP-21]

720:         return _calcQuotaRevenueAccrued(timestampLU); // U:[LP-21]

729:             _expectedLiquidityLU += _calcQuotaRevenueAccrued(timestampLU).toUint128(); // U:[LP-20]

730:             lastQuotaRevenueUpdate = uint40(block.timestamp); // U:[LP-20]

732:         _quotaRevenue = newQuotaRevenue.toUint96(); // U:[LP-20]

751:         configuratorOnly // U:[LP-2C]

752:         nonZeroAddress(newInterestRateModel) // U:[LP-22A]

754:         interestRateModel = newInterestRateModel; // U:[LP-22B]

755:         _updateBaseInterest(0, 0, false); // U:[LP-22B]

756:         emit SetInterestRateModel(newInterestRateModel); // U:[LP-22B]

766:         configuratorOnly // U:[LP-2C]

767:         nonZeroAddress(newPoolQuotaKeeper) // U:[LP-23A]

770:             revert IncompatiblePoolQuotaKeeperException(); // U:[LP-23C]

773:         poolQuotaKeeper = newPoolQuotaKeeper; // U:[LP-23D]

776:         _setQuotaRevenue(newQuotaRevenue); // U:[LP-23D]

778:         emit SetPoolQuotaKeeper(newPoolQuotaKeeper); // U:[LP-23D]

788:         controllerOnly // U:[LP-2C]

790:         _setTotalDebtLimit(newLimit); // U:[LP-24]

803:         controllerOnly // U:[LP-2C]

804:         nonZeroAddress(creditManager) // U:[LP-25A]

808:                 revert IncompatibleCreditManagerException(); // U:[LP-25C]

810:             _creditManagerSet.add(creditManager); // U:[LP-25D]

811:             emit AddCreditManager(creditManager); // U:[LP-25D]

813:         _creditManagerDebt[creditManager].limit = _convertToU128(newLimit); // U:[LP-25D]

814:         emit SetCreditManagerDebtLimit(creditManager, newLimit); // U:[LP-25D]

824:         controllerOnly // U:[LP-2C]

827:             revert IncorrectParameterException(); // U:[LP-26A]

831:         withdrawFee = newWithdrawFee.toUint16(); // U:[LP-26B]

832:         emit SetWithdrawFee(newWithdrawFee); // U:[LP-26B]

859:         _totalDebt.limit = newLimit; // U:[LP-1B,24]

860:         emit SetTotalDebtLimit(limit); // U:[LP-1B,24]

881:         return (amount * PERCENTAGE_FACTOR) / (PERCENTAGE_FACTOR - withdrawFee);

886:         return (amount * (PERCENTAGE_FACTOR - withdrawFee)) / PERCENTAGE_FACTOR;

906:         }); // U:[LP-14B,14C,14D]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

4: import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

5: import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

3: import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

4: import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

5: import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

6: import "src/Silo.sol";

109:         cooldowns[msg.sender].cooldownEnd = uint104(block.timestamp) + cooldownDuration;

110:         cooldowns[msg.sender].underlyingAmount += uint152(assets);

122:         cooldowns[msg.sender].cooldownEnd = uint104(block.timestamp) + cooldownDuration;

123:         cooldowns[msg.sender].underlyingAmount += uint152(assets);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

4: import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

5: import {ICDPVault} from "./interfaces/ICDPVault.sol";

6: import {Permission} from "./utils/Permission.sol";

7: import {Pause, PAUSER_ROLE} from "./utils/Pause.sol";

8: import {IVaultRegistry} from "./interfaces/IVaultRegistry.sol";

70:             totalNormalDebt += debt;

73:                 ++i;

84:                 vaultList[i] = vaultList[vaultLen - 1];

90:                 ++i;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

4: import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

5: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

6: import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

8: import {wdiv, WAD, wpow, wmul} from "../utils/Math.sol";

9: import {IOracle, MANAGER_ROLE} from "../interfaces/IOracle.sol";

10: import {IVault} from "../vendor/IBalancerVault.sol";

11: import {IWeightedPool} from "../vendor/IWeightedPool.sol";

110:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {

115:         if (block.timestamp - lastUpdate < updateWaitWindow) revert BalancerOracle__update_InUpdateWaitWindow();

126:         for (uint256 i = 0; i < weights.length; i++) {

145:     function getStatus(address /*token*/) public view virtual override returns (bool status) {

151:         status = (safePrice != 0) && block.timestamp - lastUpdate < stalePeriod;

158:     function spot(address /*token*/) external view virtual override returns (uint256 price) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

4: import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

5: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

7: import {AggregatorV3Interface} from "../vendor/AggregatorV3Interface.sol";

9: import {wdiv} from "../utils/Math.sol";

10: import {IOracle, MANAGER_ROLE} from "../interfaces/IOracle.sol";

46:         for (uint256 i = 0; i < _tokens.length; i++) {

70:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {}

99:             uint80 /*roundId*/,

101:             uint256 /*startedAt*/,

103:             uint80 /*answeredInRound*/

105:             isValid = (answer > 0 && block.timestamp - updatedAt <= oracle.stalePeriod);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/ERC165Plugin.sol

4: import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

5: import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

7: import {IPRBProxyPlugin} from "prb-proxy/interfaces/IPRBProxyPlugin.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/ERC165Plugin.sol)

```solidity
File: src/proxy/PoolAction.sol

4: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

5: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

6: import {TransferAction, PermitParams} from "./TransferAction.sol";

8: import {IVault, JoinKind, JoinPoolRequest, ExitKind, ExitPoolRequest} from "../vendor/IBalancerVault.sol";

87:                         ++i;

122:                 ++i;

164:                 joinAmount += upfrontAmount;

169:                 uint256 assetIndex = i - (skipIndex ? 1 : 0);

180:                     i++;

229:                 outIndex++;

233:                 ++i;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction.sol

3: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

4: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

5: import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

6: import {IPermission} from "../interfaces/IPermission.sol";

7: import {ICDPVault} from "../interfaces/ICDPVault.sol";

8: import {toInt256, wmul, min} from "../utils/Math.sol";

9: import {TransferAction, PermitParams} from "./TransferAction.sol";

10: import {BaseAction} from "./BaseAction.sol";

11: import {SwapAction, SwapParams, SwapType} from "./SwapAction.sol";

12: import {PoolAction, PoolActionParams} from "./PoolAction.sol";

13: import {IVaultRegistry} from "../interfaces/IVaultRegistry.sol";

15: import {IFlashlender, IERC3156FlashBorrower, ICreditFlashBorrower} from "../interfaces/IFlashlender.sol";

283:                 ++i;

321:                 IERC20(upFrontToken).safeTransfer(self, upFrontAmount); // if tokens are on the proxy then just transfer

380:         address /*initiator*/,

381:         address /*token*/,

413:         uint256 addDebt = amount + fee;

432:         address /*initiator*/,

433:         uint256 /*amount*/,

434:         uint256 /*fee*/,

453:             -toInt256(subDebt)

469:         uint256 residualAmount = withdrawnCollateral - swapAmountIn;

589:             -toInt256(creditParams.amount)

607:             uint256 remainder = swapParams.limit - retAmount;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/PositionAction20.sol

4: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

5: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

7: import {ICDPVault} from "../interfaces/ICDPVault.sol";

9: import {PositionAction, LeverParams} from "./PositionAction.sol";

39:     function _onDeposit(address vault, address position, address /*src*/, uint256 amount) internal override returns (uint256) {

50:     function _onWithdraw(address vault, address position, address /*dst*/, uint256 amount) internal override returns (uint256) {

61:         address /*upFrontToken*/,

66:         uint256 addCollateralAmount = swapAmountOut + upFrontAmount;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction20.sol)

```solidity
File: src/proxy/PositionAction4626.sol

4: import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

5: import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

6: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

8: import {ICDPVault} from "../interfaces/ICDPVault.sol";

10: import {PositionAction, LeverParams, PoolActionParams} from "./PositionAction.sol";

41:     function _onDeposit(address vault, address /*position*/, address src, uint256 amount) internal override returns (uint256) {

61:     function _onWithdraw(address vault, address /*position*/, address dst, uint256 amount) internal override returns (uint256) {

92:             addCollateralAmount += upFrontAmount;

124:             IERC4626(leverParams.collateralToken).deposit(addCollateralAmount, address(this)) +

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction4626.sol)

```solidity
File: src/proxy/SwapAction.sol

4: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

5: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

7: import {IUniswapV3Router, ExactInputParams, ExactOutputParams, decodeLastToken} from "../vendor/IUniswapV3Router.sol";

8: import {IVault, SwapKind, BatchSwapStep, FundManagement} from "../vendor/IBalancerVault.sol";

10: import {toInt256, abs} from "../utils/Math.sol";

12: import {TransferAction, PermitParams} from "./TransferAction.sol";

31:     uint256 amount; // Exact amount in or exact amount out depending on swapType

32:     uint256 limit; // Min amount out or max amount in depending on swapType

130:             IERC20(swapParams.assetIn).safeTransfer(swapParams.recipient, swapParams.limit - retAmount);

172:         int256[] memory limits = new int256[](pathLength + 1); // limit for each asset, leave as 0 to autocalculate

211:             bytes memory userData; // empty bytes, not used

221:                         assetInIndex: i + inIncrement,

222:                         assetOutIndex: i + outIncrement,

223:                         amount: 0, // 0 to autocalculate

226:                     ++i;

229:             swaps[0].amount = amount; // amount always pertains to the first swap

238:             limits[0] = toInt256(amount); // positive signifies tokens going into the vault from the caller

239:             limits[pathLength] = -toInt256(limit); // negative signifies tokens going out of the vault to the caller

243:             limits[0] = -toInt256(amount);

324:             token = primarySwapPath[primarySwapPath.length - 1];

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/proxy/TransferAction.sol

4: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

5: import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

6: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

8: import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

63:                 bytes.concat(params.r, params.s, bytes1(params.v)) // Construct signature

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/TransferAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

8: import {IGaugeV3, QuotaRateParams, UserVotes} from "@gearbox-protocol/core-v3/contracts/interfaces/IGaugeV3.sol";

9: import {IGearStakingV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IGearStakingV3.sol";

10: import {IPoolQuotaKeeperV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol";

11: import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

14: import {ACLNonReentrantTrait} from "@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol";

17: import {CallerNotVoterException, IncorrectParameterException, TokenNotAllowedException, InsufficientVotesException} from "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

57:         nonZeroAddress(_voter) // U:[GA-01]

59:         pool = _pool; // U:[GA-01]

60:         voter = _voter; // U:[GA-01]

61:         epochLastUpdate = IGearStakingV3(_voter).getCurrentEpoch(); // U:[GA-01]

62:         epochFrozen = true; // U:[GA-01]

63:         emit SetFrozenEpoch(true); // U:[GA-01]

68:         _revertIfCallerNotVoter(); // U:[GA-02]

74:         _checkAndUpdateEpoch(); // U:[GA-14]

79:         uint16 epochNow = IGearStakingV3(voter).getCurrentEpoch(); // U:[GA-14]

82:             epochLastUpdate = epochNow; // U:[GA-14]

86:                 _poolQuotaKeeper().updateRates(); // U:[GA-14]

89:             emit UpdateEpoch(epochNow); // U:[GA-14]

98:         uint256 len = tokens.length; // U:[GA-15]

99:         rates = new uint16[](len); // U:[GA-15]

102:             for (uint256 i; i < len; ++i) {

103:                 address token = tokens[i]; // U:[GA-15]

105:                 if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-15]

107:                 QuotaRateParams memory qrp = quotaRateParams[token]; // U:[GA-15]

109:                 uint96 votesLpSide = qrp.totalVotesLpSide; // U:[GA-15]

110:                 uint96 votesCaSide = qrp.totalVotesCaSide; // U:[GA-15]

111:                 uint256 totalVotes = votesLpSide + votesCaSide; // U:[GA-15]

115:                     : uint16((uint256(qrp.minRate) * votesCaSide + uint256(qrp.maxRate) * votesLpSide) / totalVotes); // U:[GA-15]

133:         onlyVoter // U:[GA-02]

135:         (address token, bool lpSide) = abi.decode(extraData, (address, bool)); // U:[GA-10,11,12]

136:         _vote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-10,11,12]

145:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

147:         _checkAndUpdateEpoch(); // U:[GA-11]

149:         QuotaRateParams storage qp = quotaRateParams[token]; // U:[GA-12]

153:             qp.totalVotesLpSide += votes; // U:[GA-12]

154:             uv.votesLpSide += votes; // U:[GA-12]

156:             qp.totalVotesCaSide += votes; // U:[GA-12]

157:             uv.votesCaSide += votes; // U:[GA-12]

160:         emit Vote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-12]

176:         onlyVoter // U:[GA-02]

178:         (address token, bool lpSide) = abi.decode(extraData, (address, bool)); // U:[GA-10,11,13]

179:         _unvote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-10,11,13]

188:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

190:         _checkAndUpdateEpoch(); // U:[GA-11]

192:         QuotaRateParams storage qp = quotaRateParams[token]; // U:[GA-13]

193:         UserVotes storage uv = userTokenVotes[user][token]; // U:[GA-13]

198:                 qp.totalVotesLpSide -= votes; // U:[GA-13]

199:                 uv.votesLpSide -= votes; // U:[GA-13]

204:                 qp.totalVotesCaSide -= votes; // U:[GA-13]

205:                 uv.votesCaSide -= votes; // U:[GA-13]

209:         emit Unvote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-13]

239:         nonZeroAddress(token) // U:[GA-04]

240:         configuratorOnly // U:[GA-03]

243:             revert TokenNotAllowedException(); // U:[GA-04]

245:         _checkParams({minRate: minRate, maxRate: maxRate}); // U:[GA-04]

252:         }); // U:[GA-05]

256:             quotaKeeper.addQuotaToken({token: token}); // U:[GA-05]

259:         emit AddQuotaToken({token: token, minRate: minRate, maxRate: maxRate}); // U:[GA-05]

270:         nonZeroAddress(token) // U: [GA-04]

271:         controllerOnly // U: [GA-03]

284:         nonZeroAddress(token) // U: [GA-04]

285:         controllerOnly // U: [GA-03]

292:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-06A, GA-06B]

294:         _checkParams(minRate, maxRate); // U:[GA-04]

296:         QuotaRateParams storage qrp = quotaRateParams[token]; // U:[GA-06A, GA-06B]

298:         qrp.minRate = minRate; // U:[GA-06A, GA-06B]

299:         qrp.maxRate = maxRate; // U:[GA-06A, GA-06B]

301:         emit SetQuotaTokenParams({token: token, minRate: minRate, maxRate: maxRate}); // U:[GA-06A, GA-06B]

307:             revert IncorrectParameterException(); // U:[GA-04]

313:         return quotaRateParams[token].maxRate != 0; // U:[GA-08]

324:             revert CallerNotVoterException(); // U:[GA-02]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

7: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

10: import {ACLNonReentrantTrait} from "@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol";

11: import {ContractsRegisterTrait} from "@gearbox-protocol/core-v3/contracts/traits/ContractsRegisterTrait.sol";

12: import {QuotasLogic} from "@gearbox-protocol/core-v3/contracts/libraries/QuotasLogic.sol";

14: import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

15: import {IPoolQuotaKeeperV3, TokenQuotaParams, AccountQuota} from "src/interfaces/IPoolQuotaKeeperV3.sol";

16: import {IGaugeV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IGaugeV3.sol";

17: import {ICreditManagerV3} from "@gearbox-protocol/core-v3/contracts/interfaces/ICreditManagerV3.sol";

19: import {PERCENTAGE_FACTOR, RAY} from "@gearbox-protocol/core-v2/contracts/libraries/Constants.sol";

22: import "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

82:         pool = _pool; // U:[PQK-1]

83:         underlying = IPoolV3(_pool).asset(); // U:[PQK-1]

147:             quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR;

150:                 ++i;

166:         gaugeOnly // U:[PQK-3]

169:             revert TokenAlreadyAddedException(); // U:[PQK-6]

173:         quotaTokensSet.add(token); // U:[PQK-5]

174:         totalQuotaParams[token].cumulativeIndexLU = 1; // U:[PQK-5]

176:         emit AddQuotaToken(token); // U:[PQK-5]

186:         gaugeOnly // U:[PQK-3]

189:         uint16[] memory rates = IGaugeV3(gauge).getRates(tokens); // U:[PQK-7]

191:         uint256 quotaRevenue; // U:[PQK-7]

199:             TokenQuotaParams storage tokenQuotaParams = totalQuotaParams[token]; // U:[PQK-7]

206:             ); // U:[PQK-7]

208:             tokenQuotaParams.rate = rate; // U:[PQK-7]

210:             quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR; // U:[PQK-7]

212:             emit UpdateTokenQuotaRate(token, rate); // U:[PQK-7]

215:                 ++i;

219:         IPoolV3(pool).setQuotaRevenue(quotaRevenue); // U:[PQK-7]

220:         lastQuotaRateUpdate = uint40(block.timestamp); // U:[PQK-7]

230:         configuratorOnly // U:[PQK-2]

233:             gauge = _gauge; // U:[PQK-8]

234:             emit SetGauge(_gauge); // U:[PQK-8]

244:         configuratorOnly // U:[PQK-2]

273:             revert TokenIsNotQuotedException(); // U:[PQK-14]

279:         if (msg.sender != gauge) revert CallerNotGaugeException(); // U:[PQK-3]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/quotas/QuotasLogic.sol

6: import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

7: import {RAY, SECONDS_PER_YEAR, PERCENTAGE_FACTOR} from "@gearbox-protocol/core-v2/contracts/libraries/Constants.sol";

9: uint192 constant RAY_DIVIDED_BY_PERCENTAGE = uint192(RAY / PERCENTAGE_FACTOR);

24:                 + RAY_DIVIDED_BY_PERCENTAGE * (block.timestamp - lastQuotaRateUpdate) * rate / SECONDS_PER_YEAR

25:         ); // U:[QL-1]

35:         return uint128(uint256(quoted) * (cumulativeIndexNow - cumulativeIndexLU) / RAY); // U:[QL-2]

40:         return change * int256(uint256(rate)) / int16(PERCENTAGE_FACTOR);

54:             uint96 maxQuotaCapacity = limit - totalQuoted;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

4: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

5: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

6: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

7: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

8: import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

10: import {RecoverERC20} from "./RecoverERC20.sol";

11: import {IMultiFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";

12: import {IEligibilityDataProvider} from "./interfaces/IEligibilityDataProvider.sol";

14: import {ICDPVault} from "../interfaces/ICDPVault.sol";

34:         uint256 allocPoint; // How many allocation points assigned to this vault.

35:         uint256 lastRewardTime; // Last second that reward distribution occurs.

36:         uint256 accRewardPerShare; // Accumulated rewards per share, times ACC_REWARD_PRECISION. See below.

305:         totalAllocPoint = totalAllocPoint + _allocPoint;

326:             _totalAllocPoint = _totalAllocPoint - pool.allocPoint + _allocPoints[i];

329:                 i++;

356:             uint128 offset = uint128(block.timestamp - startTime);

359:                     i++;

365:                 rewardsPerSecond = uint256(emissionSchedule[i - 1].rewardsPerSecond);

382:                 i++;

403:                 if (_startTimeOffsets[i - 1] > _startTimeOffsets[i]) revert NotAscending();

410:                 if (_startTimeOffsets[i] < block.timestamp - startTime) revert InvalidStart();

419:                 i++;

458:                 i++;

480:         accountedRewards = accountedRewards + reward;

481:         pool.accRewardPerShare = pool.accRewardPerShare + newAccRewardPerShare;

503:                 accRewardPerShare = accRewardPerShare + newAccRewardPerShare;

505:             claimable[i] = (user.amount * accRewardPerShare) / ACC_REWARD_PRECISION - user.rewardDebt;

507:                 i++;

538:             uint256 rewardDebt = (user.amount * pool.accRewardPerShare) / ACC_REWARD_PRECISION;

539:             pending = pending + rewardDebt - user.rewardDebt;

543:                 i++;

643:             uint256 pending = (amount * accRewardPerShare) / ACC_REWARD_PRECISION - user.rewardDebt;

645:                 userBaseClaimable[_user] = userBaseClaimable[_user] + pending;

648:         pool.totalSupply = pool.totalSupply - user.amount;

650:         user.rewardDebt = (_balance * accRewardPerShare) / ACC_REWARD_PRECISION;

651:         pool.totalSupply = pool.totalSupply + _balance;

700:                     vaultInfo[registeredTokens[i]].totalSupply + newBal - registeredBal

704:                 i++;

723:                 i++;

800:                 _handleActionAfterForToken(token, _user, 0, pool.totalSupply - user.amount);

803:                 i++;

826:                 uint256 pending = (amount * accRewardPerShare) / ACC_REWARD_PRECISION - user.rewardDebt;

828:                     userBaseClaimable[_user] = userBaseClaimable[_user] + pending;

830:                 uint256 newTotalSupply = pool.totalSupply - amount;

838:                 i++;

873:         if (endingTime.lastUpdatedTime + endingTime.updateCadence > block.timestamp) {

884:                 extra +=

885:                     ((pool.lastRewardTime - lastAllPoolUpdate) * pool.allocPoint * rewardsPerSecond) /

889:                 i++;

898:             uint256 newEndTime = (unclaimedRewards + extra) / rewardsPerSecond + lastAllPoolUpdate;

921:         depositedRewards = depositedRewards + _amount;

935:         return depositedRewards - accountedRewards;

956:             pending += claimable[i];

958:                 i++;

988:             uint256 duration = block.timestamp - pool.lastRewardTime;

989:             uint256 rawReward = duration * rewardsPerSecond;

995:             newReward = (rawReward * pool.allocPoint) / _totalAllocPoint;

996:             newAccRewardPerShare = (newReward * ACC_REWARD_PRECISION) / lpSupply;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

4: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

5: import {IMultiFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";

6: import {IChefIncentivesController} from "./interfaces/IChefIncentivesController.sol";

7: import {IPriceProvider} from "./interfaces/IPriceProvider.sol";

8: import {LockedBalance, Balances} from "./interfaces/LockedBalance.sol";

9: import {IVaultRegistry} from "../interfaces/IVaultRegistry.sol";

189:         required = (totalNormalDebt * requiredDepositRatio) / RATIO_DIVISOR;

200:         uint256 requiredValue = (requiredUsdValue(_user) * priceToleranceRatio) / RATIO_DIVISOR;

231:             LockedBalance memory currentLockData = lpLockData[i - 1];

232:             lockedLP += currentLockData.amount;

238:                 i--;

276:         return (lockedLP * lpPrice) / 10 ** 18;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

4: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

5: import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

6: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

8: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

9: import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

11: import {RecoverERC20} from "./libraries/RecoverERC20.sol";

12: import {IChefIncentivesController} from "./interfaces/IChefIncentivesController.sol";

13: import {IBountyManager} from "./interfaces/IBountyManager.sol";

14: import {IMultiFeeDistribution, IFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";

15: import {IMintableToken} from "./interfaces/IMintableToken.sol";

16: import {LockedBalance, Balances, Reward, EarnedBalance} from "./interfaces/LockedBalance.sol";

17: import {IPriceProvider} from "./interfaces/IPriceProvider.sol";

37:     uint256 public constant QUART = 25000; //  25%

38:     uint256 public constant HALF = 65000; //  65%

39:     uint256 public constant WHOLE = 100000; // 100%

42:     uint256 public constant MAX_SLIPPAGE = 9000; //10%

43:     uint256 public constant PERCENT_DIVISOR = 10000; //100%

272:                 i++;

313:                 i++;

372:         for (uint256 i; i < length; i++) {

383:         if (indexToRemove < length - 1) {

384:             rewardTokens[indexToRemove] = rewardTokens[length - 1];

507:         bal.total = bal.total + amount;

509:             bal.earned = bal.earned + amount;

512:             uint256 currentDay = block.timestamp / 1 days;

513:             uint256 lastIndex = earnings.length > 0 ? earnings.length - 1 : 0;

514:             uint256 vestingDurationDays = vestDuration / 1 days;

517:             if (earnings.length > 0 && (earnings[lastIndex].unlockTime / 1 days) == currentDay + vestingDurationDays) {

518:                 earnings[lastIndex].amount = earnings[lastIndex].amount + amount;

521:                 uint256 unlockTime = block.timestamp + vestDuration;

527:             bal.unlocked = bal.unlocked + amount;

546:             bal.unlocked = bal.unlocked - amount;

548:             uint256 remaining = amount - bal.unlocked;

565:                     remaining = remaining - withdrawAmount;

566:                     if (remaining == 0) i++;

568:                     requiredAmount = (remaining * WHOLE) / (WHOLE - penaltyFactor);

569:                     _userEarnings[_address][i].amount = earnedAmount - requiredAmount;

572:                     newPenaltyAmount = (requiredAmount * penaltyFactor) / WHOLE;

573:                     newBurnAmount = (newPenaltyAmount * burn) / WHOLE;

575:                 sumEarned = sumEarned - requiredAmount;

577:                 penaltyAmount = penaltyAmount + newPenaltyAmount;

578:                 burnAmount = burnAmount + newBurnAmount;

586:                     i++;

592:                     _userEarnings[_address][j - i] = _userEarnings[_address][j];

594:                         j++;

600:                         j++;

608:         bal.total = bal.total - amount - penaltyAmount;

627:         for (uint256 i = index + 1; i < length; ) {

628:             _userEarnings[onBehalfOf][i - 1] = _userEarnings[onBehalfOf][i];

630:                 i++;

636:         bal.total = bal.total - amount - penaltyAmount;

637:         bal.earned = bal.earned - amount - penaltyAmount;

653:         bal.total = bal.total - bal.unlocked - bal.earned;

697:             if (earnings[i - 1].unlockTime > currentTimestamp) {

698:                 zapped = zapped + earnings[i - 1].amount;

704:                 i--;

711:         bal.earned = bal.earned - zapped;

712:         bal.total = bal.total - zapped;

733:                 uint256 reward = rewards[onBehalf][token] / 1e12;

736:                     rewardData[token].balance = rewardData[token].balance - reward;

743:                 i++;

823:         return (rewardData[rewardToken].rewardPerSecond * rewardsDuration) / 1e12;

919:                     lockData = new LockedBalance[](locks.length - i);

922:                 idx++;

923:                 locked = locked + locks[i].amount;

924:                 lockedWithMultiplier = lockedWithMultiplier + (locks[i].amount * locks[i].multiplier);

926:                 unlockable = unlockable + locks[i].amount;

929:                 i++;

946:                 locked = locked + locks[i].amount;

949:                 i++;

972:                     earningsData = new EarnedBalance[](earnings.length - i);

978:                 idx++;

979:                 totalVesting = totalVesting + earnings[i].amount;

981:                 unlocked = unlocked + earnings[i].amount;

984:                 i++;

1008:                 penaltyAmount = penaltyAmount + newPenaltyAmount;

1009:                 burnAmount = burnAmount + newBurnAmount;

1011:                     i++;

1015:         amount = _balances[user].unlocked + earned - penaltyAmount;

1038:             uint256 newReward = (lastTimeRewardApplicable(rewardToken) - rewardData[rewardToken].lastUpdateTime) *

1040:             rptStored = rptStored + ((newReward * 1e18) / lockedSupplyWithMultiplier);

1061:                 ) /

1064:                 i++;

1093:         bal.total = bal.total + amount;

1095:         bal.locked = bal.locked + amount;

1096:         lockedSupply = lockedSupply + amount;

1099:         bal.lockedWithMultiplier = bal.lockedWithMultiplier + (amount * rewardMultiplier);

1100:         lockedSupplyWithMultiplier = lockedSupplyWithMultiplier + (amount * rewardMultiplier);

1102:         uint256 lockDurationWeeks = _lockPeriod[typeIndex] / AGGREGATION_EPOCH;

1103:         uint256 unlockTime = block.timestamp + (lockDurationWeeks * AGGREGATION_EPOCH);

1106:             uint256 indexToAggregate = lockIndex == 0 ? 0 : lockIndex - 1;

1109:                 (userLocks[indexToAggregate].unlockTime / AGGREGATION_EPOCH == unlockTime / AGGREGATION_EPOCH) &&

1112:                 _userLocks[onBehalfOf][indexToAggregate].amount = userLocks[indexToAggregate].amount + amount;

1176:                 i++;

1191:             uint256 opExAmount = (reward * operationExpenseRatio_) / RATIO_DIVISOR;

1194:                 reward = reward - opExAmount;

1200:             r.rewardPerSecond = (reward * 1e12) / rewardsDuration;

1202:             uint256 remaining = r.periodFinish - block.timestamp;

1203:             uint256 leftover = (remaining * r.rewardPerSecond) / 1e12;

1204:             r.rewardPerSecond = ((reward + leftover) * 1e12) / rewardsDuration;

1208:         r.periodFinish = block.timestamp + rewardsDuration;

1209:         r.balance = r.balance + reward;

1231:         if (periodFinish < block.timestamp + rewardsDuration - rewardsLookback) {

1232:             uint256 unseen = IERC20(token).balanceOf(address(this)) - r.balance;

1251:             uint256 reward = rewards[user][token] / 1e12;

1254:                 rewardData[token].balance = rewardData[token].balance - reward;

1260:                 i++;

1290:             rdntToken.safeTransfer(daoTreasury, penaltyAmount - burnAmount);

1320:                 lockAmount = lockAmount + locks[i].amount;

1321:                 lockAmountWithMultiplier = lockAmountWithMultiplier + (locks[i].amount * locks[i].multiplier);

1322:                 i = i + 1;

1326:                 locks[j - i] = locks[j];

1328:                     j++;

1334:                     j++;

1363:         bal.locked = bal.locked - amount;

1364:         bal.lockedWithMultiplier = bal.lockedWithMultiplier - amountWithMultiplier;

1365:         bal.total = bal.total - amount;

1366:         lockedSupply = lockedSupply - amount;

1367:         lockedSupplyWithMultiplier = lockedSupplyWithMultiplier - amountWithMultiplier;

1405:                 index++;

1423:             locks[j] = locks[j - 1];

1425:                 j--;

1446:         uint256 realRPT = currentRewardPerToken - userRewardPerTokenPaid[user][rewardToken];

1447:         earnings = earnings + ((balance * realRPT) / 1e18);

1463:             penaltyFactor = ((earning.unlockTime - block.timestamp) * HALF) / vestDuration + QUART; // 25% + timeLeft/vestDuration * 65%

1464:             penaltyAmount = (earning.amount * penaltyFactor) / WHOLE;

1465:             burnAmount = (penaltyAmount * burn) / WHOLE;

1467:         amount = earning.amount - penaltyAmount;

1480:             uint256 mid = (low + high) / 2;

1482:                 low = mid + 1;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/reward/RecoverERC20.sol

4: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

5: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/RecoverERC20.sol)

```solidity
File: src/utils/Math.sol

30:     assembly ("memory-safe") {

38:     assembly ("memory-safe") {

45:     assembly ("memory-safe") {

52:     assembly ("memory-safe") {

59:     assembly ("memory-safe") {

67:     assembly ("memory-safe") {

76:         z = int256(x) * y;

77:         if (int256(x) < 0 || (y != 0 && z / y != int256(x))) revert Math__mul_overflow_signed();

84:     assembly ("memory-safe") {

99:         z = mul(x, y) / int256(WAD);

122:     assembly ("memory-safe") {

154:         assembly ("memory-safe") {

172:                     let half := div(b, 2) // for rounding.

210:     return wexp((wln(x) * y) / int256(WAD));

219:         if (x <= -42139678854452767551) return r;

226:                 mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.

234:         x = (x << 78) / 5 ** 18;

239:         int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;

240:         x = x - k * 54916777467707473351141471128;

246:         int256 y = x + 1346386616545796478920950773328;

247:         y = ((y * x) >> 96) + 57155421227552351082224309758442;

248:         int256 p = y + x - 94201549194550492254356042504812;

249:         p = ((p * y) >> 96) + 28719021644029726153956944680412240;

250:         p = p * x + (4385272521454847904659076985693276 << 96);

253:         int256 q = x - 2855989394907223263936484059900;

254:         q = ((q * x) >> 96) + 50020603652535783019961831881945;

255:         q = ((q * x) >> 96) - 533845033583426703283633433725380;

256:         q = ((q * x) >> 96) + 3604857256930695427073651918091429;

257:         q = ((q * x) >> 96) - 14423608567350463180887372962807573;

258:         q = ((q * x) >> 96) + 26449188498355588339934803723976023;

276:         r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));

287:                 mstore(0x00, 0x1615e638) // `LnWadUndefined()`.

322:         int256 p = x + 3273285459638523848632254066296;

323:         p = ((p * x) >> 96) + 24828157081833163892658089445524;

324:         p = ((p * x) >> 96) + 43456485725739037958740375743393;

325:         p = ((p * x) >> 96) - 11111509109440967052023855526967;

326:         p = ((p * x) >> 96) - 45023709667254063763336534515857;

327:         p = ((p * x) >> 96) - 14706773417378608786704636184526;

328:         p = p * x - (795164235651350426258249787498 << 96);

332:         int256 q = x + 5573035233440673466300451813936;

333:         q = ((q * x) >> 96) + 71694874799317883764090561454958;

334:         q = ((q * x) >> 96) + 283447036172924575727196451306956;

335:         q = ((q * x) >> 96) + 401686690394027663651624208769553;

336:         q = ((q * x) >> 96) + 204048457590392012362485061816622;

337:         q = ((q * x) >> 96) + 31853899698501571402653359427138;

338:         q = ((q * x) >> 96) + 909429971244387300277376558375;

356:         r *= 1677202110996718588342820967067443963516166;

358:         r += 16597577552685614221487285958193947469193820559219878177908093499208371 * (159 - t);

360:         r += 600920179829731861736702779321621459595472258049074101567377883020018308;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/utils/Pause.sol

4: import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

5: import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

7: import {IPause} from "../interfaces/IPause.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Pause.sol)

```solidity
File: src/utils/Permission.sol

4: import "../interfaces/IPermission.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

4: import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

5: import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

6: import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

7: import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

8: import {AggregatorV3Interface} from "../vendor/AggregatorV3Interface.sol";

9: import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

10: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

11: import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

12: import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

13: import {wdiv, wmul} from "../utils/Math.sol";

14: import {IPool} from "./IAuraPool.sol";

15: import {IOracle} from "../interfaces/IOracle.sol";

16: import {IVault, BatchSwapStep, FundManagement, SwapKind} from "../vendor/IBalancerVault.sol";

17: import {IPriceOracle} from "./IPriceOracle.sol";

62:     uint256 private constant EMISSIONS_MAX_SUPPLY = 5e25; // 50m

63:     uint256 private constant INIT_MINT_AMOUNT = 5e25; // 50m

183:         return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);

190:         return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);

297:         IERC20(BAL).safeTransfer(_config.lockerRewards, (amounts[0] * _config.lockerIncentive) / INCENTIVE_BASIS);

302:             IERC20(AURA).safeTransfer(_config.lockerRewards, (amounts[1] * _config.lockerIncentive) / INCENTIVE_BASIS);

317:         uint256 balReward = IPool(rewardPool).earned(address(this)) + IERC20(BAL).balanceOf(address(this));

321:             : _previewMining(balReward) + IERC20(AURA).balanceOf(address(this));

330:         amount = (balReward * _chainlinkSpot()) / IOracle(feed).spot(asset());

331:         amount = amount + (auraReward * _getAuraSpot()) / IOracle(feed).spot(asset());

332:         amount = (amount * (INCENTIVE_BASIS - config.claimerIncentive)) / INCENTIVE_BASIS;

342:         uint256 minterMinted = 0; // Cannot fetch because private in AURA

343:         uint256 emissionsMinted = supply - INIT_MINT_AMOUNT - minterMinted;

345:         uint256 cliff = emissionsMinted / REDUCTION_PER_CLIFF;

352:             uint256 reduction = ((TOTAL_CLIFFS - cliff) * 5) / 2 + 700;

356:             amount = (_amount * reduction) / TOTAL_CLIFFS;

358:             uint256 amtTillMax = EMISSIONS_MAX_SUPPLY - emissionsMinted;

368:             uint80 /*roundId*/,

370:             uint256 /*startedAt*/,

371:             uint256 /*updatedAt*/,

372:             uint80 /*answeredInRound*/

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IBalancerVault.sol

97:     MANAGEMENT_FEE_TOKENS_OUT // for InvestmentPool

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IBalancerVault.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

25:     if (_start + 20 < _start) revert UniswapV3Router_toAddress_overflow();

26:     if (_bytes.length < _start + 20) revert UniswapV3Router_toAddress_outOfBounds();

41:     token = toAddress(path, path.length - 20);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

```solidity
File: src/vendor/Imports.sol

4: import {PRBProxyRegistry} from "prb-proxy/PRBProxyRegistry.sol";

6: import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

7: import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

9: import {IAllowanceTransfer} from "permit2/interfaces/IAllowanceTransfer.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/Imports.sol)

### <a name="GAS-10"></a>[GAS-10] Use Custom Errors instead of Revert Strings to save Gas

Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (3)*:

```solidity
File: src/vendor/AuraVault.sol

238:         require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");

261:         require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

289:         require(amountIn <= maxAmountIn, "!Slippage");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-11"></a>[GAS-11] Avoid contract existence checks by using low level calls

Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (10)*:

```solidity
File: src/PoolV3.sol

203:         return IERC20(underlyingToken).balanceOf(address(this)); // U:[LP-3]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/proxy/BaseAction.sol

21:         (bool success, bytes memory returnData) = to.delegatecall(data);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/BaseAction.sol)

```solidity
File: src/proxy/PoolAction.sol

237:         return IERC20(assets[outIndex]).balanceOf(address(poolActionParams.recipient));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction4626.sol

118:             addCollateralAmount = IERC20(underlyingToken).balanceOf(address(this));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction4626.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

859:         uint256 chefReserve = IERC20(rdntToken_).balanceOf(address(this));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

1232:             uint256 unseen = IERC20(token).balanceOf(address(this)) - r.balance;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

176:         return IPool(rewardPool).balanceOf(address(this));

306:             IERC20(AURA).safeTransfer(_config.lockerRewards, IERC20(AURA).balanceOf(address(this)));

317:         uint256 balReward = IPool(rewardPool).earned(address(this)) + IERC20(BAL).balanceOf(address(this));

321:             : _previewMining(balReward) + IERC20(AURA).balanceOf(address(this));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-12"></a>[GAS-12] Stack variable used as a cheaper cache for a state variable is only used once

If the variable is only accessed once, it's cheaper to use the state variable directly that one time, and save the **3 gas** the extra stack assignment would spend

*Instances (9)*:

```solidity
File: src/CDPVault.sol

447:         VaultConfig memory config = vaultConfig;

514:         VaultConfig memory config = vaultConfig;

584:         VaultConfig memory config = vaultConfig;

585:         LiquidationConfig memory liqConfig_ = liquidationConfig;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/StakingLPEth.sol

135:         uint24 previousDuration = cooldownDuration;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

192:         uint256 timestampLU = lastQuotaRateUpdate;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

453:         uint256 totalAP = totalAllocPoint;

530:         uint256 _totalAllocPoint = totalAllocPoint;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/vendor/AuraVault.sol

316:         VaultConfig memory config = vaultConfig;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-13"></a>[GAS-13] State variables only set in the constructor should be declared `immutable`

Variables only set in the constructor and never edited afterwards should be marked as immutable, as it would avoid the expensive storage-writing operation in the constructor (around **20 000 gas** per variable) and replace the expensive storage-reading operations (around **2100 gas** per reading) to a less expensive value reading (**3 gas**)

*Instances (39)*:

```solidity
File: src/CDPVault.sol

165:         pool = constants.pool;

166:         oracle = constants.oracle;

168:         tokenScale = constants.tokenScale;

170:         poolUnderlying = IERC20(pool.underlyingToken());

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

51:         pool = pool_;

52:         underlyingToken = IERC20(pool.underlyingToken());

53:         protocolFee = protocolFee_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

168:         addressProvider = addressProvider_; // U:[LP-1B]

169:         underlyingToken = underlyingToken_; // U:[LP-1B]

171:         treasury = IAddressProviderV3(addressProvider_).getAddressOrRevert({

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

19:         STAKING_VAULT = _stakingVault;

20:         lpETH = IERC20(_lpEth);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

59:         silo = new Silo(address(this), _liquidityPool);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/oracle/BalancerOracle.sol

75:         balancerVault = IVault(balancerVault_);

76:         updateWaitWindow = updateWaitWindow_;

77:         stalePeriod = stalePeriod_;

78:         chainlinkOracle = IOracle(chainlinkOracle_);

79:         pool = pool_;

80:         poolId = IWeightedPool(pool).getPoolId();

86:         token0 = (len > 0) ? tokens[0] : address(0);

87:         token1 = (len > 1) ? tokens[1] : address(0);

88:         token2 = (len > 2) ? tokens[2] : address(0);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/proxy/PoolAction.sol

53:         balancerVault = IVault(balancerVault_);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction.sol

118:         flashlender = IFlashlender(flashlender_);

119:         pool = flashlender.pool();

120:         vaultRegistry = IVaultRegistry(vaultRegistry_);

121:         underlyingToken = IERC20(pool.underlyingToken());

122:         self = address(this);

123:         swapAction = SwapAction(swapAction_);

124:         poolAction = PoolAction(poolAction_);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/SwapAction.sol

70:         balancerVault = balancerVault_;

71:         uniRouter = uniRouter_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

59:         pool = _pool; // U:[GA-01]

60:         voter = _voter; // U:[GA-01]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

82:         pool = _pool; // U:[PQK-1]

83:         underlying = IPoolV3(_pool).asset(); // U:[PQK-1]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/vendor/AuraVault.sol

130:         rewardPool = rewardPool_;

133:         maxClaimerIncentive = maxClaimerIncentive_;

134:         maxLockerIncentive = maxLockerIncentive_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-14"></a>[GAS-14] Functions guaranteed to revert when called by normal users can be marked `payable`

If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (41)*:

```solidity
File: src/CDPVault.sol

195:     function setParameter(bytes32 parameter, uint256 data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {

208:     function setParameter(bytes32 parameter, address data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Silo.sol

28:     function withdraw(address to, uint256 amount) external onlyStakingVault {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

130:     function setCooldownDuration(uint24 duration) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

39:     function addVault(ICDPVault vault) external override(IVaultRegistry) onlyRole(VAULT_MANAGER_ROLE) {

49:     function removeVault(ICDPVault vault) external override(IVaultRegistry) onlyRole(VAULT_MANAGER_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

110:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {

114:     function update() external virtual onlyRole(KEEPER_ROLE) returns (uint256 safePrice_) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

45:     function setOracles(address[] calldata _tokens, Oracle[] calldata _oracles) external onlyRole(DEFAULT_ADMIN_ROLE) {

70:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {}

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PositionAction.sol

214:     function borrow(address position, address vault, CreditParams calldata creditParams) external onlyRegisteredVault(vault) onlyDelegatecall {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

272:     function setBountyManager(address _bountyManager) external onlyOwner {

281:     function setEligibilityMode(EligibilityModes _newVal) external onlyOwner {

291:     function start() public onlyOwner {

318:     function batchUpdateAllocPoint(address[] calldata _tokens, uint256[] calldata _allocPoints) external onlyOwner {

342:     function setRewardsPerSecond(uint256 _rewardsPerSecond, bool _persist) external onlyOwner {

430:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

581:     function setContractAuthorization(address _address, bool _authorize) external onlyOwner {

909:     function setEndingTimeUpdateCadence(uint256 _lapse) external onlyOwner {

920:     function registerRewardDeposit(uint256 _amount) external onlyOwner {

966:     function pause() external onlyOwner {

973:     function unpause() external onlyOwner {

1005:     function setAddressWLstatus(address user, bool status) external onlyOwner {

1012:     function toggleWhitelist() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

118:     function setChefIncentivesController(IChefIncentivesController _chef) external onlyOwner {

127:     function setLPToken(address _lpToken) external onlyOwner {

139:     function setRequiredDepositRatio(uint256 _requiredDepositRatio) external onlyOwner {

150:     function setPriceToleranceRatio(uint256 _priceToleranceRatio) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

266:     function setMinters(address[] calldata minters_) external onlyOwner {

282:     function setBountyManager(address bounty) external onlyOwner {

293:     function addRewardConverter(address rewardConverter_) external onlyOwner {

304:     function setLockTypeInfo(uint256[] calldata lockPeriod_, uint256[] calldata rewardMultipliers_) external onlyOwner {

324:     function setAddresses(IChefIncentivesController controller_, address treasury_) external onlyOwner {

336:     function setLPToken(address stakingToken_) external onlyOwner {

452:     function setLookback(uint256 lookback) external onlyOwner {

770:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

873:     function pause() public onlyOwner {

880:     function unpause() public onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Pause.sol

30:     function pause() external onlyRole(PAUSER_ROLE) {

36:     function unpause() external onlyRole(PAUSER_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Pause.sol)

```solidity
File: src/vendor/AuraVault.sol

145:     function setParameter(bytes32 parameter, uint256 data) external onlyRole(VAULT_CONFIG_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-15"></a>[GAS-15] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)

Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (41)*:

```solidity
File: src/oracle/BalancerOracle.sol

126:         for (uint256 i = 0; i < weights.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

46:         for (uint256 i = 0; i < _tokens.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PoolAction.sol

180:                     i++;

229:                 outIndex++;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

329:                 i++;

359:                     i++;

382:                 i++;

419:                 i++;

458:                 i++;

507:                 i++;

543:                 i++;

704:                 i++;

723:                 i++;

803:                 i++;

838:                 i++;

889:                 i++;

958:                 i++;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

238:                 i--;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

272:                 i++;

313:                 i++;

372:         for (uint256 i; i < length; i++) {

566:                     if (remaining == 0) i++;

586:                     i++;

594:                         j++;

600:                         j++;

630:                 i++;

704:                 i--;

743:                 i++;

922:                 idx++;

929:                 i++;

949:                 i++;

978:                 idx++;

984:                 i++;

1011:                     i++;

1064:                 i++;

1176:                 i++;

1260:                 i++;

1328:                     j++;

1334:                     j++;

1405:                 index++;

1425:                 j--;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="GAS-16"></a>[GAS-16] Using `private` rather than `public` for constants, saves gas

If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (21)*:

```solidity
File: src/Flashlender.sol

19:     bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

20:     bytes32 public constant CALLBACK_SUCCESS_CREDIT = keccak256("CreditFlashBorrower.onCreditFlashLoan");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

62:     uint256 public constant override version = 3_00;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/VaultRegistry.sol

14:     bytes32 public constant VAULT_MANAGER_ROLE = keccak256("VAULT_MANAGER_ROLE");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/proxy/PositionAction.sol

72:     bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

73:     bytes32 public constant CALLBACK_SUCCESS_CREDIT = keccak256("CreditFlashBorrower.onCreditFlashLoan");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/TransferAction.sol

39:     address public constant permit2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/TransferAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

29:     uint256 public constant override version = 3_00;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

37:     uint256 public constant override version = 3_00;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

20:     uint256 public constant RATIO_DIVISOR = 10000;

23:     uint256 public constant INITIAL_REQUIRED_DEPOSIT_RATIO = 500;

26:     uint256 public constant INITIAL_PRICE_TOLERANCE_RATIO = 9000;

29:     uint256 public constant MIN_PRICE_TOLERANCE_RATIO = 8000;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

37:     uint256 public constant QUART = 25000; //  25%

38:     uint256 public constant HALF = 65000; //  65%

39:     uint256 public constant WHOLE = 100000; // 100%

42:     uint256 public constant MAX_SLIPPAGE = 9000; //10%

43:     uint256 public constant PERCENT_DIVISOR = 10000; //100%

45:     uint256 public constant AGGREGATION_EPOCH = 6 days;

47:     uint256 public constant RATIO_DIVISOR = 10000;

59:     uint256 public constant DEFAULT_LOCK_INDEX = 1;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="GAS-17"></a>[GAS-17] Use shift right/left instead of division/multiplication if possible

While the `DIV` / `MUL` opcode uses 5 gas, the `SHR` / `SHL` opcode only uses 3 gas. Furthermore, beware that Solidity's division operation also includes a division-by-0 prevention which is bypassed using shifting. Eventually, overflow checks are never performed for shift operations as they are done for arithmetic operations. Instead, the result is always truncated, so the calculation can be unchecked in Solidity version `0.8+`

- Use `>> 1` instead of `/ 2`
- Use `>> 2` instead of `/ 4`
- Use `<< 3` instead of `* 8`
- ...
- Use `>> 5` instead of `/ 2^5 == / 32`
- Use `<< 6` instead of `* 2^6 == * 64`

TL;DR:

- Shifting left by N is like multiplying by 2^N (Each bits to the left is an increased power of 2)
- Shifting right by N is like dividing by 2^N (Each bits to the right is a decreased power of 2)

*Saves around 2 gas + 20 for unchecked per instance*

*Instances (2)*:

```solidity
File: src/reward/MultiFeeDistribution.sol

1480:             uint256 mid = (low + high) / 2;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

352:             uint256 reduction = ((TOTAL_CLIFFS - cliff) * 5) / 2 + 700;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="GAS-18"></a>[GAS-18] Increments/decrements can be unchecked in for-loops

In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (4)*:

```solidity
File: src/oracle/BalancerOracle.sol

126:         for (uint256 i = 0; i < weights.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

46:         for (uint256 i = 0; i < _tokens.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/quotas/GaugeV3.sol

102:             for (uint256 i; i < len; ++i) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

372:         for (uint256 i; i < length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="GAS-19"></a>[GAS-19] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (34)*:

```solidity
File: src/CDPVault.sol

376:             ((deltaDebt > 0 || deltaCollateral < 0) && !hasPermission(owner, msg.sender)) ||

378:             (deltaCollateral > 0 && !hasPermission(collateralizer, msg.sender)) ||

391:         if (deltaDebt > 0) {

437:         if (deltaCollateral > 0) {

452:             (deltaDebt > 0 || deltaCollateral < 0) &&

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

548:         if (profit > 0) {

550:         } else if (loss > 0) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

143:         if (_totalSupply > 0 && _totalSupply < MIN_SHARES) revert MinSharesViolation();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/oracle/BalancerOracle.sol

86:         token0 = (len > 0) ? tokens[0] : address(0);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

105:             isValid = (answer > 0 && block.timestamp - updatedAt <= oracle.stalePeriod);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PositionAction.sol

319:         if (upFrontAmount > 0) {

472:         if (residualAmount > 0) {

608:             if (remainder > 0) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

402:             if (i > 0) {

409:             if (startTime > 0) {

923:         if (rewardsPerSecond == 0 && lastRPS > 0) {

987:         if (lpSupply > 0) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

230:         for (uint256 i = lpLockData.length; i > 0; ) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

513:             uint256 lastIndex = earnings.length > 0 ? earnings.length - 1 : 0;

517:             if (earnings.length > 0 && (earnings[lastIndex].unlockTime / 1 days) == currentDay + vestingDurationDays) {

589:             if (i > 0) {

696:         for (uint256 i = earnings.length; i > 0; ) {

734:                 if (reward > 0) {

1002:         if (earned > 0) {

1037:         if (lockedSupplyWithMultiplier > 0) {

1105:         if (userLocksLength > 0) {

1233:             if (unseen > 0) {

1252:             if (reward > 0) {

1286:         if (penaltyAmount > 0) {

1287:             if (burnAmount > 0) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

62:     if ((y > 0 && z < x) || (y < 0 && z > x)) revert Math__add_overflow_signed();

70:     if ((y > 0 && z > x) || (y < 0 && z < x)) revert Math__sub_overflow_signed();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/vendor/AuraVault.sol

375:             isValid = (price > 0);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

25:     if (_start + 20 < _start) revert UniswapV3Router_toAddress_overflow();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

### <a name="GAS-20"></a>[GAS-20] `internal` functions not called by the contract should be removed

If the functions are required by an interface, the contract should inherit from that interface and use the `override` keyword

*Instances (7)*:

```solidity
File: src/CDPVault.sol

717:     function calcAccruedInterest(

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/proxy/SwapAction.sol

344: 

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

254:     function isInitialised(TokenQuotaParams storage tokenQuotaParams) internal view returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/quotas/QuotasLogic.sol

17:     function cumulativeIndexSince(uint192 cumulativeIndexLU, uint16 rate, uint256 lastQuotaRateUpdate)

29:     function calcAccruedQuotaInterest(uint96 quoted, uint192 cumulativeIndexNow, uint192 cumulativeIndexLU)

39:     function calcQuotaRevenueChange(uint16 rate, int256 change) internal pure returns (int256) {

44:     function calcActualQuotaChange(uint96 totalQuoted, uint96 limit, int96 requestedChange)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

## Non Critical Issues

| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Replace `abi.encodeWithSignature` and `abi.encodeWithSelector` with `abi.encodeCall` which keeps the code typo/type safe | 9 |
| [NC-2](#NC-2) | Missing checks for `address(0)` when assigning values to address state variables | 15 |
| [NC-3](#NC-3) | Array indices should be referenced via `enum`s rather than via numeric literals | 17 |
| [NC-4](#NC-4) | Constants should be in CONSTANT_CASE | 1 |
| [NC-5](#NC-5) | `constant`s should be defined rather than using magic numbers | 56 |
| [NC-6](#NC-6) | Control structures do not follow the Solidity Style Guide | 252 |
| [NC-7](#NC-7) | Critical Changes Should Use Two-step Procedure | 1 |
| [NC-8](#NC-8) | Default Visibility for constants | 9 |
| [NC-9](#NC-9) | Consider disabling `renounceOwnership()` | 3 |
| [NC-10](#NC-10) | Draft Dependencies | 1 |
| [NC-11](#NC-11) | Unused `error` definition | 8 |
| [NC-12](#NC-12) | Event is never emitted | 2 |
| [NC-13](#NC-13) | Event missing indexed field | 8 |
| [NC-14](#NC-14) | Events that mark critical parameter changes should contain both the old and the new value | 29 |
| [NC-15](#NC-15) | Function ordering does not follow the Solidity style guide | 17 |
| [NC-16](#NC-16) | Functions should not be longer than 50 lines | 270 |
| [NC-17](#NC-17) | Change int to int256 | 9 |
| [NC-18](#NC-18) | Change uint to uint256 | 1 |
| [NC-19](#NC-19) | Interfaces should be defined in separate files from their usage | 3 |
| [NC-20](#NC-20) | Lack of checks in setters | 16 |
| [NC-21](#NC-21) | Lines are too long | 1 |
| [NC-22](#NC-22) | Missing Event for critical parameters change | 18 |
| [NC-23](#NC-23) | NatSpec is completely non-existent on functions that should have them | 10 |
| [NC-24](#NC-24) | Incomplete NatSpec: `@param` is missing on actually documented functions | 12 |
| [NC-25](#NC-25) | Incomplete NatSpec: `@return` is missing on actually documented functions | 9 |
| [NC-26](#NC-26) | File's first line is not an SPDX Identifier | 1 |
| [NC-27](#NC-27) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 34 |
| [NC-28](#NC-28) | Constant state variables defined more than once | 11 |
| [NC-29](#NC-29) | Consider using named mappings | 33 |
| [NC-30](#NC-30) | `address`s shouldn't be hard-coded | 5 |
| [NC-31](#NC-31) | Variable names that consist of all capital letters should be reserved for `constant`/`immutable` variables | 1 |
| [NC-32](#NC-32) | Owner can renounce while system is paused | 4 |
| [NC-33](#NC-33) | Adding a `return` statement when the function defines a named return variable, is redundant | 28 |
| [NC-34](#NC-34) | Take advantage of Custom Error's return value property | 190 |
| [NC-35](#NC-35) | Use scientific notation (e.g. `1e18`) rather than exponentiation (e.g. `10**18`) | 2 |
| [NC-36](#NC-36) | Use scientific notation for readability reasons for large multiples of ten | 1 |
| [NC-37](#NC-37) | Avoid the use of sensitive terms | 11 |
| [NC-38](#NC-38) | Contract does not follow the Solidity style guide's suggested layout ordering | 15 |
| [NC-39](#NC-39) | Use Underscores for Number Literals (add an underscore every 3 digits) | 42 |
| [NC-40](#NC-40) | Internal and private variables and functions names should begin with an underscore | 39 |
| [NC-41](#NC-41) | Event is missing `indexed` fields | 27 |
| [NC-42](#NC-42) | Constants should be defined rather than using magic numbers | 7 |
| [NC-43](#NC-43) | `public` functions not called by the contract should be declared `external` instead | 20 |
| [NC-44](#NC-44) | Variables need not be initialized to zero | 16 |

### <a name="NC-1"></a>[NC-1] Replace `abi.encodeWithSignature` and `abi.encodeWithSelector` with `abi.encodeCall` which keeps the code typo/type safe

When using `abi.encodeWithSignature`, it is possible to include a typo for the correct function signature.
When using `abi.encodeWithSignature` or `abi.encodeWithSelector`, it is also possible to provide parameters that are not of the correct type for the function.

To avoid these pitfalls, it would be best to use [`abi.encodeCall`](https://solidity-by-example.org/abi-encode/) instead.

*Instances (9)*:

```solidity
File: src/proxy/PositionAction.sol

397:                 abi.encodeWithSelector(swapAction.swap.selector, leverParams.auxSwap)

405:             abi.encodeWithSelector(swapAction.swap.selector, leverParams.primarySwap)

461:             abi.encodeWithSelector(

478:                     abi.encodeWithSelector(

540:                 abi.encodeWithSelector(swapAction.swap.selector, collateralParams.auxSwap)

561:             _delegateCall(address(swapAction), abi.encodeWithSelector(swapAction.swap.selector, creditParams.auxSwap));

601:             abi.encodeWithSelector(swapAction.transferAndSwap.selector, sender, permitParams, swapParams)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/PositionAction4626.sol

115:             _delegateCall(address(poolAction), abi.encodeWithSelector(poolAction.join.selector, poolActionParams));

149:                 abi.encodeWithSelector(poolAction.exit.selector, leverParams.auxAction)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction4626.sol)

### <a name="NC-2"></a>[NC-2] Missing checks for `address(0)` when assigning values to address state variables

*Instances (15)*:

```solidity
File: src/PoolV3.sol

168:         addressProvider = addressProvider_; // U:[LP-1B]

169:         underlyingToken = underlyingToken_; // U:[LP-1B]

179:         interestRateModel = interestRateModel_; // U:[LP-1B]

754:         interestRateModel = newInterestRateModel; // U:[LP-22B]

773:         poolQuotaKeeper = newPoolQuotaKeeper; // U:[LP-23D]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

19:         STAKING_VAULT = _stakingVault;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/oracle/BalancerOracle.sol

79:         pool = pool_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/quotas/GaugeV3.sol

59:         pool = _pool; // U:[GA-01]

60:         voter = _voter; // U:[GA-01]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

82:         pool = _pool; // U:[PQK-1]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

273:         bountyManager = _bountyManager;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

328:         starfleetTreasury = treasury_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

130:         rewardPool = rewardPool_;

131:         feed = feed_;

132:         auraPriceOracle = auraPriceOracle_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-3"></a>[NC-3] Array indices should be referenced via `enum`s rather than via numeric literals

*Instances (17)*:

```solidity
File: src/oracle/BalancerOracle.sol

86:         token0 = (len > 0) ? tokens[0] : address(0);

87:         token1 = (len > 1) ? tokens[1] : address(0);

88:         token2 = (len > 2) ? tokens[2] : address(0);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/proxy/ERC165Plugin.sol

20:         methods[0] = this.onERC1155Received.selector;

21:         methods[1] = this.onERC1155BatchReceived.selector;

22:         methods[2] = this.onERC721Received.selector;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/ERC165Plugin.sol)

```solidity
File: src/proxy/SwapAction.sol

247:         IERC20(assetIn).forceApprove(address(balancerVault), amountToApprove);

256:                     FundManagement({

264:                 )[pathLength]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/vendor/AuraVault.sol

286:         amountIn = _previewReward(amounts[0], amounts[1], _config);

297:         IERC20(BAL).safeTransfer(_config.lockerRewards, (amounts[0] * _config.lockerIncentive) / INCENTIVE_BASIS);

298:         IERC20(BAL).safeTransfer(msg.sender, amounts[0]);

302:             IERC20(AURA).safeTransfer(_config.lockerRewards, (amounts[1] * _config.lockerIncentive) / INCENTIVE_BASIS);

303:             IERC20(AURA).safeTransfer(msg.sender, amounts[1]);

309:         emit Claimed(msg.sender, amounts[0], amounts[1], amountIn);

387:         queries[0] = IPriceOracle.OracleAverageQuery(IPriceOracle.Variable.PAIR_PRICE, 1800, 0);

390:         price = wmul(results[0], ethPrice);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-4"></a>[NC-4] Constants should be in CONSTANT_CASE

For `constant` variable names, each word should use all capital letters, with underscores separating each word (CONSTANT_CASE)

*Instances (1)*:

```solidity
File: src/proxy/TransferAction.sol

39:     address public constant permit2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/TransferAction.sol)

### <a name="NC-5"></a>[NC-5] `constant`s should be defined rather than using magic numbers

Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (56)*:

```solidity
File: src/PoolV3.sol

182:         if (ERC20(underlyingToken_).decimals() != 18) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

34:     uint24 public MAX_COOLDOWN_DURATION = 30 days;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/oracle/BalancerOracle.sol

88:         token2 = (len > 2) ? tokens[2] : address(0);

169:         else if (index == 2) token = token2;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

276:         return (lockedLP * lpPrice) / 10 ** 18;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

1480:             uint256 mid = (low + high) / 2;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

18:     if (x >= 1 << 255) revert Math__toInt256_overflow();

24:     if (x >= 1 << 64) revert Math__toUint64_overflow();

165:                     switch mod(n, 2)

172:                     let half := div(b, 2) // for rounding.

174:                         n := div(n, 2)

176:                         n := div(n, 2)

187:                         if mod(n, 2) {

225:             if iszero(slt(x, 135305999368893231589)) {

234:         x = (x << 78) / 5 ** 18;

239:         int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;

240:         x = x - k * 54916777467707473351141471128;

246:         int256 y = x + 1346386616545796478920950773328;

247:         y = ((y * x) >> 96) + 57155421227552351082224309758442;

248:         int256 p = y + x - 94201549194550492254356042504812;

249:         p = ((p * y) >> 96) + 28719021644029726153956944680412240;

250:         p = p * x + (4385272521454847904659076985693276 << 96);

253:         int256 q = x - 2855989394907223263936484059900;

254:         q = ((q * x) >> 96) + 50020603652535783019961831881945;

255:         q = ((q * x) >> 96) - 533845033583426703283633433725380;

256:         q = ((q * x) >> 96) + 3604857256930695427073651918091429;

257:         q = ((q * x) >> 96) - 14423608567350463180887372962807573;

258:         q = ((q * x) >> 96) + 26449188498355588339934803723976023;

276:         r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));

318:         x = int256(uint256(x << uint256(t)) >> 159);

322:         int256 p = x + 3273285459638523848632254066296;

323:         p = ((p * x) >> 96) + 24828157081833163892658089445524;

324:         p = ((p * x) >> 96) + 43456485725739037958740375743393;

325:         p = ((p * x) >> 96) - 11111509109440967052023855526967;

326:         p = ((p * x) >> 96) - 45023709667254063763336534515857;

327:         p = ((p * x) >> 96) - 14706773417378608786704636184526;

328:         p = p * x - (795164235651350426258249787498 << 96);

332:         int256 q = x + 5573035233440673466300451813936;

333:         q = ((q * x) >> 96) + 71694874799317883764090561454958;

334:         q = ((q * x) >> 96) + 283447036172924575727196451306956;

335:         q = ((q * x) >> 96) + 401686690394027663651624208769553;

336:         q = ((q * x) >> 96) + 204048457590392012362485061816622;

337:         q = ((q * x) >> 96) + 31853899698501571402653359427138;

338:         q = ((q * x) >> 96) + 909429971244387300277376558375;

356:         r *= 1677202110996718588342820967067443963516166;

358:         r += 16597577552685614221487285958193947469193820559219878177908093499208371 * (159 - t);

360:         r += 600920179829731861736702779321621459595472258049074101567377883020018308;

362:         r >>= 174;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/vendor/AuraVault.sol

183:         return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);

190:         return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);

352:             uint256 reduction = ((TOTAL_CLIFFS - cliff) * 5) / 2 + 700;

387:         queries[0] = IPriceOracle.OracleAverageQuery(IPriceOracle.Variable.PAIR_PRICE, 1800, 0);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

25:     if (_start + 20 < _start) revert UniswapV3Router_toAddress_overflow();

26:     if (_bytes.length < _start + 20) revert UniswapV3Router_toAddress_outOfBounds();

40:     if (path.length < 20) revert UniswapV3Router_decodeLastToken_invalidPath();

41:     token = toAddress(path, path.length - 20);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

### <a name="NC-6"></a>[NC-6] Control structures do not follow the Solidity Style Guide

See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (252)*:

```solidity
File: src/CDPVault.sol

125:     event ModifyPosition(address indexed position, uint256 debt, uint256 collateral, uint256 totalDebt);

126:     event ModifyCollateralAndDebt(

147:     error CDPVault__modifyPosition_debtFloor();

148:     error CDPVault__modifyCollateralAndDebt_notSafe();

149:     error CDPVault__modifyCollateralAndDebt_noPermission();

150:     error CDPVault__modifyCollateralAndDebt_maxUtilizationRatio();

196:         if (parameter == "debtFloor") vaultConfig.debtFloor = uint128(data);

197:         else if (parameter == "liquidationRatio") vaultConfig.liquidationRatio = uint64(data);

198:         else if (parameter == "liquidationPenalty") liquidationConfig.liquidationPenalty = uint64(data);

199:         else if (parameter == "liquidationDiscount") liquidationConfig.liquidationDiscount = uint64(data);

209:         if (parameter == "rewardController") rewardController = IChefIncentivesController(data);

305:     function _modifyPosition(

321:         if (position.debt != 0 && position.debt < uint256(vaultConfig.debtFloor))

322:             revert CDPVault__modifyPosition_debtFloor();

339:         emit ModifyPosition(owner, position.debt, position.collateral, totalDebt_);

367:     function modifyCollateralAndDebt(

374:         if (

381:         ) revert CDPVault__modifyCollateralAndDebt_noPermission();

445:         position = _modifyPosition(owner, position, newDebt, newCumulativeIndex, deltaCollateral, totalDebt);

451:         if (

454:         ) revert CDPVault__modifyCollateralAndDebt_notSafe();

459:         emit ModifyCollateralAndDebt(owner, collateralizer, creditor, deltaCollateral, deltaDebt);

511:         if (owner == address(0) || repayAmount == 0) revert CDPVault__liquidatePosition_invalidParameters();

524:         if (spotPrice_ == 0) revert CDPVault__liquidatePosition_invalidSpotPrice();

526:         if (calcTotalDebt(debtData) > wmul(position.collateral, spotPrice_)) revert CDPVault__BadDebt();

532:         if (takeCollateral > position.collateral) revert CDPVault__tooHighRepayAmount();

535:         if (_isCollateralized(calcTotalDebt(debtData), wmul(position.collateral, spotPrice_), config.liquidationRatio))

561:         position = _modifyPosition(owner, position, newDebt, newCumulativeIndex, -toInt256(takeCollateral), totalDebt);

581:         if (owner == address(0) || repayAmount == 0) revert CDPVault__liquidatePosition_invalidParameters();

591:         if (spotPrice_ == 0) revert CDPVault__liquidatePosition_invalidSpotPrice();

593:         if (_isCollateralized(calcTotalDebt(debtData), wmul(position.collateral, spotPrice_), config.liquidationRatio))

599:         if (calcTotalDebt(debtData) <= wmul(position.collateral, discountedPrice)) revert CDPVault__noBadDebt();

602:         if (takeCollateral < position.collateral) revert CDPVault__repayAmountNotEnough();

615:         position = _modifyPosition(

722:         if (amount == 0) return 0;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

6: import {IFlashlender, IERC3156FlashBorrower, ICreditFlashBorrower} from "./interfaces/IFlashlender.sol";

76:         if (token != address(underlyingToken)) revert Flash__flashFee_unsupportedToken();

93:         if (token != address(underlyingToken)) revert Flash__flashLoan_unsupportedToken();

101:         if (receiver.onFlashLoan(msg.sender, token, amount, fee, data) != CALLBACK_SUCCESS)

129:         if (receiver.onCreditFlashLoan(msg.sender, amount, fee, data) != CALLBACK_SUCCESS_CREDIT)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

111:         _revertIfCallerIsNotPoolQuotaKeeper();

117:         _revertIfCallerNotCreditManager();

125:             _revertIfLocked();

131:         if (msg.sender != poolQuotaKeeper) revert CallerNotPoolQuotaKeeperException(); // U:[LP-2C]

142:         if (locked) revert PoolV3LockedException(); // U:[LP-2C]

468:         if (borrowable == 0) return 0; // U:[LP-12]

471:         if (borrowable == 0) return 0; // U:[LP-12]

585:         if (borrowed >= limit) return 0;

606:         if (assets == 0) return baseInterestRate_;

616:         if (block.timestamp == timestampLU) return _baseInterestIndexLU; // U:[LP-16]

628:         if (block.timestamp == timestampLU) return 0; // U:[LP-17]

719:         if (block.timestamp == timestampLU) return 0; // U:[LP-21]

829:         if (newWithdrawFee == withdrawFee) return;

857:         if (newLimit == _totalDebt.limit) return;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

24:         if (msg.sender != STAKING_VAULT) revert OnlyStakingVault();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

44:         if (cooldownDuration != 0) revert OperationNotAllowed();

50:         if (cooldownDuration == 0) revert OperationNotAllowed();

105:         if (assets > maxWithdraw(msg.sender)) revert ExcessiveWithdrawAmount();

118:         if (shares > maxRedeem(msg.sender)) revert ExcessiveRedeemAmount();

143:         if (_totalSupply > 0 && _totalSupply < MIN_SHARES) revert MinSharesViolation();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

40:         if (registeredVaults[vault]) revert VaultRegistry__addVault_vaultAlreadyRegistered();

50:         if (!registeredVaults[vault]) revert VaultRegistry__removeVault_vaultNotFound();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

111:         if (_getStatus()) revert BalancerOracle__authorizeUpgrade_validStatus();

115:         if (block.timestamp - lastUpdate < updateWaitWindow) revert BalancerOracle__update_InUpdateWaitWindow();

167:         if (index == 0) token = token0;

168:         else if (index == 1) token = token1;

169:         else if (index == 2) token = token2;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

90:         if (!isValid) revert ChainlinkOracle__spot_invalidValue();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/BaseAction.sol

22:         if (!success) _revertBytes(returnData);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/BaseAction.sol)

```solidity
File: src/proxy/PoolAction.sol

213:         if (bptAmount != 0) IERC20(bpt).forceApprove(address(balancerVault), bptAmount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction.sol

15: import {IFlashlender, IERC3156FlashBorrower, ICreditFlashBorrower} from "../interfaces/IFlashlender.sol";

79:     IFlashlender public immutable flashlender;

115:         if (flashlender_ == address(0) || swapAction_ == address(0) || poolAction_ == address(0) || vaultRegistry_ == address(0))

118:         flashlender = IFlashlender(flashlender_);

128:                                 MODIFIERS

133:         if (address(this) == self) revert PositionAction__onlyDelegatecall();

138:         if (!vaultRegistry.isVaultRegistered(vault)) revert PositionAction__unregisteredVault();

280:                 if (!success) _revertBytes(response);

304:         if (

311:         if (

321:                 IERC20(upFrontToken).safeTransfer(self, upFrontAmount); // if tokens are on the proxy then just transfer

328:         IPermission(leverParams.vault).modifyPermission(leverParams.position, self, true);

335:         IPermission(leverParams.vault).modifyPermission(leverParams.position, self, false);

351:         if (leverParams.primarySwap.swapType != SwapType.EXACT_OUT || leverParams.primarySwap.recipient != self)

355:         if (leverParams.auxSwap.assetIn != address(0) && (leverParams.auxSwap.swapType != SwapType.EXACT_IN))

359:         if (leverParams.auxSwap.assetIn == address(0) && residualRecipient == address(0))

363:         IPermission(leverParams.vault).modifyPermission(leverParams.position, self, true);

370:         IPermission(leverParams.vault).modifyPermission(leverParams.position, self, false);

386:         if (msg.sender != address(flashlender)) revert PositionAction__onFlashLoan__invalidSender();

416:         ICDPVault(leverParams.vault).modifyCollateralAndDebt(

437:         if (msg.sender != address(flashlender)) revert PositionAction__onCreditFlashLoan__invalidSender();

448:         ICDPVault(leverParams.vault).modifyCollateralAndDebt(

511:             if (

554:         ICDPVault(vault).modifyCollateralAndDebt(position, address(this), address(this), 0, toInt256(creditParams.amount));

560:             if (creditParams.auxSwap.assetIn != address(underlyingToken)) revert PositionAction__borrow_InvalidAuxSwap();

573:             if (creditParams.auxSwap.recipient != address(this)) revert PositionAction__repay_InvalidAuxSwap();

584:         ICDPVault(vault).modifyCollateralAndDebt(

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/SwapAction.sol

214:             if (swapType == SwapType.EXACT_IN) outIncrement = 1;

238:             limits[0] = toInt256(amount); // positive signifies tokens going into the vault from the caller

239:             limits[pathLength] = -toInt256(limit); // negative signifies tokens going out of the vault to the caller

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

68:         _revertIfCallerNotVoter(); // U:[GA-02]

105:                 if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-15]

145:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

188:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

196:             if (uv.votesLpSide < votes) revert InsufficientVotesException();

202:             if (uv.votesCaSide < votes) revert InsufficientVotesException();

292:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-06A, GA-06B]

297:         if (minRate == qrp.minRate && maxRate == qrp.maxRate) return;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

67:         _revertIfCallerNotGauge();

279:         if (msg.sender != gauge) revert CallerNotGaugeException(); // U:[PQK-3]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

11: import {IMultiFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";

71:     event Disqualified(address indexed user);

194:     IMultiFeeDistribution public mfd;

218:             if (!whitelist[msg.sender] && msg.sender != address(this)) revert NotWhitelisted();

237:         IMultiFeeDistribution _mfd,

242:         if (_poolConfigurator == address(0)) revert AddressZero();

243:         if (_rdntToken == address(0)) revert AddressZero();

244:         if (address(_eligibleDataProvider) == address(0)) revert AddressZero();

245:         if (address(_mfd) == address(0)) revert AddressZero();

292:         if (startTime != 0) revert AlreadyStarted();

302:         if (msg.sender != poolConfigurator) revert NotAllowed();

303:         if (vaultInfo[_token].lastRewardTime != 0) revert PoolExists();

319:         if (_tokens.length != _allocPoints.length) revert ArrayLengthMismatch();

325:             if (pool.lastRewardTime == 0) revert UnknownPool();

399:         if (length <= 0 || length != _rewardsPerSecond.length) revert ArrayLengthMismatch();

403:                 if (_startTimeOffsets[i - 1] > _startTimeOffsets[i]) revert NotAscending();

405:             if (_startTimeOffsets[i] > type(uint128).max) revert ExceedsMaxInt();

406:             if (_rewardsPerSecond[i] > type(uint128).max) revert ExceedsMaxInt();

407:             if (_checkDuplicateSchedule(_startTimeOffsets[i])) revert DuplicateSchedule();

410:                 if (_startTimeOffsets[i] < block.timestamp - startTime) revert InvalidStart();

520:             if (!eligibleDataProvider.isEligibleForRewards(_user)) revert EligibleRequired();

533:             if (!validRTokens[_tokens[i]]) revert InvalidRToken();

535:             if (pool.lastRewardTime == 0) revert UnknownPool();

558:         if (_amount == 0) revert NothingToVest();

559:         IMultiFeeDistribution mfd_ = mfd;

572:         if (eligibilityMode != EligibilityModes.FULL) return;

573:         if (msg.sender != owner() && !authorizedContracts[msg.sender]) revert InsufficientPermission();

582:         if (authorizedContracts[_address] == _authorize) revert AuthorizationAlreadySet();

597:         if (!validRTokens[msg.sender] && msg.sender != address(mfd)) revert NotRTokenOrMfd();

634:         if (pool.lastRewardTime == 0) revert UnknownPool();

676:             if (msg.sender != address(mfd)) revert NotMFD();

749:             emit Disqualified(_user);

782:         if (msg.sender != address(bountyManager)) revert BountyOnly();

791:         if (eligibilityMode == EligibilityModes.DISABLED) revert NotEligible();

814:         if (_user == address(0)) revert AddressZero();

821:             if (pool.lastRewardTime == 0) revert UnknownPool();

910:         if (_lapse > 1 weeks) revert CadenceTooLong();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

5: import {IMultiFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";

37:     IMultiFeeDistribution public multiFeeDistribution;

57:     mapping(address => uint256) public disqualifiedTime;

97:         IMultiFeeDistribution _multiFeeDistribution,

100:         if (address(_vaultRegistry) == address(0)) revert AddressZero();

101:         if (address(_multiFeeDistribution) == address(0)) revert AddressZero();

102:         if (address(_priceProvider) == address(0)) revert AddressZero();

105:         multiFeeDistribution = _multiFeeDistribution;

119:         if (address(_chef) == address(0)) revert AddressZero();

128:         if (_lpToken == address(0)) revert AddressZero();

129:         if (lpToken != address(0)) revert LPTokenSet();

140:         if (_requiredDepositRatio > RATIO_DIVISOR) revert InvalidRatio();

151:         if (_priceToleranceRatio < MIN_PRICE_TOLERANCE_RATIO || _priceToleranceRatio > RATIO_DIVISOR)

165:         if (msg.sender != address(chef)) revert OnlyCIC();

166:         disqualifiedTime[_user] = _time;

178:         Balances memory _balances = IMultiFeeDistribution(multiFeeDistribution).getBalances(user);

209:         return disqualifiedTime[_user];

227:         LockedBalance[] memory lpLockData = IMultiFeeDistribution(multiFeeDistribution).lockInfo(user);

250:         if (msg.sender != address(chef)) revert OnlyCIC();

251:         if (user == address(0)) revert AddressZero();

256:             disqualifiedTime[user] = 0;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

14: import {IMultiFeeDistribution, IFeeDistribution} from "./interfaces/IMultiFeeDistribution.sol";

23: contract MultiFeeDistribution is

24:     IMultiFeeDistribution,

232:         if (rdntToken_ == address(0)) revert AddressZero();

233:         if (lockZap_ == address(0)) revert AddressZero();

234:         if (dao_ == address(0)) revert AddressZero();

235:         if (priceProvider_ == address(0)) revert AddressZero();

236:         if (rewardsDuration_ == uint256(0)) revert AmountZero();

237:         if (rewardsLookback_ == uint256(0)) revert AmountZero();

238:         if (lockDuration_ == uint256(0)) revert AmountZero();

239:         if (vestDuration_ == uint256(0)) revert AmountZero();

240:         if (burnRatio_ > WHOLE) revert InvalidBurn();

241:         if (rewardsLookback_ > rewardsDuration_) revert InvalidLookback();

269:             if (minters_[i] == address(0)) revert AddressZero();

283:         if (bounty == address(0)) revert AddressZero();

294:         if (rewardConverter_ == address(0)) revert AddressZero();

305:         if (lockPeriod_.length != rewardMultipliers_.length) revert InvalidLockPeriod();

325:         if (address(controller_) == address(0)) revert AddressZero();

326:         if (address(treasury_) == address(0)) revert AddressZero();

337:         if (stakingToken_ == address(0)) revert AddressZero();

338:         if (stakingToken != address(0)) revert AlreadySet();

348:         if (_rewardToken == address(0)) revert AddressZero();

349:         if (!minters[msg.sender]) revert InsufficientPermission();

350:         if (rewardData[_rewardToken].lastUpdateTime != 0) revert AlreadyAdded();

366:         if (!minters[msg.sender]) revert InsufficientPermission();

380:         if (!isTokenFound) revert InvalidAddress();

405:         if (index >= _lockPeriod.length) revert InvalidType();

453:         if (lookback == uint256(0)) revert AmountZero();

454:         if (lookback > rewardsDuration) revert InvalidLookback();

468:         if (_operationExpenseRatio > RATIO_DIVISOR) revert InvalidRatio();

469:         if (_operationExpenseReceiver == address(0)) revert AddressZero();

497:         if (!minters[msg.sender]) revert InsufficientPermission();

498:         if (amount == 0) return;

502:             _notifyReward(address(rdntToken), amount);

539:         if (amount == 0) revert AmountZero();

549:             if (bal.earned < remaining) revert InvalidEarned();

555:                 if (earnedAmount == 0) continue;

566:                     if (remaining == 0) i++;

583:                     if (sumEarned == 0) revert InvalidEarned();

620:         if (unlockTime <= block.timestamp) revert InvalidTime();

679:         if (limit_ == 0) limit_ = _userLocks[address_].length;

690:         if (msg.sender != _lockZap) revert InsufficientPermission();

726:         if (msg.sender != rewardConverter) revert InsufficientPermission();

732:                 _notifyUnseenReward(token);

762:         requalifyFor(msg.sender);

844:         if (msg.sender != address(bountyManager)) revert InsufficientPermission();

1006:                 if (earnedAmount == 0) continue;

1050:         rewardsData = new IFeeDistribution.RewardData[](rewardTokens.length);

1081:         if (amount == 0) return;

1083:             if (amount < IBountyManager(bountyManager).minDLPBalance()) revert InvalidAmount();

1085:         if (typeIndex >= _lockPeriod.length) revert InvalidType();

1107:             if (

1224:         if (token == address(0)) revert AddressZero();

1230:         if (periodFinish == 0) revert InvalidPeriod();

1234:                 _notifyReward(token, unseen);

1250:             _notifyUnseenReward(token);

1282:         if (onBehalfOf != msg.sender) revert InsufficientPermission();

1357:         if (isRelockAction && address_ != msg.sender && _lockZap != msg.sender) revert InsufficientPermission();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

18:     if (x >= 1 << 255) revert Math__toInt256_overflow();

24:     if (x >= 1 << 64) revert Math__toUint64_overflow();

62:     if ((y > 0 && z < x) || (y < 0 && z > x)) revert Math__add_overflow_signed();

70:     if ((y > 0 && z > x) || (y < 0 && z < x)) revert Math__sub_overflow_signed();

77:         if (int256(x) < 0 || (y != 0 && z / y != int256(x))) revert Math__mul_overflow_signed();

219:         if (x <= -42139678854452767551) return r;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/utils/Permission.sol

11:     event ModifyPermission(address authorizer, address owner, address caller, bool grant);

18:     error Permission__modifyPermission_notPermitted();

40:         emit ModifyPermission(msg.sender, msg.sender, caller, permitted);

48:         if (owner != msg.sender && !_permittedAgents[owner][msg.sender])

49:             revert Permission__modifyPermission_notPermitted();

51:         emit ModifyPermission(msg.sender, owner, caller, permitted);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

64:     uint256 private constant TOTAL_CLIFFS = 500;

65:     uint256 private constant REDUCTION_PER_CLIFF = 1e23;

146:         if (parameter == "feed") feed = address(uint160(data));

147:         else if (parameter == "auraPriceOracle") auraPriceOracle = address(uint160(data));

157:         if (_claimerIncentive > maxClaimerIncentive) revert AuraVault__setVaultConfig_invalidClaimerIncentive();

158:         if (_lockerIncentive > maxLockerIncentive) revert AuraVault__setVaultConfig_invalidLockerIncentive();

159:         if (_lockerRewards == address(0x0)) revert AuraVault__setVaultConfig_invalidLockerRewards();

345:         uint256 cliff = emissionsMinted / REDUCTION_PER_CLIFF;

352:             uint256 reduction = ((TOTAL_CLIFFS - cliff) * 5) / 2 + 700;

356:             amount = (_amount * reduction) / TOTAL_CLIFFS;

378:         if (!isValid) revert AuraVault__chainlinkSpot_invalidPrice();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

25:     if (_start + 20 < _start) revert UniswapV3Router_toAddress_overflow();

26:     if (_bytes.length < _start + 20) revert UniswapV3Router_toAddress_outOfBounds();

40:     if (path.length < 20) revert UniswapV3Router_decodeLastToken_invalidPath();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

### <a name="NC-7"></a>[NC-7] Critical Changes Should Use Two-step Procedure

The critical procedures should be two step process.

See similar findings in previous Code4rena contests for reference: <https://code4rena.com/reports/2022-06-illuminate/#2-critical-changes-should-use-two-step-procedure>

**Recommended Mitigation Steps**

Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (1)*:

```solidity
File: src/oracle/ChainlinkOracle.sol

45:     function setOracles(address[] calldata _tokens, Oracle[] calldata _oracles) external onlyRole(DEFAULT_ADMIN_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

### <a name="NC-8"></a>[NC-8] Default Visibility for constants

Some constants are using the default visibility. For readability, consider explicitly declaring them as `internal`.

*Instances (9)*:

```solidity
File: src/CDPVault.sol

33: bytes32 constant VAULT_CONFIG_ROLE = keccak256("VAULT_CONFIG_ROLE");

34: bytes32 constant VAULT_UNWINDER_ROLE = keccak256("VAULT_UNWINDER_ROLE");

59:     uint256 constant INDEX_PRECISION = 10 ** 9;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/oracle/BalancerOracle.sol

13: bytes32 constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/quotas/QuotasLogic.sol

9: uint192 constant RAY_DIVIDED_BY_PERCENTAGE = uint192(RAY / PERCENTAGE_FACTOR);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/utils/Math.sol

14: uint256 constant WAD = 1e18;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/utils/Pause.sol

10: bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Pause.sol)

```solidity
File: src/vendor/AuraVault.sol

20: bytes32 constant VAULT_ADMIN_ROLE = keccak256("VAULT_ADMIN_ROLE");

22: bytes32 constant VAULT_CONFIG_ROLE = keccak256("VAULT_CONFIG_ROLE");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-9"></a>[NC-9] Consider disabling `renounceOwnership()`

If the plan for your project does not include eventually giving up all ownership control, consider overwriting OpenZeppelin's `Ownable`'s `renounceOwnership()` function in order to disable it.

*Instances (3)*:

```solidity
File: src/StakingLPEth.sol

8: contract StakingLPEth is ERC4626, Ownable, ReentrancyGuard {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

20: contract ChefIncentivesController is Initializable, PausableUpgradeable, OwnableUpgradeable, RecoverERC20 {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

16: contract EligibilityDataProvider is OwnableUpgradeable {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

### <a name="NC-10"></a>[NC-10] Draft Dependencies

Draft contracts have not received adequate security auditing or are liable to change with future developments.

*Instances (1)*:

```solidity
File: src/proxy/TransferAction.sol

5: import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/TransferAction.sol)

### <a name="NC-11"></a>[NC-11] Unused `error` definition

Note that there may be cases where an error superficially appears to be used, but this is only because there are multiple definitions of the error in different files. In such cases, the error definition should be moved into a separate file. The instances below are the unused definitions.

*Instances (8)*:

```solidity
File: src/CDPVault.sol

150:     error CDPVault__modifyCollateralAndDebt_maxUtilizationRatio();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

44:     error Flash__creditFlashLoan_unsupportedToken();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

57:     error CallerNotManagerException();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

39:     error ChainlinkOracle__authorizeUpgrade_validStatus();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

130:     error ValueZero();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

188:     error MintersSet();

194:     error ActiveReward();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

110:     error AuraVault__fetchAggregator_invalidToken();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-12"></a>[NC-12] Event is never emitted

The following are defined but never emitted. They can be removed to make the code cleaner.

*Instances (2)*:

```solidity
File: src/CDPVault.sol

135:     event LiquidatePosition(

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

69:     event ChefReserveLow(uint256 indexed _balance);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

### <a name="NC-13"></a>[NC-13] Event missing indexed field

Index event fields make the field more quickly accessible [to off-chain tools](https://ethereum.stackexchange.com/questions/40396/can-somebody-please-explain-the-concept-of-event-indexing) that parse events. This is especially useful when it comes to filtering based on an address. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Where applicable, each `event` should use three `indexed` fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three applicable fields, all of the applicable fields should be indexed.

*Instances (8)*:

```solidity
File: src/StakingLPEth.sol

40:     event CooldownDurationUpdated(uint24 previousDuration, uint24 newDuration);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

67:     event EmissionScheduleAppended(uint256[] startTimeOffsets, uint256[] rewardsPerSeconds);

77:     event BatchAllocPointsUpdated(address[] _tokens, uint256[] _allocPoints);

79:     event AuthorizedContractUpdated(address _contract, bool _authorized);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

172:     event LockTypeInfoUpdated(uint256[] lockPeriod, uint256[] rewardMultipliers);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Permission.sol

11:     event ModifyPermission(address authorizer, address owner, address caller, bool grant);

12:     event SetPermittedAgent(address owner, address agent, bool grant);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

102:     event SetParameter(bytes32 parameter, uint256 data);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-14"></a>[NC-14] Events that mark critical parameter changes should contain both the old and the new value

This should especially be done if the new value is not required to be different from the old value

*Instances (29)*:

```solidity
File: src/CDPVault.sol

195:     function setParameter(bytes32 parameter, uint256 data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {
             if (parameter == "debtFloor") vaultConfig.debtFloor = uint128(data);
             else if (parameter == "liquidationRatio") vaultConfig.liquidationRatio = uint64(data);
             else if (parameter == "liquidationPenalty") liquidationConfig.liquidationPenalty = uint64(data);
             else if (parameter == "liquidationDiscount") liquidationConfig.liquidationDiscount = uint64(data);
             else revert CDPVault__setParameter_unrecognizedParameter();
             emit SetParameter(parameter, data);

208:     function setParameter(bytes32 parameter, address data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {
             if (parameter == "rewardController") rewardController = IChefIncentivesController(data);
             else revert CDPVault__setParameter_unrecognizedParameter();
             emit SetParameter(parameter, data);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

746:     function setInterestRateModel(
             address newInterestRateModel
         )
             external
             override
             configuratorOnly // U:[LP-2C]
             nonZeroAddress(newInterestRateModel) // U:[LP-22A]
         {
             interestRateModel = newInterestRateModel; // U:[LP-22B]
             _updateBaseInterest(0, 0, false); // U:[LP-22B]
             emit SetInterestRateModel(newInterestRateModel); // U:[LP-22B]

761:     function setPoolQuotaKeeper(
             address newPoolQuotaKeeper
         )
             external
             override
             configuratorOnly // U:[LP-2C]
             nonZeroAddress(newPoolQuotaKeeper) // U:[LP-23A]
         {
             if (IPoolQuotaKeeperV3(newPoolQuotaKeeper).pool() != address(this)) {
                 revert IncompatiblePoolQuotaKeeperException(); // U:[LP-23C]
             }
     
             poolQuotaKeeper = newPoolQuotaKeeper; // U:[LP-23D]
     
             uint256 newQuotaRevenue = IPoolQuotaKeeperV3(poolQuotaKeeper).poolQuotaRevenue();
             _setQuotaRevenue(newQuotaRevenue); // U:[LP-23D]
     
             emit SetPoolQuotaKeeper(newPoolQuotaKeeper); // U:[LP-23D]

797:     function setCreditManagerDebtLimit(
             address creditManager,
             uint256 newLimit
         )
             external
             override
             controllerOnly // U:[LP-2C]
             nonZeroAddress(creditManager) // U:[LP-25A]
         {
             if (!_creditManagerSet.contains(creditManager)) {
                 if (address(this) != ICreditManagerV3(creditManager).pool()) {
                     revert IncompatibleCreditManagerException(); // U:[LP-25C]
                 }
                 _creditManagerSet.add(creditManager); // U:[LP-25D]
                 emit AddCreditManager(creditManager); // U:[LP-25D]
             }
             _creditManagerDebt[creditManager].limit = _convertToU128(newLimit); // U:[LP-25D]
             emit SetCreditManagerDebtLimit(creditManager, newLimit); // U:[LP-25D]

797:     function setCreditManagerDebtLimit(
             address creditManager,
             uint256 newLimit
         )
             external
             override
             controllerOnly // U:[LP-2C]
             nonZeroAddress(creditManager) // U:[LP-25A]
         {
             if (!_creditManagerSet.contains(creditManager)) {
                 if (address(this) != ICreditManagerV3(creditManager).pool()) {
                     revert IncompatibleCreditManagerException(); // U:[LP-25C]
                 }
                 _creditManagerSet.add(creditManager); // U:[LP-25D]
                 emit AddCreditManager(creditManager); // U:[LP-25D]

819:     function setWithdrawFee(
             uint256 newWithdrawFee
         )
             external
             override
             controllerOnly // U:[LP-2C]
         {
             if (newWithdrawFee > MAX_WITHDRAW_FEE) {
                 revert IncorrectParameterException(); // U:[LP-26A]
             }
             if (newWithdrawFee == withdrawFee) return;
     
             withdrawFee = newWithdrawFee.toUint16(); // U:[LP-26B]
             emit SetWithdrawFee(newWithdrawFee); // U:[LP-26B]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

130:     function setCooldownDuration(uint24 duration) external onlyOwner {
             if (duration > MAX_COOLDOWN_DURATION) {
                 revert InvalidCooldown();
             }
     
             uint24 previousDuration = cooldownDuration;
             cooldownDuration = duration;
             emit CooldownDurationUpdated(previousDuration, cooldownDuration);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/quotas/GaugeV3.sol

219:     function setFrozenEpoch(bool status) external override configuratorOnly {
             if (status != epochFrozen) {
                 epochFrozen = status;
     
                 emit SetFrozenEpoch(status);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

183:     function updateRates()
             external
             override
             gaugeOnly // U:[PQK-3]
         {
             address[] memory tokens = quotaTokensSet.values();
             uint16[] memory rates = IGaugeV3(gauge).getRates(tokens); // U:[PQK-7]
     
             uint256 quotaRevenue; // U:[PQK-7]
             uint256 timestampLU = lastQuotaRateUpdate;
             uint256 len = tokens.length;
     
             for (uint256 i; i < len; ) {
                 address token = tokens[i];
                 uint16 rate = rates[i];
     
                 TokenQuotaParams storage tokenQuotaParams = totalQuotaParams[token]; // U:[PQK-7]
                 (uint16 prevRate, uint192 tqCumulativeIndexLU, ) = _getTokenQuotaParamsOrRevert(tokenQuotaParams);
     
                 tokenQuotaParams.cumulativeIndexLU = QuotasLogic.cumulativeIndexSince(
                     tqCumulativeIndexLU,
                     prevRate,
                     timestampLU
                 ); // U:[PQK-7]
     
                 tokenQuotaParams.rate = rate; // U:[PQK-7]
     
                 quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR; // U:[PQK-7]
     
                 emit UpdateTokenQuotaRate(token, rate); // U:[PQK-7]

225:     function setGauge(
             address _gauge
         )
             external
             override
             configuratorOnly // U:[PQK-2]
         {
             if (gauge != _gauge) {
                 gauge = _gauge; // U:[PQK-8]
                 emit SetGauge(_gauge); // U:[PQK-8]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

272:     function setBountyManager(address _bountyManager) external onlyOwner {
             bountyManager = _bountyManager;
             emit BountyManagerUpdated(_bountyManager);

281:     function setEligibilityMode(EligibilityModes _newVal) external onlyOwner {
             eligibilityMode = _newVal;
             emit EligibilityModeUpdated(_newVal);

342:     function setRewardsPerSecond(uint256 _rewardsPerSecond, bool _persist) external onlyOwner {
             _massUpdatePools();
             rewardsPerSecond = _rewardsPerSecond;
             persistRewardsPerSecond = _persist;
             emit RewardsPerSecondUpdated(_rewardsPerSecond, _persist);

394:     function setEmissionSchedule(
             uint256[] calldata _startTimeOffsets,
             uint256[] calldata _rewardsPerSecond
         ) external onlyOwner {
             uint256 length = _startTimeOffsets.length;
             if (length <= 0 || length != _rewardsPerSecond.length) revert ArrayLengthMismatch();
     
             for (uint256 i = 0; i < length; ) {
                 if (i > 0) {
                     if (_startTimeOffsets[i - 1] > _startTimeOffsets[i]) revert NotAscending();
                 }
                 if (_startTimeOffsets[i] > type(uint128).max) revert ExceedsMaxInt();
                 if (_rewardsPerSecond[i] > type(uint128).max) revert ExceedsMaxInt();
                 if (_checkDuplicateSchedule(_startTimeOffsets[i])) revert DuplicateSchedule();
     
                 if (startTime > 0) {
                     if (_startTimeOffsets[i] < block.timestamp - startTime) revert InvalidStart();
                 }
                 emissionSchedule.push(
                     EmissionPoint({
                         startTimeOffset: uint128(_startTimeOffsets[i]),
                         rewardsPerSecond: uint128(_rewardsPerSecond[i])
                     })
                 );
                 unchecked {
                     i++;
                 }
             }
             emit EmissionScheduleAppended(_startTimeOffsets, _rewardsPerSecond);

581:     function setContractAuthorization(address _address, bool _authorize) external onlyOwner {
             if (authorizedContracts[_address] == _authorize) revert AuthorizationAlreadySet();
             authorizedContracts[_address] = _authorize;
             emit AuthorizedContractUpdated(_address, _authorize);

909:     function setEndingTimeUpdateCadence(uint256 _lapse) external onlyOwner {
             if (_lapse > 1 weeks) revert CadenceTooLong();
             endingTime.updateCadence = _lapse;
             emit EndingTimeUpdateCadence(_lapse);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

118:     function setChefIncentivesController(IChefIncentivesController _chef) external onlyOwner {
             if (address(_chef) == address(0)) revert AddressZero();
             chef = _chef;
             emit ChefIncentivesControllerUpdated(_chef);

127:     function setLPToken(address _lpToken) external onlyOwner {
             if (_lpToken == address(0)) revert AddressZero();
             if (lpToken != address(0)) revert LPTokenSet();
             lpToken = _lpToken;
     
             emit LPTokenUpdated(_lpToken);

139:     function setRequiredDepositRatio(uint256 _requiredDepositRatio) external onlyOwner {
             if (_requiredDepositRatio > RATIO_DIVISOR) revert InvalidRatio();
             requiredDepositRatio = _requiredDepositRatio;
     
             emit RequiredDepositRatioUpdated(_requiredDepositRatio);

150:     function setPriceToleranceRatio(uint256 _priceToleranceRatio) external onlyOwner {
             if (_priceToleranceRatio < MIN_PRICE_TOLERANCE_RATIO || _priceToleranceRatio > RATIO_DIVISOR)
                 revert InvalidRatio();
             priceToleranceRatio = _priceToleranceRatio;
     
             emit PriceToleranceRatioUpdated(_priceToleranceRatio);

164:     function setDqTime(address _user, uint256 _time) external {
             if (msg.sender != address(chef)) revert OnlyCIC();
             disqualifiedTime[_user] = _time;
     
             emit DqTimeUpdated(_user, _time);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

282:     function setBountyManager(address bounty) external onlyOwner {
             if (bounty == address(0)) revert AddressZero();
             bountyManager = bounty;
             minters[bounty] = true;
             emit BountyManagerUpdated(bounty);

304:     function setLockTypeInfo(uint256[] calldata lockPeriod_, uint256[] calldata rewardMultipliers_) external onlyOwner {
             if (lockPeriod_.length != rewardMultipliers_.length) revert InvalidLockPeriod();
             delete _lockPeriod;
             delete _rewardMultipliers;
             uint256 length = lockPeriod_.length;
             for (uint256 i; i < length; ) {
                 _lockPeriod.push(lockPeriod_[i]);
                 _rewardMultipliers.push(rewardMultipliers_[i]);
                 unchecked {
                     i++;
                 }
             }
             emit LockTypeInfoUpdated(lockPeriod_, rewardMultipliers_);

324:     function setAddresses(IChefIncentivesController controller_, address treasury_) external onlyOwner {
             if (address(controller_) == address(0)) revert AddressZero();
             if (address(treasury_) == address(0)) revert AddressZero();
             incentivesController = controller_;
             starfleetTreasury = treasury_;
             emit AddressesUpdated(controller_, treasury_);

336:     function setLPToken(address stakingToken_) external onlyOwner {
             if (stakingToken_ == address(0)) revert AddressZero();
             if (stakingToken != address(0)) revert AlreadySet();
             stakingToken = stakingToken_;
             emit LPTokenUpdated(stakingToken_);

464:     function setOperationExpenses(
             address _operationExpenseReceiver,
             uint256 _operationExpenseRatio
         ) external onlyOwner {
             if (_operationExpenseRatio > RATIO_DIVISOR) revert InvalidRatio();
             if (_operationExpenseReceiver == address(0)) revert AddressZero();
             operationExpenseReceiver = _operationExpenseReceiver;
             operationExpenseRatio = _operationExpenseRatio;
             emit OperationExpensesUpdated(_operationExpenseReceiver, _operationExpenseRatio);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Permission.sol

57:     function setPermissionAgent(address agent, bool permitted) external {
            _permittedAgents[msg.sender][agent] = permitted;
            emit SetPermittedAgent(msg.sender, agent, permitted);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

145:     function setParameter(bytes32 parameter, uint256 data) external onlyRole(VAULT_CONFIG_ROLE) {
             if (parameter == "feed") feed = address(uint160(data));
             else if (parameter == "auraPriceOracle") auraPriceOracle = address(uint160(data));
             else revert AuraVault__setParameter_unrecognizedParameter();
             emit SetParameter(parameter, data);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-15"></a>[NC-15] Function ordering does not follow the Solidity style guide

According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*Instances (17)*:

```solidity
File: src/CDPVault.sol

1: 
   Current order:
   external mintProfit
   external enter
   external exit
   external addAvailable
   external setParameter
   external setParameter
   external deposit
   external withdraw
   external borrow
   external repay
   public spotPrice
   internal _modifyPosition
   internal _isCollateralized
   public modifyCollateralAndDebt
   internal _calcQuotaRevenueChange
   internal _calcDebt
   internal _getQuotedTokensData
   external liquidatePosition
   external liquidatePositionBadDebt
   internal calcDecrease
   internal calcAccruedInterest
   external virtualDebt
   internal calcTotalDebt
   public poolQuotaKeeper
   external quotasInterest
   external getDebtData
   external getDebtInfo
   
   Suggested order:
   external mintProfit
   external enter
   external exit
   external addAvailable
   external setParameter
   external setParameter
   external deposit
   external withdraw
   external borrow
   external repay
   external liquidatePosition
   external liquidatePositionBadDebt
   external virtualDebt
   external quotasInterest
   external getDebtData
   external getDebtInfo
   public spotPrice
   public modifyCollateralAndDebt
   public poolQuotaKeeper
   internal _modifyPosition
   internal _isCollateralized
   internal _calcQuotaRevenueChange
   internal _calcDebt
   internal _getQuotedTokensData
   internal calcDecrease
   internal calcAccruedInterest
   internal calcTotalDebt

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

1: 
   Current order:
   internal _revertIfCallerIsNotPoolQuotaKeeper
   internal _revertIfCallerNotCreditManager
   internal _revertIfLocked
   public decimals
   external creditManagers
   public availableLiquidity
   public expectedLiquidity
   public expectedLiquidityLU
   public totalAssets
   public deposit
   external depositWithReferral
   public mint
   external mintWithReferral
   public withdraw
   public redeem
   public previewDeposit
   public previewMint
   public previewWithdraw
   public previewRedeem
   public maxDeposit
   public maxMint
   public maxWithdraw
   public maxRedeem
   internal _deposit
   internal _withdraw
   internal _convertToShares
   internal _convertToAssets
   external totalBorrowed
   external totalDebtLimit
   external creditManagerBorrowed
   external creditManagerDebtLimit
   external creditManagerBorrowable
   external lendCreditAccount
   external repayCreditAccount
   internal _borrowable
   public baseInterestRate
   external supplyRate
   public baseInterestIndex
   external baseInterestIndexLU
   internal _calcBaseInterestAccrued
   external calcAccruedQuotaInterest
   internal _updateBaseInterest
   private _calcBaseInterestAccrued
   private _calcBaseInterestIndex
   public quotaRevenue
   external updateQuotaRevenue
   external setQuotaRevenue
   internal _calcQuotaRevenueAccrued
   internal _setQuotaRevenue
   private _calcQuotaRevenueAccrued
   external setInterestRateModel
   external setPoolQuotaKeeper
   external setTotalDebtLimit
   external setCreditManagerDebtLimit
   external setWithdrawFee
   external setAllowed
   external setLock
   external isAllowed
   internal _setTotalDebtLimit
   internal _amountWithFee
   internal _amountMinusFee
   internal _amountWithWithdrawalFee
   internal _amountMinusWithdrawalFee
   internal _convertToU256
   internal _convertToU128
   external mintProfit
   
   Suggested order:
   external creditManagers
   external depositWithReferral
   external mintWithReferral
   external totalBorrowed
   external totalDebtLimit
   external creditManagerBorrowed
   external creditManagerDebtLimit
   external creditManagerBorrowable
   external lendCreditAccount
   external repayCreditAccount
   external supplyRate
   external baseInterestIndexLU
   external calcAccruedQuotaInterest
   external updateQuotaRevenue
   external setQuotaRevenue
   external setInterestRateModel
   external setPoolQuotaKeeper
   external setTotalDebtLimit
   external setCreditManagerDebtLimit
   external setWithdrawFee
   external setAllowed
   external setLock
   external isAllowed
   external mintProfit
   public decimals
   public availableLiquidity
   public expectedLiquidity
   public expectedLiquidityLU
   public totalAssets
   public deposit
   public mint
   public withdraw
   public redeem
   public previewDeposit
   public previewMint
   public previewWithdraw
   public previewRedeem
   public maxDeposit
   public maxMint
   public maxWithdraw
   public maxRedeem
   public baseInterestRate
   public baseInterestIndex
   public quotaRevenue
   internal _revertIfCallerIsNotPoolQuotaKeeper
   internal _revertIfCallerNotCreditManager
   internal _revertIfLocked
   internal _deposit
   internal _withdraw
   internal _convertToShares
   internal _convertToAssets
   internal _borrowable
   internal _calcBaseInterestAccrued
   internal _updateBaseInterest
   internal _calcQuotaRevenueAccrued
   internal _setQuotaRevenue
   internal _setTotalDebtLimit
   internal _amountWithFee
   internal _amountMinusFee
   internal _amountWithWithdrawalFee
   internal _amountMinusWithdrawalFee
   internal _convertToU256
   internal _convertToU128
   private _calcBaseInterestAccrued
   private _calcBaseInterestIndex
   private _calcQuotaRevenueAccrued

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

1: 
   Current order:
   public withdraw
   public redeem
   external unstake
   external cooldownAssets
   external cooldownShares
   external setCooldownDuration
   internal _checkMinShares
   internal _deposit
   internal _withdraw
   
   Suggested order:
   external unstake
   external cooldownAssets
   external cooldownShares
   external setCooldownDuration
   public withdraw
   public redeem
   internal _checkMinShares
   internal _deposit
   internal _withdraw

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

1: 
   Current order:
   external addVault
   external removeVault
   external getVaults
   external getUserTotalDebt
   private _removeVaultFromList
   external isVaultRegistered
   
   Suggested order:
   external addVault
   external removeVault
   external getVaults
   external getUserTotalDebt
   external isVaultRegistered
   private _removeVaultFromList

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

1: 
   Current order:
   external initialize
   internal _authorizeUpgrade
   external update
   public getStatus
   internal _getStatus
   external spot
   internal _getTokenPrice
   
   Suggested order:
   external initialize
   external update
   external spot
   public getStatus
   internal _authorizeUpgrade
   internal _getStatus
   internal _getTokenPrice

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

1: 
   Current order:
   external setOracles
   external initialize
   internal _authorizeUpgrade
   public getStatus
   external spot
   internal _fetchAndValidate
   private _getStatus
   
   Suggested order:
   external setOracles
   external initialize
   external spot
   public getStatus
   internal _authorizeUpgrade
   internal _fetchAndValidate
   private _getStatus

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PoolAction.sol

1: 
   Current order:
   external transferAndJoin
   public join
   internal _balancerJoin
   external updateLeverJoin
   public exit
   internal _balancerExit
   
   Suggested order:
   external transferAndJoin
   external updateLeverJoin
   public join
   public exit
   internal _balancerJoin
   internal _balancerExit

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction.sol

1: 
   Current order:
   internal _onDeposit
   internal _onWithdraw
   internal _onIncreaseLever
   internal _onDecreaseLever
   external deposit
   external withdraw
   external borrow
   external repay
   external depositAndBorrow
   external withdrawAndRepay
   external multisend
   external increaseLever
   external decreaseLever
   external onFlashLoan
   external onCreditFlashLoan
   internal _deposit
   internal _withdraw
   internal _borrow
   internal _repay
   internal _transferAndSwap
   
   Suggested order:
   external deposit
   external withdraw
   external borrow
   external repay
   external depositAndBorrow
   external withdrawAndRepay
   external multisend
   external increaseLever
   external decreaseLever
   external onFlashLoan
   external onCreditFlashLoan
   internal _onDeposit
   internal _onWithdraw
   internal _onIncreaseLever
   internal _onDecreaseLever
   internal _deposit
   internal _withdraw
   internal _borrow
   internal _repay
   internal _transferAndSwap

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/SwapAction.sol

1: 
   Current order:
   external transferAndSwap
   public swap
   internal balancerSwap
   internal uniV3Swap
   public getSwapToken
   internal _revertBytes
   
   Suggested order:
   external transferAndSwap
   public swap
   public getSwapToken
   internal balancerSwap
   internal uniV3Swap
   internal _revertBytes

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

1: 
   Current order:
   external updateEpoch
   internal _checkAndUpdateEpoch
   external getRates
   external vote
   internal _vote
   external unvote
   internal _unvote
   external setFrozenEpoch
   external addQuotaToken
   external changeQuotaMinRate
   external changeQuotaMaxRate
   internal _changeQuotaTokenRateParams
   internal _checkParams
   public isTokenAdded
   internal _poolQuotaKeeper
   internal _revertIfCallerNotVoter
   
   Suggested order:
   external updateEpoch
   external getRates
   external vote
   external unvote
   external setFrozenEpoch
   external addQuotaToken
   external changeQuotaMinRate
   external changeQuotaMaxRate
   public isTokenAdded
   internal _checkAndUpdateEpoch
   internal _vote
   internal _unvote
   internal _changeQuotaTokenRateParams
   internal _checkParams
   internal _poolQuotaKeeper
   internal _revertIfCallerNotVoter

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

1: 
   Current order:
   public cumulativeIndex
   external getQuotaRate
   external quotedTokens
   external isQuotedToken
   external getTokenQuotaParams
   external poolQuotaRevenue
   external addQuotaToken
   external updateRates
   external setGauge
   external setCreditManager
   internal isInitialised
   internal _getTokenQuotaParamsOrRevert
   internal _revertIfCallerNotGauge
   
   Suggested order:
   external getQuotaRate
   external quotedTokens
   external isQuotedToken
   external getTokenQuotaParams
   external poolQuotaRevenue
   external addQuotaToken
   external updateRates
   external setGauge
   external setCreditManager
   public cumulativeIndex
   internal isInitialised
   internal _getTokenQuotaParamsOrRevert
   internal _revertIfCallerNotGauge

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

1: 
   Current order:
   public initialize
   public poolLength
   external setBountyManager
   external setEligibilityMode
   public start
   external addPool
   external batchUpdateAllocPoint
   external setRewardsPerSecond
   internal setScheduledRewardsPerSecond
   internal _checkDuplicateSchedule
   external setEmissionSchedule
   external recoverERC20
   internal _updateEmissions
   internal _massUpdatePools
   internal _updatePool
   public pendingRewards
   public claim
   internal _vestTokens
   public setEligibilityExempt
   external setContractAuthorization
   external handleActionAfter
   internal _handleActionAfterForToken
   external handleActionBefore
   external beforeLockUpdate
   external afterLockUpdate
   internal _updateRegisteredBalance
   public hasEligibleDeposits
   internal _processEligibility
   internal checkAndProcessEligibility
   public claimBounty
   internal stopEmissionsFor
   public manualStopEmissionsFor
   external manualStopAllEmissionsFor
   internal _sendRadiant
   public endRewardTime
   external setEndingTimeUpdateCadence
   external registerRewardDeposit
   internal availableRewards
   external claimAll
   public allPendingRewards
   external pause
   external unpause
   internal _newRewards
   external setAddressWLstatus
   external toggleWhitelist
   
   Suggested order:
   external setBountyManager
   external setEligibilityMode
   external addPool
   external batchUpdateAllocPoint
   external setRewardsPerSecond
   external setEmissionSchedule
   external recoverERC20
   external setContractAuthorization
   external handleActionAfter
   external handleActionBefore
   external beforeLockUpdate
   external afterLockUpdate
   external manualStopAllEmissionsFor
   external setEndingTimeUpdateCadence
   external registerRewardDeposit
   external claimAll
   external pause
   external unpause
   external setAddressWLstatus
   external toggleWhitelist
   public initialize
   public poolLength
   public start
   public pendingRewards
   public claim
   public setEligibilityExempt
   public hasEligibleDeposits
   public claimBounty
   public manualStopEmissionsFor
   public endRewardTime
   public allPendingRewards
   internal setScheduledRewardsPerSecond
   internal _checkDuplicateSchedule
   internal _updateEmissions
   internal _massUpdatePools
   internal _updatePool
   internal _vestTokens
   internal _handleActionAfterForToken
   internal _updateRegisteredBalance
   internal _processEligibility
   internal checkAndProcessEligibility
   internal stopEmissionsFor
   internal _sendRadiant
   internal availableRewards
   internal _newRewards

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

1: 
   Current order:
   public initialize
   external setChefIncentivesController
   external setLPToken
   external setRequiredDepositRatio
   external setPriceToleranceRatio
   external setDqTime
   public lockedUsdValue
   public requiredUsdValue
   public isEligibleForRewards
   public getDqTime
   public lastEligibleTime
   external refresh
   public updatePrice
   internal _lockedUsdValue
   
   Suggested order:
   external setChefIncentivesController
   external setLPToken
   external setRequiredDepositRatio
   external setPriceToleranceRatio
   external setDqTime
   external refresh
   public initialize
   public lockedUsdValue
   public requiredUsdValue
   public isEligibleForRewards
   public getDqTime
   public lastEligibleTime
   public updatePrice
   internal _lockedUsdValue

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

1: 
   Current order:
   public initialize
   external setMinters
   external setBountyManager
   external addRewardConverter
   external setLockTypeInfo
   external setAddresses
   external setLPToken
   external addReward
   external removeReward
   external setDefaultRelockTypeIndex
   external setAutocompound
   external setUserSlippage
   external toggleAutocompound
   external setRelock
   external setLookback
   external setOperationExpenses
   external stake
   external vestTokens
   external withdraw
   external individualEarlyExit
   external exit
   external getAllRewards
   external withdrawExpiredLocksForWithOptions
   external zapVestingToLp
   external claimFromConverter
   external relock
   external requalify
   external recoverERC20
   external getLockDurations
   external getLockMultipliers
   external lockInfo
   external totalBalance
   external getPriceProvider
   external getRewardForDuration
   external getBalances
   public claimBounty
   public getReward
   public pause
   public unpause
   public requalifyFor
   public lockedBalances
   public lockedBalance
   public earnedBalances
   public withdrawableBalance
   public lastTimeRewardApplicable
   public rewardPerToken
   public claimableRewards
   internal _stake
   internal _updateReward
   internal _notifyReward
   internal _notifyUnseenReward
   internal _getReward
   internal _withdrawTokens
   internal _cleanWithdrawableLocks
   internal _withdrawExpiredLocksFor
   internal _ieeWithdrawableBalance
   internal _insertLock
   internal _earned
   internal _penaltyInfo
   private _binarySearch
   
   Suggested order:
   external setMinters
   external setBountyManager
   external addRewardConverter
   external setLockTypeInfo
   external setAddresses
   external setLPToken
   external addReward
   external removeReward
   external setDefaultRelockTypeIndex
   external setAutocompound
   external setUserSlippage
   external toggleAutocompound
   external setRelock
   external setLookback
   external setOperationExpenses
   external stake
   external vestTokens
   external withdraw
   external individualEarlyExit
   external exit
   external getAllRewards
   external withdrawExpiredLocksForWithOptions
   external zapVestingToLp
   external claimFromConverter
   external relock
   external requalify
   external recoverERC20
   external getLockDurations
   external getLockMultipliers
   external lockInfo
   external totalBalance
   external getPriceProvider
   external getRewardForDuration
   external getBalances
   public initialize
   public claimBounty
   public getReward
   public pause
   public unpause
   public requalifyFor
   public lockedBalances
   public lockedBalance
   public earnedBalances
   public withdrawableBalance
   public lastTimeRewardApplicable
   public rewardPerToken
   public claimableRewards
   internal _stake
   internal _updateReward
   internal _notifyReward
   internal _notifyUnseenReward
   internal _getReward
   internal _withdrawTokens
   internal _cleanWithdrawableLocks
   internal _withdrawExpiredLocksFor
   internal _ieeWithdrawableBalance
   internal _insertLock
   internal _earned
   internal _penaltyInfo
   private _binarySearch

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Pause.sol

1: 
   Current order:
   internal _pause
   external pause
   external unpause
   
   Suggested order:
   external pause
   external unpause
   internal _pause

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Pause.sol)

```solidity
File: src/vendor/AuraVault.sol

1: 
   Current order:
   external setParameter
   public setVaultConfig
   public totalAssets
   internal _convertToShares
   internal _convertToAssets
   public deposit
   public mint
   public withdraw
   public redeem
   external claim
   public previewReward
   private _previewReward
   private _previewMining
   private _chainlinkSpot
   internal _getAuraSpot
   
   Suggested order:
   external setParameter
   external claim
   public setVaultConfig
   public totalAssets
   public deposit
   public mint
   public withdraw
   public redeem
   public previewReward
   internal _convertToShares
   internal _convertToAssets
   internal _getAuraSpot
   private _previewReward
   private _previewMining
   private _chainlinkSpot

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

1: 
   Current order:
   internal toAddress
   internal decodeLastToken
   external exactInput
   external exactOutput
   
   Suggested order:
   external exactInput
   external exactOutput
   internal toAddress
   internal decodeLastToken

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

### <a name="NC-16"></a>[NC-16] Functions should not be longer than 50 lines

Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability

*Instances (270)*:

```solidity
File: src/CDPVault.sol

25:     function enter(address user, uint256 amount) external;

27:     function exit(address user, uint256 amount) external;

29:     function addAvailable(address user, int256 amount) external;

195:     function setParameter(bytes32 parameter, uint256 data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {

208:     function setParameter(bytes32 parameter, address data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {

223:     function deposit(address to, uint256 amount) external whenNotPaused returns (uint256 tokenAmount) {

239:     function withdraw(address to, uint256 amount) external whenNotPaused returns (uint256 tokenAmount) {

256:     function borrow(address borrower, address position, uint256 amount) external {

272:     function repay(address borrower, address position, uint256 amount) external {

289:     function spotPrice() public view returns (uint256) {

462:     function _calcQuotaRevenueChange(int256 deltaDebt) internal view returns (int256 quotaRevenueChange) {

467:     function _calcDebt(Position memory position) internal view returns (DebtData memory cdd) {

509:     function liquidatePosition(address owner, uint256 repayAmount) external whenNotPaused {

579:     function liquidatePositionBadDebt(address owner, uint256 repayAmount) external whenNotPaused {

729:     function virtualDebt(address position) external view returns (uint256) {

735:     function calcTotalDebt(DebtData memory debtData) internal pure returns (uint256) {

740:     function poolQuotaKeeper() public view returns (address) {

745:     function quotasInterest(address position) external view returns (uint256) {

751:     function getDebtData(address position) external view returns (DebtData memory) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

64:     function maxFlashLoan(address token) external view override returns (uint256 max) {

75:     function flashFee(address token, uint256 amount) external view override returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

130:     function _revertIfCallerIsNotPoolQuotaKeeper() internal view {

135:     function _revertIfCallerNotCreditManager() internal view {

192:     function decimals() public view override(ERC20, ERC4626, IERC20Metadata) returns (uint8) {

197:     function creditManagers() external view override returns (address[] memory) {

202:     function availableLiquidity() public view override returns (uint256) {

208:     function expectedLiquidity() public view override returns (uint256) {

213:     function expectedLiquidityLU() public view override returns (uint256) {

223:     function totalAssets() public view override(ERC4626, IERC4626) returns (uint256 assets) {

336:     function previewDeposit(uint256 assets) public view override(ERC4626, IERC4626) returns (uint256 shares) {

341:     function previewMint(uint256 shares) public view override(ERC4626, IERC4626) returns (uint256) {

346:     function previewWithdraw(uint256 assets) public view override(ERC4626, IERC4626) returns (uint256) {

351:     function previewRedeem(uint256 shares) public view override(ERC4626, IERC4626) returns (uint256) {

356:     function maxDeposit(address) public view override(ERC4626, IERC4626) returns (uint256) {

361:     function maxMint(address) public view override(ERC4626, IERC4626) returns (uint256) {

366:     function maxWithdraw(address owner) public view override(ERC4626, IERC4626) returns (uint256) {

376:     function maxRedeem(address owner) public view override(ERC4626, IERC4626) returns (uint256) {

384:     function _deposit(address receiver, uint256 assetsSent, uint256 assetsReceived, uint256 shares) internal {

429:     function _convertToShares(uint256 assets) internal pure returns (uint256 shares) {

436:     function _convertToAssets(uint256 shares) internal pure returns (uint256 assets) {

446:     function totalBorrowed() external view override returns (uint256) {

451:     function totalDebtLimit() external view override returns (uint256) {

456:     function creditManagerBorrowed(address creditManager) external view override returns (uint256) {

461:     function creditManagerDebtLimit(address creditManager) external view override returns (uint256) {

466:     function creditManagerBorrowable(address creditManager) external view override returns (uint256 borrowable) {

579:     function _borrowable(DebtParams storage debt) internal view returns (uint256) {

596:     function baseInterestRate() public view override returns (uint256) {

603:     function supplyRate() external view override returns (uint256) {

614:     function baseInterestIndex() public view override returns (uint256) {

621:     function baseInterestIndexLU() external view override returns (uint256) {

626:     function _calcBaseInterestAccrued() internal view returns (uint256) {

632:     function calcAccruedQuotaInterest() external view returns (uint256) {

671:     function _calcBaseInterestAccrued(uint256 timestamp) private view returns (uint256) {

676:     function _calcBaseInterestIndex(uint256 timestamp) private view returns (uint256) {

685:     function quotaRevenue() public view override returns (uint256) {

717:     function _calcQuotaRevenueAccrued() internal view returns (uint256) {

726:     function _setQuotaRevenue(uint256 newQuotaRevenue) internal {

736:     function _calcQuotaRevenueAccrued(uint256 timestamp) private view returns (uint256) {

838:     function setAllowed(address account, bool status) external controllerOnly {

844:     function setLock(bool status) external controllerOnly {

850:     function isAllowed(address account) external view returns (bool) {

855:     function _setTotalDebtLimit(uint256 limit) internal {

869:     function _amountWithFee(uint256 amount) internal view virtual returns (uint256) {

875:     function _amountMinusFee(uint256 amount) internal view virtual returns (uint256) {

880:     function _amountWithWithdrawalFee(uint256 amount) internal view returns (uint256) {

885:     function _amountMinusWithdrawalFee(uint256 amount) internal view returns (uint256) {

890:     function _convertToU256(uint128 limit) internal pure returns (uint256) {

895:     function _convertToU128(uint256 limit) internal pure returns (uint128) {

899:     function mintProfit(uint256 amount) external creditManagerOnly {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

28:     function withdraw(address to, uint256 amount) external onlyStakingVault {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

104:     function cooldownAssets(uint256 assets) external ensureCooldownOn returns (uint256 shares) {

117:     function cooldownShares(uint256 shares) external ensureCooldownOn returns (uint256 assets) {

130:     function setCooldownDuration(uint24 duration) external onlyOwner {

153:     function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal override nonReentrant {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

39:     function addVault(ICDPVault vault) external override(IVaultRegistry) onlyRole(VAULT_MANAGER_ROLE) {

49:     function removeVault(ICDPVault vault) external override(IVaultRegistry) onlyRole(VAULT_MANAGER_ROLE) {

59:     function getVaults() external view override(IVaultRegistry) returns (ICDPVault[] memory) {

65:     function getUserTotalDebt(address user) external view override(IVaultRegistry) returns (uint256 totalNormalDebt) {

80:     function _removeVaultFromList(ICDPVault vault) private {

95:     function isVaultRegistered(address vault) external view returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

98:     function initialize(address admin, address manager) external initializer {

110:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {

114:     function update() external virtual onlyRole(KEEPER_ROLE) returns (uint256 safePrice_) {

145:     function getStatus(address /*token*/) public view virtual override returns (bool status) {

150:     function _getStatus() internal view returns (bool status) {

158:     function spot(address /*token*/) external view virtual override returns (uint256 price) {

165:     function _getTokenPrice(uint256 index) internal view returns (uint256 price) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

45:     function setOracles(address[] calldata _tokens, Oracle[] calldata _oracles) external onlyRole(DEFAULT_ADMIN_ROLE) {

58:     function initialize(address admin, address manager) external initializer {

70:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {}

79:     function getStatus(address token) public view virtual override returns (bool status) {

87:     function spot(address token) external view virtual override returns (uint256 price) {

96:     function _fetchAndValidate(address token) internal view returns (bool isValid, uint256 price) {

115:     function _getStatus(address token) private view returns (bool status) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/BaseAction.sol

20:     function _delegateCall(address to, bytes memory data) internal returns (bytes memory) {

29:     function _revertBytes(bytes memory errMsg) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/BaseAction.sol)

```solidity
File: src/proxy/ERC165Plugin.sol

18:     function getMethods() external pure returns (bytes4[] memory methods) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/ERC165Plugin.sol)

```solidity
File: src/proxy/PoolAction.sol

100:     function join(PoolActionParams memory poolActionParams) public {

112:     function _balancerJoin(PoolActionParams memory poolActionParams) internal {

195:     function exit(PoolActionParams memory poolActionParams) public returns (uint256 retAmount) {

203:     function _balancerExit(PoolActionParams memory poolActionParams) internal returns (uint256 retAmount) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction.sol

152:     function _onDeposit(address vault, address position, address src, uint256 amount) internal virtual returns (uint256);

160:     function _onWithdraw(address vault, address position, address dst, uint256 amount) internal virtual returns (uint256);

179:     function _onDecreaseLever(LeverParams memory leverParams, uint256 subCollateral) internal virtual returns (uint256);

214:     function borrow(address position, address vault, CreditParams calldata creditParams) external onlyRegisteredVault(vault) onlyDelegatecall {

533:     function _withdraw(address vault, address position, CollateralParams calldata collateralParams) internal returns (uint256) {

553:     function _borrow(address vault, address position, CreditParams calldata creditParams) internal {

569:     function _repay(address vault, address position, CreditParams calldata creditParams, PermitParams calldata permitParams) internal {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/PositionAction20.sol

39:     function _onDeposit(address vault, address position, address /*src*/, uint256 amount) internal override returns (uint256) {

50:     function _onWithdraw(address vault, address position, address /*dst*/, uint256 amount) internal override returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction20.sol)

```solidity
File: src/proxy/PositionAction4626.sol

41:     function _onDeposit(address vault, address /*position*/, address src, uint256 amount) internal override returns (uint256) {

61:     function _onWithdraw(address vault, address /*position*/, address dst, uint256 amount) internal override returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction4626.sol)

```solidity
File: src/proxy/SwapAction.sol

98:     function swap(SwapParams memory swapParams) public returns (uint256 retAmount) {

320:     function getSwapToken(SwapParams calldata swapParams) public pure returns (address token) {

335:     function _revertBytes(bytes memory errMsg) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

97:     function getRates(address[] calldata tokens) external view override returns (uint16[] memory rates) {

144:     function _vote(address user, uint96 votes, address token, bool lpSide) internal {

187:     function _unvote(address user, uint96 votes, address token, bool lpSide) internal {

219:     function setFrozenEpoch(bool status) external override configuratorOnly {

291:     function _changeQuotaTokenRateParams(address token, uint16 minRate, uint16 maxRate) internal {

305:     function _checkParams(uint16 minRate, uint16 maxRate) internal pure {

312:     function isTokenAdded(address token) public view override returns (bool) {

317:     function _poolQuotaKeeper() internal view returns (IPoolQuotaKeeperV3) {

322:     function _revertIfCallerNotVoter() internal view {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

87:     function cumulativeIndex(address token) public view override returns (uint192) {

95:     function getQuotaRate(address token) external view override returns (uint16) {

100:     function quotedTokens() external view override returns (address[] memory) {

105:     function isQuotedToken(address token) external view override returns (bool) {

135:     function poolQuotaRevenue() external view virtual override returns (uint256 quotaRevenue) {

254:     function isInitialised(TokenQuotaParams storage tokenQuotaParams) internal view returns (bool) {

278:     function _revertIfCallerNotGauge() internal view {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/quotas/QuotasLogic.sol

17:     function cumulativeIndexSince(uint192 cumulativeIndexLU, uint16 rate, uint256 lastQuotaRateUpdate)

29:     function calcAccruedQuotaInterest(uint96 quoted, uint192 cumulativeIndexNow, uint192 cumulativeIndexLU)

39:     function calcQuotaRevenueChange(uint16 rate, int256 change) internal pure returns (int256) {

44:     function calcActualQuotaChange(uint96 totalQuoted, uint96 limit, int96 requestedChange)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

264:     function poolLength() public view returns (uint256) {

272:     function setBountyManager(address _bountyManager) external onlyOwner {

281:     function setEligibilityMode(EligibilityModes _newVal) external onlyOwner {

301:     function addPool(address _token, uint256 _allocPoint) external {

318:     function batchUpdateAllocPoint(address[] calldata _tokens, uint256[] calldata _allocPoints) external onlyOwner {

342:     function setRewardsPerSecond(uint256 _rewardsPerSecond, bool _persist) external onlyOwner {

352:     function setScheduledRewardsPerSecond() internal {

375:     function _checkDuplicateSchedule(uint256 _startTimeOffset) internal view returns (bool) {

430:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

469:     function _updatePool(VaultInfo storage pool, uint256 _totalAllocPoint) internal {

493:     function pendingRewards(address _user, address[] memory _tokens) public view returns (uint256[] memory) {

518:     function claim(address _user, address[] memory _tokens) public whenNotPaused {

557:     function _vestTokens(address _user, uint256 _amount) internal {

570:     function setEligibilityExempt(address _contract, bool _value) public {

581:     function setContractAuthorization(address _address, bool _authorize) external onlyOwner {

596:     function handleActionAfter(address _user, uint256 _balance, uint256 _totalSupply) external {

660:     function handleActionBefore(address _user) external {}

667:     function beforeLockUpdate(address _user) external {}

674:     function afterLockUpdate(address _user) external {

690:     function _updateRegisteredBalance(address _user) internal {

715:     function hasEligibleDeposits(address _user) public view returns (bool hasDeposits) {

781:     function claimBounty(address _user, bool _execute) public returns (bool issueBaseBounty) {

790:     function stopEmissionsFor(address _user) internal {

813:     function manualStopEmissionsFor(address _user, address[] memory _tokens) public isWhitelisted {

844:     function manualStopAllEmissionsFor(address _user) external isWhitelisted {

853:     function _sendRadiant(address _user, uint256 _amount) internal {

872:     function endRewardTime() public returns (uint256) {

909:     function setEndingTimeUpdateCadence(uint256 _lapse) external onlyOwner {

920:     function registerRewardDeposit(uint256 _amount) external onlyOwner {

934:     function availableRewards() internal view returns (uint256 amount) {

951:     function allPendingRewards(address _user) public view returns (uint256 pending) {

1005:     function setAddressWLstatus(address user, bool status) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

118:     function setChefIncentivesController(IChefIncentivesController _chef) external onlyOwner {

127:     function setLPToken(address _lpToken) external onlyOwner {

139:     function setRequiredDepositRatio(uint256 _requiredDepositRatio) external onlyOwner {

150:     function setPriceToleranceRatio(uint256 _priceToleranceRatio) external onlyOwner {

164:     function setDqTime(address _user, uint256 _time) external {

177:     function lockedUsdValue(address user) public view returns (uint256) {

187:     function requiredUsdValue(address user) public view returns (uint256 required) {

197:     function isEligibleForRewards(address _user) public view returns (bool) {

208:     function getDqTime(address _user) public view returns (uint256) {

220:     function lastEligibleTime(address user) public view returns (uint256 lastEligibleTimestamp) {

249:     function refresh(address user) external returns (bool currentEligibility) {

274:     function _lockedUsdValue(uint256 lockedLP) internal view returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

266:     function setMinters(address[] calldata minters_) external onlyOwner {

282:     function setBountyManager(address bounty) external onlyOwner {

293:     function addRewardConverter(address rewardConverter_) external onlyOwner {

304:     function setLockTypeInfo(uint256[] calldata lockPeriod_, uint256[] calldata rewardMultipliers_) external onlyOwner {

324:     function setAddresses(IChefIncentivesController controller_, address treasury_) external onlyOwner {

336:     function setLPToken(address stakingToken_) external onlyOwner {

347:     function addReward(address _rewardToken) external {

365:     function removeReward(address _rewardToken) external {

404:     function setDefaultRelockTypeIndex(uint256 index) external {

414:     function setAutocompound(bool status, uint256 slippage) external {

426:     function setUserSlippage(uint256 slippage) external {

444:     function setRelock(bool status) external virtual {

452:     function setLookback(uint256 lookback) external onlyOwner {

484:     function stake(uint256 amount, address onBehalfOf, uint256 typeIndex) external {

496:     function vestTokens(address user, uint256 amount, bool withPenalty) external whenNotPaused {

618:     function individualEarlyExit(bool claimRewards, uint256 unlockTime) external {

689:     function zapVestingToLp(address user) external returns (uint256 zapped) {

725:     function claimFromConverter(address onBehalf) external whenNotPaused {

770:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

779:     function getLockDurations() external view returns (uint256[] memory) {

786:     function getLockMultipliers() external view returns (uint256[] memory) {

795:     function lockInfo(address user) external view returns (LockedBalance[] memory) {

803:     function totalBalance(address user) external view returns (uint256) {

813:     function getPriceProvider() external view returns (address) {

822:     function getRewardForDuration(address rewardToken) external view returns (uint256) {

830:     function getBalances(address user) external view returns (Balances memory) {

843:     function claimBounty(address user, bool execute) public whenNotPaused returns (bool issueBaseBounty) {

864:     function getReward(address[] memory rewardTokens_) public {

940:     function lockedBalance(address user) public view returns (uint256 locked) {

1024:     function lastTimeRewardApplicable(address rewardToken) public view returns (uint256) {

1035:     function rewardPerToken(address rewardToken) public view returns (uint256 rptStored) {

1049:     function claimableRewards(address account) public view returns (IFeeDistribution.RewardData[] memory rewardsData) {

1080:     function _stake(uint256 amount, address onBehalfOf, uint256 typeIndex, bool isRelock) internal whenNotPaused {

1160:     function _updateReward(address account) internal {

1187:     function _notifyReward(address rewardToken, uint256 reward) internal {

1223:     function _notifyUnseenReward(address token) internal {

1244:     function _getReward(address user, address[] memory rewardTokens_) internal whenNotPaused {

1419:     function _insertLock(address user, LockedBalance memory newLock, uint256 index, uint256 lockLength) internal {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/reward/RecoverERC20.sol

19:     function _recoverERC20(address tokenAddress, uint256 tokenAmount) internal {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/RecoverERC20.sol)

```solidity
File: src/utils/Math.sol

17: function toInt256(uint256 x) pure returns (int256) {

23: function toUint64(uint256 x) pure returns (uint64) {

37: function min(uint256 x, uint256 y) pure returns (uint256 z) {

44: function min(int256 x, int256 y) pure returns (int256 z) {

51: function max(uint256 x, uint256 y) pure returns (uint256 z) {

58: function add(uint256 x, int256 y) pure returns (uint256 z) {

66: function sub(uint256 x, int256 y) pure returns (uint256 z) {

74: function mul(uint256 x, int256 y) pure returns (int256 z) {

83: function wmul(uint256 x, uint256 y) pure returns (uint256 z) {

97: function wmul(uint256 x, int256 y) pure returns (int256 z) {

105: function wmulUp(uint256 x, uint256 y) pure returns (uint256 z) {

121: function wdiv(uint256 x, uint256 y) pure returns (uint256 z) {

137: function wdivUp(uint256 x, uint256 y) pure returns (uint256 z) {

152: function wpow(uint256 x, uint256 n, uint256 b) pure returns (uint256 z) {

208: function wpow(int256 x, int256 y) pure returns (int256) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/utils/Pause.sol

36:     function unpause() external onlyRole(PAUSER_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Pause.sol)

```solidity
File: src/utils/Permission.sol

38:     function modifyPermission(address caller, bool permitted) external {

47:     function modifyPermission(address owner, address caller, bool permitted) external {

57:     function setPermissionAgent(address agent, bool permitted) external {

66:     function hasPermission(address owner, address caller) public view returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AggregatorV3Interface.sol

8:     function decimals() external view returns (uint8);

10:     function description() external view returns (string memory);

12:     function version() external view returns (uint256);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AggregatorV3Interface.sol)

```solidity
File: src/vendor/AuraVault.sol

145:     function setParameter(bytes32 parameter, uint256 data) external onlyRole(VAULT_CONFIG_ROLE) {

175:     function totalAssets() public view virtual override(IERC4626, ERC4626) returns (uint256) {

182:     function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual override returns (uint256) {

189:     function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual override returns (uint256) {

199:     function deposit(uint256 assets, address receiver) public virtual override(IERC4626, ERC4626) returns (uint256) {

216:     function mint(uint256 shares, address receiver) public virtual override(IERC4626, ERC4626) returns (uint256) {

280:     function claim(uint256[] memory amounts, uint256 maxAmountIn) external returns (uint256 amountIn) {

315:     function previewReward() public view returns (uint256 amount) {

340:     function _previewMining(uint256 _amount) private view returns (uint256 amount) {

365:     function _chainlinkSpot() private view returns (uint256 price) {

381:     function _getAuraSpot() internal view returns (uint256 price) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IAuraPool.sol

6:     function balanceOf(address) external view returns (uint256);

7:     function deposit(uint256, address) external returns (uint256);

9:     function withdraw(uint256, address, address) external;

10:     function redeem(uint256 shares, address receiver, address owner) external returns (uint256);

12:     function extraRewardsLength() external view returns (uint256);

13:     function rewardToken() external view returns (address);

14:     function earned(address account) external view returns (uint256);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IAuraPool.sol)

```solidity
File: src/vendor/ICurvePool.sol

6:     function get_virtual_price() external view returns (uint256);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/ICurvePool.sol)

```solidity
File: src/vendor/IPriceOracle.sol

57:     function getLatest(Variable variable) external view returns (uint256);

79:     function getLargestSafeQueryWindow() external view returns (uint256);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IPriceOracle.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

24: function toAddress(bytes memory _bytes, uint256 _start) pure returns (address) {

39: function decodeLastToken(bytes memory path) pure returns (address token) {

50:     function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

55:     function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

```solidity
File: src/vendor/IWeightedPool.sol

5:     function getNormalizedWeights() external view returns (uint256[] memory);

7:     function totalSupply() external view returns (uint256);

9:     function getPoolId() external view returns (bytes32);

11:     function getInvariant() external view returns (uint256);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IWeightedPool.sol)

### <a name="NC-17"></a>[NC-17] Change int to int256

Throughout the code base, some variables are declared as `int`. To favor explicitness, consider changing all instances of `int` to `int256`

*Instances (9)*:

```solidity
File: src/reward/ChefIncentivesController.sol

40:     struct EmissionPoint {

305:         totalAllocPoint = totalAllocPoint + _allocPoint;

308:         pool.allocPoint = _allocPoint;

321:         uint256 _totalAllocPoint = totalAllocPoint;

326:             _totalAllocPoint = _totalAllocPoint - pool.allocPoint + _allocPoints[i];

327:             pool.allocPoint = _allocPoints[i];

332:         totalAllocPoint = _totalAllocPoint;

530:         uint256 _totalAllocPoint = totalAllocPoint;

885:                     ((pool.lastRewardTime - lastAllPoolUpdate) * pool.allocPoint * rewardsPerSecond) /

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

### <a name="NC-18"></a>[NC-18] Change uint to uint256

Throughout the code base, some variables are declared as `uint`. To favor explicitness, consider changing all instances of `uint` to `uint256`

*Instances (1)*:

```solidity
File: src/proxy/PositionAction.sol

364:         uint loanAmount = leverParams.primarySwap.amount;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

### <a name="NC-19"></a>[NC-19] Interfaces should be defined in separate files from their usage

The interfaces below should be defined in separate files, so that it's easier for future projects to import them, and to avoid duplication later on if they need to be used elsewhere in the project

*Instances (3)*:

```solidity
File: src/CDPVault.sol

22: interface IPoolV3Loop is IPoolV3 {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/vendor/IAuraPool.sol

4: interface IPool {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IAuraPool.sol)

```solidity
File: src/vendor/IBalancerVault.sol

111: interface IVault {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IBalancerVault.sol)

### <a name="NC-20"></a>[NC-20] Lack of checks in setters

Be it sanity checks (like checks against `0`-values) or initial setting checks: it's best for Setter functions to have them

*Instances (16)*:

```solidity
File: src/PoolV3.sol

691:     function updateQuotaRevenue(
             int256 quotaRevenueDelta
         )
             external
             override
             nonReentrant // U:[LP-2B]
             //poolQuotaKeeperOnly // U:[LP-2C]
             creditManagerOnly
         {
             _setQuotaRevenue(uint256(quotaRevenue().toInt256() + quotaRevenueDelta)); // U:[LP-19]

705:     function setQuotaRevenue(
             uint256 newQuotaRevenue
         )
             external
             override
             nonReentrant // U:[LP-2B]
             poolQuotaKeeperOnly // U:[LP-2C]
         {
             _setQuotaRevenue(newQuotaRevenue); // U:[LP-20]

746:     function setInterestRateModel(
             address newInterestRateModel
         )
             external
             override
             configuratorOnly // U:[LP-2C]
             nonZeroAddress(newInterestRateModel) // U:[LP-22A]
         {
             interestRateModel = newInterestRateModel; // U:[LP-22B]
             _updateBaseInterest(0, 0, false); // U:[LP-22B]
             emit SetInterestRateModel(newInterestRateModel); // U:[LP-22B]

783:     function setTotalDebtLimit(
             uint256 newLimit
         )
             external
             override
             controllerOnly // U:[LP-2C]
         {
             _setTotalDebtLimit(newLimit); // U:[LP-24]

838:     function setAllowed(address account, bool status) external controllerOnly {
             _allowed[account] = status;

844:     function setLock(bool status) external controllerOnly {
             locked = status;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

45:     function setOracles(address[] calldata _tokens, Oracle[] calldata _oracles) external onlyRole(DEFAULT_ADMIN_ROLE) {
            for (uint256 i = 0; i < _tokens.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/quotas/GaugeV3.sol

73:     function updateEpoch() external override {
            _checkAndUpdateEpoch(); // U:[GA-14]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

183:     function updateRates()
             external
             override
             gaugeOnly // U:[PQK-3]
         {
             address[] memory tokens = quotaTokensSet.values();
             uint16[] memory rates = IGaugeV3(gauge).getRates(tokens); // U:[PQK-7]
     
             uint256 quotaRevenue; // U:[PQK-7]
             uint256 timestampLU = lastQuotaRateUpdate;
             uint256 len = tokens.length;
     
             for (uint256 i; i < len; ) {
                 address token = tokens[i];
                 uint16 rate = rates[i];
     
                 TokenQuotaParams storage tokenQuotaParams = totalQuotaParams[token]; // U:[PQK-7]
                 (uint16 prevRate, uint192 tqCumulativeIndexLU, ) = _getTokenQuotaParamsOrRevert(tokenQuotaParams);
     
                 tokenQuotaParams.cumulativeIndexLU = QuotasLogic.cumulativeIndexSince(
                     tqCumulativeIndexLU,
                     prevRate,
                     timestampLU
                 ); // U:[PQK-7]
     
                 tokenQuotaParams.rate = rate; // U:[PQK-7]
     
                 quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR; // U:[PQK-7]
     
                 emit UpdateTokenQuotaRate(token, rate); // U:[PQK-7]
     
                 unchecked {
                     ++i;
                 }
             }
     
             IPoolV3(pool).setQuotaRevenue(quotaRevenue); // U:[PQK-7]
             lastQuotaRateUpdate = uint40(block.timestamp); // U:[PQK-7]

238:     function setCreditManager(
             address token,
             address vault
         )
             external
             override
             configuratorOnly // U:[PQK-2]
         {
             creditManagers[token] = vault;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

272:     function setBountyManager(address _bountyManager) external onlyOwner {
             bountyManager = _bountyManager;
             emit BountyManagerUpdated(_bountyManager);

281:     function setEligibilityMode(EligibilityModes _newVal) external onlyOwner {
             eligibilityMode = _newVal;
             emit EligibilityModeUpdated(_newVal);

342:     function setRewardsPerSecond(uint256 _rewardsPerSecond, bool _persist) external onlyOwner {
             _massUpdatePools();
             rewardsPerSecond = _rewardsPerSecond;
             persistRewardsPerSecond = _persist;
             emit RewardsPerSecondUpdated(_rewardsPerSecond, _persist);

1005:     function setAddressWLstatus(address user, bool status) external onlyOwner {
              whitelist[user] = status;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

264:     function updatePrice() public {
             priceProvider.update();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/utils/Permission.sol

57:     function setPermissionAgent(address agent, bool permitted) external {
            _permittedAgents[msg.sender][agent] = permitted;
            emit SetPermittedAgent(msg.sender, agent, permitted);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

### <a name="NC-21"></a>[NC-21] Lines are too long

Usually lines in source code are limited to [80](https://softwareengineering.stackexchange.com/questions/148677/why-is-80-characters-the-standard-limit-for-code-width) characters. Today's screens are much larger so it's reasonable to stretch this in some cases. Since the files will most likely reside in GitHub, and GitHub starts using a scroll bar in all cases when the length is over [164](https://github.com/aizatto/character-length) characters, the lines below should be split when they reach that length

*Instances (1)*:

```solidity
File: src/quotas/GaugeV3.sol

17: import {CallerNotVoterException, IncorrectParameterException, TokenNotAllowedException, InsufficientVotesException} from "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

### <a name="NC-22"></a>[NC-22] Missing Event for critical parameters change

Events help non-contract tools to track changes, and events prevent users from being surprised by changes.

*Instances (18)*:

```solidity
File: src/PoolV3.sol

691:     function updateQuotaRevenue(
             int256 quotaRevenueDelta
         )
             external
             override
             nonReentrant // U:[LP-2B]
             //poolQuotaKeeperOnly // U:[LP-2C]
             creditManagerOnly
         {
             _setQuotaRevenue(uint256(quotaRevenue().toInt256() + quotaRevenueDelta)); // U:[LP-19]

705:     function setQuotaRevenue(
             uint256 newQuotaRevenue
         )
             external
             override
             nonReentrant // U:[LP-2B]
             poolQuotaKeeperOnly // U:[LP-2C]
         {
             _setQuotaRevenue(newQuotaRevenue); // U:[LP-20]

783:     function setTotalDebtLimit(
             uint256 newLimit
         )
             external
             override
             controllerOnly // U:[LP-2C]
         {
             _setTotalDebtLimit(newLimit); // U:[LP-24]

838:     function setAllowed(address account, bool status) external controllerOnly {
             _allowed[account] = status;

844:     function setLock(bool status) external controllerOnly {
             locked = status;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

104:     function cooldownAssets(uint256 assets) external ensureCooldownOn returns (uint256 shares) {
             if (assets > maxWithdraw(msg.sender)) revert ExcessiveWithdrawAmount();
     
             shares = previewWithdraw(assets);
     
             cooldowns[msg.sender].cooldownEnd = uint104(block.timestamp) + cooldownDuration;
             cooldowns[msg.sender].underlyingAmount += uint152(assets);
     
             _withdraw(msg.sender, address(silo), msg.sender, assets, shares);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

45:     function setOracles(address[] calldata _tokens, Oracle[] calldata _oracles) external onlyRole(DEFAULT_ADMIN_ROLE) {
            for (uint256 i = 0; i < _tokens.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/quotas/GaugeV3.sol

73:     function updateEpoch() external override {
            _checkAndUpdateEpoch(); // U:[GA-14]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

238:     function setCreditManager(
             address token,
             address vault
         )
             external
             override
             configuratorOnly // U:[PQK-2]
         {
             creditManagers[token] = vault;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

570:     function setEligibilityExempt(address _contract, bool _value) public {
             // skip this if not processing eligibilty all the time
             if (eligibilityMode != EligibilityModes.FULL) return;
             if (msg.sender != owner() && !authorizedContracts[msg.sender]) revert InsufficientPermission();
             eligibilityExempt[_contract] = _value;

1005:     function setAddressWLstatus(address user, bool status) external onlyOwner {
              whitelist[user] = status;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

264:     function updatePrice() public {
             priceProvider.update();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

266:     function setMinters(address[] calldata minters_) external onlyOwner {
             uint256 length = minters_.length;
             for (uint256 i; i < length; ) {
                 if (minters_[i] == address(0)) revert AddressZero();
                 minters[minters_[i]] = true;
                 unchecked {
                     i++;
                 }
             }
             mintersAreSet = true;

404:     function setDefaultRelockTypeIndex(uint256 index) external {
             if (index >= _lockPeriod.length) revert InvalidType();
             defaultLockIndex[msg.sender] = index;

414:     function setAutocompound(bool status, uint256 slippage) external {
             autocompoundEnabled[msg.sender] = status;
             if (slippage < MAX_SLIPPAGE || slippage >= PERCENT_DIVISOR) {
                 revert InvalidAmount();
             }
             userSlippage[msg.sender] = slippage;

426:     function setUserSlippage(uint256 slippage) external {
             if (slippage < MAX_SLIPPAGE || slippage >= PERCENT_DIVISOR) {
                 revert InvalidAmount();
             }
             userSlippage[msg.sender] = slippage;

452:     function setLookback(uint256 lookback) external onlyOwner {
             if (lookback == uint256(0)) revert AmountZero();
             if (lookback > rewardsDuration) revert InvalidLookback();
     
             rewardsLookback = lookback;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

152:     function setVaultConfig(
             uint32 _claimerIncentive,
             uint32 _lockerIncentive,
             address _lockerRewards
         ) public onlyRole(VAULT_ADMIN_ROLE) returns (bool) {
             if (_claimerIncentive > maxClaimerIncentive) revert AuraVault__setVaultConfig_invalidClaimerIncentive();
             if (_lockerIncentive > maxLockerIncentive) revert AuraVault__setVaultConfig_invalidLockerIncentive();
             if (_lockerRewards == address(0x0)) revert AuraVault__setVaultConfig_invalidLockerRewards();
     
             vaultConfig = VaultConfig({
                 claimerIncentive: _claimerIncentive,
                 lockerIncentive: _lockerIncentive,
                 lockerRewards: _lockerRewards
             });
     
             return true;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-23"></a>[NC-23] NatSpec is completely non-existent on functions that should have them

Public and external functions that aren't view or pure should have NatSpec comments

*Instances (10)*:

```solidity
File: src/CDPVault.sol

23:     function mintProfit(uint256 profit) external;

25:     function enter(address user, uint256 amount) external;

27:     function exit(address user, uint256 amount) external;

29:     function addAvailable(address user, int256 amount) external;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

899:     function mintProfit(uint256 amount) external creditManagerOnly {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

28:     function withdraw(address to, uint256 amount) external onlyStakingVault {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

45:     function setOracles(address[] calldata _tokens, Oracle[] calldata _oracles) external onlyRole(DEFAULT_ADMIN_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

238:     function setCreditManager(

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

844:     function manualStopAllEmissionsFor(address _user) external isWhitelisted {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/vendor/AuraVault.sol

152:     function setVaultConfig(

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-24"></a>[NC-24] Incomplete NatSpec: `@param` is missing on actually documented functions

The following functions are missing `@param` NatSpec comments.

*Instances (12)*:

```solidity
File: src/PoolV3.sol

247:     /// @dev Same as `deposit`, but allows to specify the referral code
         function depositWithReferral(
             uint256 assets,
             address receiver,
             uint256 referralCode

277:     /// @dev Same as `mint`, but allows to specify the referral code
         function mintWithReferral(
             uint256 shares,
             address receiver,
             uint256 referralCode

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/proxy/PositionAction.sol

185:     /// @notice Adds collateral to a CDP Vault
         /// @param position The CDP Vault position
         /// @param vault The CDP Vault
         /// @param collateralParams The collateral parameters
         function deposit(
             address position,
             address vault,
             CollateralParams calldata collateralParams,
             PermitParams calldata permitParams

232:     /// @notice Adds collateral and debt to a CDP Vault
         /// @param position The CDP Vault position
         /// @param vault The CDP Vault
         /// @param collateralParams The collateral parameters
         /// @param creditParams The credit parameters
         function depositAndBorrow(
             address position,
             address vault,
             CollateralParams calldata collateralParams,
             CreditParams calldata creditParams,
             PermitParams calldata permitParams

377:     /// @notice Callback function for the flash loan taken out in increaseLever
         /// @param data The encoded bytes that were passed into the flash loan
         function onFlashLoan(
             address /*initiator*/,
             address /*token*/,
             uint256 amount,
             uint256 fee,
             bytes calldata data

429:     /// @notice Callback function for the credit flash loan taken out in decreaseLever
         /// @param data The encoded bytes that were passed into the credit flash loan
         function onCreditFlashLoan(
             address /*initiator*/,
             uint256 /*amount*/,
             uint256 /*fee*/,
             bytes calldata data

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

262:     /// @dev Changes the min rate for a quoted token
         /// @param minRate The minimal interest rate paid on token's quotas
         function changeQuotaMinRate(
             address token,
             uint16 minRate

276:     /// @dev Changes the max rate for a quoted token
         /// @param maxRate The maximal interest rate paid on token's quotas
         function changeQuotaMaxRate(
             address token,
             uint16 maxRate

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

227:     /**
          * @notice Initializer
          * @param _poolConfigurator Pool configurator address
          * @param _eligibleDataProvider Eligibility Data provider address
          * @param _mfd MultiFeeDistribution contract
          * @param _rewardsPerSecond RPS
          */
         function initialize(
             address _poolConfigurator,
             IEligibilityDataProvider _eligibleDataProvider,
             IMultiFeeDistribution _mfd,
             uint256 _rewardsPerSecond,
             address _rdntToken,
             uint256 _endingTimeCadence

577:     /**
          * @notice Updates whether the provided address is authorized to call setEligibilityExempt(), only callable by owner.
          * @param _address address of the user or contract whose authorization level is being changed
          */
         function setContractAuthorization(address _address, bool _authorize) external onlyOwner {

809:     /**
          * @notice function to stop user emissions
          * @param _user address of user to stop emissions for
          */
         function manualStopEmissionsFor(address _user, address[] memory _tokens) public isWhitelisted {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

124:     /**
          * @notice Set LP token
          */
         function setLPToken(address _lpToken) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

### <a name="NC-25"></a>[NC-25] Incomplete NatSpec: `@return` is missing on actually documented functions

The following functions are missing `@return` NatSpec comments.

*Instances (9)*:

```solidity
File: src/PoolV3.sol

247:     /// @dev Same as `deposit`, but allows to specify the referral code
         function depositWithReferral(
             uint256 assets,
             address receiver,
             uint256 referralCode
         ) external override returns (uint256 shares) {

277:     /// @dev Same as `mint`, but allows to specify the referral code
         function mintWithReferral(
             uint256 shares,
             address receiver,
             uint256 referralCode
         ) external override returns (uint256 assets) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

102:     /// @notice redeem assets and starts a cooldown to claim the converted underlying asset
         /// @param assets assets to redeem
         function cooldownAssets(uint256 assets) external ensureCooldownOn returns (uint256 shares) {

115:     /// @notice redeem shares into assets and starts a cooldown to claim the converted underlying asset
         /// @param shares shares to redeem
         function cooldownShares(uint256 shares) external ensureCooldownOn returns (uint256 assets) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/proxy/PoolAction.sol

193:     /// @notice Exit a protocol specific pool
         /// @param poolActionParams The parameters for the exit
         function exit(PoolActionParams memory poolActionParams) public returns (uint256 retAmount) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction.sol

377:     /// @notice Callback function for the flash loan taken out in increaseLever
         /// @param data The encoded bytes that were passed into the flash loan
         function onFlashLoan(
             address /*initiator*/,
             address /*token*/,
             uint256 amount,
             uint256 fee,
             bytes calldata data
         ) external returns (bytes32) {

429:     /// @notice Callback function for the credit flash loan taken out in decreaseLever
         /// @param data The encoded bytes that were passed into the credit flash loan
         function onCreditFlashLoan(
             address /*initiator*/,
             uint256 /*amount*/,
             uint256 /*fee*/,
             bytes calldata data
         ) external returns (bytes32) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

869:     /**
          * @notice Ending reward distribution time.
          */
         function endRewardTime() public returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/vendor/AuraVault.sol

275:     /**
          * @notice Allows anyone to claim accumulated rewards by depositing WETH instead
          * @param amounts An array of reward amounts to be claimed ordered as [rewardToken, secondaryRewardToken]
          * @param maxAmountIn The max amount of WETH to be sent to the Vault
          */
         function claim(uint256[] memory amounts, uint256 maxAmountIn) external returns (uint256 amountIn) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-26"></a>[NC-26] File's first line is not an SPDX Identifier

*Instances (1)*:

```solidity
File: src/StakingLPEth.sol

1: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

### <a name="NC-27"></a>[NC-27] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor

If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (34)*:

```solidity
File: src/Flashlender.sol

101:         if (receiver.onFlashLoan(msg.sender, token, amount, fee, data) != CALLBACK_SUCCESS)

129:         if (receiver.onCreditFlashLoan(msg.sender, amount, fee, data) != CALLBACK_SUCCESS_CREDIT)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

122:         if (_allowed[msg.sender]) {

131:         if (msg.sender != poolQuotaKeeper) revert CallerNotPoolQuotaKeeperException(); // U:[LP-2C]

136:         if (!_creditManagerSet.contains(msg.sender)) {

409:         if (msg.sender != owner) _spendAllowance({owner: owner, spender: msg.sender, amount: shares}); // U:[LP-8,9]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

24:         if (msg.sender != STAKING_VAULT) revert OnlyStakingVault();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

105:         if (assets > maxWithdraw(msg.sender)) revert ExcessiveWithdrawAmount();

118:         if (shares > maxRedeem(msg.sender)) revert ExcessiveRedeemAmount();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/proxy/PositionAction.sol

386:         if (msg.sender != address(flashlender)) revert PositionAction__onFlashLoan__invalidSender();

437:         if (msg.sender != address(flashlender)) revert PositionAction__onCreditFlashLoan__invalidSender();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

323:         if (msg.sender != voter) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

279:         if (msg.sender != gauge) revert CallerNotGaugeException(); // U:[PQK-3]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

218:             if (!whitelist[msg.sender] && msg.sender != address(this)) revert NotWhitelisted();

302:         if (msg.sender != poolConfigurator) revert NotAllowed();

573:         if (msg.sender != owner() && !authorizedContracts[msg.sender]) revert InsufficientPermission();

597:         if (!validRTokens[msg.sender] && msg.sender != address(mfd)) revert NotRTokenOrMfd();

676:             if (msg.sender != address(mfd)) revert NotMFD();

782:         if (msg.sender != address(bountyManager)) revert BountyOnly();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

165:         if (msg.sender != address(chef)) revert OnlyCIC();

250:         if (msg.sender != address(chef)) revert OnlyCIC();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

349:         if (!minters[msg.sender]) revert InsufficientPermission();

366:         if (!minters[msg.sender]) revert InsufficientPermission();

497:         if (!minters[msg.sender]) revert InsufficientPermission();

690:         if (msg.sender != _lockZap) revert InsufficientPermission();

726:         if (msg.sender != rewardConverter) revert InsufficientPermission();

762:         requalifyFor(msg.sender);

844:         if (msg.sender != address(bountyManager)) revert InsufficientPermission();

1282:         if (onBehalfOf != msg.sender) revert InsufficientPermission();

1357:         if (isRelockAction && address_ != msg.sender && _lockZap != msg.sender) revert InsufficientPermission();

1369:         if (isRelockAction || (address_ != msg.sender && !autoRelockDisabled[address_])) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Permission.sol

40:         emit ModifyPermission(msg.sender, msg.sender, caller, permitted);

48:         if (owner != msg.sender && !_permittedAgents[owner][msg.sender])

51:         emit ModifyPermission(msg.sender, owner, caller, permitted);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

### <a name="NC-28"></a>[NC-28] Constant state variables defined more than once

Rather than redefining state variable constant, consider using a library to store all constants as this will prevent data redundancy

*Instances (11)*:

```solidity
File: src/CDPVault.sol

33: bytes32 constant VAULT_CONFIG_ROLE = keccak256("VAULT_CONFIG_ROLE");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

19:     bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

20:     bytes32 public constant CALLBACK_SUCCESS_CREDIT = keccak256("CreditFlashBorrower.onCreditFlashLoan");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

62:     uint256 public constant override version = 3_00;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/proxy/PositionAction.sol

72:     bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

73:     bytes32 public constant CALLBACK_SUCCESS_CREDIT = keccak256("CreditFlashBorrower.onCreditFlashLoan");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

29:     uint256 public constant override version = 3_00;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

37:     uint256 public constant override version = 3_00;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

20:     uint256 public constant RATIO_DIVISOR = 10000;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

47:     uint256 public constant RATIO_DIVISOR = 10000;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

22: bytes32 constant VAULT_CONFIG_ROLE = keccak256("VAULT_CONFIG_ROLE");

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-29"></a>[NC-29] Consider using named mappings

Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (33)*:

```solidity
File: src/CDPVault.sol

106:     mapping(address => Position) public positions;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

101:     mapping(address => DebtParams) internal _creditManagerDebt;

107:     mapping(address => bool) internal _allowed;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

32:     mapping(address => UserCooldown) public cooldowns;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

17:     mapping(ICDPVault => bool) private registeredVaults;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

27:     mapping(address => Oracle) public oracles;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/quotas/GaugeV3.sol

35:     mapping(address => QuotaRateParams) public override quotaRateParams;

38:     mapping(address => mapping(address => UserVotes)) public override userTokenVotes;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

52:     mapping(address => TokenQuotaParams) internal totalQuotaParams;

63:     mapping(address => address) public creditManagers;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

160:     mapping(address => VaultInfo) public vaultInfo;

161:     mapping(address => bool) private validRTokens;

167:     mapping(address => mapping(address => UserInfo)) public userInfo;

170:     mapping(address => uint256) public userBaseClaimable;

173:     mapping(address => bool) public eligibilityExempt;

206:     mapping(address => bool) public authorizedContracts;

209:     mapping(address => bool) public whitelist;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

54:     mapping(address => bool) public lastEligibleStatus;

57:     mapping(address => uint256) public disqualifiedTime;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

87:     mapping(address => Balances) private _balances;

88:     mapping(address => LockedBalance[]) internal _userLocks;

89:     mapping(address => LockedBalance[]) private _userEarnings;

90:     mapping(address => bool) public autocompoundEnabled;

91:     mapping(address => uint256) public lastAutocompound;

111:     mapping(address => Reward) public rewardData;

114:     mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;

117:     mapping(address => mapping(address => uint256)) public rewards;

128:     mapping(address => bool) public minters;

131:     mapping(address => bool) public autoRelockDisabled;

134:     mapping(address => uint256) public defaultLockIndex;

140:     mapping(address => uint256) public lastClaimTime;

146:     mapping(address => uint256) public userSlippage;

155:     mapping(address => bool) public isRewardToken;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="NC-30"></a>[NC-30] `address`s shouldn't be hard-coded

It is often better to declare `address`es as `immutable`, and assign them via constructor arguments. This allows the code to remain the same across deployments on different networks, and avoids recompilation when addresses need to change.

*Instances (5)*:

```solidity
File: src/proxy/TransferAction.sol

39:     address public constant permit2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/TransferAction.sol)

```solidity
File: src/vendor/AuraVault.sol

50:     address private constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;

52:     address private constant BAL_CHAINLINK_FEED = 0xdF2917806E30300537aEB49A7663062F4d1F2b5F;

55:     address private constant ETH_CHAINLINK_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

59:     address private constant AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-31"></a>[NC-31] Variable names that consist of all capital letters should be reserved for `constant`/`immutable` variables

If the variable needs to be different based on which class it comes from, a `view`/`pure` *function* should be used instead (e.g. like [this](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/76eee35971c2541585e05cbf258510dda7b2fbc6/contracts/token/ERC20/extensions/draft-IERC20Permit.sol#L59)).

*Instances (1)*:

```solidity
File: src/StakingLPEth.sol

1: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

### <a name="NC-32"></a>[NC-32] Owner can renounce while system is paused

The contract owner or single user with a role is not prevented from renouncing the role/ownership while the contract is paused, which would cause any user assets stored in the protocol, to be locked indefinitely.

*Instances (4)*:

```solidity
File: src/reward/ChefIncentivesController.sol

966:     function pause() external onlyOwner {

973:     function unpause() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

873:     function pause() public onlyOwner {

880:     function unpause() public onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="NC-33"></a>[NC-33] Adding a `return` statement when the function defines a named return variable, is redundant

*Instances (28)*:

```solidity
File: src/CDPVault.sol

462:     function _calcQuotaRevenueChange(int256 deltaDebt) internal view returns (int256 quotaRevenueChange) {
             uint16 rate = IPoolQuotaKeeperV3(poolQuotaKeeper()).getQuotaRate(address(token));
             return QuotasLogic.calcQuotaRevenueChange(rate, deltaDebt);

755:     /// @notice Returns debt data for a position
         function getDebtInfo(
             address position
         ) external view returns (uint256 debt, uint256 accruedInterest, uint256 cumulativeQuotaInterest) {
             DebtData memory debtData = _calcDebt(positions[position]);
             return (debtData.debt, debtData.accruedInterest, debtData.cumulativeQuotaInterest);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

221:     /// @notice Total amount of underlying tokens managed by the pool, same as `expectedLiquidity`
         /// @dev Since `totalAssets` doesn't depend on underlying balance, pool is not vulnerable to the inflation attack
         function totalAssets() public view override(ERC4626, IERC4626) returns (uint256 assets) {
             return expectedLiquidity();

427:     /// @dev Internal conversion function (from assets to shares) with support for rounding direction
         /// @dev Pool is not vulnerable to the inflation attack, so the simplified implementation w/o virtual shares is used
         function _convertToShares(uint256 assets) internal pure returns (uint256 shares) {
             // uint256 supply = totalSupply();
             return assets; //(assets == 0 || supply == 0) ? assets : assets.mulDiv(supply, totalAssets(), rounding);

434:     /// @dev Internal conversion function (from shares to assets) with support for rounding direction
         /// @dev Pool is not vulnerable to the inflation attack, so the simplified implementation w/o virtual shares is used
         function _convertToAssets(uint256 shares) internal pure returns (uint256 assets) {
             //uint256 supply = totalSupply();
             return shares; //(supply == 0) ? shares : shares.mulDiv(totalAssets(), supply, rounding);

465:     /// @notice Amount available to borrow for a given credit manager
         function creditManagerBorrowable(address creditManager) external view override returns (uint256 borrowable) {
             borrowable = _borrowable(_totalDebt); // U:[LP-12]
             if (borrowable == 0) return 0; // U:[LP-12]

465:     /// @notice Amount available to borrow for a given credit manager
         function creditManagerBorrowable(address creditManager) external view override returns (uint256 borrowable) {
             borrowable = _borrowable(_totalDebt); // U:[LP-12]
             if (borrowable == 0) return 0; // U:[LP-12]
     
             borrowable = Math.min(borrowable, _borrowable(_creditManagerDebt[creditManager])); // U:[LP-12]
             if (borrowable == 0) return 0; // U:[LP-12]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/oracle/BalancerOracle.sol

142:     /// @notice Returns the status of the oracle
         /// @param /*token*/ Token address, ignored for this oracle
         /// @dev The status is valid if the price is validated and not stale
         function getStatus(address /*token*/) public view virtual override returns (bool status) {
             // add stale check?
             return _getStatus();

154:     /// @notice Returns the latest price for the asset
         /// @param /*token*/ Token address
         /// @return price Asset price [WAD]
         /// @dev reverts if the price is invalid
         function spot(address /*token*/) external view virtual override returns (uint256 price) {
             if (!_getStatus()) {
                 revert BalancerOracle__spot_invalidPrice();
             }
             return safePrice;

165:     function _getTokenPrice(uint256 index) internal view returns (uint256 price) {
             address token;
             if (index == 0) token = token0;
             else if (index == 1) token = token1;
             else if (index == 2) token = token2;
             else revert BalancerOracle__getTokenPrice_invalidIndex();
     
             return chainlinkOracle.spot(token);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

76:     /// @notice Returns the status of the oracle
        /// @param token Token address
        /// @dev The status is valid if the price is validated and not stale
        function getStatus(address token) public view virtual override returns (bool status) {
            return _getStatus(token);

93:     /// @notice Fetches and validates the latest price from Chainlink
        /// @return isValid Whether the price is valid based on the value range and staleness
        /// @return price Asset price [WAD]
        function _fetchAndValidate(address token) internal view returns (bool isValid, uint256 price) {
            Oracle memory oracle = oracles[token];
            try AggregatorV3Interface(oracle.aggregator).latestRoundData() returns (
                uint80 /*roundId*/,
                int256 answer,
                uint256 /*startedAt*/,
                uint256 updatedAt,
                uint80 /*answeredInRound*/
            ) {
                isValid = (answer > 0 && block.timestamp - updatedAt <= oracle.stalePeriod);
                return (isValid, wdiv(uint256(answer), oracle.aggregatorScale));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PoolAction.sol

203:     function _balancerExit(PoolActionParams memory poolActionParams) internal returns (uint256 retAmount) {
             (
                 bytes32 poolId,
                 address bpt,
                 uint256 bptAmount,
                 uint256 outIndex,
                 address[] memory assets,
                 uint256[] memory minAmountsOut
             ) = abi.decode(poolActionParams.args, (bytes32, address, uint256, uint256, address[], uint256[]));
     
             if (bptAmount != 0) IERC20(bpt).forceApprove(address(balancerVault), bptAmount);
     
             balancerVault.exitPool(
                 poolId,
                 address(this),
                 payable(poolActionParams.recipient),
                 ExitPoolRequest({
                     assets: assets,
                     minAmountsOut: minAmountsOut,
                     userData: abi.encode(ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, bptAmount, outIndex),
                     toInternalBalance: false
                 })
             );
     
             for (uint256 i = 0; i <= outIndex; ) {
                 if (assets[i] == bpt) {
                     outIndex++;
                 }
     
                 unchecked {
                     ++i;
                 }
             }
     
             return IERC20(assets[outIndex]).balanceOf(address(poolActionParams.recipient));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/quotas/QuotasLogic.sol

43:     /// @dev Upper-bounds requested quota increase such that the resulting total quota doesn't exceed the limit
        function calcActualQuotaChange(uint96 totalQuoted, uint96 limit, int96 requestedChange)
            internal
            pure
            returns (int96 quotaChange)
        {
            if (totalQuoted >= limit) {
                return 0;
            }
    
            unchecked {
                uint96 maxQuotaCapacity = limit - totalQuoted;
                // The function is never called with `requestedChange < 0`, so casting it to `uint96` is safe
                // With correct configuration, `limit < type(int96).max`, so casting `maxQuotaCapacity` to `int96` is safe
                return uint96(requestedChange) > maxQuotaCapacity ? int96(maxQuotaCapacity) : requestedChange;

43:     /// @dev Upper-bounds requested quota increase such that the resulting total quota doesn't exceed the limit
        function calcActualQuotaChange(uint96 totalQuoted, uint96 limit, int96 requestedChange)
            internal
            pure
            returns (int96 quotaChange)
        {
            if (totalQuoted >= limit) {
                return 0;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

929:     /**
          * @notice Available reward amount for future distribution.
          * @dev This value is equal to `depositedRewards` - `accountedRewards`.
          * @return amount available
          */
         function availableRewards() internal view returns (uint256 amount) {
             return depositedRewards - accountedRewards;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

182:     /**
          * @notice Returns USD value required to be locked
          * @param user's address
          * @return required USD value.
          */
         function requiredUsdValue(address user) public view returns (uint256 required) {
             uint256 totalNormalDebt = vaultRegistry.getUserTotalDebt(user);
             required = (totalNormalDebt * requiredDepositRatio) / RATIO_DIVISOR;
             return _lockedUsdValue(required);

212:     /**
          * @notice Returns last eligible time of the user
          * @dev If user is still eligible, it will return future time
          *  CAUTION: this function only works perfect when the array
          *  is ordered by lock time. This is assured when _stake happens.
          * @param user's address
          * @return lastEligibleTimestamp of the user. Returns 0 if user is not eligible.
          */
         function lastEligibleTime(address user) public view returns (uint256 lastEligibleTimestamp) {
             if (!isEligibleForRewards(user)) {
                 return 0;

212:     /**
          * @notice Returns last eligible time of the user
          * @dev If user is still eligible, it will return future time
          *  CAUTION: this function only works perfect when the array
          *  is ordered by lock time. This is assured when _stake happens.
          * @param user's address
          * @return lastEligibleTimestamp of the user. Returns 0 if user is not eligible.
          */
         function lastEligibleTime(address user) public view returns (uint256 lastEligibleTimestamp) {
             if (!isEligibleForRewards(user)) {
                 return 0;
             }
     
             uint256 requiredValue = requiredUsdValue(user);
     
             LockedBalance[] memory lpLockData = IMultiFeeDistribution(multiFeeDistribution).lockInfo(user);
     
             uint256 lockedLP;
             for (uint256 i = lpLockData.length; i > 0; ) {
                 LockedBalance memory currentLockData = lpLockData[i - 1];
                 lockedLP += currentLockData.amount;
     
                 if (_lockedUsdValue(lockedLP) >= requiredValue) {
                     return currentLockData.unlockTime;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

684:     /**
          * @notice Zap vesting RDNT tokens to LP
          * @param user address
          * @return zapped amount
          */
         function zapVestingToLp(address user) external returns (uint256 zapped) {
             if (msg.sender != _lockZap) revert InsufficientPermission();
     
             _updateReward(user);
     
             uint256 currentTimestamp = block.timestamp;
             LockedBalance[] storage earnings = _userEarnings[user];
             for (uint256 i = earnings.length; i > 0; ) {
                 if (earnings[i - 1].unlockTime > currentTimestamp) {
                     zapped = zapped + earnings[i - 1].amount;
                     earnings.pop();
                 } else {
                     break;
                 }
                 unchecked {
                     i--;
                 }
             }
     
             rdntToken.safeTransfer(_lockZap, zapped);
     
             Balances storage bal = _balances[user];
             bal.earned = bal.earned - zapped;
             bal.total = bal.total - zapped;
     
             IPriceProvider(_priceProvider).update();
     
             return zapped;

836:     /**
          * @notice Claims bounty.
          * @dev Remove expired locks
          * @param user address
          * @param execute true if this is actual execution
          * @return issueBaseBounty true if needs to issue base bounty
          */
         function claimBounty(address user, bool execute) public whenNotPaused returns (bool issueBaseBounty) {
             if (msg.sender != address(bountyManager)) revert InsufficientPermission();
     
             (, uint256 unlockable, , , ) = lockedBalances(user);
             if (unlockable == 0) {
                 return (false);

836:     /**
          * @notice Claims bounty.
          * @dev Remove expired locks
          * @param user address
          * @param execute true if this is actual execution
          * @return issueBaseBounty true if needs to issue base bounty
          */
         function claimBounty(address user, bool execute) public whenNotPaused returns (bool issueBaseBounty) {
             if (msg.sender != address(bountyManager)) revert InsufficientPermission();
     
             (, uint256 unlockable, , , ) = lockedBalances(user);
             if (unlockable == 0) {
                 return (false);
             } else {
                 issueBaseBounty = true;
             }
     
             if (!execute) {
                 return (issueBaseBounty);

954:     /**
          * @notice Earnings which are vesting, and earnings which have vested for full duration.
          * @dev Earned balances may be withdrawn immediately, but will incur a penalty between 25-90%, based on a linear schedule of elapsed time.
          * @return totalVesting sum of vesting tokens
          * @return unlocked earnings
          * @return earningsData which is an array of all infos
          */
         function earnedBalances(
             address user
         ) public view returns (uint256 totalVesting, uint256 unlocked, EarnedBalance[] memory earningsData) {
             unlocked = _balances[user].unlocked;
             LockedBalance[] storage earnings = _userEarnings[user];
             uint256 idx;
             uint256 length = earnings.length;
             uint256 currentTimestamp = block.timestamp;
             for (uint256 i; i < length; ) {
                 if (earnings[i].unlockTime > currentTimestamp) {
                     if (idx == 0) {
                         earningsData = new EarnedBalance[](earnings.length - i);
                     }
                     (, uint256 penaltyAmount, , ) = _ieeWithdrawableBalance(user, earnings[i].unlockTime);
                     earningsData[idx].amount = earnings[i].amount;
                     earningsData[idx].unlockTime = earnings[i].unlockTime;
                     earningsData[idx].penalty = penaltyAmount;
                     idx++;
                     totalVesting = totalVesting + earnings[i].amount;
                 } else {
                     unlocked = unlocked + earnings[i].amount;
                 }
                 unchecked {
                     i++;
                 }
             }
             return (totalVesting, unlocked, earningsData);

990:     /**
          * @notice Final balance received and penalty balance paid by user upon calling exit.
          * @dev This is earnings, not locks.
          * @param user address.
          * @return amount total withdrawable amount.
          * @return penaltyAmount penalty amount.
          * @return burnAmount amount to burn.
          */
         function withdrawableBalance(
             address user
         ) public view returns (uint256 amount, uint256 penaltyAmount, uint256 burnAmount) {
             uint256 earned = _balances[user].earned;
             if (earned > 0) {
                 uint256 length = _userEarnings[user].length;
                 for (uint256 i; i < length; ) {
                     uint256 earnedAmount = _userEarnings[user][i].amount;
                     if (earnedAmount == 0) continue;
                     (, , uint256 newPenaltyAmount, uint256 newBurnAmount) = _penaltyInfo(_userEarnings[user][i]);
                     penaltyAmount = penaltyAmount + newPenaltyAmount;
                     burnAmount = burnAmount + newBurnAmount;
                     unchecked {
                         i++;
                     }
                 }
             }
             amount = _balances[user].unlocked + earned - penaltyAmount;
             return (amount, penaltyAmount, burnAmount);

1044:     /**
           * @notice Address and claimable amount of all reward tokens for the given account.
           * @param account for rewards
           * @return rewardsData array of rewards
           */
          function claimableRewards(address account) public view returns (IFeeDistribution.RewardData[] memory rewardsData) {
              rewardsData = new IFeeDistribution.RewardData[](rewardTokens.length);
      
              uint256 length = rewardTokens.length;
              for (uint256 i; i < length; ) {
                  rewardsData[i].token = rewardTokens[i];
                  rewardsData[i].amount =
                      _earned(
                          account,
                          rewardsData[i].token,
                          _balances[account].lockedWithMultiplier,
                          rewardPerToken(rewardsData[i].token)
                      ) /
                      1e12;
                  unchecked {
                      i++;
                  }
              }
              return rewardsData;

1343:     /**
           * @notice Withdraw all currently locked tokens where the unlock time has passed.
           * @param address_ of the user.
           * @param isRelockAction true if withdraw with relock
           * @param doTransfer true to transfer tokens to user
           * @param limit limit for looping operation
           * @return amount for withdraw
           */
          function _withdrawExpiredLocksFor(
              address address_,
              bool isRelockAction,
              bool doTransfer,
              uint256 limit
          ) internal whenNotPaused returns (uint256 amount) {
              if (isRelockAction && address_ != msg.sender && _lockZap != msg.sender) revert InsufficientPermission();
              _updateReward(address_);
      
              uint256 amountWithMultiplier;
              Balances storage bal = _balances[address_];
              (amount, amountWithMultiplier) = _cleanWithdrawableLocks(address_, limit);
              bal.locked = bal.locked - amount;
              bal.lockedWithMultiplier = bal.lockedWithMultiplier - amountWithMultiplier;
              bal.total = bal.total - amount;
              lockedSupply = lockedSupply - amount;
              lockedSupplyWithMultiplier = lockedSupplyWithMultiplier - amountWithMultiplier;
      
              if (isRelockAction || (address_ != msg.sender && !autoRelockDisabled[address_])) {
                  _stake(amount, address_, defaultLockIndex[address_], true);
              } else {
                  if (doTransfer) {
                      IERC20(stakingToken).safeTransfer(address_, amount);
                      incentivesController.afterLockUpdate(address_);
                      emit Withdrawn(address_, amount, _balances[address_].locked, 0, 0, stakingToken != address(rdntToken));
                  } else {
                      revert InvalidAction();
                  }
              }
              return amount;

1385:     /**
           * @notice Returns withdrawable balance at exact unlock time
           * @param user address for withdraw
           * @param unlockTime exact unlock time
           * @return amount total withdrawable amount
           * @return penaltyAmount penalty amount
           * @return burnAmount amount to burn
           * @return index of earning
           */
          function _ieeWithdrawableBalance(
              address user,
              uint256 unlockTime
          ) internal view returns (uint256 amount, uint256 penaltyAmount, uint256 burnAmount, uint256 index) {
              uint256 length = _userEarnings[user].length;
              for (index; index < length; ) {
                  if (_userEarnings[user][index].unlockTime == unlockTime) {
                      (amount, , penaltyAmount, burnAmount) = _penaltyInfo(_userEarnings[user][index]);
                      return (amount, penaltyAmount, burnAmount, index);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

213: /// @dev Taken from https://github.com/Vectorized/solady/blob/cde0a5fb594da8655ba6bfcdc2e40a7c870c0cc0/src/utils/FixedPointMathLib.sol#L116
     /// @dev Returns `exp(x)`, denominated in `WAD`.
     function wexp(int256 x) pure returns (int256 r) {
         unchecked {
             // When the result is < 0.5 we return zero. This happens when
             // x <= floor(log(0.5e18) * 1e18) ~ -42e18
             if (x <= -42139678854452767551) return r;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

### <a name="NC-34"></a>[NC-34] Take advantage of Custom Error's return value property

An important feature of Custom Error is that values such as address, tokenID, msg.value can be written inside the () sign, this kind of approach provides a serious advantage in debugging and examining the revert details of dapps such as tenderly.

*Instances (190)*:

```solidity
File: src/CDPVault.sol

200:         else revert CDPVault__setParameter_unrecognizedParameter();

210:         else revert CDPVault__setParameter_unrecognizedParameter();

322:             revert CDPVault__modifyPosition_debtFloor();

381:         ) revert CDPVault__modifyCollateralAndDebt_noPermission();

454:         ) revert CDPVault__modifyCollateralAndDebt_notSafe();

511:         if (owner == address(0) || repayAmount == 0) revert CDPVault__liquidatePosition_invalidParameters();

524:         if (spotPrice_ == 0) revert CDPVault__liquidatePosition_invalidSpotPrice();

526:         if (calcTotalDebt(debtData) > wmul(position.collateral, spotPrice_)) revert CDPVault__BadDebt();

532:         if (takeCollateral > position.collateral) revert CDPVault__tooHighRepayAmount();

536:             revert CDPVault__liquidatePosition_notUnsafe();

581:         if (owner == address(0) || repayAmount == 0) revert CDPVault__liquidatePosition_invalidParameters();

591:         if (spotPrice_ == 0) revert CDPVault__liquidatePosition_invalidSpotPrice();

594:             revert CDPVault__liquidatePosition_notUnsafe();

599:         if (calcTotalDebt(debtData) <= wmul(position.collateral, discountedPrice)) revert CDPVault__noBadDebt();

602:         if (takeCollateral < position.collateral) revert CDPVault__repayAmountNotEnough();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

76:         if (token != address(underlyingToken)) revert Flash__flashFee_unsupportedToken();

93:         if (token != address(underlyingToken)) revert Flash__flashLoan_unsupportedToken();

102:             revert Flash__flashLoan_callbackFailed();

130:             revert Flash__creditFlashLoan_callbackFailed();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

111:         _revertIfCallerIsNotPoolQuotaKeeper();

117:         _revertIfCallerNotCreditManager();

125:             _revertIfLocked();

130:     function _revertIfCallerIsNotPoolQuotaKeeper() internal view {

131:         if (msg.sender != poolQuotaKeeper) revert CallerNotPoolQuotaKeeperException(); // U:[LP-2C]

135:     function _revertIfCallerNotCreditManager() internal view {

137:             revert CallerNotCreditManagerException(); // U:[PQK-4]

141:     function _revertIfLocked() internal view {

142:         if (locked) revert PoolV3LockedException(); // U:[LP-2C]

183:             revert IncompatibleDecimalsException();

500:             revert CreditManagerCantBorrowException(); // U:[LP-2C,13A]

545:             revert CallerNotCreditManagerException(); // U:[LP-2C,14A]

770:             revert IncompatiblePoolQuotaKeeperException(); // U:[LP-23C]

808:                 revert IncompatibleCreditManagerException(); // U:[LP-25C]

827:             revert IncorrectParameterException(); // U:[LP-26A]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

24:         if (msg.sender != STAKING_VAULT) revert OnlyStakingVault();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

44:         if (cooldownDuration != 0) revert OperationNotAllowed();

50:         if (cooldownDuration == 0) revert OperationNotAllowed();

98:             revert InvalidCooldown();

105:         if (assets > maxWithdraw(msg.sender)) revert ExcessiveWithdrawAmount();

118:         if (shares > maxRedeem(msg.sender)) revert ExcessiveRedeemAmount();

132:             revert InvalidCooldown();

143:         if (_totalSupply > 0 && _totalSupply < MIN_SHARES) revert MinSharesViolation();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

40:         if (registeredVaults[vault]) revert VaultRegistry__addVault_vaultAlreadyRegistered();

50:         if (!registeredVaults[vault]) revert VaultRegistry__removeVault_vaultNotFound();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

111:         if (_getStatus()) revert BalancerOracle__authorizeUpgrade_validStatus();

115:         if (block.timestamp - lastUpdate < updateWaitWindow) revert BalancerOracle__update_InUpdateWaitWindow();

160:             revert BalancerOracle__spot_invalidPrice();

170:         else revert BalancerOracle__getTokenPrice_invalidIndex();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

90:         if (!isValid) revert ChainlinkOracle__spot_invalidValue();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/BaseAction.sol

9:     error Action__revertBytes_emptyRevertBytes();

35:         revert Action__revertBytes_emptyRevertBytes();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/BaseAction.sol)

```solidity
File: src/proxy/PoolAction.sol

78:                     revert PoolAction__transferAndJoin_invalidPermitParams();

91:                 revert PoolAction__transferAndJoin_unsupportedProtocol();

104:             revert PoolAction__join_unsupportedProtocol();

199:             revert PoolAction__exit_unsupportedProtocol();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction.sol

116:             revert PositionAction__constructor_InvalidParam();

133:         if (address(this) == self) revert PositionAction__onlyDelegatecall();

138:         if (!vaultRegistry.isVaultRegistered(vault)) revert PositionAction__unregisteredVault();

308:         ) revert PositionAction__increaseLever_invalidPrimarySwap();

316:         ) revert PositionAction__increaseLever_invalidAuxSwap();

352:             revert PositionAction__decreaseLever_invalidPrimarySwap();

356:             revert PositionAction__decreaseLever_invalidAuxSwap();

360:             revert PositionAction__decreaseLever_invalidResidualRecipient();

386:         if (msg.sender != address(flashlender)) revert PositionAction__onFlashLoan__invalidSender();

437:         if (msg.sender != address(flashlender)) revert PositionAction__onCreditFlashLoan__invalidSender();

514:             ) revert PositionAction__deposit_InvalidAuxSwap();

560:             if (creditParams.auxSwap.assetIn != address(underlyingToken)) revert PositionAction__borrow_InvalidAuxSwap();

573:             if (creditParams.auxSwap.recipient != address(this)) revert PositionAction__repay_InvalidAuxSwap();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/SwapAction.sol

63:     error SwapAction__revertBytes_emptyRevertBytes();

125:             revert SwapAction__swap_notSupported();

328:             revert SwapAction__swap_notSupported();

341:         revert SwapAction__revertBytes_emptyRevertBytes();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

68:         _revertIfCallerNotVoter(); // U:[GA-02]

105:                 if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-15]

145:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

188:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

196:             if (uv.votesLpSide < votes) revert InsufficientVotesException();

202:             if (uv.votesCaSide < votes) revert InsufficientVotesException();

243:             revert TokenNotAllowedException(); // U:[GA-04]

292:         if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-06A, GA-06B]

307:             revert IncorrectParameterException(); // U:[GA-04]

322:     function _revertIfCallerNotVoter() internal view {

324:             revert CallerNotVoterException(); // U:[GA-02]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

67:         _revertIfCallerNotGauge();

169:             revert TokenAlreadyAddedException(); // U:[PQK-6]

273:             revert TokenIsNotQuotedException(); // U:[PQK-14]

278:     function _revertIfCallerNotGauge() internal view {

279:         if (msg.sender != gauge) revert CallerNotGaugeException(); // U:[PQK-3]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

218:             if (!whitelist[msg.sender] && msg.sender != address(this)) revert NotWhitelisted();

242:         if (_poolConfigurator == address(0)) revert AddressZero();

243:         if (_rdntToken == address(0)) revert AddressZero();

244:         if (address(_eligibleDataProvider) == address(0)) revert AddressZero();

245:         if (address(_mfd) == address(0)) revert AddressZero();

292:         if (startTime != 0) revert AlreadyStarted();

302:         if (msg.sender != poolConfigurator) revert NotAllowed();

303:         if (vaultInfo[_token].lastRewardTime != 0) revert PoolExists();

319:         if (_tokens.length != _allocPoints.length) revert ArrayLengthMismatch();

325:             if (pool.lastRewardTime == 0) revert UnknownPool();

399:         if (length <= 0 || length != _rewardsPerSecond.length) revert ArrayLengthMismatch();

403:                 if (_startTimeOffsets[i - 1] > _startTimeOffsets[i]) revert NotAscending();

405:             if (_startTimeOffsets[i] > type(uint128).max) revert ExceedsMaxInt();

406:             if (_rewardsPerSecond[i] > type(uint128).max) revert ExceedsMaxInt();

407:             if (_checkDuplicateSchedule(_startTimeOffsets[i])) revert DuplicateSchedule();

410:                 if (_startTimeOffsets[i] < block.timestamp - startTime) revert InvalidStart();

520:             if (!eligibleDataProvider.isEligibleForRewards(_user)) revert EligibleRequired();

533:             if (!validRTokens[_tokens[i]]) revert InvalidRToken();

535:             if (pool.lastRewardTime == 0) revert UnknownPool();

558:         if (_amount == 0) revert NothingToVest();

573:         if (msg.sender != owner() && !authorizedContracts[msg.sender]) revert InsufficientPermission();

582:         if (authorizedContracts[_address] == _authorize) revert AuthorizationAlreadySet();

597:         if (!validRTokens[msg.sender] && msg.sender != address(mfd)) revert NotRTokenOrMfd();

634:         if (pool.lastRewardTime == 0) revert UnknownPool();

676:             if (msg.sender != address(mfd)) revert NotMFD();

782:         if (msg.sender != address(bountyManager)) revert BountyOnly();

791:         if (eligibilityMode == EligibilityModes.DISABLED) revert NotEligible();

814:         if (_user == address(0)) revert AddressZero();

821:             if (pool.lastRewardTime == 0) revert UnknownPool();

861:             revert OutOfRewards();

910:         if (_lapse > 1 weeks) revert CadenceTooLong();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

100:         if (address(_vaultRegistry) == address(0)) revert AddressZero();

101:         if (address(_multiFeeDistribution) == address(0)) revert AddressZero();

102:         if (address(_priceProvider) == address(0)) revert AddressZero();

119:         if (address(_chef) == address(0)) revert AddressZero();

128:         if (_lpToken == address(0)) revert AddressZero();

129:         if (lpToken != address(0)) revert LPTokenSet();

140:         if (_requiredDepositRatio > RATIO_DIVISOR) revert InvalidRatio();

152:             revert InvalidRatio();

165:         if (msg.sender != address(chef)) revert OnlyCIC();

250:         if (msg.sender != address(chef)) revert OnlyCIC();

251:         if (user == address(0)) revert AddressZero();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

232:         if (rdntToken_ == address(0)) revert AddressZero();

233:         if (lockZap_ == address(0)) revert AddressZero();

234:         if (dao_ == address(0)) revert AddressZero();

235:         if (priceProvider_ == address(0)) revert AddressZero();

236:         if (rewardsDuration_ == uint256(0)) revert AmountZero();

237:         if (rewardsLookback_ == uint256(0)) revert AmountZero();

238:         if (lockDuration_ == uint256(0)) revert AmountZero();

239:         if (vestDuration_ == uint256(0)) revert AmountZero();

240:         if (burnRatio_ > WHOLE) revert InvalidBurn();

241:         if (rewardsLookback_ > rewardsDuration_) revert InvalidLookback();

269:             if (minters_[i] == address(0)) revert AddressZero();

283:         if (bounty == address(0)) revert AddressZero();

294:         if (rewardConverter_ == address(0)) revert AddressZero();

305:         if (lockPeriod_.length != rewardMultipliers_.length) revert InvalidLockPeriod();

325:         if (address(controller_) == address(0)) revert AddressZero();

326:         if (address(treasury_) == address(0)) revert AddressZero();

337:         if (stakingToken_ == address(0)) revert AddressZero();

338:         if (stakingToken != address(0)) revert AlreadySet();

348:         if (_rewardToken == address(0)) revert AddressZero();

349:         if (!minters[msg.sender]) revert InsufficientPermission();

350:         if (rewardData[_rewardToken].lastUpdateTime != 0) revert AlreadyAdded();

366:         if (!minters[msg.sender]) revert InsufficientPermission();

380:         if (!isTokenFound) revert InvalidAddress();

405:         if (index >= _lockPeriod.length) revert InvalidType();

417:             revert InvalidAmount();

428:             revert InvalidAmount();

453:         if (lookback == uint256(0)) revert AmountZero();

454:         if (lookback > rewardsDuration) revert InvalidLookback();

468:         if (_operationExpenseRatio > RATIO_DIVISOR) revert InvalidRatio();

469:         if (_operationExpenseReceiver == address(0)) revert AddressZero();

497:         if (!minters[msg.sender]) revert InsufficientPermission();

539:         if (amount == 0) revert AmountZero();

549:             if (bal.earned < remaining) revert InvalidEarned();

583:                     if (sumEarned == 0) revert InvalidEarned();

620:         if (unlockTime <= block.timestamp) revert InvalidTime();

690:         if (msg.sender != _lockZap) revert InsufficientPermission();

726:         if (msg.sender != rewardConverter) revert InsufficientPermission();

844:         if (msg.sender != address(bountyManager)) revert InsufficientPermission();

1083:             if (amount < IBountyManager(bountyManager).minDLPBalance()) revert InvalidAmount();

1085:         if (typeIndex >= _lockPeriod.length) revert InvalidType();

1224:         if (token == address(0)) revert AddressZero();

1230:         if (periodFinish == 0) revert InvalidPeriod();

1282:         if (onBehalfOf != msg.sender) revert InsufficientPermission();

1357:         if (isRelockAction && address_ != msg.sender && _lockZap != msg.sender) revert InsufficientPermission();

1377:                 revert InvalidAction();

1408:         revert UnlockTimeNotFound();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

18:     if (x >= 1 << 255) revert Math__toInt256_overflow();

24:     if (x >= 1 << 64) revert Math__toUint64_overflow();

62:     if ((y > 0 && z < x) || (y < 0 && z > x)) revert Math__add_overflow_signed();

70:     if ((y > 0 && z > x) || (y < 0 && z < x)) revert Math__sub_overflow_signed();

77:         if (int256(x) < 0 || (y != 0 && z / y != int256(x))) revert Math__mul_overflow_signed();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/utils/Permission.sol

49:             revert Permission__modifyPermission_notPermitted();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

148:         else revert AuraVault__setParameter_unrecognizedParameter();

157:         if (_claimerIncentive > maxClaimerIncentive) revert AuraVault__setVaultConfig_invalidClaimerIncentive();

158:         if (_lockerIncentive > maxLockerIncentive) revert AuraVault__setVaultConfig_invalidLockerIncentive();

159:         if (_lockerRewards == address(0x0)) revert AuraVault__setVaultConfig_invalidLockerRewards();

378:         if (!isValid) revert AuraVault__chainlinkSpot_invalidPrice();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

25:     if (_start + 20 < _start) revert UniswapV3Router_toAddress_overflow();

26:     if (_bytes.length < _start + 20) revert UniswapV3Router_toAddress_outOfBounds();

40:     if (path.length < 20) revert UniswapV3Router_decodeLastToken_invalidPath();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

### <a name="NC-35"></a>[NC-35] Use scientific notation (e.g. `1e18`) rather than exponentiation (e.g. `10**18`)

While this won't save gas in the recent solidity versions, this is shorter and more readable (this is especially true in calculations).

*Instances (2)*:

```solidity
File: src/CDPVault.sol

59:     uint256 constant INDEX_PRECISION = 10 ** 9;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

276:         return (lockedLP * lpPrice) / 10 ** 18;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

### <a name="NC-36"></a>[NC-36] Use scientific notation for readability reasons for large multiples of ten

The more a number has zeros, the harder it becomes to see with the eyes if it's the intended value. To ease auditing and bug bounty hunting, consider using the scientific notation

*Instances (1)*:

```solidity
File: src/reward/MultiFeeDistribution.sol

39:     uint256 public constant WHOLE = 100000; // 100%

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="NC-37"></a>[NC-37] Avoid the use of sensitive terms

Use [alternative variants](https://www.zdnet.com/article/mysql-drops-master-slave-and-blacklist-whitelist-terminology/), e.g. allowlist/denylist instead of whitelist/blacklist

*Instances (11)*:

```solidity
File: src/reward/ChefIncentivesController.sol

112:     error NotWhitelisted();

209:     mapping(address => bool) public whitelist;

211:     bool public whitelistActive;

216:     modifier isWhitelisted() {

217:         if (whitelistActive) {

218:             if (!whitelist[msg.sender] && msg.sender != address(this)) revert NotWhitelisted();

813:     function manualStopEmissionsFor(address _user, address[] memory _tokens) public isWhitelisted {

844:     function manualStopAllEmissionsFor(address _user) external isWhitelisted {

1006:         whitelist[user] = status;

1012:     function toggleWhitelist() external onlyOwner {

1013:         whitelistActive = !whitelistActive;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

### <a name="NC-38"></a>[NC-38] Contract does not follow the Solidity style guide's suggested layout ordering

The [style guide](https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout) says that, within a contract, the ordering should be:

1) Type declarations
2) State variables
3) Events
4) Modifiers
5) Functions

However, the contract(s) below do not follow this ordering

*Instances (15)*:

```solidity
File: src/CDPVault.sol

1: 
   Current order:
   FunctionDefinition.mintProfit
   FunctionDefinition.enter
   FunctionDefinition.exit
   FunctionDefinition.addAvailable
   UsingForDirective.IERC20
   UsingForDirective.SafeCast
   VariableDeclaration.oracle
   VariableDeclaration.token
   VariableDeclaration.tokenScale
   VariableDeclaration.INDEX_PRECISION
   VariableDeclaration.pool
   VariableDeclaration.poolUnderlying
   StructDefinition.VaultConfig
   VariableDeclaration.vaultConfig
   VariableDeclaration.totalDebt
   StructDefinition.DebtData
   StructDefinition.Position
   VariableDeclaration.positions
   StructDefinition.LiquidationConfig
   VariableDeclaration.liquidationConfig
   VariableDeclaration.rewardController
   EventDefinition.ModifyPosition
   EventDefinition.ModifyCollateralAndDebt
   EventDefinition.SetParameter
   EventDefinition.SetParameter
   EventDefinition.LiquidatePosition
   EventDefinition.VaultCreated
   ErrorDefinition.CDPVault__modifyPosition_debtFloor
   ErrorDefinition.CDPVault__modifyCollateralAndDebt_notSafe
   ErrorDefinition.CDPVault__modifyCollateralAndDebt_noPermission
   ErrorDefinition.CDPVault__modifyCollateralAndDebt_maxUtilizationRatio
   ErrorDefinition.CDPVault__setParameter_unrecognizedParameter
   ErrorDefinition.CDPVault__liquidatePosition_notUnsafe
   ErrorDefinition.CDPVault__liquidatePosition_invalidSpotPrice
   ErrorDefinition.CDPVault__liquidatePosition_invalidParameters
   ErrorDefinition.CDPVault__noBadDebt
   ErrorDefinition.CDPVault__BadDebt
   ErrorDefinition.CDPVault__repayAmountNotEnough
   ErrorDefinition.CDPVault__tooHighRepayAmount
   FunctionDefinition.constructor
   FunctionDefinition.setParameter
   FunctionDefinition.setParameter
   FunctionDefinition.deposit
   FunctionDefinition.withdraw
   FunctionDefinition.borrow
   FunctionDefinition.repay
   FunctionDefinition.spotPrice
   FunctionDefinition._modifyPosition
   FunctionDefinition._isCollateralized
   FunctionDefinition.modifyCollateralAndDebt
   FunctionDefinition._calcQuotaRevenueChange
   FunctionDefinition._calcDebt
   FunctionDefinition._getQuotedTokensData
   FunctionDefinition.liquidatePosition
   FunctionDefinition.liquidatePositionBadDebt
   FunctionDefinition.calcDecrease
   FunctionDefinition.calcAccruedInterest
   FunctionDefinition.virtualDebt
   FunctionDefinition.calcTotalDebt
   FunctionDefinition.poolQuotaKeeper
   FunctionDefinition.quotasInterest
   FunctionDefinition.getDebtData
   FunctionDefinition.getDebtInfo
   
   Suggested order:
   UsingForDirective.IERC20
   UsingForDirective.SafeCast
   VariableDeclaration.oracle
   VariableDeclaration.token
   VariableDeclaration.tokenScale
   VariableDeclaration.INDEX_PRECISION
   VariableDeclaration.pool
   VariableDeclaration.poolUnderlying
   VariableDeclaration.vaultConfig
   VariableDeclaration.totalDebt
   VariableDeclaration.positions
   VariableDeclaration.liquidationConfig
   VariableDeclaration.rewardController
   StructDefinition.VaultConfig
   StructDefinition.DebtData
   StructDefinition.Position
   StructDefinition.LiquidationConfig
   ErrorDefinition.CDPVault__modifyPosition_debtFloor
   ErrorDefinition.CDPVault__modifyCollateralAndDebt_notSafe
   ErrorDefinition.CDPVault__modifyCollateralAndDebt_noPermission
   ErrorDefinition.CDPVault__modifyCollateralAndDebt_maxUtilizationRatio
   ErrorDefinition.CDPVault__setParameter_unrecognizedParameter
   ErrorDefinition.CDPVault__liquidatePosition_notUnsafe
   ErrorDefinition.CDPVault__liquidatePosition_invalidSpotPrice
   ErrorDefinition.CDPVault__liquidatePosition_invalidParameters
   ErrorDefinition.CDPVault__noBadDebt
   ErrorDefinition.CDPVault__BadDebt
   ErrorDefinition.CDPVault__repayAmountNotEnough
   ErrorDefinition.CDPVault__tooHighRepayAmount
   EventDefinition.ModifyPosition
   EventDefinition.ModifyCollateralAndDebt
   EventDefinition.SetParameter
   EventDefinition.SetParameter
   EventDefinition.LiquidatePosition
   EventDefinition.VaultCreated
   FunctionDefinition.mintProfit
   FunctionDefinition.enter
   FunctionDefinition.exit
   FunctionDefinition.addAvailable
   FunctionDefinition.constructor
   FunctionDefinition.setParameter
   FunctionDefinition.setParameter
   FunctionDefinition.deposit
   FunctionDefinition.withdraw
   FunctionDefinition.borrow
   FunctionDefinition.repay
   FunctionDefinition.spotPrice
   FunctionDefinition._modifyPosition
   FunctionDefinition._isCollateralized
   FunctionDefinition.modifyCollateralAndDebt
   FunctionDefinition._calcQuotaRevenueChange
   FunctionDefinition._calcDebt
   FunctionDefinition._getQuotedTokensData
   FunctionDefinition.liquidatePosition
   FunctionDefinition.liquidatePositionBadDebt
   FunctionDefinition.calcDecrease
   FunctionDefinition.calcAccruedInterest
   FunctionDefinition.virtualDebt
   FunctionDefinition.calcTotalDebt
   FunctionDefinition.poolQuotaKeeper
   FunctionDefinition.quotasInterest
   FunctionDefinition.getDebtData
   FunctionDefinition.getDebtInfo

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

1: 
   Current order:
   VariableDeclaration.CALLBACK_SUCCESS
   VariableDeclaration.CALLBACK_SUCCESS_CREDIT
   VariableDeclaration.pool
   VariableDeclaration.protocolFee
   VariableDeclaration.underlyingToken
   EventDefinition.FlashLoan
   EventDefinition.CreditFlashLoan
   ErrorDefinition.Flash__flashFee_unsupportedToken
   ErrorDefinition.Flash__flashLoan_unsupportedToken
   ErrorDefinition.Flash__flashLoan_callbackFailed
   ErrorDefinition.Flash__creditFlashLoan_callbackFailed
   ErrorDefinition.Flash__creditFlashLoan_unsupportedToken
   FunctionDefinition.constructor
   FunctionDefinition.maxFlashLoan
   FunctionDefinition.flashFee
   FunctionDefinition.flashLoan
   FunctionDefinition.creditFlashLoan
   
   Suggested order:
   VariableDeclaration.CALLBACK_SUCCESS
   VariableDeclaration.CALLBACK_SUCCESS_CREDIT
   VariableDeclaration.pool
   VariableDeclaration.protocolFee
   VariableDeclaration.underlyingToken
   ErrorDefinition.Flash__flashFee_unsupportedToken
   ErrorDefinition.Flash__flashLoan_unsupportedToken
   ErrorDefinition.Flash__flashLoan_callbackFailed
   ErrorDefinition.Flash__creditFlashLoan_callbackFailed
   ErrorDefinition.Flash__creditFlashLoan_unsupportedToken
   EventDefinition.FlashLoan
   EventDefinition.CreditFlashLoan
   FunctionDefinition.constructor
   FunctionDefinition.maxFlashLoan
   FunctionDefinition.flashFee
   FunctionDefinition.flashLoan
   FunctionDefinition.creditFlashLoan

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

1: 
   Current order:
   UsingForDirective.Math
   UsingForDirective.SafeCast
   UsingForDirective.SafeCast
   UsingForDirective.CreditLogic
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.IERC20
   ErrorDefinition.CallerNotManagerException
   ErrorDefinition.PoolV3LockedException
   ErrorDefinition.IncompatibleDecimalsException
   VariableDeclaration.version
   VariableDeclaration.addressProvider
   VariableDeclaration.underlyingToken
   VariableDeclaration.treasury
   VariableDeclaration.interestRateModel
   VariableDeclaration.lastBaseInterestUpdate
   VariableDeclaration.lastQuotaRevenueUpdate
   VariableDeclaration.withdrawFee
   VariableDeclaration.locked
   VariableDeclaration.poolQuotaKeeper
   VariableDeclaration._quotaRevenue
   VariableDeclaration._baseInterestRate
   VariableDeclaration._baseInterestIndexLU
   VariableDeclaration._expectedLiquidityLU
   VariableDeclaration._totalDebt
   VariableDeclaration._creditManagerDebt
   VariableDeclaration._creditManagerSet
   VariableDeclaration._allowed
   ModifierDefinition.poolQuotaKeeperOnly
   ModifierDefinition.creditManagerOnly
   ModifierDefinition.whenNotLocked
   FunctionDefinition._revertIfCallerIsNotPoolQuotaKeeper
   FunctionDefinition._revertIfCallerNotCreditManager
   FunctionDefinition._revertIfLocked
   FunctionDefinition.constructor
   FunctionDefinition.decimals
   FunctionDefinition.creditManagers
   FunctionDefinition.availableLiquidity
   FunctionDefinition.expectedLiquidity
   FunctionDefinition.expectedLiquidityLU
   FunctionDefinition.totalAssets
   FunctionDefinition.deposit
   FunctionDefinition.depositWithReferral
   FunctionDefinition.mint
   FunctionDefinition.mintWithReferral
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.previewDeposit
   FunctionDefinition.previewMint
   FunctionDefinition.previewWithdraw
   FunctionDefinition.previewRedeem
   FunctionDefinition.maxDeposit
   FunctionDefinition.maxMint
   FunctionDefinition.maxWithdraw
   FunctionDefinition.maxRedeem
   FunctionDefinition._deposit
   FunctionDefinition._withdraw
   FunctionDefinition._convertToShares
   FunctionDefinition._convertToAssets
   FunctionDefinition.totalBorrowed
   FunctionDefinition.totalDebtLimit
   FunctionDefinition.creditManagerBorrowed
   FunctionDefinition.creditManagerDebtLimit
   FunctionDefinition.creditManagerBorrowable
   FunctionDefinition.lendCreditAccount
   FunctionDefinition.repayCreditAccount
   FunctionDefinition._borrowable
   FunctionDefinition.baseInterestRate
   FunctionDefinition.supplyRate
   FunctionDefinition.baseInterestIndex
   FunctionDefinition.baseInterestIndexLU
   FunctionDefinition._calcBaseInterestAccrued
   FunctionDefinition.calcAccruedQuotaInterest
   FunctionDefinition._updateBaseInterest
   FunctionDefinition._calcBaseInterestAccrued
   FunctionDefinition._calcBaseInterestIndex
   FunctionDefinition.quotaRevenue
   FunctionDefinition.updateQuotaRevenue
   FunctionDefinition.setQuotaRevenue
   FunctionDefinition._calcQuotaRevenueAccrued
   FunctionDefinition._setQuotaRevenue
   FunctionDefinition._calcQuotaRevenueAccrued
   FunctionDefinition.setInterestRateModel
   FunctionDefinition.setPoolQuotaKeeper
   FunctionDefinition.setTotalDebtLimit
   FunctionDefinition.setCreditManagerDebtLimit
   FunctionDefinition.setWithdrawFee
   FunctionDefinition.setAllowed
   FunctionDefinition.setLock
   FunctionDefinition.isAllowed
   FunctionDefinition._setTotalDebtLimit
   FunctionDefinition._amountWithFee
   FunctionDefinition._amountMinusFee
   FunctionDefinition._amountWithWithdrawalFee
   FunctionDefinition._amountMinusWithdrawalFee
   FunctionDefinition._convertToU256
   FunctionDefinition._convertToU128
   FunctionDefinition.mintProfit
   
   Suggested order:
   UsingForDirective.Math
   UsingForDirective.SafeCast
   UsingForDirective.SafeCast
   UsingForDirective.CreditLogic
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.IERC20
   VariableDeclaration.version
   VariableDeclaration.addressProvider
   VariableDeclaration.underlyingToken
   VariableDeclaration.treasury
   VariableDeclaration.interestRateModel
   VariableDeclaration.lastBaseInterestUpdate
   VariableDeclaration.lastQuotaRevenueUpdate
   VariableDeclaration.withdrawFee
   VariableDeclaration.locked
   VariableDeclaration.poolQuotaKeeper
   VariableDeclaration._quotaRevenue
   VariableDeclaration._baseInterestRate
   VariableDeclaration._baseInterestIndexLU
   VariableDeclaration._expectedLiquidityLU
   VariableDeclaration._totalDebt
   VariableDeclaration._creditManagerDebt
   VariableDeclaration._creditManagerSet
   VariableDeclaration._allowed
   ErrorDefinition.CallerNotManagerException
   ErrorDefinition.PoolV3LockedException
   ErrorDefinition.IncompatibleDecimalsException
   ModifierDefinition.poolQuotaKeeperOnly
   ModifierDefinition.creditManagerOnly
   ModifierDefinition.whenNotLocked
   FunctionDefinition._revertIfCallerIsNotPoolQuotaKeeper
   FunctionDefinition._revertIfCallerNotCreditManager
   FunctionDefinition._revertIfLocked
   FunctionDefinition.constructor
   FunctionDefinition.decimals
   FunctionDefinition.creditManagers
   FunctionDefinition.availableLiquidity
   FunctionDefinition.expectedLiquidity
   FunctionDefinition.expectedLiquidityLU
   FunctionDefinition.totalAssets
   FunctionDefinition.deposit
   FunctionDefinition.depositWithReferral
   FunctionDefinition.mint
   FunctionDefinition.mintWithReferral
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.previewDeposit
   FunctionDefinition.previewMint
   FunctionDefinition.previewWithdraw
   FunctionDefinition.previewRedeem
   FunctionDefinition.maxDeposit
   FunctionDefinition.maxMint
   FunctionDefinition.maxWithdraw
   FunctionDefinition.maxRedeem
   FunctionDefinition._deposit
   FunctionDefinition._withdraw
   FunctionDefinition._convertToShares
   FunctionDefinition._convertToAssets
   FunctionDefinition.totalBorrowed
   FunctionDefinition.totalDebtLimit
   FunctionDefinition.creditManagerBorrowed
   FunctionDefinition.creditManagerDebtLimit
   FunctionDefinition.creditManagerBorrowable
   FunctionDefinition.lendCreditAccount
   FunctionDefinition.repayCreditAccount
   FunctionDefinition._borrowable
   FunctionDefinition.baseInterestRate
   FunctionDefinition.supplyRate
   FunctionDefinition.baseInterestIndex
   FunctionDefinition.baseInterestIndexLU
   FunctionDefinition._calcBaseInterestAccrued
   FunctionDefinition.calcAccruedQuotaInterest
   FunctionDefinition._updateBaseInterest
   FunctionDefinition._calcBaseInterestAccrued
   FunctionDefinition._calcBaseInterestIndex
   FunctionDefinition.quotaRevenue
   FunctionDefinition.updateQuotaRevenue
   FunctionDefinition.setQuotaRevenue
   FunctionDefinition._calcQuotaRevenueAccrued
   FunctionDefinition._setQuotaRevenue
   FunctionDefinition._calcQuotaRevenueAccrued
   FunctionDefinition.setInterestRateModel
   FunctionDefinition.setPoolQuotaKeeper
   FunctionDefinition.setTotalDebtLimit
   FunctionDefinition.setCreditManagerDebtLimit
   FunctionDefinition.setWithdrawFee
   FunctionDefinition.setAllowed
   FunctionDefinition.setLock
   FunctionDefinition.isAllowed
   FunctionDefinition._setTotalDebtLimit
   FunctionDefinition._amountWithFee
   FunctionDefinition._amountMinusFee
   FunctionDefinition._amountWithWithdrawalFee
   FunctionDefinition._amountMinusWithdrawalFee
   FunctionDefinition._convertToU256
   FunctionDefinition._convertToU128
   FunctionDefinition.mintProfit

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

1: 
   Current order:
   UsingForDirective.IERC20
   ErrorDefinition.OnlyStakingVault
   VariableDeclaration.STAKING_VAULT
   VariableDeclaration.lpETH
   FunctionDefinition.constructor
   ModifierDefinition.onlyStakingVault
   FunctionDefinition.withdraw
   
   Suggested order:
   UsingForDirective.IERC20
   VariableDeclaration.STAKING_VAULT
   VariableDeclaration.lpETH
   ErrorDefinition.OnlyStakingVault
   ModifierDefinition.onlyStakingVault
   FunctionDefinition.constructor
   FunctionDefinition.withdraw

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

1: 
   Current order:
   UsingForDirective.IERC20
   ErrorDefinition.ExcessiveRedeemAmount
   ErrorDefinition.ExcessiveWithdrawAmount
   ErrorDefinition.InvalidCooldown
   ErrorDefinition.OperationNotAllowed
   ErrorDefinition.MinSharesViolation
   StructDefinition.UserCooldown
   VariableDeclaration.MIN_SHARES
   VariableDeclaration.silo
   VariableDeclaration.cooldowns
   VariableDeclaration.MAX_COOLDOWN_DURATION
   VariableDeclaration.cooldownDuration
   EventDefinition.CooldownDurationUpdated
   ModifierDefinition.ensureCooldownOff
   ModifierDefinition.ensureCooldownOn
   FunctionDefinition.constructor
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.unstake
   FunctionDefinition.cooldownAssets
   FunctionDefinition.cooldownShares
   FunctionDefinition.setCooldownDuration
   FunctionDefinition._checkMinShares
   FunctionDefinition._deposit
   FunctionDefinition._withdraw
   
   Suggested order:
   UsingForDirective.IERC20
   VariableDeclaration.MIN_SHARES
   VariableDeclaration.silo
   VariableDeclaration.cooldowns
   VariableDeclaration.MAX_COOLDOWN_DURATION
   VariableDeclaration.cooldownDuration
   StructDefinition.UserCooldown
   ErrorDefinition.ExcessiveRedeemAmount
   ErrorDefinition.ExcessiveWithdrawAmount
   ErrorDefinition.InvalidCooldown
   ErrorDefinition.OperationNotAllowed
   ErrorDefinition.MinSharesViolation
   EventDefinition.CooldownDurationUpdated
   ModifierDefinition.ensureCooldownOff
   ModifierDefinition.ensureCooldownOn
   FunctionDefinition.constructor
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.unstake
   FunctionDefinition.cooldownAssets
   FunctionDefinition.cooldownShares
   FunctionDefinition.setCooldownDuration
   FunctionDefinition._checkMinShares
   FunctionDefinition._deposit
   FunctionDefinition._withdraw

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

1: 
   Current order:
   VariableDeclaration.VAULT_MANAGER_ROLE
   VariableDeclaration.registeredVaults
   VariableDeclaration.vaultList
   EventDefinition.VaultAdded
   EventDefinition.VaultRemoved
   ErrorDefinition.VaultRegistry__removeVault_vaultNotFound
   ErrorDefinition.VaultRegistry__addVault_vaultAlreadyRegistered
   FunctionDefinition.constructor
   FunctionDefinition.addVault
   FunctionDefinition.removeVault
   FunctionDefinition.getVaults
   FunctionDefinition.getUserTotalDebt
   FunctionDefinition._removeVaultFromList
   FunctionDefinition.isVaultRegistered
   
   Suggested order:
   VariableDeclaration.VAULT_MANAGER_ROLE
   VariableDeclaration.registeredVaults
   VariableDeclaration.vaultList
   ErrorDefinition.VaultRegistry__removeVault_vaultNotFound
   ErrorDefinition.VaultRegistry__addVault_vaultAlreadyRegistered
   EventDefinition.VaultAdded
   EventDefinition.VaultRemoved
   FunctionDefinition.constructor
   FunctionDefinition.addVault
   FunctionDefinition.removeVault
   FunctionDefinition.getVaults
   FunctionDefinition.getUserTotalDebt
   FunctionDefinition._removeVaultFromList
   FunctionDefinition.isVaultRegistered

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

1: 
   Current order:
   StructDefinition.Oracle
   VariableDeclaration.oracles
   VariableDeclaration.__gap
   ErrorDefinition.ChainlinkOracle__spot_invalidValue
   ErrorDefinition.ChainlinkOracle__authorizeUpgrade_validStatus
   FunctionDefinition.setOracles
   FunctionDefinition.initialize
   FunctionDefinition._authorizeUpgrade
   FunctionDefinition.getStatus
   FunctionDefinition.spot
   FunctionDefinition._fetchAndValidate
   FunctionDefinition._getStatus
   
   Suggested order:
   VariableDeclaration.oracles
   VariableDeclaration.__gap
   StructDefinition.Oracle
   ErrorDefinition.ChainlinkOracle__spot_invalidValue
   ErrorDefinition.ChainlinkOracle__authorizeUpgrade_validStatus
   FunctionDefinition.setOracles
   FunctionDefinition.initialize
   FunctionDefinition._authorizeUpgrade
   FunctionDefinition.getStatus
   FunctionDefinition.spot
   FunctionDefinition._fetchAndValidate
   FunctionDefinition._getStatus

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PositionAction.sol

1: 
   Current order:
   UsingForDirective.IERC20
   VariableDeclaration.CALLBACK_SUCCESS
   VariableDeclaration.CALLBACK_SUCCESS_CREDIT
   VariableDeclaration.vaultRegistry
   VariableDeclaration.flashlender
   VariableDeclaration.pool
   VariableDeclaration.underlyingToken
   VariableDeclaration.self
   VariableDeclaration.swapAction
   VariableDeclaration.poolAction
   ErrorDefinition.PositionAction__constructor_InvalidParam
   ErrorDefinition.PositionAction__deposit_InvalidAuxSwap
   ErrorDefinition.PositionAction__borrow_InvalidAuxSwap
   ErrorDefinition.PositionAction__repay_InvalidAuxSwap
   ErrorDefinition.PositionAction__increaseLever_invalidPrimarySwap
   ErrorDefinition.PositionAction__increaseLever_invalidAuxSwap
   ErrorDefinition.PositionAction__decreaseLever_invalidPrimarySwap
   ErrorDefinition.PositionAction__decreaseLever_invalidAuxSwap
   ErrorDefinition.PositionAction__decreaseLever_invalidResidualRecipient
   ErrorDefinition.PositionAction__onFlashLoan__invalidSender
   ErrorDefinition.PositionAction__onFlashLoan__invalidInitiator
   ErrorDefinition.PositionAction__onCreditFlashLoan__invalidSender
   ErrorDefinition.PositionAction__onlyDelegatecall
   ErrorDefinition.PositionAction__unregisteredVault
   FunctionDefinition.constructor
   ModifierDefinition.onlyDelegatecall
   ModifierDefinition.onlyRegisteredVault
   FunctionDefinition._onDeposit
   FunctionDefinition._onWithdraw
   FunctionDefinition._onIncreaseLever
   FunctionDefinition._onDecreaseLever
   FunctionDefinition.deposit
   FunctionDefinition.withdraw
   FunctionDefinition.borrow
   FunctionDefinition.repay
   FunctionDefinition.depositAndBorrow
   FunctionDefinition.withdrawAndRepay
   FunctionDefinition.multisend
   FunctionDefinition.increaseLever
   FunctionDefinition.decreaseLever
   FunctionDefinition.onFlashLoan
   FunctionDefinition.onCreditFlashLoan
   FunctionDefinition._deposit
   FunctionDefinition._withdraw
   FunctionDefinition._borrow
   FunctionDefinition._repay
   FunctionDefinition._transferAndSwap
   
   Suggested order:
   UsingForDirective.IERC20
   VariableDeclaration.CALLBACK_SUCCESS
   VariableDeclaration.CALLBACK_SUCCESS_CREDIT
   VariableDeclaration.vaultRegistry
   VariableDeclaration.flashlender
   VariableDeclaration.pool
   VariableDeclaration.underlyingToken
   VariableDeclaration.self
   VariableDeclaration.swapAction
   VariableDeclaration.poolAction
   ErrorDefinition.PositionAction__constructor_InvalidParam
   ErrorDefinition.PositionAction__deposit_InvalidAuxSwap
   ErrorDefinition.PositionAction__borrow_InvalidAuxSwap
   ErrorDefinition.PositionAction__repay_InvalidAuxSwap
   ErrorDefinition.PositionAction__increaseLever_invalidPrimarySwap
   ErrorDefinition.PositionAction__increaseLever_invalidAuxSwap
   ErrorDefinition.PositionAction__decreaseLever_invalidPrimarySwap
   ErrorDefinition.PositionAction__decreaseLever_invalidAuxSwap
   ErrorDefinition.PositionAction__decreaseLever_invalidResidualRecipient
   ErrorDefinition.PositionAction__onFlashLoan__invalidSender
   ErrorDefinition.PositionAction__onFlashLoan__invalidInitiator
   ErrorDefinition.PositionAction__onCreditFlashLoan__invalidSender
   ErrorDefinition.PositionAction__onlyDelegatecall
   ErrorDefinition.PositionAction__unregisteredVault
   ModifierDefinition.onlyDelegatecall
   ModifierDefinition.onlyRegisteredVault
   FunctionDefinition.constructor
   FunctionDefinition._onDeposit
   FunctionDefinition._onWithdraw
   FunctionDefinition._onIncreaseLever
   FunctionDefinition._onDecreaseLever
   FunctionDefinition.deposit
   FunctionDefinition.withdraw
   FunctionDefinition.borrow
   FunctionDefinition.repay
   FunctionDefinition.depositAndBorrow
   FunctionDefinition.withdrawAndRepay
   FunctionDefinition.multisend
   FunctionDefinition.increaseLever
   FunctionDefinition.decreaseLever
   FunctionDefinition.onFlashLoan
   FunctionDefinition.onCreditFlashLoan
   FunctionDefinition._deposit
   FunctionDefinition._withdraw
   FunctionDefinition._borrow
   FunctionDefinition._repay
   FunctionDefinition._transferAndSwap

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

1: 
   Current order:
   VariableDeclaration.version
   VariableDeclaration.pool
   VariableDeclaration.quotaRateParams
   VariableDeclaration.userTokenVotes
   VariableDeclaration.voter
   VariableDeclaration.epochLastUpdate
   VariableDeclaration.epochFrozen
   FunctionDefinition.constructor
   ModifierDefinition.onlyVoter
   FunctionDefinition.updateEpoch
   FunctionDefinition._checkAndUpdateEpoch
   FunctionDefinition.getRates
   FunctionDefinition.vote
   FunctionDefinition._vote
   FunctionDefinition.unvote
   FunctionDefinition._unvote
   FunctionDefinition.setFrozenEpoch
   FunctionDefinition.addQuotaToken
   FunctionDefinition.changeQuotaMinRate
   FunctionDefinition.changeQuotaMaxRate
   FunctionDefinition._changeQuotaTokenRateParams
   FunctionDefinition._checkParams
   FunctionDefinition.isTokenAdded
   FunctionDefinition._poolQuotaKeeper
   FunctionDefinition._revertIfCallerNotVoter
   
   Suggested order:
   VariableDeclaration.version
   VariableDeclaration.pool
   VariableDeclaration.quotaRateParams
   VariableDeclaration.userTokenVotes
   VariableDeclaration.voter
   VariableDeclaration.epochLastUpdate
   VariableDeclaration.epochFrozen
   ModifierDefinition.onlyVoter
   FunctionDefinition.constructor
   FunctionDefinition.updateEpoch
   FunctionDefinition._checkAndUpdateEpoch
   FunctionDefinition.getRates
   FunctionDefinition.vote
   FunctionDefinition._vote
   FunctionDefinition.unvote
   FunctionDefinition._unvote
   FunctionDefinition.setFrozenEpoch
   FunctionDefinition.addQuotaToken
   FunctionDefinition.changeQuotaMinRate
   FunctionDefinition.changeQuotaMaxRate
   FunctionDefinition._changeQuotaTokenRateParams
   FunctionDefinition._checkParams
   FunctionDefinition.isTokenAdded
   FunctionDefinition._poolQuotaKeeper
   FunctionDefinition._revertIfCallerNotVoter

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

1: 
   Current order:
   UsingForDirective.IERC20
   StructDefinition.UserInfo
   StructDefinition.VaultInfo
   StructDefinition.EmissionPoint
   StructDefinition.EndingTime
   EnumDefinition.EligibilityModes
   EventDefinition.RewardsPerSecondUpdated
   EventDefinition.BalanceUpdated
   EventDefinition.EmissionScheduleAppended
   EventDefinition.ChefReserveLow
   EventDefinition.Disqualified
   EventDefinition.BountyManagerUpdated
   EventDefinition.EligibilityModeUpdated
   EventDefinition.BatchAllocPointsUpdated
   EventDefinition.AuthorizedContractUpdated
   EventDefinition.EndingTimeUpdateCadence
   EventDefinition.RewardDeposit
   ErrorDefinition.AddressZero
   ErrorDefinition.UnknownPool
   ErrorDefinition.PoolExists
   ErrorDefinition.AlreadyStarted
   ErrorDefinition.NotAllowed
   ErrorDefinition.ArrayLengthMismatch
   ErrorDefinition.NotAscending
   ErrorDefinition.ExceedsMaxInt
   ErrorDefinition.InvalidStart
   ErrorDefinition.InvalidRToken
   ErrorDefinition.InsufficientPermission
   ErrorDefinition.AuthorizationAlreadySet
   ErrorDefinition.NotMFD
   ErrorDefinition.NotWhitelisted
   ErrorDefinition.BountyOnly
   ErrorDefinition.NotEligible
   ErrorDefinition.CadenceTooLong
   ErrorDefinition.EligibleRequired
   ErrorDefinition.NotRTokenOrMfd
   ErrorDefinition.OutOfRewards
   ErrorDefinition.NothingToVest
   ErrorDefinition.DuplicateSchedule
   ErrorDefinition.ValueZero
   VariableDeclaration.ACC_REWARD_PRECISION
   VariableDeclaration.emissionSchedule
   VariableDeclaration.persistRewardsPerSecond
   VariableDeclaration.registeredTokens
   VariableDeclaration.rewardsPerSecond
   VariableDeclaration.lastRPS
   VariableDeclaration.emissionScheduleIndex
   VariableDeclaration.vaultInfo
   VariableDeclaration.validRTokens
   VariableDeclaration.totalAllocPoint
   VariableDeclaration.userInfo
   VariableDeclaration.userBaseClaimable
   VariableDeclaration.eligibilityExempt
   VariableDeclaration.startTime
   VariableDeclaration.eligibilityMode
   VariableDeclaration.poolConfigurator
   VariableDeclaration.depositedRewards
   VariableDeclaration.accountedRewards
   VariableDeclaration.lastAllPoolUpdate
   VariableDeclaration.mfd
   VariableDeclaration.eligibleDataProvider
   VariableDeclaration.bountyManager
   VariableDeclaration.endingTime
   VariableDeclaration.authorizedContracts
   VariableDeclaration.whitelist
   VariableDeclaration.whitelistActive
   VariableDeclaration.rdntToken
   ModifierDefinition.isWhitelisted
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.poolLength
   FunctionDefinition.setBountyManager
   FunctionDefinition.setEligibilityMode
   FunctionDefinition.start
   FunctionDefinition.addPool
   FunctionDefinition.batchUpdateAllocPoint
   FunctionDefinition.setRewardsPerSecond
   FunctionDefinition.setScheduledRewardsPerSecond
   FunctionDefinition._checkDuplicateSchedule
   FunctionDefinition.setEmissionSchedule
   FunctionDefinition.recoverERC20
   FunctionDefinition._updateEmissions
   FunctionDefinition._massUpdatePools
   FunctionDefinition._updatePool
   FunctionDefinition.pendingRewards
   FunctionDefinition.claim
   FunctionDefinition._vestTokens
   FunctionDefinition.setEligibilityExempt
   FunctionDefinition.setContractAuthorization
   FunctionDefinition.handleActionAfter
   FunctionDefinition._handleActionAfterForToken
   FunctionDefinition.handleActionBefore
   FunctionDefinition.beforeLockUpdate
   FunctionDefinition.afterLockUpdate
   FunctionDefinition._updateRegisteredBalance
   FunctionDefinition.hasEligibleDeposits
   FunctionDefinition._processEligibility
   FunctionDefinition.checkAndProcessEligibility
   FunctionDefinition.claimBounty
   FunctionDefinition.stopEmissionsFor
   FunctionDefinition.manualStopEmissionsFor
   FunctionDefinition.manualStopAllEmissionsFor
   FunctionDefinition._sendRadiant
   FunctionDefinition.endRewardTime
   FunctionDefinition.setEndingTimeUpdateCadence
   FunctionDefinition.registerRewardDeposit
   FunctionDefinition.availableRewards
   FunctionDefinition.claimAll
   FunctionDefinition.allPendingRewards
   FunctionDefinition.pause
   FunctionDefinition.unpause
   FunctionDefinition._newRewards
   FunctionDefinition.setAddressWLstatus
   FunctionDefinition.toggleWhitelist
   
   Suggested order:
   UsingForDirective.IERC20
   VariableDeclaration.ACC_REWARD_PRECISION
   VariableDeclaration.emissionSchedule
   VariableDeclaration.persistRewardsPerSecond
   VariableDeclaration.registeredTokens
   VariableDeclaration.rewardsPerSecond
   VariableDeclaration.lastRPS
   VariableDeclaration.emissionScheduleIndex
   VariableDeclaration.vaultInfo
   VariableDeclaration.validRTokens
   VariableDeclaration.totalAllocPoint
   VariableDeclaration.userInfo
   VariableDeclaration.userBaseClaimable
   VariableDeclaration.eligibilityExempt
   VariableDeclaration.startTime
   VariableDeclaration.eligibilityMode
   VariableDeclaration.poolConfigurator
   VariableDeclaration.depositedRewards
   VariableDeclaration.accountedRewards
   VariableDeclaration.lastAllPoolUpdate
   VariableDeclaration.mfd
   VariableDeclaration.eligibleDataProvider
   VariableDeclaration.bountyManager
   VariableDeclaration.endingTime
   VariableDeclaration.authorizedContracts
   VariableDeclaration.whitelist
   VariableDeclaration.whitelistActive
   VariableDeclaration.rdntToken
   EnumDefinition.EligibilityModes
   StructDefinition.UserInfo
   StructDefinition.VaultInfo
   StructDefinition.EmissionPoint
   StructDefinition.EndingTime
   ErrorDefinition.AddressZero
   ErrorDefinition.UnknownPool
   ErrorDefinition.PoolExists
   ErrorDefinition.AlreadyStarted
   ErrorDefinition.NotAllowed
   ErrorDefinition.ArrayLengthMismatch
   ErrorDefinition.NotAscending
   ErrorDefinition.ExceedsMaxInt
   ErrorDefinition.InvalidStart
   ErrorDefinition.InvalidRToken
   ErrorDefinition.InsufficientPermission
   ErrorDefinition.AuthorizationAlreadySet
   ErrorDefinition.NotMFD
   ErrorDefinition.NotWhitelisted
   ErrorDefinition.BountyOnly
   ErrorDefinition.NotEligible
   ErrorDefinition.CadenceTooLong
   ErrorDefinition.EligibleRequired
   ErrorDefinition.NotRTokenOrMfd
   ErrorDefinition.OutOfRewards
   ErrorDefinition.NothingToVest
   ErrorDefinition.DuplicateSchedule
   ErrorDefinition.ValueZero
   EventDefinition.RewardsPerSecondUpdated
   EventDefinition.BalanceUpdated
   EventDefinition.EmissionScheduleAppended
   EventDefinition.ChefReserveLow
   EventDefinition.Disqualified
   EventDefinition.BountyManagerUpdated
   EventDefinition.EligibilityModeUpdated
   EventDefinition.BatchAllocPointsUpdated
   EventDefinition.AuthorizedContractUpdated
   EventDefinition.EndingTimeUpdateCadence
   EventDefinition.RewardDeposit
   ModifierDefinition.isWhitelisted
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.poolLength
   FunctionDefinition.setBountyManager
   FunctionDefinition.setEligibilityMode
   FunctionDefinition.start
   FunctionDefinition.addPool
   FunctionDefinition.batchUpdateAllocPoint
   FunctionDefinition.setRewardsPerSecond
   FunctionDefinition.setScheduledRewardsPerSecond
   FunctionDefinition._checkDuplicateSchedule
   FunctionDefinition.setEmissionSchedule
   FunctionDefinition.recoverERC20
   FunctionDefinition._updateEmissions
   FunctionDefinition._massUpdatePools
   FunctionDefinition._updatePool
   FunctionDefinition.pendingRewards
   FunctionDefinition.claim
   FunctionDefinition._vestTokens
   FunctionDefinition.setEligibilityExempt
   FunctionDefinition.setContractAuthorization
   FunctionDefinition.handleActionAfter
   FunctionDefinition._handleActionAfterForToken
   FunctionDefinition.handleActionBefore
   FunctionDefinition.beforeLockUpdate
   FunctionDefinition.afterLockUpdate
   FunctionDefinition._updateRegisteredBalance
   FunctionDefinition.hasEligibleDeposits
   FunctionDefinition._processEligibility
   FunctionDefinition.checkAndProcessEligibility
   FunctionDefinition.claimBounty
   FunctionDefinition.stopEmissionsFor
   FunctionDefinition.manualStopEmissionsFor
   FunctionDefinition.manualStopAllEmissionsFor
   FunctionDefinition._sendRadiant
   FunctionDefinition.endRewardTime
   FunctionDefinition.setEndingTimeUpdateCadence
   FunctionDefinition.registerRewardDeposit
   FunctionDefinition.availableRewards
   FunctionDefinition.claimAll
   FunctionDefinition.allPendingRewards
   FunctionDefinition.pause
   FunctionDefinition.unpause
   FunctionDefinition._newRewards
   FunctionDefinition.setAddressWLstatus
   FunctionDefinition.toggleWhitelist

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

1: 
   Current order:
   VariableDeclaration.RATIO_DIVISOR
   VariableDeclaration.INITIAL_REQUIRED_DEPOSIT_RATIO
   VariableDeclaration.INITIAL_PRICE_TOLERANCE_RATIO
   VariableDeclaration.MIN_PRICE_TOLERANCE_RATIO
   VariableDeclaration.vaultRegistry
   VariableDeclaration.chef
   VariableDeclaration.multiFeeDistribution
   VariableDeclaration.priceProvider
   VariableDeclaration.requiredDepositRatio
   VariableDeclaration.priceToleranceRatio
   VariableDeclaration.lpToken
   VariableDeclaration.lastEligibleStatus
   VariableDeclaration.disqualifiedTime
   EventDefinition.ChefIncentivesControllerUpdated
   EventDefinition.LPTokenUpdated
   EventDefinition.RequiredDepositRatioUpdated
   EventDefinition.PriceToleranceRatioUpdated
   EventDefinition.DqTimeUpdated
   ErrorDefinition.AddressZero
   ErrorDefinition.LPTokenSet
   ErrorDefinition.InvalidRatio
   ErrorDefinition.OnlyCIC
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.setChefIncentivesController
   FunctionDefinition.setLPToken
   FunctionDefinition.setRequiredDepositRatio
   FunctionDefinition.setPriceToleranceRatio
   FunctionDefinition.setDqTime
   FunctionDefinition.lockedUsdValue
   FunctionDefinition.requiredUsdValue
   FunctionDefinition.isEligibleForRewards
   FunctionDefinition.getDqTime
   FunctionDefinition.lastEligibleTime
   FunctionDefinition.refresh
   FunctionDefinition.updatePrice
   FunctionDefinition._lockedUsdValue
   
   Suggested order:
   VariableDeclaration.RATIO_DIVISOR
   VariableDeclaration.INITIAL_REQUIRED_DEPOSIT_RATIO
   VariableDeclaration.INITIAL_PRICE_TOLERANCE_RATIO
   VariableDeclaration.MIN_PRICE_TOLERANCE_RATIO
   VariableDeclaration.vaultRegistry
   VariableDeclaration.chef
   VariableDeclaration.multiFeeDistribution
   VariableDeclaration.priceProvider
   VariableDeclaration.requiredDepositRatio
   VariableDeclaration.priceToleranceRatio
   VariableDeclaration.lpToken
   VariableDeclaration.lastEligibleStatus
   VariableDeclaration.disqualifiedTime
   ErrorDefinition.AddressZero
   ErrorDefinition.LPTokenSet
   ErrorDefinition.InvalidRatio
   ErrorDefinition.OnlyCIC
   EventDefinition.ChefIncentivesControllerUpdated
   EventDefinition.LPTokenUpdated
   EventDefinition.RequiredDepositRatioUpdated
   EventDefinition.PriceToleranceRatioUpdated
   EventDefinition.DqTimeUpdated
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.setChefIncentivesController
   FunctionDefinition.setLPToken
   FunctionDefinition.setRequiredDepositRatio
   FunctionDefinition.setPriceToleranceRatio
   FunctionDefinition.setDqTime
   FunctionDefinition.lockedUsdValue
   FunctionDefinition.requiredUsdValue
   FunctionDefinition.isEligibleForRewards
   FunctionDefinition.getDqTime
   FunctionDefinition.lastEligibleTime
   FunctionDefinition.refresh
   FunctionDefinition.updatePrice
   FunctionDefinition._lockedUsdValue

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

1: 
   Current order:
   UsingForDirective.IERC20
   UsingForDirective.IMintableToken
   VariableDeclaration._priceProvider
   VariableDeclaration.QUART
   VariableDeclaration.HALF
   VariableDeclaration.WHOLE
   VariableDeclaration.MAX_SLIPPAGE
   VariableDeclaration.PERCENT_DIVISOR
   VariableDeclaration.AGGREGATION_EPOCH
   VariableDeclaration.RATIO_DIVISOR
   VariableDeclaration.burn
   VariableDeclaration.rewardsDuration
   VariableDeclaration.rewardsLookback
   VariableDeclaration.DEFAULT_LOCK_INDEX
   VariableDeclaration.defaultLockDuration
   VariableDeclaration.vestDuration
   VariableDeclaration.rewardConverter
   VariableDeclaration.incentivesController
   VariableDeclaration.rdntToken
   VariableDeclaration.stakingToken
   VariableDeclaration._lockZap
   VariableDeclaration._balances
   VariableDeclaration._userLocks
   VariableDeclaration._userEarnings
   VariableDeclaration.autocompoundEnabled
   VariableDeclaration.lastAutocompound
   VariableDeclaration.lockedSupply
   VariableDeclaration.lockedSupplyWithMultiplier
   VariableDeclaration._lockPeriod
   VariableDeclaration._rewardMultipliers
   VariableDeclaration.rewardTokens
   VariableDeclaration.rewardData
   VariableDeclaration.userRewardPerTokenPaid
   VariableDeclaration.rewards
   VariableDeclaration.daoTreasury
   VariableDeclaration.starfleetTreasury
   VariableDeclaration.minters
   VariableDeclaration.autoRelockDisabled
   VariableDeclaration.defaultLockIndex
   VariableDeclaration.mintersAreSet
   VariableDeclaration.lastClaimTime
   VariableDeclaration.bountyManager
   VariableDeclaration.userSlippage
   VariableDeclaration.operationExpenseRatio
   VariableDeclaration.operationExpenseReceiver
   VariableDeclaration.isRewardToken
   EventDefinition.Locked
   EventDefinition.Withdrawn
   EventDefinition.RewardPaid
   EventDefinition.Relocked
   EventDefinition.BountyManagerUpdated
   EventDefinition.RewardConverterUpdated
   EventDefinition.LockTypeInfoUpdated
   EventDefinition.AddressesUpdated
   EventDefinition.LPTokenUpdated
   EventDefinition.RewardAdded
   EventDefinition.LockerAdded
   EventDefinition.LockerRemoved
   EventDefinition.RevenueEarned
   EventDefinition.OperationExpensesUpdated
   EventDefinition.NewTransferAdded
   ErrorDefinition.AddressZero
   ErrorDefinition.AmountZero
   ErrorDefinition.InvalidBurn
   ErrorDefinition.InvalidRatio
   ErrorDefinition.InvalidLookback
   ErrorDefinition.MintersSet
   ErrorDefinition.InvalidLockPeriod
   ErrorDefinition.InsufficientPermission
   ErrorDefinition.AlreadyAdded
   ErrorDefinition.AlreadySet
   ErrorDefinition.InvalidType
   ErrorDefinition.ActiveReward
   ErrorDefinition.InvalidAmount
   ErrorDefinition.InvalidEarned
   ErrorDefinition.InvalidTime
   ErrorDefinition.InvalidPeriod
   ErrorDefinition.UnlockTimeNotFound
   ErrorDefinition.InvalidAddress
   ErrorDefinition.InvalidAction
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.setMinters
   FunctionDefinition.setBountyManager
   FunctionDefinition.addRewardConverter
   FunctionDefinition.setLockTypeInfo
   FunctionDefinition.setAddresses
   FunctionDefinition.setLPToken
   FunctionDefinition.addReward
   FunctionDefinition.removeReward
   FunctionDefinition.setDefaultRelockTypeIndex
   FunctionDefinition.setAutocompound
   FunctionDefinition.setUserSlippage
   FunctionDefinition.toggleAutocompound
   FunctionDefinition.setRelock
   FunctionDefinition.setLookback
   FunctionDefinition.setOperationExpenses
   FunctionDefinition.stake
   FunctionDefinition.vestTokens
   FunctionDefinition.withdraw
   FunctionDefinition.individualEarlyExit
   FunctionDefinition.exit
   FunctionDefinition.getAllRewards
   FunctionDefinition.withdrawExpiredLocksForWithOptions
   FunctionDefinition.zapVestingToLp
   FunctionDefinition.claimFromConverter
   FunctionDefinition.relock
   FunctionDefinition.requalify
   FunctionDefinition.recoverERC20
   FunctionDefinition.getLockDurations
   FunctionDefinition.getLockMultipliers
   FunctionDefinition.lockInfo
   FunctionDefinition.totalBalance
   FunctionDefinition.getPriceProvider
   FunctionDefinition.getRewardForDuration
   FunctionDefinition.getBalances
   FunctionDefinition.claimBounty
   FunctionDefinition.getReward
   FunctionDefinition.pause
   FunctionDefinition.unpause
   FunctionDefinition.requalifyFor
   FunctionDefinition.lockedBalances
   FunctionDefinition.lockedBalance
   FunctionDefinition.earnedBalances
   FunctionDefinition.withdrawableBalance
   FunctionDefinition.lastTimeRewardApplicable
   FunctionDefinition.rewardPerToken
   FunctionDefinition.claimableRewards
   FunctionDefinition._stake
   FunctionDefinition._updateReward
   FunctionDefinition._notifyReward
   FunctionDefinition._notifyUnseenReward
   FunctionDefinition._getReward
   FunctionDefinition._withdrawTokens
   FunctionDefinition._cleanWithdrawableLocks
   FunctionDefinition._withdrawExpiredLocksFor
   FunctionDefinition._ieeWithdrawableBalance
   FunctionDefinition._insertLock
   FunctionDefinition._earned
   FunctionDefinition._penaltyInfo
   FunctionDefinition._binarySearch
   
   Suggested order:
   UsingForDirective.IERC20
   UsingForDirective.IMintableToken
   VariableDeclaration._priceProvider
   VariableDeclaration.QUART
   VariableDeclaration.HALF
   VariableDeclaration.WHOLE
   VariableDeclaration.MAX_SLIPPAGE
   VariableDeclaration.PERCENT_DIVISOR
   VariableDeclaration.AGGREGATION_EPOCH
   VariableDeclaration.RATIO_DIVISOR
   VariableDeclaration.burn
   VariableDeclaration.rewardsDuration
   VariableDeclaration.rewardsLookback
   VariableDeclaration.DEFAULT_LOCK_INDEX
   VariableDeclaration.defaultLockDuration
   VariableDeclaration.vestDuration
   VariableDeclaration.rewardConverter
   VariableDeclaration.incentivesController
   VariableDeclaration.rdntToken
   VariableDeclaration.stakingToken
   VariableDeclaration._lockZap
   VariableDeclaration._balances
   VariableDeclaration._userLocks
   VariableDeclaration._userEarnings
   VariableDeclaration.autocompoundEnabled
   VariableDeclaration.lastAutocompound
   VariableDeclaration.lockedSupply
   VariableDeclaration.lockedSupplyWithMultiplier
   VariableDeclaration._lockPeriod
   VariableDeclaration._rewardMultipliers
   VariableDeclaration.rewardTokens
   VariableDeclaration.rewardData
   VariableDeclaration.userRewardPerTokenPaid
   VariableDeclaration.rewards
   VariableDeclaration.daoTreasury
   VariableDeclaration.starfleetTreasury
   VariableDeclaration.minters
   VariableDeclaration.autoRelockDisabled
   VariableDeclaration.defaultLockIndex
   VariableDeclaration.mintersAreSet
   VariableDeclaration.lastClaimTime
   VariableDeclaration.bountyManager
   VariableDeclaration.userSlippage
   VariableDeclaration.operationExpenseRatio
   VariableDeclaration.operationExpenseReceiver
   VariableDeclaration.isRewardToken
   ErrorDefinition.AddressZero
   ErrorDefinition.AmountZero
   ErrorDefinition.InvalidBurn
   ErrorDefinition.InvalidRatio
   ErrorDefinition.InvalidLookback
   ErrorDefinition.MintersSet
   ErrorDefinition.InvalidLockPeriod
   ErrorDefinition.InsufficientPermission
   ErrorDefinition.AlreadyAdded
   ErrorDefinition.AlreadySet
   ErrorDefinition.InvalidType
   ErrorDefinition.ActiveReward
   ErrorDefinition.InvalidAmount
   ErrorDefinition.InvalidEarned
   ErrorDefinition.InvalidTime
   ErrorDefinition.InvalidPeriod
   ErrorDefinition.UnlockTimeNotFound
   ErrorDefinition.InvalidAddress
   ErrorDefinition.InvalidAction
   EventDefinition.Locked
   EventDefinition.Withdrawn
   EventDefinition.RewardPaid
   EventDefinition.Relocked
   EventDefinition.BountyManagerUpdated
   EventDefinition.RewardConverterUpdated
   EventDefinition.LockTypeInfoUpdated
   EventDefinition.AddressesUpdated
   EventDefinition.LPTokenUpdated
   EventDefinition.RewardAdded
   EventDefinition.LockerAdded
   EventDefinition.LockerRemoved
   EventDefinition.RevenueEarned
   EventDefinition.OperationExpensesUpdated
   EventDefinition.NewTransferAdded
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.setMinters
   FunctionDefinition.setBountyManager
   FunctionDefinition.addRewardConverter
   FunctionDefinition.setLockTypeInfo
   FunctionDefinition.setAddresses
   FunctionDefinition.setLPToken
   FunctionDefinition.addReward
   FunctionDefinition.removeReward
   FunctionDefinition.setDefaultRelockTypeIndex
   FunctionDefinition.setAutocompound
   FunctionDefinition.setUserSlippage
   FunctionDefinition.toggleAutocompound
   FunctionDefinition.setRelock
   FunctionDefinition.setLookback
   FunctionDefinition.setOperationExpenses
   FunctionDefinition.stake
   FunctionDefinition.vestTokens
   FunctionDefinition.withdraw
   FunctionDefinition.individualEarlyExit
   FunctionDefinition.exit
   FunctionDefinition.getAllRewards
   FunctionDefinition.withdrawExpiredLocksForWithOptions
   FunctionDefinition.zapVestingToLp
   FunctionDefinition.claimFromConverter
   FunctionDefinition.relock
   FunctionDefinition.requalify
   FunctionDefinition.recoverERC20
   FunctionDefinition.getLockDurations
   FunctionDefinition.getLockMultipliers
   FunctionDefinition.lockInfo
   FunctionDefinition.totalBalance
   FunctionDefinition.getPriceProvider
   FunctionDefinition.getRewardForDuration
   FunctionDefinition.getBalances
   FunctionDefinition.claimBounty
   FunctionDefinition.getReward
   FunctionDefinition.pause
   FunctionDefinition.unpause
   FunctionDefinition.requalifyFor
   FunctionDefinition.lockedBalances
   FunctionDefinition.lockedBalance
   FunctionDefinition.earnedBalances
   FunctionDefinition.withdrawableBalance
   FunctionDefinition.lastTimeRewardApplicable
   FunctionDefinition.rewardPerToken
   FunctionDefinition.claimableRewards
   FunctionDefinition._stake
   FunctionDefinition._updateReward
   FunctionDefinition._notifyReward
   FunctionDefinition._notifyUnseenReward
   FunctionDefinition._getReward
   FunctionDefinition._withdrawTokens
   FunctionDefinition._cleanWithdrawableLocks
   FunctionDefinition._withdrawExpiredLocksFor
   FunctionDefinition._ieeWithdrawableBalance
   FunctionDefinition._insertLock
   FunctionDefinition._earned
   FunctionDefinition._penaltyInfo
   FunctionDefinition._binarySearch

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Permission.sol

1: 
   Current order:
   EventDefinition.ModifyPermission
   EventDefinition.SetPermittedAgent
   ErrorDefinition.Permission__modifyPermission_notPermitted
   VariableDeclaration._permitted
   VariableDeclaration._permittedAgents
   FunctionDefinition.modifyPermission
   FunctionDefinition.modifyPermission
   FunctionDefinition.setPermissionAgent
   FunctionDefinition.hasPermission
   
   Suggested order:
   VariableDeclaration._permitted
   VariableDeclaration._permittedAgents
   ErrorDefinition.Permission__modifyPermission_notPermitted
   EventDefinition.ModifyPermission
   EventDefinition.SetPermittedAgent
   FunctionDefinition.modifyPermission
   FunctionDefinition.modifyPermission
   FunctionDefinition.setPermissionAgent
   FunctionDefinition.hasPermission

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

1: 
   Current order:
   UsingForDirective.IERC20
   UsingForDirective.Math
   VariableDeclaration.rewardPool
   VariableDeclaration.maxClaimerIncentive
   VariableDeclaration.maxLockerIncentive
   VariableDeclaration.INCENTIVE_BASIS
   VariableDeclaration.BAL
   VariableDeclaration.BAL_CHAINLINK_FEED
   VariableDeclaration.BAL_CHAINLINK_DECIMALS
   VariableDeclaration.ETH_CHAINLINK_FEED
   VariableDeclaration.ETH_CHAINLINK_DECIMALS
   VariableDeclaration.AURA
   VariableDeclaration.EMISSIONS_MAX_SUPPLY
   VariableDeclaration.INIT_MINT_AMOUNT
   VariableDeclaration.TOTAL_CLIFFS
   VariableDeclaration.REDUCTION_PER_CLIFF
   VariableDeclaration.INFLATION_PROTECTION_TIME
   VariableDeclaration.feed
   VariableDeclaration.auraPriceOracle
   StructDefinition.VaultConfig
   VariableDeclaration.vaultConfig
   EventDefinition.Claimed
   EventDefinition.SetParameter
   ErrorDefinition.AuraVault__setParameter_unrecognizedParameter
   ErrorDefinition.AuraVault__chainlinkSpot_invalidPrice
   ErrorDefinition.AuraVault__fetchAggregator_invalidToken
   ErrorDefinition.AuraVault__setVaultConfig_invalidClaimerIncentive
   ErrorDefinition.AuraVault__setVaultConfig_invalidLockerIncentive
   ErrorDefinition.AuraVault__setVaultConfig_invalidLockerRewards
   FunctionDefinition.constructor
   FunctionDefinition.setParameter
   FunctionDefinition.setVaultConfig
   FunctionDefinition.totalAssets
   FunctionDefinition._convertToShares
   FunctionDefinition._convertToAssets
   FunctionDefinition.deposit
   FunctionDefinition.mint
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.claim
   FunctionDefinition.previewReward
   FunctionDefinition._previewReward
   FunctionDefinition._previewMining
   FunctionDefinition._chainlinkSpot
   FunctionDefinition._getAuraSpot
   
   Suggested order:
   UsingForDirective.IERC20
   UsingForDirective.Math
   VariableDeclaration.rewardPool
   VariableDeclaration.maxClaimerIncentive
   VariableDeclaration.maxLockerIncentive
   VariableDeclaration.INCENTIVE_BASIS
   VariableDeclaration.BAL
   VariableDeclaration.BAL_CHAINLINK_FEED
   VariableDeclaration.BAL_CHAINLINK_DECIMALS
   VariableDeclaration.ETH_CHAINLINK_FEED
   VariableDeclaration.ETH_CHAINLINK_DECIMALS
   VariableDeclaration.AURA
   VariableDeclaration.EMISSIONS_MAX_SUPPLY
   VariableDeclaration.INIT_MINT_AMOUNT
   VariableDeclaration.TOTAL_CLIFFS
   VariableDeclaration.REDUCTION_PER_CLIFF
   VariableDeclaration.INFLATION_PROTECTION_TIME
   VariableDeclaration.feed
   VariableDeclaration.auraPriceOracle
   VariableDeclaration.vaultConfig
   StructDefinition.VaultConfig
   ErrorDefinition.AuraVault__setParameter_unrecognizedParameter
   ErrorDefinition.AuraVault__chainlinkSpot_invalidPrice
   ErrorDefinition.AuraVault__fetchAggregator_invalidToken
   ErrorDefinition.AuraVault__setVaultConfig_invalidClaimerIncentive
   ErrorDefinition.AuraVault__setVaultConfig_invalidLockerIncentive
   ErrorDefinition.AuraVault__setVaultConfig_invalidLockerRewards
   EventDefinition.Claimed
   EventDefinition.SetParameter
   FunctionDefinition.constructor
   FunctionDefinition.setParameter
   FunctionDefinition.setVaultConfig
   FunctionDefinition.totalAssets
   FunctionDefinition._convertToShares
   FunctionDefinition._convertToAssets
   FunctionDefinition.deposit
   FunctionDefinition.mint
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.claim
   FunctionDefinition.previewReward
   FunctionDefinition._previewReward
   FunctionDefinition._previewMining
   FunctionDefinition._chainlinkSpot
   FunctionDefinition._getAuraSpot

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/IPriceOracle.sol

1: 
   Current order:
   EnumDefinition.Variable
   FunctionDefinition.getTimeWeightedAverage
   FunctionDefinition.getLatest
   StructDefinition.OracleAverageQuery
   FunctionDefinition.getLargestSafeQueryWindow
   FunctionDefinition.getPastAccumulators
   StructDefinition.OracleAccumulatorQuery
   
   Suggested order:
   EnumDefinition.Variable
   StructDefinition.OracleAverageQuery
   StructDefinition.OracleAccumulatorQuery
   FunctionDefinition.getTimeWeightedAverage
   FunctionDefinition.getLatest
   FunctionDefinition.getLargestSafeQueryWindow
   FunctionDefinition.getPastAccumulators

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IPriceOracle.sol)

### <a name="NC-39"></a>[NC-39] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (42)*:

```solidity
File: src/reward/EligibilityDataProvider.sol

20:     uint256 public constant RATIO_DIVISOR = 10000;

26:     uint256 public constant INITIAL_PRICE_TOLERANCE_RATIO = 9000;

29:     uint256 public constant MIN_PRICE_TOLERANCE_RATIO = 8000;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

37:     uint256 public constant QUART = 25000; //  25%

38:     uint256 public constant HALF = 65000; //  65%

39:     uint256 public constant WHOLE = 100000; // 100%

42:     uint256 public constant MAX_SLIPPAGE = 9000; //10%

43:     uint256 public constant PERCENT_DIVISOR = 10000; //100%

47:     uint256 public constant RATIO_DIVISOR = 10000;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

225:             if iszero(slt(x, 135305999368893231589)) {

239:         int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;

240:         x = x - k * 54916777467707473351141471128;

246:         int256 y = x + 1346386616545796478920950773328;

247:         y = ((y * x) >> 96) + 57155421227552351082224309758442;

248:         int256 p = y + x - 94201549194550492254356042504812;

249:         p = ((p * y) >> 96) + 28719021644029726153956944680412240;

253:         int256 q = x - 2855989394907223263936484059900;

254:         q = ((q * x) >> 96) + 50020603652535783019961831881945;

255:         q = ((q * x) >> 96) - 533845033583426703283633433725380;

256:         q = ((q * x) >> 96) + 3604857256930695427073651918091429;

257:         q = ((q * x) >> 96) - 14423608567350463180887372962807573;

258:         q = ((q * x) >> 96) + 26449188498355588339934803723976023;

276:         r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));

322:         int256 p = x + 3273285459638523848632254066296;

323:         p = ((p * x) >> 96) + 24828157081833163892658089445524;

324:         p = ((p * x) >> 96) + 43456485725739037958740375743393;

325:         p = ((p * x) >> 96) - 11111509109440967052023855526967;

326:         p = ((p * x) >> 96) - 45023709667254063763336534515857;

327:         p = ((p * x) >> 96) - 14706773417378608786704636184526;

332:         int256 q = x + 5573035233440673466300451813936;

333:         q = ((q * x) >> 96) + 71694874799317883764090561454958;

334:         q = ((q * x) >> 96) + 283447036172924575727196451306956;

335:         q = ((q * x) >> 96) + 401686690394027663651624208769553;

336:         q = ((q * x) >> 96) + 204048457590392012362485061816622;

337:         q = ((q * x) >> 96) + 31853899698501571402653359427138;

338:         q = ((q * x) >> 96) + 909429971244387300277376558375;

356:         r *= 1677202110996718588342820967067443963516166;

358:         r += 16597577552685614221487285958193947469193820559219878177908093499208371 * (159 - t);

360:         r += 600920179829731861736702779321621459595472258049074101567377883020018308;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/vendor/AuraVault.sol

47:     uint256 private constant INCENTIVE_BASIS = 10000;

66:     uint256 private constant INFLATION_PROTECTION_TIME = 1749120350;

387:         queries[0] = IPriceOracle.OracleAverageQuery(IPriceOracle.Variable.PAIR_PRICE, 1800, 0);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-40"></a>[NC-40] Internal and private variables and functions names should begin with an underscore

According to the Solidity Style Guide, Non-`external` variable and function names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)

*Instances (39)*:

```solidity
File: src/CDPVault.sol

652:     function calcDecrease(

717:     function calcAccruedInterest(

735:     function calcTotalDebt(DebtData memory debtData) internal pure returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/VaultRegistry.sol

17:     mapping(ICDPVault => bool) private registeredVaults;

20:     ICDPVault[] private vaultList;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/proxy/SwapAction.sol

161:     function balancerSwap(

303:             IERC20(assetIn).forceApprove(address(uniRouter), limit);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

49:     EnumerableSet.AddressSet internal quotaTokensSet;

52:     mapping(address => TokenQuotaParams) internal totalQuotaParams;

254:     function isInitialised(TokenQuotaParams storage tokenQuotaParams) internal view returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/quotas/QuotasLogic.sol

17:     function cumulativeIndexSince(uint192 cumulativeIndexLU, uint16 rate, uint256 lastQuotaRateUpdate)

29:     function calcAccruedQuotaInterest(uint96 quoted, uint192 cumulativeIndexNow, uint192 cumulativeIndexLU)

39:     function calcQuotaRevenueChange(uint16 rate, int256 change) internal pure returns (int256) {

44:     function calcActualQuotaChange(uint96 totalQuoted, uint96 limit, int96 requestedChange)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

161:     mapping(address => bool) private validRTokens;

352:     function setScheduledRewardsPerSecond() internal {

761:     function checkAndProcessEligibility(

790:     function stopEmissionsFor(address _user) internal {

934:     function availableRewards() internal view returns (uint256 amount) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/utils/Math.sol

17: function toInt256(uint256 x) pure returns (int256) {

23: function toUint64(uint256 x) pure returns (uint64) {

29: function abs(int256 x) pure returns (uint256 z) {

37: function min(uint256 x, uint256 y) pure returns (uint256 z) {

44: function min(int256 x, int256 y) pure returns (int256 z) {

51: function max(uint256 x, uint256 y) pure returns (uint256 z) {

58: function add(uint256 x, int256 y) pure returns (uint256 z) {

66: function sub(uint256 x, int256 y) pure returns (uint256 z) {

74: function mul(uint256 x, int256 y) pure returns (int256 z) {

83: function wmul(uint256 x, uint256 y) pure returns (uint256 z) {

97: function wmul(uint256 x, int256 y) pure returns (int256 z) {

105: function wmulUp(uint256 x, uint256 y) pure returns (uint256 z) {

121: function wdiv(uint256 x, uint256 y) pure returns (uint256 z) {

137: function wdivUp(uint256 x, uint256 y) pure returns (uint256 z) {

152: function wpow(uint256 x, uint256 n, uint256 b) pure returns (uint256 z) {

208: function wpow(int256 x, int256 y) pure returns (int256) {

215: function wexp(int256 x) pure returns (int256 r) {

282: function wln(int256 x) pure returns (int256 r) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/vendor/IUniswapV3Router.sol

24: function toAddress(bytes memory _bytes, uint256 _start) pure returns (address) {

39: function decodeLastToken(bytes memory path) pure returns (address token) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/IUniswapV3Router.sol)

### <a name="NC-41"></a>[NC-41] Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (27)*:

```solidity
File: src/CDPVault.sol

125:     event ModifyPosition(address indexed position, uint256 debt, uint256 collateral, uint256 totalDebt);

133:     event SetParameter(bytes32 indexed parameter, uint256 data);

134:     event SetParameter(bytes32 indexed parameter, address data);

135:     event LiquidatePosition(

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

33:     event FlashLoan(address indexed receiver, address token, uint256 amount, uint256 fee);

34:     event CreditFlashLoan(address indexed receiver, uint256 amount, uint256 fee);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/StakingLPEth.sol

40:     event CooldownDurationUpdated(uint24 previousDuration, uint24 newDuration);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

63:     event RewardsPerSecondUpdated(uint256 indexed rewardsPerSecond, bool persist);

65:     event BalanceUpdated(address indexed token, address indexed user, uint256 balance, uint256 totalSupply);

67:     event EmissionScheduleAppended(uint256[] startTimeOffsets, uint256[] rewardsPerSeconds);

77:     event BatchAllocPointsUpdated(address[] _tokens, uint256[] _allocPoints);

79:     event AuthorizedContractUpdated(address _contract, bool _authorized);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

74:     event DqTimeUpdated(address indexed _user, uint256 _time);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

159:     event Locked(address indexed user, uint256 amount, uint256 lockedBalance, uint256 indexed lockLength, bool isLP);

160:     event Withdrawn(

168:     event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);

169:     event Relocked(address indexed user, uint256 amount, uint256 lockIndex);

172:     event LockTypeInfoUpdated(uint256[] lockPeriod, uint256[] rewardMultipliers);

173:     event AddressesUpdated(IChefIncentivesController _controller, address indexed _treasury);

178:     event RevenueEarned(address indexed asset, uint256 assetAmount);

179:     event OperationExpensesUpdated(address indexed _operationExpenses, uint256 _operationExpenseRatio);

180:     event NewTransferAdded(address indexed asset, uint256 lpUsdValue);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/reward/RecoverERC20.sol

14:     event Recovered(address indexed token, uint256 amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/RecoverERC20.sol)

```solidity
File: src/utils/Permission.sol

11:     event ModifyPermission(address authorizer, address owner, address caller, bool grant);

12:     event SetPermittedAgent(address owner, address agent, bool grant);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

95:     event Claimed(

102:     event SetParameter(bytes32 parameter, uint256 data);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-42"></a>[NC-42] Constants should be defined rather than using magic numbers

*Instances (7)*:

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

268:             cumulativeIndexLU := and(shr(16, data), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

269:             quotaIncreaseFee := shr(208, data)

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/utils/Math.sol

31:         let mask := sub(0, shr(255, x))

250:         p = p * x + (4385272521454847904659076985693276 << 96);

276:         r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));

328:         p = p * x - (795164235651350426258249787498 << 96);

358:         r += 16597577552685614221487285958193947469193820559219878177908093499208371 * (159 - t);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

### <a name="NC-43"></a>[NC-43] `public` functions not called by the contract should be declared `external` instead

*Instances (20)*:

```solidity
File: src/proxy/PoolAction.sol

195:     function exit(PoolActionParams memory poolActionParams) public returns (uint256 retAmount) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/SwapAction.sol

334:     /// @param errMsg Error message to revert with.

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

234:     function initialize(

291:     function start() public onlyOwner {

570:     function setEligibilityExempt(address _contract, bool _value) public {

781:     function claimBounty(address _user, bool _execute) public returns (bool issueBaseBounty) {

951:     function allPendingRewards(address _user) public view returns (uint256 pending) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

95:     function initialize(

208:     function getDqTime(address _user) public view returns (uint256) {

220:     function lastEligibleTime(address user) public view returns (uint256 lastEligibleTimestamp) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

221:     function initialize(

843:     function claimBounty(address user, bool execute) public whenNotPaused returns (bool issueBaseBounty) {

873:     function pause() public onlyOwner {

880:     function unpause() public onlyOwner {

940:     function lockedBalance(address user) public view returns (uint256 locked) {

961:     function earnedBalances(

1049:     function claimableRewards(address account) public view returns (IFeeDistribution.RewardData[] memory rewardsData) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Permission.sol

66:     function hasPermission(address owner, address caller) public view returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Permission.sol)

```solidity
File: src/vendor/AuraVault.sol

152:     function setVaultConfig(

315:     function previewReward() public view returns (uint256 amount) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="NC-44"></a>[NC-44] Variables need not be initialized to zero

The default value for variables is zero, so initializing them to zero is superfluous.

*Instances (16)*:

```solidity
File: src/VaultRegistry.sol

67:         for (uint256 i = 0; i < vaultLen; ) {

82:         for (uint256 i = 0; i < vaultLen; ) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

126:         for (uint256 i = 0; i < weights.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

46:         for (uint256 i = 0; i < _tokens.length; i++) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/PoolAction.sol

81:                 for (uint256 i = 0; i < assets.length; ) {

116:         for (uint256 i = 0; i < assets.length; ) {

168:             for (uint256 i = 0; i < len; ) {

227:         for (uint256 i = 0; i <= outIndex; ) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

377:         for (uint256 i = 0; i < length; ) {

401:         for (uint256 i = 0; i < length; ) {

878:         uint256 extra = 0;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

597:                 for (uint256 j = 0; j < i; ) {

1163:         for (uint256 i = 0; i < length; ) {

1331:             for (uint256 j = 0; j < i; ) {

1477:         uint256 low = 0;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

342:         uint256 minterMinted = 0; // Cannot fetch because private in AURA

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

## Low Issues

| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | `approve()`/`safeApprove()` may revert if the current approval is not zero | 3 |
| [L-2](#L-2) | Use a 2-step ownership transfer pattern | 3 |
| [L-3](#L-3) | Some tokens may revert when zero value transfers are made | 36 |
| [L-4](#L-4) | Missing checks for `address(0)` when assigning values to address state variables | 15 |
| [L-5](#L-5) | `decimals()` is not a part of the ERC-20 standard | 2 |
| [L-6](#L-6) | Do not use deprecated library functions | 5 |
| [L-7](#L-7) | `safeApprove()` is deprecated | 3 |
| [L-8](#L-8) | Deprecated _setupRole() function | 2 |
| [L-9](#L-9) | Do not leave an implementation contract uninitialized | 1 |
| [L-10](#L-10) | Division by zero not prevented | 14 |
| [L-11](#L-11) | External calls in an un-bounded `for-`loop may result in a DOS | 2 |
| [L-12](#L-12) | External call recipient may consume all transaction gas | 1 |
| [L-13](#L-13) | Initializers could be front-run | 16 |
| [L-14](#L-14) | Signature use at deadlines should be allowed | 7 |
| [L-15](#L-15) | Prevent accidentally burning tokens | 12 |
| [L-16](#L-16) | Owner can renounce while system is paused | 4 |
| [L-17](#L-17) | Possible rounding issue | 5 |
| [L-18](#L-18) | Loss of precision | 37 |
| [L-19](#L-19) | Solidity version 0.8.20+ may not work on other chains due to `PUSH0` | 22 |
| [L-20](#L-20) | Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership` | 4 |
| [L-21](#L-21) | File allows a version of solidity that is susceptible to an assembly optimizer bug | 1 |
| [L-22](#L-22) | Sweeping may break accounting if tokens with multiple addresses are used | 10 |
| [L-23](#L-23) | Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting | 17 |
| [L-24](#L-24) | Unsafe ERC20 operation(s) | 2 |
| [L-25](#L-25) | Unsafe solidity low-level call can cause gas grief attack | 1 |
| [L-26](#L-26) | Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions | 18 |
| [L-27](#L-27) | Upgradeable contract not initialized | 37 |

### <a name="L-1"></a>[L-1] `approve()`/`safeApprove()` may revert if the current approval is not zero

- Some tokens (like the *very popular* USDT) do not work when changing the allowance from an existing non-zero allowance value (it will revert if the current approval is not zero to protect against front-running changes of approvals). These tokens must first be approved for zero and then the actual allowance can be approved.
- Furthermore, OZ's implementation of safeApprove would throw an error if an approve is attempted from a non-zero value (`"SafeERC20: approve from non-zero to non-zero allowance"`)

Set the allowance to zero immediately before each of the existing allowance calls

*Instances (3)*:

```solidity
File: src/vendor/AuraVault.sol

204:         IERC20(asset()).safeApprove(rewardPool, assets);

221:         IERC20(asset()).safeApprove(rewardPool, assets);

293:         IERC20(asset()).safeApprove(rewardPool, amountIn);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-2"></a>[L-2] Use a 2-step ownership transfer pattern

Recommend considering implementing a two step process where the owner or admin nominates an account and the nominated account needs to call an `acceptOwnership()` function for the transfer of ownership to fully succeed. This ensures the nominated EOA account is a valid and active account. Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (3)*:

```solidity
File: src/StakingLPEth.sol

8: contract StakingLPEth is ERC4626, Ownable, ReentrancyGuard {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

20: contract ChefIncentivesController is Initializable, PausableUpgradeable, OwnableUpgradeable, RecoverERC20 {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

16: contract EligibilityDataProvider is OwnableUpgradeable {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

### <a name="L-3"></a>[L-3] Some tokens may revert when zero value transfers are made

Example: <https://github.com/d-xo/weird-erc20#revert-on-zero-value-transfers>.

In spite of the fact that EIP-20 [states](https://github.com/ethereum/EIPs/blob/46b9b698815abbfa628cd1097311deee77dd45c5/EIPS/eip-20.md?plain=1#L116) that zero-valued transfers must be accepted, some tokens, such as LEND will revert if this is attempted, which may cause transactions that involve other tokens (such as batch operations) to fully revert. Consider skipping the transfer if the amount is zero, which will also save gas.

*Instances (36)*:

```solidity
File: src/CDPVault.sol

410:             poolUnderlying.safeTransferFrom(creditor, address(pool), amount);

439:             token.safeTransferFrom(collateralizer, address(this), amount);

442:             token.safeTransfer(collateralizer, amount);

539:         poolUnderlying.safeTransferFrom(msg.sender, address(pool), repayAmount - penalty);

565:         token.safeTransfer(msg.sender, takeCollateral);

568:         poolUnderlying.safeTransferFrom(msg.sender, address(pool), penalty);

610:         poolUnderlying.safeTransferFrom(msg.sender, address(pool), repayAmount);

626:         token.safeTransfer(msg.sender, takeCollateral);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/Flashlender.sol

105:         underlyingToken.transferFrom(address(receiver), address(pool), total);

133:         underlyingToken.transferFrom(address(receiver), address(pool), total);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

385:         IERC20(underlyingToken).safeTransferFrom({from: msg.sender, to: address(this), value: assetsSent}); // U:[LP-6,7]

418:         IERC20(underlyingToken).safeTransfer({to: receiver, value: amountToUser}); // U:[LP-8,9]

421:                 IERC20(underlyingToken).safeTransfer({to: treasury, value: assetsSent - amountToUser}); // U:[LP-8,9]

512:         IERC20(underlyingToken).safeTransfer({to: creditAccount, value: borrowedAmount}); // U:[LP-13B]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

29:         lpETH.safeTransfer(to, amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/proxy/PositionAction.sol

321:                 IERC20(upFrontToken).safeTransfer(self, upFrontAmount); // if tokens are on the proxy then just transfer

485:                 IERC20(leverParams.primarySwap.assetIn).safeTransfer(residualRecipient, residualAmount);

544:             IERC20(collateralParams.targetToken).safeTransfer(collateralParams.collateralizer, collateral);

557:             underlyingToken.safeTransferFrom(address(this), creditParams.creditor, creditParams.amount);

609:                 IERC20(swapParams.assetIn).safeTransfer(sender, remainder);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/proxy/SwapAction.sol

130:             IERC20(swapParams.assetIn).safeTransfer(swapParams.recipient, swapParams.limit - retAmount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/proxy/TransferAction.sol

76:             IERC20(token).safeTransferFrom(from, to, amount);

79:             IERC20(token).safeTransferFrom(from, to, amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/TransferAction.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

863:             IERC20(rdntToken_).safeTransfer(_user, _amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

738:                     IERC20(token).safeTransfer(rewardConverter, reward);

1143:             IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), amount);

1193:                 IERC20(rewardToken).safeTransfer(operationExpenseReceiver_, opExAmount);

1256:                 IERC20(token).safeTransfer(user, reward);

1373:                 IERC20(stakingToken).safeTransfer(address_, amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/reward/RecoverERC20.sol

20:         IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/RecoverERC20.sol)

```solidity
File: src/vendor/AuraVault.sol

290:         IERC20(asset()).safeTransferFrom(msg.sender, address(this), amountIn);

297:         IERC20(BAL).safeTransfer(_config.lockerRewards, (amounts[0] * _config.lockerIncentive) / INCENTIVE_BASIS);

298:         IERC20(BAL).safeTransfer(msg.sender, amounts[0]);

302:             IERC20(AURA).safeTransfer(_config.lockerRewards, (amounts[1] * _config.lockerIncentive) / INCENTIVE_BASIS);

303:             IERC20(AURA).safeTransfer(msg.sender, amounts[1]);

306:             IERC20(AURA).safeTransfer(_config.lockerRewards, IERC20(AURA).balanceOf(address(this)));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-4"></a>[L-4] Missing checks for `address(0)` when assigning values to address state variables

*Instances (15)*:

```solidity
File: src/PoolV3.sol

168:         addressProvider = addressProvider_; // U:[LP-1B]

169:         underlyingToken = underlyingToken_; // U:[LP-1B]

179:         interestRateModel = interestRateModel_; // U:[LP-1B]

754:         interestRateModel = newInterestRateModel; // U:[LP-22B]

773:         poolQuotaKeeper = newPoolQuotaKeeper; // U:[LP-23D]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

19:         STAKING_VAULT = _stakingVault;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/oracle/BalancerOracle.sol

79:         pool = pool_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/quotas/GaugeV3.sol

59:         pool = _pool; // U:[GA-01]

60:         voter = _voter; // U:[GA-01]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

82:         pool = _pool; // U:[PQK-1]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

273:         bountyManager = _bountyManager;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

328:         starfleetTreasury = treasury_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

130:         rewardPool = rewardPool_;

131:         feed = feed_;

132:         auraPriceOracle = auraPriceOracle_;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-5"></a>[L-5] `decimals()` is not a part of the ERC-20 standard

The `decimals()` function is not a part of the [ERC-20 standard](https://eips.ethereum.org/EIPS/eip-20), and was added later as an [optional extension](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol). As such, some valid ERC20 tokens do not support this interface, so it is unsafe to blindly cast all tokens to this interface, and then call this function.

*Instances (2)*:

```solidity
File: src/PoolV3.sol

182:         if (ERC20(underlyingToken_).decimals() != 18) {

193:         return ERC4626.decimals();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

### <a name="L-6"></a>[L-6] Do not use deprecated library functions

*Instances (5)*:

```solidity
File: src/VaultRegistry.sol

33:         _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

34:         _setupRole(VAULT_MANAGER_ROLE, msg.sender);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/vendor/AuraVault.sol

204:         IERC20(asset()).safeApprove(rewardPool, assets);

221:         IERC20(asset()).safeApprove(rewardPool, assets);

293:         IERC20(asset()).safeApprove(rewardPool, amountIn);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-7"></a>[L-7] `safeApprove()` is deprecated

[Deprecated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/bfff03c0d2a59bcd8e2ead1da9aed9edf0080d05/contracts/token/ERC20/utils/SafeERC20.sol#L38-L45) in favor of `safeIncreaseAllowance()` and `safeDecreaseAllowance()`. If only setting the initial allowance to the value that means infinite, `safeIncreaseAllowance()` can be used instead. The function may currently work, but if a bug is found in this version of OpenZeppelin, and the version that you're forced to upgrade to no longer has this function, you'll encounter unnecessary delays in porting and testing replacement contracts.

*Instances (3)*:

```solidity
File: src/vendor/AuraVault.sol

204:         IERC20(asset()).safeApprove(rewardPool, assets);

221:         IERC20(asset()).safeApprove(rewardPool, assets);

293:         IERC20(asset()).safeApprove(rewardPool, amountIn);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-8"></a>[L-8] Deprecated _setupRole() function

*Instances (2)*:

```solidity
File: src/VaultRegistry.sol

33:         _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

34:         _setupRole(VAULT_MANAGER_ROLE, msg.sender);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

### <a name="L-9"></a>[L-9] Do not leave an implementation contract uninitialized

An uninitialized implementation contract can be taken over by an attacker, which may impact the proxy. To prevent the implementation contract from being used, it's advisable to invoke the `_disableInitializers` function in the constructor to automatically lock it when it is deployed. This should look similar to this:

```solidity
  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
      _disableInitializers();
  }
```

Sources:

- <https://docs.openzeppelin.com/contracts/4.x/api/proxy#Initializable-_disableInitializers-->
- <https://twitter.com/0xCygaar/status/1621417995905167360?s=20>

*Instances (1)*:

```solidity
File: src/oracle/BalancerOracle.sol

68:     constructor(

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

### <a name="L-10"></a>[L-10] Division by zero not prevented

The divisions below take an input parameter which does not have any zero-value checks, which may lead to the functions reverting when zero is passed.

*Instances (14)*:

```solidity
File: src/CDPVault.sol

723:         return (amount * cumulativeIndexNow) / cumulativeIndexLastUpdate - amount;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

881:         return (amount * PERCENTAGE_FACTOR) / (PERCENTAGE_FACTOR - withdrawFee);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/quotas/GaugeV3.sol

115:                     : uint16((uint256(qrp.minRate) * votesCaSide + uint256(qrp.maxRate) * votesLpSide) / totalVotes); // U:[GA-15]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/QuotasLogic.sol

40:         return change * int256(uint256(rate)) / int16(PERCENTAGE_FACTOR);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

898:             uint256 newEndTime = (unclaimedRewards + extra) / rewardsPerSecond + lastAllPoolUpdate;

995:             newReward = (rawReward * pool.allocPoint) / _totalAllocPoint;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

568:                     requiredAmount = (remaining * WHOLE) / (WHOLE - penaltyFactor);

1040:             rptStored = rptStored + ((newReward * 1e18) / lockedSupplyWithMultiplier);

1200:             r.rewardPerSecond = (reward * 1e12) / rewardsDuration;

1204:             r.rewardPerSecond = ((reward + leftover) * 1e12) / rewardsDuration;

1463:             penaltyFactor = ((earning.unlockTime - block.timestamp) * HALF) / vestDuration + QUART; // 25% + timeLeft/vestDuration * 65%

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

77:         if (int256(x) < 0 || (y != 0 && z / y != int256(x))) revert Math__mul_overflow_signed();

99:         z = mul(x, y) / int256(WAD);

210:     return wexp((wln(x) * y) / int256(WAD));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

### <a name="L-11"></a>[L-11] External calls in an un-bounded `for-`loop may result in a DOS

Consider limiting the number of iterations in for-loops that make external calls

*Instances (2)*:

```solidity
File: src/proxy/PositionAction.sol

279:                 (bool success, bytes memory response) = targets[i].call(data[i]);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

598:                     _userEarnings[_address].pop();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="L-12"></a>[L-12] External call recipient may consume all transaction gas

There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (1)*:

```solidity
File: src/proxy/PositionAction.sol

279:                 (bool success, bytes memory response) = targets[i].call(data[i]);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

### <a name="L-13"></a>[L-13] Initializers could be front-run

Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (16)*:

```solidity
File: src/oracle/BalancerOracle.sol

74:     ) initializer {

98:     function initialize(address admin, address manager) external initializer {

100:         __AccessControl_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

58:     function initialize(address admin, address manager) external initializer {

60:         __AccessControl_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

234:     function initialize(

241:     ) public initializer {

247:         __Ownable_init();

248:         __Pausable_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

95:     function initialize(

99:     ) public initializer {

109:         __Ownable_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

221:     function initialize(

231:     ) public initializer {

243:         __Pausable_init();

244:         __Ownable_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="L-14"></a>[L-14] Signature use at deadlines should be allowed

According to [EIP-2612](https://github.com/ethereum/EIPs/blob/71dc97318013bf2ac572ab63fab530ac9ef419ca/EIPS/eip-2612.md?plain=1#L58), signatures used on exactly the deadline timestamp are supposed to be allowed. While the signature may or may not be used for the exact EIP-2612 use case (transfer approvals), for consistency's sake, all deadlines should follow this semantic. If the timestamp is an expiration rather than a deadline, consider whether it makes more sense to include the expiration timestamp as a valid timestamp, as is done for deadlines.

*Instances (7)*:

```solidity
File: src/reward/ChefIncentivesController.sol

410:                 if (_startTimeOffsets[i] < block.timestamp - startTime) revert InvalidStart();

873:         if (endingTime.lastUpdatedTime + endingTime.updateCadence > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

620:         if (unlockTime <= block.timestamp) revert InvalidTime();

917:             if (locks[i].unlockTime > block.timestamp) {

1231:         if (periodFinish < block.timestamp + rewardsDuration - rewardsLookback) {

1319:             while (i < length && locks[i].unlockTime <= block.timestamp) {

1461:         if (earning.unlockTime > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="L-15"></a>[L-15] Prevent accidentally burning tokens

Minting and burning tokens to address(0) prevention

*Instances (12)*:

```solidity
File: src/PoolV3.sol

283:         assets = mint(shares, receiver); // U:[LP-2A,2B,5,7]

393:         _mint(receiver, shares); // U:[LP-6,7]

410:         _burn(owner, shares); // U:[LP-8,9]

549:             _mint(treasury, convertToShares(profit)); // U:[LP-14B]

563:             _burn(treasury_, sharesToBurn); // U:[LP-14C,14D]

900:         _mint(treasury, amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

610:         _withdrawTokens(_address, amount, penaltyAmount, burnAmount, false);

639:         _withdrawTokens(onBehalfOf, amount, penaltyAmount, burnAmount, claimRewards);

657:         _withdrawTokens(onBehalfOf, amount, penaltyAmount, burnAmount, claimRewards);

1288:                 rdntToken.safeTransfer(starfleetTreasury, burnAmount);

1290:             rdntToken.safeTransfer(daoTreasury, penaltyAmount - burnAmount);

1300:         emit Withdrawn(onBehalfOf, amount, _balances[onBehalfOf].locked, penaltyAmount, burnAmount, false);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="L-16"></a>[L-16] Owner can renounce while system is paused

The contract owner or single user with a role is not prevented from renouncing the role/ownership while the contract is paused, which would cause any user assets stored in the protocol, to be locked indefinitely.

*Instances (4)*:

```solidity
File: src/reward/ChefIncentivesController.sol

966:     function pause() external onlyOwner {

973:     function unpause() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

873:     function pause() public onlyOwner {

880:     function unpause() public onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="L-17"></a>[L-17] Possible rounding issue

Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator. Also, there is indication of multiplication and division without the use of parenthesis which could result in issues.

*Instances (5)*:

```solidity
File: src/quotas/GaugeV3.sol

115:                     : uint16((uint256(qrp.minRate) * votesCaSide + uint256(qrp.maxRate) * votesLpSide) / totalVotes); // U:[GA-15]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

995:             newReward = (rawReward * pool.allocPoint) / _totalAllocPoint;

996:             newAccRewardPerShare = (newReward * ACC_REWARD_PRECISION) / lpSupply;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

1040:             rptStored = rptStored + ((newReward * 1e18) / lockedSupplyWithMultiplier);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

356:             amount = (_amount * reduction) / TOTAL_CLIFFS;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-18"></a>[L-18] Loss of precision

Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator

*Instances (37)*:

```solidity
File: src/PoolV3.sol

672:         return (_totalDebt.borrowed * baseInterestRate().calcLinearGrowth(timestamp)) / RAY;

677:         return (_baseInterestIndexLU * (RAY + baseInterestRate().calcLinearGrowth(timestamp))) / RAY;

881:         return (amount * PERCENTAGE_FACTOR) / (PERCENTAGE_FACTOR - withdrawFee);

886:         return (amount * (PERCENTAGE_FACTOR - withdrawFee)) / PERCENTAGE_FACTOR;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/quotas/GaugeV3.sol

115:                     : uint16((uint256(qrp.minRate) * votesCaSide + uint256(qrp.maxRate) * votesLpSide) / totalVotes); // U:[GA-15]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

147:             quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR;

210:             quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR; // U:[PQK-7]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/quotas/QuotasLogic.sol

9: uint192 constant RAY_DIVIDED_BY_PERCENTAGE = uint192(RAY / PERCENTAGE_FACTOR);

24:                 + RAY_DIVIDED_BY_PERCENTAGE * (block.timestamp - lastQuotaRateUpdate) * rate / SECONDS_PER_YEAR

35:         return uint128(uint256(quoted) * (cumulativeIndexNow - cumulativeIndexLU) / RAY); // U:[QL-2]

40:         return change * int256(uint256(rate)) / int16(PERCENTAGE_FACTOR);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

505:             claimable[i] = (user.amount * accRewardPerShare) / ACC_REWARD_PRECISION - user.rewardDebt;

538:             uint256 rewardDebt = (user.amount * pool.accRewardPerShare) / ACC_REWARD_PRECISION;

643:             uint256 pending = (amount * accRewardPerShare) / ACC_REWARD_PRECISION - user.rewardDebt;

650:         user.rewardDebt = (_balance * accRewardPerShare) / ACC_REWARD_PRECISION;

826:                 uint256 pending = (amount * accRewardPerShare) / ACC_REWARD_PRECISION - user.rewardDebt;

995:             newReward = (rawReward * pool.allocPoint) / _totalAllocPoint;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

189:         required = (totalNormalDebt * requiredDepositRatio) / RATIO_DIVISOR;

200:         uint256 requiredValue = (requiredUsdValue(_user) * priceToleranceRatio) / RATIO_DIVISOR;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

568:                     requiredAmount = (remaining * WHOLE) / (WHOLE - penaltyFactor);

572:                     newPenaltyAmount = (requiredAmount * penaltyFactor) / WHOLE;

573:                     newBurnAmount = (newPenaltyAmount * burn) / WHOLE;

1102:         uint256 lockDurationWeeks = _lockPeriod[typeIndex] / AGGREGATION_EPOCH;

1109:                 (userLocks[indexToAggregate].unlockTime / AGGREGATION_EPOCH == unlockTime / AGGREGATION_EPOCH) &&

1191:             uint256 opExAmount = (reward * operationExpenseRatio_) / RATIO_DIVISOR;

1463:             penaltyFactor = ((earning.unlockTime - block.timestamp) * HALF) / vestDuration + QUART; // 25% + timeLeft/vestDuration * 65%

1464:             penaltyAmount = (earning.amount * penaltyFactor) / WHOLE;

1465:             burnAmount = (penaltyAmount * burn) / WHOLE;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Math.sol

99:         z = mul(x, y) / int256(WAD);

210:     return wexp((wln(x) * y) / int256(WAD));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/vendor/AuraVault.sol

297:         IERC20(BAL).safeTransfer(_config.lockerRewards, (amounts[0] * _config.lockerIncentive) / INCENTIVE_BASIS);

302:             IERC20(AURA).safeTransfer(_config.lockerRewards, (amounts[1] * _config.lockerIncentive) / INCENTIVE_BASIS);

330:         amount = (balReward * _chainlinkSpot()) / IOracle(feed).spot(asset());

331:         amount = amount + (auraReward * _getAuraSpot()) / IOracle(feed).spot(asset());

332:         amount = (amount * (INCENTIVE_BASIS - config.claimerIncentive)) / INCENTIVE_BASIS;

345:         uint256 cliff = emissionsMinted / REDUCTION_PER_CLIFF;

356:             amount = (_amount * reduction) / TOTAL_CLIFFS;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-19"></a>[L-19] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`

The compiler for Solidity 0.8.20 switches the default target EVM version to [Shanghai](https://blog.soliditylang.org/2023/05/10/solidity-0.8.20-release-announcement/#important-note), which includes the new `PUSH0` op code. This op code may not yet be implemented on all L2s, so deployment on these chains will fail. To work around this issue, use an earlier [EVM](https://docs.soliditylang.org/en/v0.8.20/using-the-compiler.html?ref=zaryabs.com#setting-the-evm-version-to-target) [version](https://book.getfoundry.sh/reference/config/solidity-compiler#evm_version). While the project itself may or may not compile with 0.8.20, other projects with which it integrates, or which extend this project may, and those projects will have problems deploying these contracts/libraries.

*Instances (22)*:

```solidity
File: src/Flashlender.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

```solidity
File: src/PoolV3.sol

4: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/Silo.sol

2: pragma solidity ^0.8.0;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

```solidity
File: src/StakingLPEth.sol

1: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/proxy/ERC165Plugin.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/ERC165Plugin.sol)

```solidity
File: src/proxy/PoolAction.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PoolAction.sol)

```solidity
File: src/proxy/PositionAction20.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction20.sol)

```solidity
File: src/proxy/PositionAction4626.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction4626.sol)

```solidity
File: src/proxy/SwapAction.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/SwapAction.sol)

```solidity
File: src/quotas/GaugeV3.sol

4: pragma solidity ^0.8.17;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/GaugeV3.sol)

```solidity
File: src/quotas/PoolQuotaKeeperV3.sol

4: pragma solidity ^0.8.17;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/PoolQuotaKeeperV3.sol)

```solidity
File: src/quotas/QuotasLogic.sol

4: pragma solidity ^0.8.17;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/reward/RecoverERC20.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/RecoverERC20.sol)

```solidity
File: src/utils/Math.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/vendor/AuraVault.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

```solidity
File: src/vendor/Imports.sol

2: pragma solidity ^0.8.19;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/Imports.sol)

### <a name="L-20"></a>[L-20] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`

Use [Ownable2Step.transferOwnership](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol) which is safer. Use it as it is more secure due to 2-stage ownership transfer.

**Recommended Mitigation Steps**

Use <a href="https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol">Ownable2Step.sol</a>
  
  ```solidity
      function acceptOwnership() external {
          address sender = _msgSender();
          require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
          _transferOwnership(sender);
      }
```

*Instances (4)*:

```solidity
File: src/StakingLPEth.sol

5: import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

7: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

4: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

8: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

### <a name="L-21"></a>[L-21] File allows a version of solidity that is susceptible to an assembly optimizer bug

In solidity versions 0.8.13 and 0.8.14, there is an [optimizer bug](https://github.com/ethereum/solidity-blog/blob/499ab8abc19391be7b7b34f88953a067029a5b45/_posts/2022-06-15-inline-assembly-memory-side-effects-bug.md) where, if the use of a variable is in a separate `assembly` block from the block in which it was stored, the `mstore` operation is optimized out, leading to uninitialized memory. The code currently does not have such a pattern of execution, but it does use `mstore`s in `assembly` blocks, so it is a risk for future changes. The affected solidity versions should be avoided if at all possible.

*Instances (1)*:

```solidity
File: src/Silo.sol

2: pragma solidity ^0.8.0;

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Silo.sol)

### <a name="L-22"></a>[L-22] Sweeping may break accounting if tokens with multiple addresses are used

There have been [cases](https://blog.openzeppelin.com/compound-tusd-integration-issue-retrospective/) in the past where a token mistakenly had two addresses that could control its balance, and transfers using one address impacted the balance of the other. To protect against this potential scenario, sweep functions should ensure that the balance of the non-sweepable token does not change after the transfer of the swept tokens.

*Instances (10)*:

```solidity
File: src/reward/ChefIncentivesController.sol

10: import {RecoverERC20} from "./RecoverERC20.sol";

20: contract ChefIncentivesController is Initializable, PausableUpgradeable, OwnableUpgradeable, RecoverERC20 {

430:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

431:         _recoverERC20(tokenAddress, tokenAmount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

11: import {RecoverERC20} from "./libraries/RecoverERC20.sol";

28:     RecoverERC20

770:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

771:         _recoverERC20(tokenAddress, tokenAmount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/reward/RecoverERC20.sol

10: contract RecoverERC20 {

19:     function _recoverERC20(address tokenAddress, uint256 tokenAmount) internal {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/RecoverERC20.sol)

### <a name="L-23"></a>[L-23] Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting

Downcasting from `uint256`/`int256` in Solidity does not revert on overflow. This can result in undesired exploitation or bugs, since developers usually assume that overflows raise errors. [OpenZeppelin's SafeCast library](https://docs.openzeppelin.com/contracts/3.x/api/utils#SafeCast) restores this intuition by reverting the transaction when such an operation overflows. Using this library eliminates an entire class of bugs, so it's recommended to use it always. Some exceptions are acceptable like with the classic `uint256(uint160(address(variable)))`

*Instances (17)*:

```solidity
File: src/CDPVault.sol

196:         if (parameter == "debtFloor") vaultConfig.debtFloor = uint128(data);

197:         else if (parameter == "liquidationRatio") vaultConfig.liquidationRatio = uint64(data);

198:         else if (parameter == "liquidationPenalty") liquidationConfig.liquidationPenalty = uint64(data);

199:         else if (parameter == "liquidationDiscount") liquidationConfig.liquidationDiscount = uint64(data);

489:             uint96(cdd.debt),

679:                 newCumulativeQuotaInterest = uint128(cumulativeQuotaInterest - quotaInterestPaid); // U:[CL-3]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

177:         _baseInterestIndexLU = uint128(RAY); // U:[LP-1B]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/StakingLPEth.sol

110:         cooldowns[msg.sender].underlyingAmount += uint152(assets);

123:         cooldowns[msg.sender].underlyingAmount += uint152(assets);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/quotas/QuotasLogic.sol

9: uint192 constant RAY_DIVIDED_BY_PERCENTAGE = uint192(RAY / PERCENTAGE_FACTOR);

40:         return change * int256(uint256(rate)) / int16(PERCENTAGE_FACTOR);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/quotas/QuotasLogic.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

415:                     rewardsPerSecond: uint128(_rewardsPerSecond[i])

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/utils/Math.sol

25:     return uint64(x);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Math.sol)

```solidity
File: src/vendor/AuraVault.sol

146:         if (parameter == "feed") feed = address(uint160(data));

146:         if (parameter == "feed") feed = address(uint160(data));

147:         else if (parameter == "auraPriceOracle") auraPriceOracle = address(uint160(data));

147:         else if (parameter == "auraPriceOracle") auraPriceOracle = address(uint160(data));

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="L-24"></a>[L-24] Unsafe ERC20 operation(s)

*Instances (2)*:

```solidity
File: src/Flashlender.sol

105:         underlyingToken.transferFrom(address(receiver), address(pool), total);

133:         underlyingToken.transferFrom(address(receiver), address(pool), total);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

### <a name="L-25"></a>[L-25] Unsafe solidity low-level call can cause gas grief attack

Using the low-level calls of a solidity address can leave the contract open to gas grief attacks. These attacks occur when the called contract returns a large amount of data.

So when calling an external contract, it is necessary to check the length of the return data before reading/copying it (using `returndatasize()`).

*Instances (1)*:

```solidity
File: src/proxy/PositionAction.sol

279:                 (bool success, bytes memory response) = targets[i].call(data[i]);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

### <a name="L-26"></a>[L-26] Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions

See [this](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps) link for a description of this storage variable. While some contracts may not currently be sub-classed, adding the variable now protects against forgetting to add it in the future.

*Instances (18)*:

```solidity
File: src/oracle/BalancerOracle.sol

4: import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

5: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

15: contract BalancerOracle is IOracle, AccessControlUpgradeable, UUPSUpgradeable {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

4: import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

5: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

15: contract ChainlinkOracle is IOracle, AccessControlUpgradeable, UUPSUpgradeable {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

6: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

7: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

8: import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

20: contract ChefIncentivesController is Initializable, PausableUpgradeable, OwnableUpgradeable, RecoverERC20 {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

4: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

16: contract EligibilityDataProvider is OwnableUpgradeable {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

8: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

9: import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

26:     PausableUpgradeable,

27:     OwnableUpgradeable,

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/Imports.sol

6: import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/Imports.sol)

### <a name="L-27"></a>[L-27] Upgradeable contract not initialized

Upgradeable contracts are initialized via an initializer function rather than by a constructor. Leaving such a contract uninitialized may lead to it being taken over by a malicious user

*Instances (37)*:

```solidity
File: src/oracle/BalancerOracle.sol

4: import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

5: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

15: contract BalancerOracle is IOracle, AccessControlUpgradeable, UUPSUpgradeable {

74:     ) initializer {

98:     function initialize(address admin, address manager) external initializer {

100:         __AccessControl_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

4: import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

5: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

15: contract ChainlinkOracle is IOracle, AccessControlUpgradeable, UUPSUpgradeable {

58:     function initialize(address admin, address manager) external initializer {

60:         __AccessControl_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

6: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

7: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

8: import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

20: contract ChefIncentivesController is Initializable, PausableUpgradeable, OwnableUpgradeable, RecoverERC20 {

224:         _disableInitializers();

234:     function initialize(

241:     ) public initializer {

247:         __Ownable_init();

248:         __Pausable_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

4: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

16: contract EligibilityDataProvider is OwnableUpgradeable {

86:         _disableInitializers();

95:     function initialize(

99:     ) public initializer {

109:         __Ownable_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

8: import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

9: import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

26:     PausableUpgradeable,

27:     OwnableUpgradeable,

204:         _disableInitializers();

221:     function initialize(

231:     ) public initializer {

243:         __Pausable_init();

244:         __Ownable_init();

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/Imports.sol

6: import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/Imports.sol)

## Medium Issues

| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Contracts are vulnerable to fee-on-transfer accounting-related issues | 5 |
| [M-2](#M-2) | `block.number` means different things on different L2s | 1 |
| [M-3](#M-3) | Centralization Risk for trusted owners | 47 |
| [M-4](#M-4) | Chainlink's `latestRoundData` might return stale or incorrect results | 1 |
| [M-5](#M-5) | Missing checks for whether the L2 Sequencer is active | 1 |
| [M-6](#M-6) | Return values of `transfer()`/`transferFrom()` not checked | 2 |
| [M-7](#M-7) | Unsafe use of `transfer()`/`transferFrom()` with `IERC20` | 2 |

### <a name="M-1"></a>[M-1] Contracts are vulnerable to fee-on-transfer accounting-related issues

Consistently check account balance before and after transfers for Fee-On-Transfer discrepancies. As arbitrary ERC20 tokens can be used, the amount here should be calculated every time to take into consideration a possible fee-on-transfer or deflation.
Also, it's a good practice for the future of the solution.

Use the balance before and after the transfer to calculate the received amount instead of assuming that it would be equal to the amount passed as a parameter. Or explicitly document that such tokens shouldn't be used and won't be supported

*Instances (5)*:

```solidity
File: src/CDPVault.sol

439:             token.safeTransferFrom(collateralizer, address(this), amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/PoolV3.sol

385:         IERC20(underlyingToken).safeTransferFrom({from: msg.sender, to: address(this), value: assetsSent}); // U:[LP-6,7]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/PoolV3.sol)

```solidity
File: src/proxy/PositionAction.sol

557:             underlyingToken.safeTransferFrom(address(this), creditParams.creditor, creditParams.amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/proxy/PositionAction.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

1143:             IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), amount);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/vendor/AuraVault.sol

290:         IERC20(asset()).safeTransferFrom(msg.sender, address(this), amountIn);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="M-2"></a>[M-2] `block.number` means different things on different L2s

On Optimism, `block.number` is the L2 block number, but on Arbitrum, it's the L1 block number, and `ArbSys(address(100)).arbBlockNumber()` must be used. Furthermore, L2 block numbers often occur much more frequently than L1 block numbers (any may even occur on a per-transaction basis), so using block numbers for timing results in inconsistencies, especially when voting is involved across multiple chains. As of version 4.9, OpenZeppelin has [modified](https://blog.openzeppelin.com/introducing-openzeppelin-contracts-v4.9#governor) their governor code to use a clock rather than block numbers, to avoid these sorts of issues, but this still requires that the project [implement](https://docs.openzeppelin.com/contracts/4.x/governance#token_2) a [clock](https://eips.ethereum.org/EIPS/eip-6372) for each L2.

*Instances (1)*:

```solidity
File: src/CDPVault.sol

318:         position.lastDebtUpdate = uint64(block.number); // U:[CM-10,11]

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

### <a name="M-3"></a>[M-3] Centralization Risk for trusted owners

#### Impact

Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (47)*:

```solidity
File: src/CDPVault.sol

39: contract CDPVault is AccessControl, Pause, Permission, ICDPVaultBase {

195:     function setParameter(bytes32 parameter, uint256 data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {

208:     function setParameter(bytes32 parameter, address data) external whenNotPaused onlyRole(VAULT_CONFIG_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/CDPVault.sol)

```solidity
File: src/StakingLPEth.sol

8: contract StakingLPEth is ERC4626, Ownable, ReentrancyGuard {

130:     function setCooldownDuration(uint24 duration) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/StakingLPEth.sol)

```solidity
File: src/VaultRegistry.sol

12: contract VaultRegistry is AccessControl, IVaultRegistry {

39:     function addVault(ICDPVault vault) external override(IVaultRegistry) onlyRole(VAULT_MANAGER_ROLE) {

49:     function removeVault(ICDPVault vault) external override(IVaultRegistry) onlyRole(VAULT_MANAGER_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/VaultRegistry.sol)

```solidity
File: src/oracle/BalancerOracle.sol

110:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {

114:     function update() external virtual onlyRole(KEEPER_ROLE) returns (uint256 safePrice_) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/BalancerOracle.sol)

```solidity
File: src/oracle/ChainlinkOracle.sol

45:     function setOracles(address[] calldata _tokens, Oracle[] calldata _oracles) external onlyRole(DEFAULT_ADMIN_ROLE) {

70:     function _authorizeUpgrade(address /*implementation*/) internal virtual override onlyRole(MANAGER_ROLE) {}

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/oracle/ChainlinkOracle.sol)

```solidity
File: src/reward/ChefIncentivesController.sol

272:     function setBountyManager(address _bountyManager) external onlyOwner {

281:     function setEligibilityMode(EligibilityModes _newVal) external onlyOwner {

291:     function start() public onlyOwner {

318:     function batchUpdateAllocPoint(address[] calldata _tokens, uint256[] calldata _allocPoints) external onlyOwner {

342:     function setRewardsPerSecond(uint256 _rewardsPerSecond, bool _persist) external onlyOwner {

397:     ) external onlyOwner {

430:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

581:     function setContractAuthorization(address _address, bool _authorize) external onlyOwner {

909:     function setEndingTimeUpdateCadence(uint256 _lapse) external onlyOwner {

920:     function registerRewardDeposit(uint256 _amount) external onlyOwner {

966:     function pause() external onlyOwner {

973:     function unpause() external onlyOwner {

1005:     function setAddressWLstatus(address user, bool status) external onlyOwner {

1012:     function toggleWhitelist() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/ChefIncentivesController.sol)

```solidity
File: src/reward/EligibilityDataProvider.sol

118:     function setChefIncentivesController(IChefIncentivesController _chef) external onlyOwner {

127:     function setLPToken(address _lpToken) external onlyOwner {

139:     function setRequiredDepositRatio(uint256 _requiredDepositRatio) external onlyOwner {

150:     function setPriceToleranceRatio(uint256 _priceToleranceRatio) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/EligibilityDataProvider.sol)

```solidity
File: src/reward/MultiFeeDistribution.sol

266:     function setMinters(address[] calldata minters_) external onlyOwner {

282:     function setBountyManager(address bounty) external onlyOwner {

293:     function addRewardConverter(address rewardConverter_) external onlyOwner {

304:     function setLockTypeInfo(uint256[] calldata lockPeriod_, uint256[] calldata rewardMultipliers_) external onlyOwner {

324:     function setAddresses(IChefIncentivesController controller_, address treasury_) external onlyOwner {

336:     function setLPToken(address stakingToken_) external onlyOwner {

452:     function setLookback(uint256 lookback) external onlyOwner {

467:     ) external onlyOwner {

770:     function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

873:     function pause() public onlyOwner {

880:     function unpause() public onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/reward/MultiFeeDistribution.sol)

```solidity
File: src/utils/Pause.sol

12: abstract contract Pause is AccessControl, Pausable, IPause {

30:     function pause() external onlyRole(PAUSER_ROLE) {

36:     function unpause() external onlyRole(PAUSER_ROLE) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/utils/Pause.sol)

```solidity
File: src/vendor/AuraVault.sol

26: contract AuraVault is IERC4626, ERC4626, AccessControl {

145:     function setParameter(bytes32 parameter, uint256 data) external onlyRole(VAULT_CONFIG_ROLE) {

156:     ) public onlyRole(VAULT_ADMIN_ROLE) returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="M-4"></a>[M-4] Chainlink's `latestRoundData` might return stale or incorrect results

- This is a common issue: <https://github.com/code-423n4/2022-12-tigris-findings/issues/655>, <https://code4rena.com/reports/2022-10-inverse#m-17-chainlink-oracle-data-feed-is-not-sufficiently-validated-and-can-return-stale-price>, <https://app.sherlock.xyz/audits/contests/41#issue-m-12-chainlinks-latestrounddata--return-stale-or-incorrect-result> and many more occurrences.

`latestRoundData()` is used to fetch the asset price from a Chainlink aggregator, but it's missing additional validations to ensure that the round is complete. If there is a problem with Chainlink starting a new round and finding consensus on the new value for the oracle (e.g. Chainlink nodes abandon the oracle, chain congestion, vulnerability/attacks on the Chainlink system) consumers of this contract may continue using outdated stale data / stale prices.

More bugs related to chainlink here: [Chainlink Oracle Security Considerations](https://medium.com/cyfrin/chainlink-oracle-defi-attacks-93b6cb6541bf#99af)

*Instances (1)*:

```solidity
File: src/vendor/AuraVault.sol

383:         (, int256 answer, , , ) = AggregatorV3Interface(ETH_CHAINLINK_FEED).latestRoundData();
             ethPrice = wdiv(uint256(answer), ETH_CHAINLINK_DECIMALS);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="M-5"></a>[M-5] Missing checks for whether the L2 Sequencer is active

Chainlink recommends that users using price oracles, check whether the Arbitrum Sequencer is [active](https://docs.chain.link/data-feeds/l2-sequencer-feeds#arbitrum). If the sequencer goes down, the Chainlink oracles will have stale prices from before the downtime, until a new L2 OCR transaction goes through. Users who submit their transactions via the [L1 Dealyed Inbox](https://developer.arbitrum.io/tx-lifecycle#1b--or-from-l1-via-the-delayed-inbox) will be able to take advantage of these stale prices. Use a [Chainlink oracle](https://blog.chain.link/how-to-use-chainlink-price-feeds-on-arbitrum/#almost_done!_meet_the_l2_sequencer_health_flag) to determine whether the sequencer is offline or not, and don't allow operations to take place while the sequencer is offline.

*Instances (1)*:

```solidity
File: src/vendor/AuraVault.sol

383:         (, int256 answer, , , ) = AggregatorV3Interface(ETH_CHAINLINK_FEED).latestRoundData();
             ethPrice = wdiv(uint256(answer), ETH_CHAINLINK_DECIMALS);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/vendor/AuraVault.sol)

### <a name="M-6"></a>[M-6] Return values of `transfer()`/`transferFrom()` not checked

Not all `IERC20` implementations `revert()` when there's a failure in `transfer()`/`transferFrom()`. The function signature has a `boolean` return value and they indicate errors that way instead. By not checking the return value, operations that should have marked as failed, may potentially go through without actually making a payment

*Instances (2)*:

```solidity
File: src/Flashlender.sol

105:         underlyingToken.transferFrom(address(receiver), address(pool), total);

133:         underlyingToken.transferFrom(address(receiver), address(pool), total);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)

### <a name="M-7"></a>[M-7] Unsafe use of `transfer()`/`transferFrom()` with `IERC20`

Some tokens do not implement the ERC20 standard properly but are still accepted by most code that accepts ERC20 tokens.  For example Tether (USDT)'s `transfer()` and `transferFrom()` functions on L1 do not return booleans as the specification requires, and instead have no return value. When these sorts of tokens are cast to `IERC20`, their [function signatures](https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca) do not match and therefore the calls made, revert (see [this](https://gist.github.com/IllIllI000/2b00a32e8f0559e8f386ea4f1800abc5) link for a test case). Use OpenZeppelin's `SafeERC20`'s `safeTransfer()`/`safeTransferFrom()` instead

*Instances (2)*:

```solidity
File: src/Flashlender.sol

105:         underlyingToken.transferFrom(address(receiver), address(pool), total);

133:         underlyingToken.transferFrom(address(receiver), address(pool), total);

```

[Link to code](https://github.com/code-423n4/2024-07-loopfi/blob/main/src/Flashlender.sol)
