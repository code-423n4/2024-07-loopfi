// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import {IPRBProxy} from "prb-proxy/interfaces/IPRBProxy.sol";
import {IPRBProxyRegistry} from "prb-proxy/interfaces/IPRBProxyRegistry.sol";
import {IPRBProxyPlugin} from "prb-proxy/interfaces/IPRBProxyPlugin.sol";
import {PRBProxy} from "prb-proxy/PRBProxy.sol";
import {PRBProxyRegistry} from "prb-proxy/PRBProxyRegistry.sol";

import {ERC165Plugin} from "../../proxy/ERC165Plugin.sol";

contract EmptyPlugin is IPRBProxyPlugin {
    function getMethods() external pure returns (bytes4[] memory) {}
}

contract ProxyTest is Test {
    PRBProxyRegistry public registry;
    EmptyPlugin public emptyPlugin;
    ERC165Plugin public erc165Plugin;

    function getNextProxyAddress(address owner) public view returns (address) {
        bytes32 creationBytecodeHash = keccak256(type(PRBProxy).creationCode);
        bytes32 salt = bytes32(abi.encodePacked(owner));
        return computeCreate2Address(salt, creationBytecodeHash, address(registry));
    }

    function setUp() public {
        registry = new PRBProxyRegistry();
        emptyPlugin = new EmptyPlugin();
        erc165Plugin = new ERC165Plugin();
    }

    function test_deployAndExecute() public {
        address precomputedAddress = getNextProxyAddress(address(this));
        address target = address(0x3);
        vm.mockCall(target, abi.encodeWithSignature("mockAction()"), abi.encodeWithSignature("mockAction()"));
        bytes memory deployData = abi.encodeWithSignature("mockAction()");
        IPRBProxy proxy = registry.deployAndExecute(target, deployData);
        assertEq(address(proxy), precomputedAddress);
    }

    function test_deployAndExecuteAndInstallPlugin_revertOnIncompletePlugin() public {
        address target = address(0x3);
        vm.mockCall(target, abi.encodeWithSignature("mockAction()"), abi.encodeWithSignature("mockAction()"));
        bytes memory deployData = abi.encodeWithSignature("mockAction()");
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxyRegistry.PRBProxyRegistry_PluginWithZeroMethods.selector,
                address(emptyPlugin)
            )
        );
        registry.deployAndExecuteAndInstallPlugin(target, deployData, emptyPlugin);
    }

    function test_plugin_onERC1155Received() public {
        address target = address(0x3);
        vm.mockCall(target, abi.encodeWithSignature("mockAction()"), abi.encodeWithSignature("mockAction()"));
        bytes memory deployData = abi.encodeWithSignature("mockAction()");
        IPRBProxy proxy = registry.deployAndExecuteAndInstallPlugin(target, deployData, erc165Plugin);

        // call the plugin function with dummy data
        (bool success, bytes memory result) = address(proxy).call(
            abi.encodeWithSelector(ERC1155Holder.onERC1155Received.selector, address(0), address(0), 0, 0, "")
        );

        assertTrue(success);
        assertEq(ERC1155Holder.onERC1155Received.selector, bytes4(result));
    }

    function test_plugin_onERC721Received() public {
        address target = address(0x3);
        vm.mockCall(target, abi.encodeWithSignature("mockAction()"), abi.encodeWithSignature("mockAction()"));
        bytes memory deployData = abi.encodeWithSignature("mockAction()");
        IPRBProxy proxy = registry.deployAndExecuteAndInstallPlugin(target, deployData, erc165Plugin);

        // call the plugin function with dummy data
        (bool success, bytes memory result) = address(proxy).call(
            abi.encodeWithSelector(ERC721Holder.onERC721Received.selector, address(0), address(0), 0, "")
        );

        assertTrue(success);
        assertEq(ERC721Holder.onERC721Received.selector, bytes4(result));
    }
}
