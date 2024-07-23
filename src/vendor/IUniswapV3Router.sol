// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
}

struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 amountInMaximum;
}

error UniswapV3Router_toAddress_overflow();
error UniswapV3Router_toAddress_outOfBounds();
error UniswapV3Router_decodeLastToken_invalidPath();

function toAddress(bytes memory _bytes, uint256 _start) pure returns (address) {
    if (_start + 20 < _start) revert UniswapV3Router_toAddress_overflow();
    if (_bytes.length < _start + 20) revert UniswapV3Router_toAddress_outOfBounds();
    address tempAddress;

    assembly {
        tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
    }

    return tempAddress;
}

/// @notice Decodes the last token in the path
/// @param path The bytes encoded swap path
/// @return token The last token of the given path
function decodeLastToken(bytes memory path) pure returns (address token) {
    if (path.length < 20) revert UniswapV3Router_decodeLastToken_invalidPath();
    token = toAddress(path, path.length - 20);
}

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface IUniswapV3Router {
    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
