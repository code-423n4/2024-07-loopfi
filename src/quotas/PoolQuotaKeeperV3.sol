// SPDX-License-Identifier: BUSL-1.1
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Foundation, 2023.
pragma solidity ^0.8.17;
pragma abicoder v1;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// LIBS & TRAITS
import {ACLNonReentrantTrait} from "@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol";
import {ContractsRegisterTrait} from "@gearbox-protocol/core-v3/contracts/traits/ContractsRegisterTrait.sol";
import {QuotasLogic} from "@gearbox-protocol/core-v3/contracts/libraries/QuotasLogic.sol";

import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";
import {IPoolQuotaKeeperV3, TokenQuotaParams, AccountQuota} from "src/interfaces/IPoolQuotaKeeperV3.sol";
import {IGaugeV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IGaugeV3.sol";
import {ICreditManagerV3} from "@gearbox-protocol/core-v3/contracts/interfaces/ICreditManagerV3.sol";

import {PERCENTAGE_FACTOR, RAY} from "@gearbox-protocol/core-v2/contracts/libraries/Constants.sol";

// EXCEPTIONS
import "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

/// @title Pool quota keeper V3
/// @notice In Gearbox V3, quotas are used to limit the system exposure to risky assets.
///         In order for a risky token to be counted towards credit account's collateral, account owner must "purchase"
///         a quota for this token, which entails two kinds of payments:
///         * interest that accrues over time with rates determined by the gauge (more suited to leveraged farming), and
///         * increase fee that is charged when additional quota is purchased (more suited to leveraged trading).
///         Quota keeper stores information about quotas of accounts in all credit managers connected to the pool, and
///         performs calculations that help to keep pool's expected liquidity and credit managers' debt consistent.
contract PoolQuotaKeeperV3 is IPoolQuotaKeeperV3, ACLNonReentrantTrait, ContractsRegisterTrait {
    using EnumerableSet for EnumerableSet.AddressSet;
    using QuotasLogic for TokenQuotaParams;

    /// @notice Contract version
    uint256 public constant override version = 3_00;

    /// @notice Address of the underlying token
    address public immutable override underlying;

    /// @notice Address of the pool
    address public immutable override pool;

    // /// @dev The list of all allowed credit managers
    // EnumerableSet.AddressSet internal creditManagerSet;

    /// @dev The list of all quoted tokens
    EnumerableSet.AddressSet internal quotaTokensSet;

    /// @notice Mapping from token to global token quota params
    mapping(address => TokenQuotaParams) internal totalQuotaParams;

    /// @dev Mapping from (creditAccount, token) to account's token quota params
    // mapping(address => mapping(address => AccountQuota)) internal accountQuotas;

    /// @notice Address of the gauge
    address public override gauge;

    /// @notice Timestamp of the last quota rates update
    uint40 public override lastQuotaRateUpdate;
    /// @notice token => vault (credit manager) mapping
    mapping(address => address) public creditManagers;

    /// @dev Ensures that function caller is gauge
    modifier gaugeOnly() {
        _revertIfCallerNotGauge();
        _;
    }

    // /// @dev Ensures that function caller is an allowed credit manager
    // modifier creditManagerOnly() {
    //     _revertIfCallerNotCreditManager();
    //     _;
    // }

    /// @notice Constructor
    /// @param _pool Pool address
    constructor(
        address _pool
    ) ACLNonReentrantTrait(IPoolV3(_pool).addressProvider()) ContractsRegisterTrait(IPoolV3(_pool).addressProvider()) {
        pool = _pool; // U:[PQK-1]
        underlying = IPoolV3(_pool).asset(); // U:[PQK-1]
    }

    /// @notice Returns current quota interest index for a token in ray
    function cumulativeIndex(address token) public view override returns (uint192) {
        TokenQuotaParams storage tokenQuotaParams = totalQuotaParams[token];
        (uint16 rate, uint192 tqCumulativeIndexLU, ) = _getTokenQuotaParamsOrRevert(tokenQuotaParams);

        return QuotasLogic.cumulativeIndexSince(tqCumulativeIndexLU, rate, lastQuotaRateUpdate);
    }

    /// @notice Returns quota interest rate for a token in bps
    function getQuotaRate(address token) external view override returns (uint16) {
        return totalQuotaParams[token].rate;
    }

    /// @notice Returns an array of all quoted tokens
    function quotedTokens() external view override returns (address[] memory) {
        return quotaTokensSet.values();
    }

    /// @notice Whether a token is quoted
    function isQuotedToken(address token) external view override returns (bool) {
        return quotaTokensSet.contains(token);
    }

    /// @notice Returns global quota params for a token
    function getTokenQuotaParams(
        address token
    )
        external
        view
        override
        returns (
            uint16 rate,
            uint192 cumulativeIndexLU,
            uint16 quotaIncreaseFee,
            uint96 totalQuoted,
            uint96 limit,
            bool isActive
        )
    {
        TokenQuotaParams memory tq = totalQuotaParams[token];
        rate = tq.rate;
        cumulativeIndexLU = tq.cumulativeIndexLU;
        quotaIncreaseFee = tq.quotaIncreaseFee;
        totalQuoted = tq.totalQuoted;
        limit = tq.limit;
        isActive = rate != 0;
    }

    /// @notice Returns the pool's quota revenue (in units of underlying per year)
    function poolQuotaRevenue() external view virtual override returns (uint256 quotaRevenue) {
        address[] memory tokens = quotaTokensSet.values();

        uint256 len = tokens.length;

        for (uint256 i; i < len; ) {
            address token = tokens[i];

            TokenQuotaParams storage tokenQuotaParams = totalQuotaParams[token];
            (uint16 rate, , ) = _getTokenQuotaParamsOrRevert(tokenQuotaParams);
            //(uint256 totalQuoted, ) = _getTokenQuotaTotalAndLimit(tokenQuotaParams);

            quotaRevenue += (IPoolV3(pool).creditManagerBorrowed(creditManagers[token]) * rate) / PERCENTAGE_FACTOR;

            unchecked {
                ++i;
            }
        }
    }

    // ------------- //
    // CONFIGURATION //
    // ------------- //

    /// @notice Adds a new quota token
    /// @param token Address of the token
    function addQuotaToken(
        address token
    )
        external
        override
        gaugeOnly // U:[PQK-3]
    {
        if (quotaTokensSet.contains(token)) {
            revert TokenAlreadyAddedException(); // U:[PQK-6]
        }

        // The rate will be set during a general epoch update in the gauge
        quotaTokensSet.add(token); // U:[PQK-5]
        totalQuotaParams[token].cumulativeIndexLU = 1; // U:[PQK-5]

        emit AddQuotaToken(token); // U:[PQK-5]
    }

    /// @notice Updates quota rates
    ///         - Updates global token cumulative indexes before changing rates
    ///         - Queries new rates for all quoted tokens from the gauge
    ///         - Sets new pool quota revenue
    function updateRates()
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
    }

    /// @notice Sets a new gauge contract to compute quota rates
    /// @param _gauge Address of the new gauge contract
    function setGauge(
        address _gauge
    )
        external
        override
        configuratorOnly // U:[PQK-2]
    {
        if (gauge != _gauge) {
            gauge = _gauge; // U:[PQK-8]
            emit SetGauge(_gauge); // U:[PQK-8]
        }
    }

    function setCreditManager(
        address token,
        address vault
    )
        external
        override
        configuratorOnly // U:[PQK-2]
    {
        creditManagers[token] = vault;
    }

    // --------- //
    // INTERNALS //
    // --------- //

    /// @dev Whether quota params for token are initialized
    function isInitialised(TokenQuotaParams storage tokenQuotaParams) internal view returns (bool) {
        return tokenQuotaParams.cumulativeIndexLU != 0;
    }

    /// @dev Efficiently loads quota params of a token from storage
    function _getTokenQuotaParamsOrRevert(
        TokenQuotaParams storage tokenQuotaParams
    ) internal view returns (uint16 rate, uint192 cumulativeIndexLU, uint16 quotaIncreaseFee) {
        // rate = tokenQuotaParams.rate;
        // cumulativeIndexLU = tokenQuotaParams.cumulativeIndexLU;
        // quotaIncreaseFee = tokenQuotaParams.quotaIncreaseFee;
        assembly {
            let data := sload(tokenQuotaParams.slot)
            rate := and(data, 0xFFFF)
            cumulativeIndexLU := and(shr(16, data), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            quotaIncreaseFee := shr(208, data)
        }

        if (cumulativeIndexLU == 0) {
            revert TokenIsNotQuotedException(); // U:[PQK-14]
        }
    }

    /// @dev Reverts if `msg.sender` is not gauge
    function _revertIfCallerNotGauge() internal view {
        if (msg.sender != gauge) revert CallerNotGaugeException(); // U:[PQK-3]
    }
}
