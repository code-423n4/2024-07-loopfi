// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/* solhint-disable func-visibility, no-inline-assembly */

error Math__toInt256_overflow();
error Math__toUint64_overflow();
error Math__add_overflow_signed();
error Math__sub_overflow_signed();
error Math__mul_overflow_signed();
error Math__mul_overflow();
error Math__div_overflow();

uint256 constant WAD = 1e18;

/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/SafeCastLib.sol#L367
function toInt256(uint256 x) pure returns (int256) {
    if (x >= 1 << 255) revert Math__toInt256_overflow();
    return int256(x);
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/SafeCastLib.sol#L53
function toUint64(uint256 x) pure returns (uint64) {
    if (x >= 1 << 64) revert Math__toUint64_overflow();
    return uint64(x);
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/FixedPointMathLib.sol#L602
function abs(int256 x) pure returns (uint256 z) {
    assembly ("memory-safe") {
        let mask := sub(0, shr(255, x))
        z := xor(mask, add(mask, x))
    }
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/FixedPointMathLib.sol#L620
function min(uint256 x, uint256 y) pure returns (uint256 z) {
    assembly ("memory-safe") {
        z := xor(x, mul(xor(x, y), lt(y, x)))
    }
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/FixedPointMathLib.sol#L628
function min(int256 x, int256 y) pure returns (int256 z) {
    assembly ("memory-safe") {
        z := xor(x, mul(xor(x, y), slt(y, x)))
    }
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/FixedPointMathLib.sol#L636
function max(uint256 x, uint256 y) pure returns (uint256 z) {
    assembly ("memory-safe") {
        z := xor(x, mul(xor(x, y), gt(y, x)))
    }
}

/// @dev Taken from https://github.com/makerdao/dss/blob/fa4f6630afb0624d04a003e920b0d71a00331d98/src/vat.sol#L74
function add(uint256 x, int256 y) pure returns (uint256 z) {
    assembly ("memory-safe") {
        z := add(x, y)
    }
    if ((y > 0 && z < x) || (y < 0 && z > x)) revert Math__add_overflow_signed();
}

/// @dev Taken from https://github.com/makerdao/dss/blob/fa4f6630afb0624d04a003e920b0d71a00331d98/src/vat.sol#L79
function sub(uint256 x, int256 y) pure returns (uint256 z) {
    assembly ("memory-safe") {
        z := sub(x, y)
    }
    if ((y > 0 && z > x) || (y < 0 && z < x)) revert Math__sub_overflow_signed();
}

/// @dev Taken from https://github.com/makerdao/dss/blob/fa4f6630afb0624d04a003e920b0d71a00331d98/src/vat.sol#L84
function mul(uint256 x, int256 y) pure returns (int256 z) {
    unchecked {
        z = int256(x) * y;
        if (int256(x) < 0 || (y != 0 && z / y != int256(x))) revert Math__mul_overflow_signed();
    }
}

/// @dev Equivalent to `(x * y) / WAD` rounded down.
/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/FixedPointMathLib.sol#L54
function wmul(uint256 x, uint256 y) pure returns (uint256 z) {
    assembly ("memory-safe") {
        // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
        if mul(y, gt(x, div(not(0), y))) {
            // Store the function selector of `Math__mul_overflow()`.
            mstore(0x00, 0xc4c5d7f5)

            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }
        z := div(mul(x, y), WAD)
    }
}

function wmul(uint256 x, int256 y) pure returns (int256 z) {
    unchecked {
        z = mul(x, y) / int256(WAD);
    }
}

/// @dev Equivalent to `(x * y) / WAD` rounded up.
/// @dev Taken from https://github.com/Vectorized/solady/blob/969a78905274b32cdb7907398c443f7ea212e4f4/src/utils/FixedPointMathLib.sol#L69C22-L69C22
function wmulUp(uint256 x, uint256 y) pure returns (uint256 z) {
    /// @solidity memory-safe-assembly
    assembly {
        // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
        if mul(y, gt(x, div(not(0), y))) {
            // Store the function selector of `Math__mul_overflow()`.
            mstore(0x00, 0xc4c5d7f5)
            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }
        z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
    }
}

/// @dev Equivalent to `(x * WAD) / y` rounded down.
/// @dev Taken from https://github.com/Vectorized/solady/blob/6d706e05ef43cbed234c648f83c55f3a4bb0a520/src/utils/FixedPointMathLib.sol#L84
function wdiv(uint256 x, uint256 y) pure returns (uint256 z) {
    assembly ("memory-safe") {
        // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
        if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
            // Store the function selector of `Math__div_overflow()`.
            mstore(0x00, 0xbcbede65)

            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }
        z := div(mul(x, WAD), y)
    }
}

/// @dev Equivalent to `(x * WAD) / y` rounded up.
/// @dev Taken from https://github.com/Vectorized/solady/blob/969a78905274b32cdb7907398c443f7ea212e4f4/src/utils/FixedPointMathLib.sol#L99
function wdivUp(uint256 x, uint256 y) pure returns (uint256 z) {
    /// @solidity memory-safe-assembly
    assembly {
        // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
        if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
            // Store the function selector of `Math__div_overflow()`.
            mstore(0x00, 0xbcbede65)
            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }
        z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
    }
}

/// @dev Taken from https://github.com/makerdao/dss/blob/fa4f6630afb0624d04a003e920b0d71a00331d98/src/jug.sol#L62
function wpow(uint256 x, uint256 n, uint256 b) pure returns (uint256 z) {
    unchecked {
        assembly ("memory-safe") {
            switch n
            case 0 {
                z := b
            }
            default {
                switch x
                case 0 {
                    z := 0
                }
                default {
                    switch mod(n, 2)
                    case 0 {
                        z := b
                    }
                    default {
                        z := x
                    }
                    let half := div(b, 2) // for rounding.
                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if shr(128, x) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, b)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, b)
                        }
                    }
                }
            }
        }
    }
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/cde0a5fb594da8655ba6bfcdc2e40a7c870c0cc0/src/utils/FixedPointMathLib.sol#L110
/// @dev Equivalent to `x` to the power of `y`.
/// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
function wpow(int256 x, int256 y) pure returns (int256) {
    // Using `ln(x)` means `x` must be greater than 0.
    return wexp((wln(x) * y) / int256(WAD));
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/cde0a5fb594da8655ba6bfcdc2e40a7c870c0cc0/src/utils/FixedPointMathLib.sol#L116
/// @dev Returns `exp(x)`, denominated in `WAD`.
function wexp(int256 x) pure returns (int256 r) {
    unchecked {
        // When the result is < 0.5 we return zero. This happens when
        // x <= floor(log(0.5e18) * 1e18) ~ -42e18
        if (x <= -42139678854452767551) return r;

        /// @solidity memory-safe-assembly
        assembly {
            // When the result is > (2**255 - 1) / 1e18 we can not represent it as an
            // int. This happens when x >= floor(log((2**255 - 1) / 1e18) * 1e18) ~ 135.
            if iszero(slt(x, 135305999368893231589)) {
                mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.
                revert(0x1c, 0x04)
            }
        }

        // x is now in the range (-42, 136) * 1e18. Convert to (-42, 136) * 2**96
        // for more intermediate precision and a binary basis. This base conversion
        // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
        x = (x << 78) / 5 ** 18;

        // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
        // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
        // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
        int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
        x = x - k * 54916777467707473351141471128;

        // k is in the range [-61, 195].

        // Evaluate using a (6, 7)-term rational approximation.
        // p is made monic, we'll multiply by a scale factor later.
        int256 y = x + 1346386616545796478920950773328;
        y = ((y * x) >> 96) + 57155421227552351082224309758442;
        int256 p = y + x - 94201549194550492254356042504812;
        p = ((p * y) >> 96) + 28719021644029726153956944680412240;
        p = p * x + (4385272521454847904659076985693276 << 96);

        // We leave p in 2**192 basis so we don't need to scale it back up for the division.
        int256 q = x - 2855989394907223263936484059900;
        q = ((q * x) >> 96) + 50020603652535783019961831881945;
        q = ((q * x) >> 96) - 533845033583426703283633433725380;
        q = ((q * x) >> 96) + 3604857256930695427073651918091429;
        q = ((q * x) >> 96) - 14423608567350463180887372962807573;
        q = ((q * x) >> 96) + 26449188498355588339934803723976023;

        /// @solidity memory-safe-assembly
        assembly {
            // Div in assembly because solidity adds a zero check despite the unchecked.
            // The q polynomial won't have zeros in the domain as all its roots are complex.
            // No scaling is necessary because p is already 2**96 too large.
            r := sdiv(p, q)
        }

        // r should be in the range (0.09, 0.25) * 2**96.

        // We now need to multiply r by:
        // * the scale factor s = ~6.031367120.
        // * the 2**k factor from the range reduction.
        // * the 1e18 / 2**96 factor for base conversion.
        // We do this all at once, with an intermediate result in 2**213
        // basis, so the final right shift is always by a positive amount.
        r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));
    }
}

/// @dev Taken from https://github.com/Vectorized/solady/blob/cde0a5fb594da8655ba6bfcdc2e40a7c870c0cc0/src/utils/FixedPointMathLib.sol#L184
/// @dev Returns `ln(x)`, denominated in `WAD`.
function wln(int256 x) pure returns (int256 r) {
    unchecked {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(sgt(x, 0)) {
                mstore(0x00, 0x1615e638) // `LnWadUndefined()`.
                revert(0x1c, 0x04)
            }
        }

        // We want to convert x from 10**18 fixed point to 2**96 fixed point.
        // We do this by multiplying by 2**96 / 10**18. But since
        // ln(x * C) = ln(x) + ln(C), we can simply do nothing here
        // and add ln(2**96 / 10**18) at the end.

        // Compute k = log2(x) - 96, t = 159 - k = 255 - log2(x) = 255 ^ log2(x).
        int256 t;
        /// @solidity memory-safe-assembly
        assembly {
            t := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            t := or(t, shl(6, lt(0xffffffffffffffff, shr(t, x))))
            t := or(t, shl(5, lt(0xffffffff, shr(t, x))))
            t := or(t, shl(4, lt(0xffff, shr(t, x))))
            t := or(t, shl(3, lt(0xff, shr(t, x))))
            // forgefmt: disable-next-item
            t := xor(
                t,
                byte(
                    and(0x1f, shr(shr(t, x), 0x8421084210842108cc6318c6db6d54be)),
                    0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff
                )
            )
        }

        // Reduce range of x to (1, 2) * 2**96
        // ln(2^k * x) = k * ln(2) + ln(x)
        x = int256(uint256(x << uint256(t)) >> 159);

        // Evaluate using a (8, 8)-term rational approximation.
        // p is made monic, we will multiply by a scale factor later.
        int256 p = x + 3273285459638523848632254066296;
        p = ((p * x) >> 96) + 24828157081833163892658089445524;
        p = ((p * x) >> 96) + 43456485725739037958740375743393;
        p = ((p * x) >> 96) - 11111509109440967052023855526967;
        p = ((p * x) >> 96) - 45023709667254063763336534515857;
        p = ((p * x) >> 96) - 14706773417378608786704636184526;
        p = p * x - (795164235651350426258249787498 << 96);

        // We leave p in 2**192 basis so we don't need to scale it back up for the division.
        // q is monic by convention.
        int256 q = x + 5573035233440673466300451813936;
        q = ((q * x) >> 96) + 71694874799317883764090561454958;
        q = ((q * x) >> 96) + 283447036172924575727196451306956;
        q = ((q * x) >> 96) + 401686690394027663651624208769553;
        q = ((q * x) >> 96) + 204048457590392012362485061816622;
        q = ((q * x) >> 96) + 31853899698501571402653359427138;
        q = ((q * x) >> 96) + 909429971244387300277376558375;
        /// @solidity memory-safe-assembly
        assembly {
            // Div in assembly because solidity adds a zero check despite the unchecked.
            // The q polynomial is known not to have zeros in the domain.
            // No scaling required because p is already 2**96 too large.
            r := sdiv(p, q)
        }

        // r is in the range (0, 0.125) * 2**96

        // Finalization, we need to:
        // * multiply by the scale factor s = 5.549…
        // * add ln(2**96 / 10**18)
        // * add k * ln(2)
        // * multiply by 10**18 / 2**96 = 5**18 >> 78

        // mul s * 5e18 * 2**96, base is now 5**18 * 2**192
        r *= 1677202110996718588342820967067443963516166;
        // add ln(2) * k * 5e18 * 2**192
        r += 16597577552685614221487285958193947469193820559219878177908093499208371 * (159 - t);
        // add ln(2**96 / 10**18) * 5e18 * 2**192
        r += 600920179829731861736702779321621459595472258049074101567377883020018308;
        // base conversion: mul 2**18 / 2**192
        r >>= 174;
    }
}
