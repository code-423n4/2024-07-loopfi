// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

import {IPause} from "../interfaces/IPause.sol";

// Authenticated Roles
bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

abstract contract Pause is AccessControl, Pausable, IPause {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public pausedAt;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _pause() internal override {
        super._pause();
        pausedAt = block.timestamp;
    }

    /// @notice Pauses the contract
    /// @dev Sender has to be allowed to call this method
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpauses the contract
    /// @dev Sender has to be allowed to call this method
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
        pausedAt = 0;
    }
}
