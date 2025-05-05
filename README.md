## sized_ints

A library for creating and using signed and unsigned ints of arbitrary bit accuracy that is compatible with native and web (both JS and WASM).

### UintX

The fundamental class on which all others depend is `UintX` with constructor `UintX(int bits, Uint32List uint32List)`. It represents an unsigned integer of the given bit size as a list of `Uint32List` from the `typed_data` package. Values are stored in big-endian fashion, i.e., `uint32List.first` is the most-significant `int` and `uint32List.last` is the least significant.

For all methods that take a second `UintX`, the bit size of both must match.

All mathematical operations (`+`, `-`, `*`, and unary `-`) rollover as if the operations were done modulo 2<sup>bits</sup>. Integer division (`~/`) and mod (`%`) also work as expected. The double division operator (`/`) is implemented as for `BigInt`, with the numbers converted first to `double`s (with a possible loss of precision) and then divided.

Bit-wise operations (`|`, `&`, and `^`) work as expected. Unary bit negation (`~`) works as expected, except that the value of the most-significant `int` is truncated based on the bit size. Similarly, bit-shift operations (`<<`, `>>`, and `>>>`) work as expected, given the bit size. (Note that `>>` and `>>>` are equivalent, since the values are unsigned and will always shift in zeroes from the left.)

