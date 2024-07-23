// SPDX-License-Identifier: BUSL-1.1
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Foundation, 2023.
pragma solidity ^0.8.17;
pragma abicoder v1;

// INTERFACES
import {IGaugeV3, QuotaRateParams, UserVotes} from "@gearbox-protocol/core-v3/contracts/interfaces/IGaugeV3.sol";
import {IGearStakingV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IGearStakingV3.sol";
import {IPoolQuotaKeeperV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolQuotaKeeperV3.sol";
import {IPoolV3} from "@gearbox-protocol/core-v3/contracts/interfaces/IPoolV3.sol";

// TRAITS
import {ACLNonReentrantTrait} from "@gearbox-protocol/core-v3/contracts/traits/ACLNonReentrantTrait.sol";

// EXCEPTIONS
import {CallerNotVoterException, IncorrectParameterException, TokenNotAllowedException, InsufficientVotesException} from "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

/// @title Gauge V3
/// @notice In Gearbox V3, quota rates are determined by GEAR holders that vote to move the rate within a given range.
///         While there are notable mechanic differences, the overall idea of token holders controlling strategy yield
///         is similar to the Curve's gauge system, and thus the contract carries the same name.
///         For each token, there are two parameters: minimum rate determined by the risk committee, and maximum rate
///         determined by the Gearbox DAO. GEAR holders then vote either for CA side, which moves the rate towards min,
///         or for LP side, which moves it towards max.
///         Rates are only updated once per epoch (1 week), to avoid manipulation and make strategies more predictable.
contract GaugeV3 is IGaugeV3, ACLNonReentrantTrait {
    /// @notice Contract version
    uint256 public constant override version = 3_00;

    /// @notice Address of the pool this gauge is connected to
    address public immutable override pool;

    /// @notice Mapping from token address to its rate parameters
    mapping(address => QuotaRateParams) public override quotaRateParams;

    /// @notice Mapping from (user, token) to vote amounts submitted by `user` for each side
    mapping(address => mapping(address => UserVotes)) public override userTokenVotes;

    /// @notice GEAR staking and voting contract
    address public immutable override voter;

    /// @notice Epoch when the rates were last updated
    uint16 public override epochLastUpdate;

    /// @notice Whether gauge is frozen and rates cannot be updated
    bool public override epochFrozen;

    /// @notice Constructor
    /// @param _pool Address of the lending pool
    /// @param _voter Address of the voter contract
    constructor(
        address _pool,
        address _voter
    )
        ACLNonReentrantTrait(IPoolV3(_pool).addressProvider())
        nonZeroAddress(_voter) // U:[GA-01]
    {
        pool = _pool; // U:[GA-01]
        voter = _voter; // U:[GA-01]
        epochLastUpdate = IGearStakingV3(_voter).getCurrentEpoch(); // U:[GA-01]
        epochFrozen = true; // U:[GA-01]
        emit SetFrozenEpoch(true); // U:[GA-01]
    }

    /// @dev Ensures that function caller is voter
    modifier onlyVoter() {
        _revertIfCallerNotVoter(); // U:[GA-02]
        _;
    }

    /// @notice Updates the epoch and, unless frozen, rates in the quota keeper
    function updateEpoch() external override {
        _checkAndUpdateEpoch(); // U:[GA-14]
    }

    /// @dev Implementation of `updateEpoch`
    function _checkAndUpdateEpoch() internal {
        uint16 epochNow = IGearStakingV3(voter).getCurrentEpoch(); // U:[GA-14]

        if (epochNow > epochLastUpdate) {
            epochLastUpdate = epochNow; // U:[GA-14]

            if (!epochFrozen) {
                // The quota keeper should call back to retrieve quota rates for needed tokens
                _poolQuotaKeeper().updateRates(); // U:[GA-14]
            }

            emit UpdateEpoch(epochNow); // U:[GA-14]
        }
    }

    /// @notice Computes rates for an array of tokens based on the current votes
    /// @dev Actual rates can be different since they are only updated once per epoch
    /// @param tokens Array of tokens to computes rates for
    /// @return rates Array of rates, in the same order as passed tokens
    function getRates(address[] calldata tokens) external view override returns (uint16[] memory rates) {
        uint256 len = tokens.length; // U:[GA-15]
        rates = new uint16[](len); // U:[GA-15]

        unchecked {
            for (uint256 i; i < len; ++i) {
                address token = tokens[i]; // U:[GA-15]

                if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-15]

                QuotaRateParams memory qrp = quotaRateParams[token]; // U:[GA-15]

                uint96 votesLpSide = qrp.totalVotesLpSide; // U:[GA-15]
                uint96 votesCaSide = qrp.totalVotesCaSide; // U:[GA-15]
                uint256 totalVotes = votesLpSide + votesCaSide; // U:[GA-15]

                rates[i] = totalVotes == 0
                    ? qrp.minRate
                    : uint16((uint256(qrp.minRate) * votesCaSide + uint256(qrp.maxRate) * votesLpSide) / totalVotes); // U:[GA-15]
            }
        }
    }

    /// @notice Submits user's votes for the provided token and side and updates the epoch if necessary
    /// @param user The user that submitted votes
    /// @param votes Amount of votes to add
    /// @param extraData Gauge specific parameters (encoded into `extraData` to adhere to the voting contract interface)
    ///        * token - address of the token to vote for
    ///        * lpSide - whether the side to add votes for is the LP side
    function vote(
        address user,
        uint96 votes,
        bytes calldata extraData
    )
        external
        override
        onlyVoter // U:[GA-02]
    {
        (address token, bool lpSide) = abi.decode(extraData, (address, bool)); // U:[GA-10,11,12]
        _vote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-10,11,12]
    }

    /// @dev Implementation of `vote`
    /// @param user User to add votes to
    /// @param votes Amount of votes to add
    /// @param token Token to add votes for
    /// @param lpSide Side to add votes for: `true` for LP side, `false` for CA side
    function _vote(address user, uint96 votes, address token, bool lpSide) internal {
        if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

        _checkAndUpdateEpoch(); // U:[GA-11]

        QuotaRateParams storage qp = quotaRateParams[token]; // U:[GA-12]
        UserVotes storage uv = userTokenVotes[user][token];

        if (lpSide) {
            qp.totalVotesLpSide += votes; // U:[GA-12]
            uv.votesLpSide += votes; // U:[GA-12]
        } else {
            qp.totalVotesCaSide += votes; // U:[GA-12]
            uv.votesCaSide += votes; // U:[GA-12]
        }

        emit Vote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-12]
    }

    /// @notice Removes user's existing votes for the provided token and side and updates the epoch if necessary
    /// @param user The user that submitted votes
    /// @param votes Amount of votes to remove
    /// @param extraData Gauge specific parameters (encoded into `extraData` to adhere to the voting contract interface)
    ///        * token - address of the token to unvote for
    ///        * lpSide - whether the side to remove votes for is the LP side
    function unvote(
        address user,
        uint96 votes,
        bytes calldata extraData
    )
        external
        override
        onlyVoter // U:[GA-02]
    {
        (address token, bool lpSide) = abi.decode(extraData, (address, bool)); // U:[GA-10,11,13]
        _unvote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-10,11,13]
    }

    /// @dev Implementation of `unvote`
    /// @param user User to remove votes from
    /// @param votes Amount of votes to remove
    /// @param token Token to remove votes from
    /// @param lpSide Side to remove votes from: `true` for LP side, `false` for CA side
    function _unvote(address user, uint96 votes, address token, bool lpSide) internal {
        if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-10]

        _checkAndUpdateEpoch(); // U:[GA-11]

        QuotaRateParams storage qp = quotaRateParams[token]; // U:[GA-13]
        UserVotes storage uv = userTokenVotes[user][token]; // U:[GA-13]

        if (lpSide) {
            if (uv.votesLpSide < votes) revert InsufficientVotesException();
            unchecked {
                qp.totalVotesLpSide -= votes; // U:[GA-13]
                uv.votesLpSide -= votes; // U:[GA-13]
            }
        } else {
            if (uv.votesCaSide < votes) revert InsufficientVotesException();
            unchecked {
                qp.totalVotesCaSide -= votes; // U:[GA-13]
                uv.votesCaSide -= votes; // U:[GA-13]
            }
        }

        emit Unvote({user: user, token: token, votes: votes, lpSide: lpSide}); // U:[GA-13]
    }

    // ------------- //
    // CONFIGURATION //
    // ------------- //

    /// @notice Sets the frozen epoch status
    /// @param status The new status
    /// @dev The epoch can be frozen to prevent rate updates during gauge/staking contracts migration
    function setFrozenEpoch(bool status) external override configuratorOnly {
        if (status != epochFrozen) {
            epochFrozen = status;

            emit SetFrozenEpoch(status);
        }
    }

    /// @notice Adds a new quoted token to the gauge and sets the initial rate params
    ///         If token is not added to the quota keeper, adds it there as well
    /// @param token Address of the token to add
    /// @param minRate The minimal interest rate paid on token's quotas
    /// @param maxRate The maximal interest rate paid on token's quotas
    function addQuotaToken(
        address token,
        uint16 minRate,
        uint16 maxRate
    )
        external
        override
        nonZeroAddress(token) // U:[GA-04]
        configuratorOnly // U:[GA-03]
    {
        if (isTokenAdded(token) || token == IPoolV3(pool).underlyingToken()) {
            revert TokenNotAllowedException(); // U:[GA-04]
        }
        _checkParams({minRate: minRate, maxRate: maxRate}); // U:[GA-04]

        quotaRateParams[token] = QuotaRateParams({
            minRate: minRate,
            maxRate: maxRate,
            totalVotesLpSide: 0,
            totalVotesCaSide: 0
        }); // U:[GA-05]

        IPoolQuotaKeeperV3 quotaKeeper = _poolQuotaKeeper();
        if (!quotaKeeper.isQuotedToken(token)) {
            quotaKeeper.addQuotaToken({token: token}); // U:[GA-05]
        }

        emit AddQuotaToken({token: token, minRate: minRate, maxRate: maxRate}); // U:[GA-05]
    }

    /// @dev Changes the min rate for a quoted token
    /// @param minRate The minimal interest rate paid on token's quotas
    function changeQuotaMinRate(
        address token,
        uint16 minRate
    )
        external
        override
        nonZeroAddress(token) // U: [GA-04]
        controllerOnly // U: [GA-03]
    {
        _changeQuotaTokenRateParams(token, minRate, quotaRateParams[token].maxRate);
    }

    /// @dev Changes the max rate for a quoted token
    /// @param maxRate The maximal interest rate paid on token's quotas
    function changeQuotaMaxRate(
        address token,
        uint16 maxRate
    )
        external
        override
        nonZeroAddress(token) // U: [GA-04]
        controllerOnly // U: [GA-03]
    {
        _changeQuotaTokenRateParams(token, quotaRateParams[token].minRate, maxRate);
    }

    /// @dev Implementation of `changeQuotaTokenRateParams`
    function _changeQuotaTokenRateParams(address token, uint16 minRate, uint16 maxRate) internal {
        if (!isTokenAdded(token)) revert TokenNotAllowedException(); // U:[GA-06A, GA-06B]

        _checkParams(minRate, maxRate); // U:[GA-04]

        QuotaRateParams storage qrp = quotaRateParams[token]; // U:[GA-06A, GA-06B]
        if (minRate == qrp.minRate && maxRate == qrp.maxRate) return;
        qrp.minRate = minRate; // U:[GA-06A, GA-06B]
        qrp.maxRate = maxRate; // U:[GA-06A, GA-06B]

        emit SetQuotaTokenParams({token: token, minRate: minRate, maxRate: maxRate}); // U:[GA-06A, GA-06B]
    }

    /// @dev Checks that given min and max rate are correct (`0 < minRate <= maxRate`)
    function _checkParams(uint16 minRate, uint16 maxRate) internal pure {
        if (minRate == 0 || minRate > maxRate) {
            revert IncorrectParameterException(); // U:[GA-04]
        }
    }

    /// @notice Whether token is added to the gauge as quoted
    function isTokenAdded(address token) public view override returns (bool) {
        return quotaRateParams[token].maxRate != 0; // U:[GA-08]
    }

    /// @dev Returns quota keeper connected to the pool
    function _poolQuotaKeeper() internal view returns (IPoolQuotaKeeperV3) {
        return IPoolQuotaKeeperV3(IPoolV3(pool).poolQuotaKeeper());
    }

    /// @dev Reverts if `msg.sender` is not voter
    function _revertIfCallerNotVoter() internal view {
        if (msg.sender != voter) {
            revert CallerNotVoterException(); // U:[GA-02]
        }
    }
}
