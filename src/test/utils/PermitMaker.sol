// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Vm} from "forge-std/Vm.sol";

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

library PermitMaker {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address public constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /// @notice Permit2 typehashes
    bytes32 public constant TOKEN_PERMISSIONS_TYPEHASH = keccak256("TokenPermissions(address token,uint256 amount)");
    bytes32 public constant PERMIT_TRANSFER_FROM_TYPEHASH =
        keccak256(
            "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
        );

    ///@notice standard Permit typehash
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    ///@dev return the signature for a permit2 transferFrom
    function getPermit2TransferFromSignature(
        address token,
        address spender,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        uint256 ownerPrivateKey
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({token: token, amount: amount}),
            nonce: nonce,
            deadline: deadline
        });

        bytes32 tokenPermissions = keccak256(abi.encode(TOKEN_PERMISSIONS_TYPEHASH, permit.permitted));
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19\x01", // EIP-191 header (x19 - indicates non RLP format, 0x01 - indicates EIP 712 structured data)
                IERC20Permit(PERMIT2).DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(PERMIT_TRANSFER_FROM_TYPEHASH, tokenPermissions, spender, permit.nonce, permit.deadline)
                )
            )
        );
        return vm.sign(ownerPrivateKey, msgHash);
    }

    ///@dev return the signature for a standard erc20 transferFrom permit
    function getPermitTransferFromSignature(
        address token,
        address spender,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        uint256 ownerPrivateKey
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        address owner = vm.addr(ownerPrivateKey);
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19\x01", // EIP-191 header (x19 - indicates non RLP format, 0x01 - indicates EIP 712 structured data)
                IERC20Permit(token).DOMAIN_SEPARATOR(),
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonce, deadline))
            )
        );
        return vm.sign(ownerPrivateKey, msgHash);
    }
}
