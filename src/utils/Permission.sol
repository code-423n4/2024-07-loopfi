// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IPermission.sol";

abstract contract Permission is IPermission {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event ModifyPermission(address authorizer, address owner, address caller, bool grant);
    event SetPermittedAgent(address owner, address agent, bool grant);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Permission__modifyPermission_notPermitted();

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    // User Permissions
    /// @notice Map specifying whether a `caller` has the permission to perform an action on the `owner`'s behalf
    mapping(address owner => mapping(address caller => bool permitted)) private _permitted;

    /// @notice Map specifying whether an `agent` has the permission to modify the permissions of the `owner`
    mapping(address owner => mapping(address manager => bool permitted)) private _permittedAgents;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Gives or revokes the permission for `caller` to perform an action on behalf of `msg.sender`
    /// @param caller Address of the caller to grant or revoke permission for
    /// @param permitted Whether to grant or revoke permission
    function modifyPermission(address caller, bool permitted) external {
        _permitted[msg.sender][caller] = permitted;
        emit ModifyPermission(msg.sender, msg.sender, caller, permitted);
    }

    /// @notice Gives or revokes the permission for `caller` to perform an action on behalf of `owner`
    /// @param owner Address of the owner
    /// @param caller Address of the caller to grant or revoke permission for
    /// @param permitted Whether to grant or revoke permission
    function modifyPermission(address owner, address caller, bool permitted) external {
        if (owner != msg.sender && !_permittedAgents[owner][msg.sender])
            revert Permission__modifyPermission_notPermitted();
        _permitted[owner][caller] = permitted;
        emit ModifyPermission(msg.sender, owner, caller, permitted);
    }

    /// @notice Gives or revokes the permission for the `agent` to modify the permissions of `msg.sender`
    /// @param agent Address of the agent to grant or revoke permission for
    /// @param permitted Whether to grant or revoke permission
    function setPermissionAgent(address agent, bool permitted) external {
        _permittedAgents[msg.sender][agent] = permitted;
        emit SetPermittedAgent(msg.sender, agent, permitted);
    }

    /// @notice Checks if `caller` has the permission to perform an action on behalf of `owner`
    /// @param owner Address of the owner
    /// @param caller Address of the caller
    /// @return _ whether `caller` has the permission
    function hasPermission(address owner, address caller) public view returns (bool) {
        return owner == caller || _permitted[owner][caller];
    }
}
