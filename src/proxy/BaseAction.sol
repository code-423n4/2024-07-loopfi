// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract BaseAction {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Action__revertBytes_emptyRevertBytes();

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Delegatecalls the provided data to the provided address
    /// @param to Address to delegatecall
    /// @param data Data to pass in delegatecall
    /// @return returnData Return data from the delegatecall
    /// @dev Reverts if the call fails
    function _delegateCall(address to, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = to.delegatecall(data);
        if (!success) _revertBytes(returnData);
        return returnData;
    }

    /// @notice Reverts with the provided error message
    /// @dev if errMsg is empty, reverts with a default error message
    /// @param errMsg Error message to revert with.
    function _revertBytes(bytes memory errMsg) internal pure {
        if (errMsg.length != 0) {
            assembly {
                revert(add(32, errMsg), mload(errMsg))
            }
        }
        revert Action__revertBytes_emptyRevertBytes();
    }
}
