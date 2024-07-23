// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

interface IInterestRateModel {
    function getIRS() external view returns (int64, uint64, uint64, uint64, uint256);

    function getAccruedInterest() external view returns (uint256 accruedInterest);

    function virtualRateAccumulator() external view returns (uint64 rateAccumulator);
}
