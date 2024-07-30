// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test} from "forge-std/Test.sol";
import {VmSafe} from 'forge-std/Vm.sol';
import {ChainIds} from "./ChainIds.sol";
import {AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3GnosisAssets} from 'aave-address-book/AaveV3Gnosis.sol';
import {AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';

contract PatchedDeal is Test {

    /**
   * @notice deal doesn't support amounts stored in a script right now.
   * This function patches deal to mock and transfer funds instead.
   * @param asset the asset to deal
   * @param user the user to deal to
   * @param amount the amount to deal
   * @return bool true if the caller has changed due to prank usage
   */
  function _patchedeal(address asset, address user, uint256 amount) internal returns (bool) {
    if (block.chainid == ChainIds.MAINNET) {
      // FXS
      if (asset == 0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0) {
        vm.prank(0xF977814e90dA44bFA03b6295A0616a897441aceC);
        IERC20(asset).transfer(user, amount);
        return true;
      }
      // GUSD
      if (asset == AaveV2EthereumAssets.GUSD_UNDERLYING) {
        vm.prank(0x22FFDA6813f4F34C520bf36E5Ea01167bC9DF159);
        IERC20(asset).transfer(user, amount);
        return true;
      }
      // SNX
      if (asset == AaveV2EthereumAssets.SNX_UNDERLYING) {
        vm.prank(0xAc86855865CbF31c8f9FBB68C749AD5Bd72802e3);
        IERC20(asset).transfer(user, amount);
        return true;
      }
      // sUSD
      if (asset == AaveV2EthereumAssets.sUSD_UNDERLYING) {
        vm.prank(0x99F4176EE457afedFfCB1839c7aB7A030a5e4A92);
        IERC20(asset).transfer(user, amount);
        return true;
      }
      // stETH
      if (asset == AaveV2EthereumAssets.stETH_UNDERLYING) {
        vm.prank(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);
        IERC20(asset).transfer(user, amount);
        return true;
      }
      // LDO
      if (asset == AaveV3EthereumAssets.LDO_UNDERLYING) {
        vm.prank(0x3e40D73EB977Dc6a537aF587D48316feE66E9C8c);
        IERC20(asset).transfer(user, amount);
        return true;
      }
      if (asset == AaveV3EthereumAssets.USDC_UNDERLYING) {
        vm.prank(0xcEe284F754E854890e311e3280b767F80797180d);
        IERC20(asset).transfer(user, amount);
        return true;
      }
    }
    if (block.chainid == ChainIds.OPTIMISM) {
      // sUSD
      if (asset == AaveV3OptimismAssets.sUSD_UNDERLYING) {
        vm.prank(AaveV3OptimismAssets.sUSD_A_TOKEN);
        IERC20(asset).transfer(user, amount);
        return true;
      }
      if (asset == AaveV3OptimismAssets.USDCn_UNDERLYING) {
        vm.prank(0xf491d040110384DBcf7F241fFE2A546513fD873d);
        IERC20(asset).transfer(user, amount);
        return true;
      }
    }
    if (block.chainid == ChainIds.GNOSIS) {
      if (asset == AaveV3GnosisAssets.EURe_UNDERLYING) {
        vm.prank(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        IERC20(asset).transfer(user, amount);
        return true;
      }
    }
    if (block.chainid == ChainIds.POLYGON) {
      if (asset == AaveV3PolygonAssets.USDCn_UNDERLYING) {
        vm.prank(0xe7804c37c13166fF0b37F5aE0BB07A3aEbb6e245);
        IERC20(asset).transfer(user, amount);
        return true;
      }
    }
    if (block.chainid == ChainIds.ARBITRUM) {
      if (asset == AaveV3ArbitrumAssets.USDCn_UNDERLYING) {
        vm.prank(0x47c031236e19d024b42f8AE6780E44A573170703);
        IERC20(asset).transfer(user, amount);
        return true;
      }
    }
    if (block.chainid == ChainIds.AVALANCHE) {
      if (asset == AaveV3AvalancheAssets.USDC_UNDERLYING) {
        vm.prank(0x9f8c163cBA728e99993ABe7495F06c0A3c8Ac8b9);
        IERC20(asset).transfer(user, amount);
        return true;
      }
    }
    if (block.chainid == ChainIds.BASE) {
      if (asset == AaveV3BaseAssets.USDC_UNDERLYING) {
        vm.prank(0x20FE51A9229EEf2cF8Ad9E89d91CAb9312cF3b7A);
        IERC20(asset).transfer(user, amount);
        return true;
      }
    }
    return false;
  }

  /**
   * Patched version of deal
   * @param asset to deal
   * @param user to deal to
   * @param amount to deal
   */
  function deal2(address asset, address user, uint256 amount) public {
    (VmSafe.CallerMode mode, address oldSender, ) = vm.readCallers();
    if (mode != VmSafe.CallerMode.None) vm.stopPrank();
    bool patched = _patchedeal(asset, user, amount);
    if (!patched) {
      deal(asset, user, amount);
    }
    if (mode != VmSafe.CallerMode.None) vm.startPrank(oldSender);
  }
}