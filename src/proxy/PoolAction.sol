// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TransferAction, PermitParams} from "./TransferAction.sol";

import {IVault, JoinKind, JoinPoolRequest, ExitKind, ExitPoolRequest} from "../vendor/IBalancerVault.sol";

/// @notice The protocol to use
enum Protocol {
    BALANCER,
    UNIV3
}

/// @notice The parameters for a join
struct PoolActionParams {
    Protocol protocol;
    uint256 minOut;
    address recipient;
    /// @dev `args` can be used for protocol specific parameters
    bytes args;
}

contract PoolAction is TransferAction {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Balancer v2 Vault
    IVault public immutable balancerVault;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error PoolAction__join_unsupportedProtocol();
    error PoolAction__transferAndJoin_unsupportedProtocol();
    error PoolAction__transferAndJoin_invalidPermitParams();
    error PoolAction__exit_unsupportedProtocol();

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(address balancerVault_) {
        balancerVault = IVault(balancerVault_);
    }

    /*//////////////////////////////////////////////////////////////
                             JOIN VARIANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Execute a transfer from an EOA and then join via `PoolActionParams`
    /// @param from The address to transfer from
    /// @param permitParams A list of parameters for the permit transfers,
    /// must be the same length and in the same order as `PoolActionParams` assets
    /// @param poolActionParams The parameters for the join
    function transferAndJoin(
        address from,
        PermitParams[] calldata permitParams,
        PoolActionParams calldata poolActionParams
    ) external {
        if (from != address(this)) {
            if (poolActionParams.protocol == Protocol.BALANCER) {
                (, address[] memory assets, , uint256[] memory maxAmountsIn) = abi.decode(
                    poolActionParams.args,
                    (bytes32, address[], uint256[], uint256[])
                );

                if (assets.length != permitParams.length) {
                    revert PoolAction__transferAndJoin_invalidPermitParams();
                }

                for (uint256 i = 0; i < assets.length; ) {
                    if (maxAmountsIn[i] != 0) {
                        _transferFrom(assets[i], from, address(this), maxAmountsIn[i], permitParams[i]);
                    }

                    unchecked {
                        ++i;
                    }
                }
            } else {
                revert PoolAction__transferAndJoin_unsupportedProtocol();
            }
        }

        join(poolActionParams);
    }

    /// @notice Perform a join using the specified protocol
    /// @param poolActionParams The parameters for the join
    function join(PoolActionParams memory poolActionParams) public {
        if (poolActionParams.protocol == Protocol.BALANCER) {
            _balancerJoin(poolActionParams);
        } else {
            revert PoolAction__join_unsupportedProtocol();
        }
    }

    /// @notice Perform a join using the Balancer protocol
    /// @param poolActionParams The parameters for the join
    /// @dev For more information regarding the Balancer join function check the
    /// documentation in {IBalancerVault}
    function _balancerJoin(PoolActionParams memory poolActionParams) internal {
        (bytes32 poolId, address[] memory assets, uint256[] memory assetsIn, uint256[] memory maxAmountsIn) = abi
            .decode(poolActionParams.args, (bytes32, address[], uint256[], uint256[]));

        for (uint256 i = 0; i < assets.length; ) {
            if (maxAmountsIn[i] != 0) {
                IERC20(assets[i]).forceApprove(address(balancerVault), maxAmountsIn[i]);
            }

            unchecked {
                ++i;
            }
        }

        balancerVault.joinPool(
            poolId,
            address(this),
            poolActionParams.recipient,
            JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                userData: abi.encode(JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, assetsIn, poolActionParams.minOut),
                fromInternalBalance: false
            })
        );
    }

    /// @notice Helper function to update the join parameters for a levered position
    /// @param poolActionParams The parameters for the join
    /// @param upFrontToken The upfront token for the levered position
    /// @param joinToken The token to join with
    /// @param flashLoanAmount The amount of the flash loan
    /// @param upfrontAmount The amount of the upfront token
    function updateLeverJoin(
        PoolActionParams memory poolActionParams,
        address joinToken,
        address upFrontToken,
        uint256 flashLoanAmount,
        uint256 upfrontAmount,
        address poolToken
    ) external pure returns (PoolActionParams memory outParams) {
        outParams = poolActionParams;

        if (poolActionParams.protocol == Protocol.BALANCER) {
            (bytes32 poolId, address[] memory assets, uint256[] memory assetsIn, uint256[] memory maxAmountsIn) = abi
                .decode(poolActionParams.args, (bytes32, address[], uint256[], uint256[]));

            uint256 len = assets.length;
            // the offset is needed because of the BPT token that needs to be skipped from the join
            bool skipIndex = false;
            uint256 joinAmount = flashLoanAmount;
            if (upFrontToken == joinToken) {
                joinAmount += upfrontAmount;
            }

            // update the join parameters with the new amounts
            for (uint256 i = 0; i < len; ) {
                uint256 assetIndex = i - (skipIndex ? 1 : 0);
                if (assets[i] == joinToken) {
                    maxAmountsIn[i] = joinAmount;
                    assetsIn[assetIndex] = joinAmount;
                } else if (assets[i] == upFrontToken && assets[i] != poolToken) {
                    maxAmountsIn[i] = upfrontAmount;
                    assetsIn[assetIndex] = upfrontAmount;
                } else {
                    skipIndex = skipIndex || assets[i] == poolToken;
                }
                unchecked {
                    i++;
                }
            }

            // update the join parameters
            outParams.args = abi.encode(poolId, assets, assetsIn, maxAmountsIn);
        }
    }

    /*//////////////////////////////////////////////////////////////
                             EXIT VARIANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Exit a protocol specific pool
    /// @param poolActionParams The parameters for the exit
    function exit(PoolActionParams memory poolActionParams) public returns (uint256 retAmount) {
        if (poolActionParams.protocol == Protocol.BALANCER) {
            retAmount = _balancerExit(poolActionParams);
        } else {
            revert PoolAction__exit_unsupportedProtocol();
        }
    }

    function _balancerExit(PoolActionParams memory poolActionParams) internal returns (uint256 retAmount) {
        (
            bytes32 poolId,
            address bpt,
            uint256 bptAmount,
            uint256 outIndex,
            address[] memory assets,
            uint256[] memory minAmountsOut
        ) = abi.decode(poolActionParams.args, (bytes32, address, uint256, uint256, address[], uint256[]));

        if (bptAmount != 0) IERC20(bpt).forceApprove(address(balancerVault), bptAmount);

        balancerVault.exitPool(
            poolId,
            address(this),
            payable(poolActionParams.recipient),
            ExitPoolRequest({
                assets: assets,
                minAmountsOut: minAmountsOut,
                userData: abi.encode(ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, bptAmount, outIndex),
                toInternalBalance: false
            })
        );

        for (uint256 i = 0; i <= outIndex; ) {
            if (assets[i] == bpt) {
                outIndex++;
            }

            unchecked {
                ++i;
            }
        }

        return IERC20(assets[outIndex]).balanceOf(address(poolActionParams.recipient));
    }
}
