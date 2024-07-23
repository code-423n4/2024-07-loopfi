// SPDX-License-Identifier: UNLICENSED
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Foundation, 2023.
pragma solidity ^0.8.17;

import {IPoolQuotaKeeperV3, TokenQuotaParams, AccountQuota} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol";

contract PoolQuotaKeeperMock is IPoolQuotaKeeperV3 {
    uint256 public constant override version = 3_00;

    /// @dev Address provider
    address public immutable underlying;

    /// @dev Address of the protocol treasury
    address public immutable override pool;

    /// @dev Mapping from token address to its respective quota parameters
    TokenQuotaParams public totalQuotaParam;

    /// @dev Mapping from creditAccount => token > quota parameters
    AccountQuota public accountQuota;

    /// @dev Address of the gauge that determines quota rates
    address public gauge;

    /// @dev Timestamp of the last time quota rates were batch-updated
    uint40 public lastQuotaRateUpdate;

    /// MOCK functionality
    address public call_creditAccount;
    address public call_token;
    int96 public call_quotaChange;
    address[] public call_tokens;
    bool public call_setLimitsToZero;

    ///
    uint128 internal return_caQuotaInterestChange;
    bool internal return_enableToken;
    bool internal return_disableToken;

    uint256 internal return_quoted;
    uint256 internal return_interest;
    bool internal return_isQuotedToken;

    mapping(address => uint96) internal _quoted;
    mapping(address => uint128) internal _outstandingInterest;

    constructor(address _pool, address _underlying) {
        pool = _pool;
        underlying = _underlying;
    }

    function updateQuota(
        address,
        address,
        int96,
        uint96,
        uint96
    ) external view returns (uint128 caQuotaInterestChange, uint128 fees, bool enableToken, bool disableToken) {
        caQuotaInterestChange = return_caQuotaInterestChange;
        fees = 0;
        enableToken = return_enableToken;
        disableToken = return_disableToken;
    }

    function setUpdateQuotaReturns(uint128 caQuotaInterestChange, bool enableToken, bool disableToken) external {
        return_caQuotaInterestChange = caQuotaInterestChange;
        return_enableToken = enableToken;
        return_disableToken = disableToken;
    }

    /// @dev Updates all quotas to zero when closing a credit account, and computes the final quota interest change
    /// @param creditAccount Address of the Credit Account being closed
    /// @param tokens Array of all active quoted tokens on the account
    function removeQuotas(address creditAccount, address[] memory tokens, bool setLimitsToZero) external {
        call_creditAccount = creditAccount;
        call_tokens = tokens;
        call_setLimitsToZero = setLimitsToZero;
    }

    /// @dev Computes the accrued quota interest and updates interest indexes
    /// @param creditAccount Address of the Credit Account to accrue interest for
    /// @param tokens Array of all active quoted tokens on the account
    function accrueQuotaInterest(address creditAccount, address[] memory tokens) external {}

    /// @dev Gauge management

    /// @dev Registers a new quoted token in the keeper
    function addQuotaToken(address token) external {}

    /// @dev Batch updates the quota rates and changes the combined quota revenue
    function updateRates() external {}

    function setQuotaAndOutstandingInterest(address token, uint96 quoted, uint128 outstandingInterest) external {
        _quoted[token] = quoted;
        _outstandingInterest[token] = outstandingInterest;
    }

    /// GETTERS
    function getQuotaAndOutstandingInterest(
        address,
        address token
    ) external view override returns (uint96 quoted, uint128 interest) {
        quoted = _quoted[token];
        interest = _outstandingInterest[token];
    }

    /// @dev Returns cumulative index in RAY for a quoted token. Returns 0 for non-quoted tokens.
    function cumulativeIndex(address token) public view override returns (uint192) {
        //        return totalQuotaParams[token].cumulativeIndexSince(lastQuotaRateUpdate);
    }

    /// @dev Returns quota rate in PERCENTAGE FORMAT
    function getQuotaRate(address) external view override returns (uint16) {
        return totalQuotaParam.rate;
    }

    /// @dev Returns an array of all quoted tokens
    function quotedTokens() external view override returns (address[] memory) {
        //        return quotaTokensSet.values();
    }

    /// @dev Returns whether a token is quoted
    function isQuotedToken(address) external view override returns (bool) {
        return return_isQuotedToken;
    }

    /// @dev Returns quota parameters for a single (account, token) pair
    function getQuota(address, address) external view returns (uint96 quota, uint192 cumulativeIndexLU) {
        AccountQuota storage aq = accountQuota;
        return (aq.quota, aq.cumulativeIndexLU);
    }

    /// @notice Returns the current annual quota revenue to the pool
    function poolQuotaRevenue() external view virtual override returns (uint256 quotaRevenue) {
        return 0;
    }

    function getTokenQuotaParams(
        address
    )
        external
        pure
        returns (
            uint16 rate,
            uint192 cumulativeIndexLU,
            uint16 quotaIncreaseFee,
            uint96 totalQuoted,
            uint96 limit,
            bool isActive
        )
    {
        return (0, 0, 0, 0, 0, false);
    }

    function addCreditManager(address _creditManager) external {}

    function creditManagers() external view returns (address[] memory) {}

    function setGauge(address _gauge) external {}

    function setTokenLimit(address token, uint96 limit) external {}

    function setTokenQuotaIncreaseFee(address token, uint16 fee) external {}
}
