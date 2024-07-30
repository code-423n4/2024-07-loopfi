
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Vm} from 'forge-std/Vm.sol';

library ChainIds {
  uint256 internal constant MAINNET = 1;
  uint256 internal constant OPTIMISM = 10;
  uint256 internal constant BNB = 56;
  uint256 internal constant POLYGON = 137;
  uint256 internal constant FANTOM = 250;
  uint256 internal constant ZK_SYNC = 324;
  uint256 internal constant METIS = 1088;
  uint256 internal constant ZK_EVM = 1101;
  uint256 internal constant BASE = 8453;
  uint256 internal constant ARBITRUM = 42161;
  uint256 internal constant AVALANCHE = 43114;
  uint256 internal constant GNOSIS = 100;
  uint256 internal constant SCROLL = 534352;
  uint256 internal constant SEPOLIA = 11155111;
  uint256 internal constant HARMONY = 1666600000;
}

library ChainHelpers {
  error UnknownChainId();

  function selectChain(Vm vm, uint256 chainId) internal returns (uint256, uint256) {
    uint256 previousFork = vm.activeFork();
    if (chainId == block.chainid) return (previousFork, previousFork);
    uint256 newFork;
    if (chainId == ChainIds.MAINNET) {
      newFork = vm.createSelectFork(vm.rpcUrl('mainnet'));
    } else if (chainId == ChainIds.OPTIMISM) {
      newFork = vm.createSelectFork(vm.rpcUrl('optimism'));
    } else if (chainId == ChainIds.BNB) {
      newFork = vm.createSelectFork(vm.rpcUrl('bnb'));
    } else if (chainId == ChainIds.POLYGON) {
      newFork = vm.createSelectFork(vm.rpcUrl('polygon'));
    } else if (chainId == ChainIds.FANTOM) {
      newFork = vm.createSelectFork(vm.rpcUrl('fantom'));
    } else if (chainId == ChainIds.ZK_SYNC) {
      newFork = vm.createSelectFork(vm.rpcUrl('zkSync'));
    } else if (chainId == ChainIds.METIS) {
      newFork = vm.createSelectFork(vm.rpcUrl('metis'));
    } else if (chainId == ChainIds.ZK_EVM) {
      newFork = vm.createSelectFork(vm.rpcUrl('zkEvm'));
    } else if (chainId == ChainIds.BASE) {
      newFork = vm.createSelectFork(vm.rpcUrl('base'));
    } else if (chainId == ChainIds.GNOSIS) {
      newFork = vm.createSelectFork(vm.rpcUrl('gnosis'));
    }  else if (chainId == ChainIds.SCROLL) {
      newFork = vm.createSelectFork(vm.rpcUrl('scroll'));
    } else if (chainId == ChainIds.ARBITRUM) {
      newFork = vm.createSelectFork(vm.rpcUrl('arbitrum'));
    } else if (chainId == ChainIds.AVALANCHE) {
      newFork = vm.createSelectFork(vm.rpcUrl('avalanche'));
    } else if (chainId == ChainIds.SEPOLIA) {
      newFork = vm.createSelectFork(vm.rpcUrl('sepolia'));
    } else if (chainId == ChainIds.HARMONY) {
      newFork = vm.createSelectFork(vm.rpcUrl('harmony'));
    } else {
      revert UnknownChainId();
    }
    return (previousFork, newFork);
  }
}