// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IPriceProvider {
    function getTokenPrice() external view returns (uint256);

    function getTokenPriceUsd() external view returns (uint256);

    function getLpTokenPrice() external view returns (uint256);

    function getLpTokenPriceUsd() external view returns (uint256);

    function getStablecoinUsd() external view returns (uint256);

    function decimals() external view returns (uint256);

    function update() external;

    function getRewardTokenPrice(address rewardToken, uint256 amount) external view returns (uint256);

    function baseAssetChainlinkAdapter() external view returns (address);
}
