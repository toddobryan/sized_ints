import 'dart:typed_data';

import 'package:sized_ints/uintx.dart';

/// Value is stored as a big-endian int. If the value is negative,
/// uint32List.first is padded with 1s.
class IntX {
  IntX(this.bits, this.uint32List);

  static final int _bitSize = 32;

  final int bits;
  final Uint32List uint32List;

  static final int maxUint32 = 0xFFFFFFFF;
  static final int twoToThe32 = 0x100000000;
  static final BigInt twoToThe32AsBigInt = BigInt.from(twoToThe32);

  static int _modBitSize(int bits) {
    int mod = bits % _bitSize;
    return mod == 0 ? _bitSize : mod;
  }

  int? _zerothIntMask;

  int get zerothIntMask {
    if (_zerothIntMask == null) {
      int numBits = _modBitSize(bits);
      _zerothIntMask = numBits == _bitSize ? maxUint32 : (1 << numBits) - 1;
    }
    return _zerothIntMask!;
  }

  int get bitLength {
    for (int i = 0; i < uint32List.length; i++) {
      int bl = uint32List[i].bitLength;
      if (bl > 0) {
        return bl + _bitSize * (uint32List.length - i - 1);
      }
    }
    return 0 + signBit;
  }

  bool nonZero() => uint32List.any((x) => x != 0);
  bool zero() => !nonZero();

  int toInt() {
    if (bitLength > 32) {
      throw RangeError(
        'not safe to return $this as int, use toBigInt() instead',
      );
    }
    if (signBit == 1) {
      return ~uint32List.last.toInt() + 1;
    } else {
      return uint32List.last.toInt();
    }
  }

  BigInt toBigInt() {
    if (signBit == 1) {
      return (~this).toBigInt() + BigInt.one;
    } else {
      assert(signBit == 0);
      BigInt value = BigInt.from(uint32List[0]);
      for (int i = 1; i < uint32List.length; i++) {
        value = (value * UintX.twoToThe32AsBigInt) + BigInt.from(uint32List[i]);
      }
      return value;
    }
  }

  int get signBitMask => (1 << (bits % _bitSize));
  int get signBit => uint32List.first & signBitMask;

  String toRadixString(int radix) {
    if (signBit == 1) {
      BigInt unsigned = (~this).toBigInt() + BigInt.one;
      return '-${unsigned.toRadixString(radix)}';
    } else {
      return toBigInt().toRadixString(radix);
    }
  }

  @override
  String toString() => toRadixString(10);

  String get hex => toRadixString(16);

  // Bit-wise operations
  IntX operator ~() {
    Uint32List result = Uint32List(uint32List.length);
    for (int i = 0; i < uint32List.length; i++) {
      result[i] = ~uint32List[i];
    }
    return IntX(bits, result);
  }
}
