import 'dart:math';
import 'dart:typed_data';

import 'package:sized_ints/sized_int.dart';

/// Value is stored as a big-endian int. If the value is negative,
/// uint32List.first is padded with 1s.
class IntX extends SizedInt {
  IntX._(super.bits, super.uints);

  factory IntX.fromInt(int bits, int value) {
    if (value < Int32.minAsInt || value > Int32.maxAsInt) {
      throw ArgumentError(
        'value must be in range [-2^31, 2^31 - 1], '
        'use fromBigInt for values outside the range',
      );
    }
    if (bits < value.bitLength) {
      throw ArgumentError(
        'value can not be represented in the given number of bits',
      );
    }
    return IntX._(bits, SizedInt.signedIntToList(bits, value));
  }

  factory IntX.fromBigInt(int bits, BigInt value) {
    BigInt min = minAsBigInt(bits);
    BigInt max = maxAsBigInt(bits);
    if (value < min || value > max) {
      throw ArgumentError(
        'value can not be represented in the given number of bits',
      );
    }
    return IntX._(bits, SizedInt.signedBigIntToList(bits, value));
  }

  factory IntX.parse(int bits, String value) {
    return IntX.fromBigInt(bits, parseWithUnderscores(value));
  }

  @override
  int toInt() {
    if (signBit != 1) {
      return toUnsignedInt();
    } else {
      int lastIntIndex = max(
        uints.length - (32 ~/ SizedInt.bitsPerListElement),
        0,
      );
      TypedDataList<int> list =
          (uints.sublist(lastIntIndex) as TypedDataList<int>);
      for (int i = 0; i < list.length; i++) {
        list[i] = ~list[i];
      }
      int value = list[0];
      for (int i = 1; i < list.length; i++) {
        value = (value << SizedInt.bitsPerListElement) + list[i];
      }
      return -(value + 1);
    }
  }

  @override
  BigInt toBigInt() {
    if (signBit == 1) {
      return -((~this).toBigInt() + BigInt.one);
    } else {
      return super.toBigInt();
    }
  }

  int? _bitLength;

  @override
  int get bitLength {
    _bitLength ??= calculateBitLength();
    return _bitLength!;
  }

  @override
  int calculateBitLength() {
    if (signBit == 1) {
      return (~this).bitLength + 1;
    } else {
      return super.calculateBitLength();
    }
  }

  int get signBitMask => (1 << modBitSize(bits)) - 1;
  int get signBit => (uints.first & signBitMask) >> (modBitSize(bits) - 1);

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

  static int min(int bits) {
    if (bits < 1 || bits > 32) {
      throw ArgumentError('min only defined for 1 to 32 bits');
    }
    return -pow(2, bits - 1).toInt();
  }

  static BigInt minAsBigInt(int bits) {
    if (bits < 1) {
      throw ArgumentError('bits must be greater than or equal to 1');
    }
    return -(BigInt.one << bits);
  }

  /*static int max(int bits) {
    if (bits < 1 || bits > 32) {
      throw ArgumentError('max only defined for 1 to 32 bits');
    }
    return pow(2, bits - 1).toInt() - 1;
  }*/

  static BigInt maxAsBigInt(int bits) {
    if (bits < 1) {
      throw ArgumentError('bits must be greater than or equal to 1');
    }
    return (BigInt.one << bits) - BigInt.one;
  }

  // Bit-wise operations
  IntX operator ~() {
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = ~uints[i];
    }
    return IntX._(bits, result);
  }
}

class Int8 extends IntX {
  Int8.fromInt(int value) : super._(8, SizedInt.signedIntToList(8, value));

  static int maxAsInt = 127;
  static Int8 max = Int8.fromInt(maxAsInt);
  static int minAsInt = -128;
  static Int8 min = Int8.fromInt(minAsInt);
}

class Int16 extends IntX {
  Int16.fromInt(int value) : super._(16, SizedInt.signedIntToList(16, value));

  static int maxAsInt = 0x7FFF;
  static Int16 max = Int16.fromInt(maxAsInt);
  static int minAsInt = -0x8000;
  static Int16 min = Int16.fromInt(minAsInt);
}

class Int32 extends IntX {
  Int32.fromInt(int value) : super._(32, SizedInt.signedIntToList(32, value));

  Int32.fromBigInt(BigInt value)
    : super._(32, SizedInt.signedBigIntToList(32, value));

  Int32.parse(String value)
    : super._(32, SizedInt.signedBigIntToList(32, parseWithUnderscores(value)));

  static int maxAsInt = 0x7FFFFFFF;
  static Int32 max = Int32.fromInt(maxAsInt);
  static int minAsInt = -0x80000000;
  static Int32 min = Int32.fromInt(minAsInt);
}

class Int64 extends IntX {
  Int64.fromInt(int value) : super._(64, SizedInt.signedIntToList(64, value));

  Int64.fromBigInt(BigInt value)
    : super._(64, SizedInt.signedBigIntToList(64, value));

  Int64.parse(String value)
    : super._(64, SizedInt.signedBigIntToList(64, parseWithUnderscores(value)));

  static BigInt minAsBigInt = parseWithUnderscores('-0x8000_0000_0000_0000');
  static Int64 min = Int64.fromBigInt(minAsBigInt);

  static BigInt maxAsBigInt = parseWithUnderscores('0x7FFF_FFFF_FFFF_FFFF');
  static Int64 max = Int64.fromBigInt(maxAsBigInt);
}

void main() {
  IntX neg512 = IntX.fromInt(10, -512);
  print(neg512.uints);
  IntX pos512 = IntX.fromInt(10, 512);
  print(pos512.uints);
  print(neg512.toInt());
  print(neg512.toUnsignedInt());
}
