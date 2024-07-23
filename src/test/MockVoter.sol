// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract MockVoter {
    //uint16 public getCurrentEpoch;
    uint256 constant EPOCH_LENGTH = 7 days;
    uint256 public firstEpochTimestamp;

    // function setCurrentEpoch(uint16 epoch) external {
    //     getCurrentEpoch = epoch;
    // }

    function setFirstEpochTimestamp(uint256 timestamp) external {
        firstEpochTimestamp = timestamp;
    }

    /// @notice Returns the current global voting epoch
    function getCurrentEpoch() public view returns (uint16) {
        if (block.timestamp < firstEpochTimestamp) return 0; // U:[GS-01]
        unchecked {
            return uint16((block.timestamp - firstEpochTimestamp) / EPOCH_LENGTH) + 1; // U:[GS-01]
        }
    }
}
