// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import {IPRBProxyPlugin} from "prb-proxy/interfaces/IPRBProxyPlugin.sol";

/// @title PRBProxyERCPlugin
/// @notice Plugin that implements ERC1155 and ERC721 support for the proxy
contract ERC165Plugin is ERC1155Holder, ERC721Holder, IPRBProxyPlugin {
    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the list of function signatures of the methods that enable ERC1155 and ERC721 support
    /// @return methods The list of function signatures
    function getMethods() external pure returns (bytes4[] memory methods) {
        methods = new bytes4[](3);
        methods[0] = this.onERC1155Received.selector;
        methods[1] = this.onERC1155BatchReceived.selector;
        methods[2] = this.onERC721Received.selector;
    }
}
