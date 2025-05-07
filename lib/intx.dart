import 'dart:typed_data';

import 'package:sized_ints/sized_int.dart';

/// Value is stored as a big-endian int. If the value is negative,
/// uint32List.first is padded with 1s.
class IntX extends SizedInt {
  IntX._(super.bits, super.uints);

  @override
  int toInt() {
    int unsigned = toUnsignedInt();
    if (signBit == 1) {
      return ~unsigned + 1;
    } else {
      return unsigned;
    }
  }

  @override
  BigInt toBigInt() {
    if (signBit == 1) {
      return (~this).toBigInt() + BigInt.one;
    } else {
      return super.toBigInt();
    }
  }

  int get signBitMask => (1 << (bits % modBitSize(bits)));
  int get signBit => uints.first & signBitMask;

  @override
  String toRadixString(int radix) {
    if (signBit == 1) {
      BigInt unsigned = (~this).toBigInt() + BigInt.one;
      return '-${unsigned.toRadixString(radix)}';
    } else {
      return super.toRadixString(radix);
    }
  }

  @override
  String get suffix => "i$bits";

  // Bit-wise operations
  IntX operator ~() {
    Uint32List result = Uint32List(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = ~uints[i];
    }
    return IntX._(bits, result);
  }
}
