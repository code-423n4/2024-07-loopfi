// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IUniswapV3Router, ExactInputParams, ExactOutputParams, decodeLastToken} from "../vendor/IUniswapV3Router.sol";
import {IVault, SwapKind, BatchSwapStep, FundManagement} from "../vendor/IBalancerVault.sol";
import {TokenInput, LimitOrderData} from "pendle/interfaces/IPAllActionTypeV3.sol";
import {ApproxParams} from "pendle/router/base/MarketApproxLib.sol";
import {IPActionAddRemoveLiqV3} from "pendle/interfaces/IPActionAddRemoveLiqV3.sol";
import {IPPrincipalToken} from "pendle/interfaces/IPPrincipalToken.sol";
import {IStandardizedYield} from "pendle/interfaces/IStandardizedYield.sol";
import {IPYieldToken} from "pendle/interfaces/IPYieldToken.sol";
import {IPMarket} from "pendle/interfaces/IPMarket.sol";
import {toInt256, abs} from "../utils/Math.sol";
import {console} from "forge-std/console.sol";
import {TransferAction, PermitParams} from "./TransferAction.sol";

/// @notice The swap protocol to use
enum SwapProtocol {
    BALANCER,
    UNIV3,
    PENDLE_IN,
    PENDLE_OUT
}

/// @notice The type of swap to perform
enum SwapType {
    EXACT_IN,
    EXACT_OUT
}

/// @notice The parameters for a swap
struct SwapParams {
    SwapProtocol swapProtocol;
    SwapType swapType;
    address assetIn;
    uint256 amount; // Exact amount in or exact amount out depending on swapType
    uint256 limit; // Min amount out or max amount in depending on swapType
    address recipient;
    uint256 deadline;
    /// @dev `args` can be used for protocol specific parameters
    /// For Balancer, it is the `poolIds` and `assetPath`
    /// For Uniswap v3, it is the `path` for the swap
    bytes args;
}

/// @title SwapAction
contract SwapAction is TransferAction {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Balancer v2 Vault
    IVault public immutable balancerVault;
    /// @notice Uniswap v3 Router
    IUniswapV3Router public immutable uniRouter;
    /// @notice Pendle Router
    IPActionAddRemoveLiqV3 public immutable pendleRouter;
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error SwapAction__swap_notSupported();
    error SwapAction__revertBytes_emptyRevertBytes();

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(IVault balancerVault_, IUniswapV3Router uniRouter_, IPActionAddRemoveLiqV3 pendleRouter_) {
        balancerVault = balancerVault_;
        uniRouter = uniRouter_;
        pendleRouter = pendleRouter_;
    }

    /*//////////////////////////////////////////////////////////////
                             SWAP VARIANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Execute a transfer from an EOA and then swap via `swapParams`
    /// @param from The address to transfer from
    /// @param permitParams The parameters for the permit
    /// @param swapParams The parameters for the swap
    /// @return _ Amount of tokens taken or received from the swap
    function transferAndSwap(
        address from,
        PermitParams calldata permitParams,
        SwapParams calldata swapParams
    ) external returns (uint256) {
        if (from != address(this)) {
            uint256 amount = swapParams.swapType == SwapType.EXACT_IN ? swapParams.amount : swapParams.limit;
            _transferFrom(swapParams.assetIn, from, address(this), amount, permitParams);
        }
        return swap(swapParams);
    }

    /// @notice Perform a swap using the protocol and swap-type specified in `swapParams`
    /// @param swapParams The parameters for the swap
    /// @return retAmount Amount of tokens taken or received from the swap
    function swap(SwapParams memory swapParams) public payable returns (uint256 retAmount) {
        if (swapParams.swapProtocol == SwapProtocol.BALANCER) {
            (bytes32[] memory poolIds, address[] memory assetPath) = abi.decode(
                swapParams.args,
                (bytes32[], address[])
            );
            retAmount = balancerSwap(
                swapParams.swapType,
                swapParams.assetIn,
                poolIds,
                assetPath,
                swapParams.amount,
                swapParams.limit,
                swapParams.recipient,
                swapParams.deadline
            );
        } else if (swapParams.swapProtocol == SwapProtocol.UNIV3) {
            retAmount = uniV3Swap(
                swapParams.swapType,
                swapParams.assetIn,
                swapParams.amount,
                swapParams.limit,
                swapParams.recipient,
                swapParams.deadline,
                swapParams.args
            );
        } else if (swapParams.swapProtocol == SwapProtocol.PENDLE_IN) {
            retAmount = pendleJoin(swapParams.recipient, swapParams.limit, swapParams.args);
        } else if (swapParams.swapProtocol == SwapProtocol.PENDLE_OUT) {
            retAmount = pendleExit(swapParams.recipient, swapParams.amount, swapParams.args);
        } else revert SwapAction__swap_notSupported();
        // Transfer any remaining tokens to the recipient
        if (swapParams.swapType == SwapType.EXACT_OUT && swapParams.recipient != address(this)) {
            IERC20(swapParams.assetIn).safeTransfer(swapParams.recipient, swapParams.limit - retAmount);
        }
    }

    /// @notice Perform a batch swap on Balancer
    /// @dev
    ///      For EXACT_IN, the `poolIds` and `assets` are in sequential order. The `assetIn` must be the first index
    ///      of `assets` and the asset out must be the last index of `assets`.
    ///
    ///      For EXACT_OUT, the `poolIds` and `assets` are reversed. The asset out must be the first index of `assets`
    ///      and the `assetIn` must be the last index of `assets`.
    ///      ex.
    ///      EXACT_IN:  { [Asset In  ->  Asset X] -> [Asset X -> Asset Out] }
    ///      EXACT_OUT: { [Asset Out ->  Asset X] -> [Asset X -> Asset In ] }
    ///
    /// @dev `assets.length` should always be `poolIds.length` + 1
    /// @param swapType The type of swap to perform
    /// @param assetIn Asset to send during the swap
    /// @param poolIds The poolIds to use for the swap:
    ///                For EXACT_IN the poolIds must be in sequential order
    ///                For EXACT_OUT the poolIds must be in reverse sequential order
    /// @param assets The assets to use for the swap:
    ///               For EXACT_IN the assets must be in sequential order
    ///               For EXACT_OUT the assets must be in reverse sequential order
    /// @param amount EXACT_IN:  `amount` is the amount of `assetIn` to send
    ///               EXACT_OUT: `amount` is the amount of asset out to receive
    /// @param limit  EXACT_IN:  `limit` is the minimum acceptable amount to receive from the swap
    ///               EXACT_OUT: `limit` is the maximum acceptable amount to send on the swap
    /// @param recipient Address to send the swapped tokens to
    /// @param deadline Timestamp after which the swap will revert
    /// @return _ Amount of tokens taken or received from the swap
    function balancerSwap(
        SwapType swapType,
        address assetIn,
        bytes32[] memory poolIds,
        address[] memory assets,
        uint256 amount,
        uint256 limit,
        address recipient,
        uint256 deadline
    ) internal returns (uint256) {
        uint256 pathLength = poolIds.length;
        int256[] memory limits = new int256[](pathLength + 1); // limit for each asset, leave as 0 to autocalculate

        // construct the BatchSwapStep array
        BatchSwapStep[] memory swaps = new BatchSwapStep[](pathLength);
        {
            // In an 'EXACT_IN' swap, 'BatchSwapStep.assetInIndex' must equal the previous swap's `assetOutIndex`.
            // For an 'EXACT_OUT' swap, `BatchSwapStep.assetOutIndex` must equal the previous swap's `assetInIndex`.
            //
            // For `EXACT_IN`, we can accomplish this by incrementing the `assetOutIndex` by 1,
            // and for `EXACT_OUT` by incrementing the `assetInIndex` by 1.
            // EX.
            //  1. Swapping an exact amount in of USDC for BAL
            //     swapType = `EXACT_IN` and `assets` = [USDC, DAI, WETH, BAL]
            //     ╔══════════╦══════════╦═══════════╗
            //     ║ EXACT_IN ║ Asset In ║ Asset Out ║
            //     ╠══════════╬══════════╬═══════════╣
            //     ║ Swap 1   ║ USDC     ║ DAI       ║
            //     ╠══════════╬══════════╬═══════════╣
            //     ║ Swap 2   ║ DAI      ║ WETH      ║
            //     ╠══════════╬══════════╬═══════════╣
            //     ║ Swap 3   ║ WETH     ║ BAL       ║
            //     ╚══════════╩══════════╩═══════════╝
            //      * Swap n "Asset Out" must equal Swap n+1 "Asset In"
            //
            //  2. Swapping in USDC for an exact amount out of BAL
            //     swapType = `EXACT_OUT` and `assets` = [BAL, WETH, DAI, USDC]:
            //     ╔═══════════╦══════════╦═══════════╗
            //     ║ EXACT_OUT ║ Asset In ║ Asset Out ║
            //     ╠═══════════╬══════════╬═══════════╣
            //     ║ Swap 1    ║ WETH     ║ BAL       ║
            //     ╠═══════════╬══════════╬═══════════╣
            //     ║ Swap 2    ║ DAI      ║ WETH      ║
            //     ╠═══════════╬══════════╬═══════════╣
            //     ║ Swap 3    ║ USDC     ║ DAI       ║
            //     ╚═══════════╩══════════╩═══════════╝
            //      * Swap n "Asset In" must equal Swap n+1 "Asset Out"
            //
            // more info: https://docs.balancer.fi/reference/swaps/batch-swaps.html

            bytes memory userData; // empty bytes, not used
            uint256 inIncrement;
            uint256 outIncrement;
            if (swapType == SwapType.EXACT_IN) outIncrement = 1;
            else inIncrement = 1;

            for (uint256 i; i < pathLength; ) {
                unchecked {
                    swaps[i] = BatchSwapStep({
                        poolId: poolIds[i],
                        assetInIndex: i + inIncrement,
                        assetOutIndex: i + outIncrement,
                        amount: 0, // 0 to autocalculate
                        userData: userData
                    });
                    ++i;
                }
            }
            swaps[0].amount = amount; // amount always pertains to the first swap
        }

        // configure swap-type dependent variables
        SwapKind kind;
        uint256 amountToApprove;
        if (swapType == SwapType.EXACT_IN) {
            kind = SwapKind.GIVEN_IN;
            amountToApprove = amount;
            limits[0] = toInt256(amount); // positive signifies tokens going into the vault from the caller
            limits[pathLength] = -toInt256(limit); // negative signifies tokens going out of the vault to the caller
        } else {
            kind = SwapKind.GIVEN_OUT;
            amountToApprove = limit;
            limits[0] = -toInt256(amount);
            limits[pathLength] = toInt256(limit);
        }

        IERC20(assetIn).forceApprove(address(balancerVault), amountToApprove);

        // execute swap and return the value of the last index in the asset delta array to get amountIn/amountOut
        return
            abs(
                balancerVault.batchSwap(
                    kind,
                    swaps,
                    assets,
                    FundManagement({
                        sender: address(this),
                        fromInternalBalance: false,
                        recipient: payable(recipient),
                        toInternalBalance: false
                    }),
                    limits,
                    deadline
                )[pathLength]
            );
    }

    /// @notice Perform a swap using uniswap v3 exactInput or exactOutput function
    /// @param swapType The type of swap to perform
    /// @param assetIn Asset to send during the swap:
    /// @param amount EXACT_IN:  `amount` is the amount of `assetIn` to send
    ///               EXACT_OUT: `amount` is the amount of asset out to receive
    /// @param limit EXACT_IN:  `limit` is the minimum acceptable amount to receive from the swap
    ///              EXACT_OUT: `limit` is the maximum acceptable amount to send on the swap
    /// @param recipient Address to send the swapped tokens to
    /// @param args Uniswap V3 path parameter, EXACT_OUT must be calculated in reverse order
    /// EXACT_IN:  { [Asset In,  Fee, Asset X], [Asset X, Fee, Asset Out] }
    /// EXACT_OUT: { [Asset Out, Fee, Asset X], [Asset X, Fee, Asset In ] }
    /// @param deadline Timestamp after which the swap will revert
    /// @return retAmount Amount of tokens taken or received from the swap
    function uniV3Swap(
        SwapType swapType,
        address assetIn,
        uint256 amount,
        uint256 limit,
        address recipient,
        uint256 deadline,
        bytes memory args
    ) internal returns (uint256) {
        if (swapType == SwapType.EXACT_IN) {
            IERC20(assetIn).forceApprove(address(uniRouter), amount);
            return
                uniRouter.exactInput(
                    ExactInputParams({
                        path: args,
                        recipient: recipient,
                        amountIn: amount,
                        amountOutMinimum: limit,
                        deadline: deadline
                    })
                );
        } else {
            IERC20(assetIn).forceApprove(address(uniRouter), limit);
            return
                uniRouter.exactOutput(
                    ExactOutputParams({
                        path: args,
                        recipient: recipient,
                        amountOut: amount,
                        amountInMaximum: limit,
                        deadline: deadline
                    })
                );
        }
    }

    /// @notice Perform a join using the Pendle protocol
    /// @param recipient Address to send the swapped tokens to
    /// @param minOut Minimum amount of LP tokens to receive
    /// @param data The parameters for joinng the pool
    /// @dev For more information regarding the Pendle join function check Pendle 
    /// documentation
    function pendleJoin(address recipient, uint256 minOut, bytes memory data) internal returns (uint256 netLpOut){
        (
            address market,
            ApproxParams memory guessPtReceivedFromSy,
            TokenInput memory input,
            LimitOrderData memory limit
        ) = abi.decode(data, (address, ApproxParams, TokenInput , LimitOrderData));
        
        if (input.tokenIn != address(0)) {
                input.netTokenIn = IERC20(input.tokenIn).balanceOf(address(this));
                IERC20(input.tokenIn).forceApprove(address(pendleRouter),input.netTokenIn);
            }

        (netLpOut,,) = pendleRouter.addLiquiditySingleToken{value: msg.value}(recipient, market, minOut, guessPtReceivedFromSy, input, limit);
    }

    function pendleExit(address recipient, uint256 minOut, bytes memory data) internal returns (uint256 retAmount){
        (
        address market, uint256 netLpIn, address tokenOut
        ) = abi.decode(data, (address,uint256, address));
            
        (IStandardizedYield SY, IPPrincipalToken PT, IPYieldToken YT) = IPMarket(market).readTokens();

        if(recipient != address(this)){
            IPMarket(market).transferFrom(recipient, market, netLpIn);
        } else {
            IPMarket(market).transfer(market, netLpIn);
        }

        uint256 netSyToRedeem;

        if (PT.isExpired()) {
            (uint256 netSyRemoved, ) = IPMarket(market).burn(address(SY), address(YT), netLpIn);
            uint256 netSyFromPt = YT.redeemPY(address(SY));
            netSyToRedeem = netSyRemoved + netSyFromPt;
        } else {
            (uint256 netSyRemoved, uint256 netPtRemoved) = IPMarket(market).burn(address(SY), market, netLpIn);
            bytes memory empty;
            (uint256 netSySwappedOut, ) = IPMarket(market).swapExactPtForSy(address(SY), netPtRemoved, empty);
            netSyToRedeem = netSyRemoved + netSySwappedOut;
        }

        return SY.redeem(recipient, netSyToRedeem, tokenOut, minOut, true);
     }

    /// @notice Helper function that decodes the swap params and returns the token that will be swapped into
    /// @param swapParams The parameters for the swap
    /// @return token The token that will be swapped into
    function getSwapToken(SwapParams calldata swapParams) public pure returns (address token) {
        if (swapParams.swapProtocol == SwapProtocol.BALANCER) {
            (, address[] memory primarySwapPath) = abi.decode(swapParams.args, (bytes32[], address[]));
            // the last token in the path is the token that will be swapped into
            token = primarySwapPath[primarySwapPath.length - 1];
        } else if (swapParams.swapProtocol == SwapProtocol.UNIV3) {
            token = decodeLastToken(swapParams.args);
        } else {
            revert SwapAction__swap_notSupported();
        }
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
        revert SwapAction__revertBytes_emptyRevertBytes();
    }
}
