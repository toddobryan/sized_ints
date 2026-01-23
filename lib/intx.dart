import "dart:math" as math;
import "dart:typed_data";

import "helpers.dart";
import "sized_int.dart";
import "config.dart";

/// Value is stored as a big-endian int. If the value is negative,
/// uint32List.first is padded with 1s.
abstract class Int<T extends Int<T>> extends SizedInt<T> {
  Int(super.bits, super.uints);

  @override
  int toInt32() {
    if (signBit != 1) {
      return toUnsignedInt();
    } else if (signedBitLength > 32) {
      throw throw RangeError(
        "not safe to return $this as int, use toBigInt() instead",
      );
    }
    int indexWhereLastIntStarts = math.max(
      uints.length - (32 ~/ Config.bitsPerListElement),
      0,
    );
    TypedDataList<int> list =
    (uints.sublist(indexWhereLastIntStarts) as TypedDataList<int>);
    for (int i = 0; i < list.length; i++) {
      list[i] = ~list[i] & elementMask(bits, i);
    }
    int value = list[0];
    for (int i = 1; i < list.length; i++) {
      value = (value << Config.bitsPerListElement) + list[i];
    }
    return -(value + 1);
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

  @override
  int get signBit {
    int numSpaces = bitsMod(bits, 0) - 1;
    return (uints.first & (1 << numSpaces)) == 0 ? 0 : 1;
  }


  @override
  String toRadixString(int radix) {
    if (signBit == 1) {
      BigInt unsigned = (~this).toBigInt() + BigInt.one;
      return "-${unsigned.toRadixString(radix)}$suffix";
    } else {
      return super.toRadixString(radix);
    }
  }

  @override
  String get suffix => "i$bits";
}


class IntX extends Int<IntX> {
  IntX._(super.bits, super.uints);

  factory IntX.fromInt(int bits, int value) {
    if (value < minInt32 || value > maxInt32) {
      throw ArgumentError(
        "value must be in range [-2^31, 2^31 - 1], "
        "use fromBigInt for values outside the range",
      );
    }
    if (bits < value.bitLength) {
      throw ArgumentError(
        "value can not be represented in the given number of bits",
      );
    }
    return IntX._(bits, signedIntToList(bits, value));
  }

  factory IntX.fromBigInt(int bits, BigInt value) {
    BigInt min = minBigInt(bits);
    BigInt max = maxBigInt(bits);
    if (value < min || value > max) {
      throw ArgumentError(
        "value can not be represented in the given number of bits",
      );
    }
    return IntX._(bits, signedBigIntToList(bits, value));
  }

  factory IntX.parse(int bits, String value) {
    IntX ix = IntX.fromBigInt(bits, parseWithUnderscores(value));
    print(ix.toRadixString(16));
    return ix;
  }

  @override
  IntX construct(TypedDataList<int> newUints) => IntX._(bits, newUints);
}

class Int8 extends Int<Int8> {
  Int8(TypedDataList<int> newUints) : super(8, newUints);
  Int8.fromInt(int value) : super(8, signedIntToList(8, value));

  @override
  Int8 construct(TypedDataList<int> newUints) => Int8(newUints);

  static int maxAsInt = 127;
  static Int8 max = Int8.fromInt(maxAsInt);
  static int minAsInt = -128;
  static Int8 min = Int8.fromInt(minAsInt);
}

class Int16 extends Int<Int16> {
  Int16(TypedDataList<int> newUints) : super(16, newUints);
  Int16.fromInt(int value) : super(16, signedIntToList(16, value));

  @override
  Int16 construct(TypedDataList<int> newUints) => Int16(newUints);

  static int maxAsInt = 0x7FFF;
  static Int16 max = Int16.fromInt(maxAsInt);
  static int minAsInt = -0x8000;
  static Int16 min = Int16.fromInt(minAsInt);
}

class Int32 extends Int<Int32> {
  Int32(TypedDataList<int> newUints) : super(32, newUints);
  Int32.fromInt(int value) : super(32, signedIntToList(32, value));

  Int32.fromBigInt(BigInt value)
    : super(32, signedBigIntToList(32, value));

  Int32.parse(String value)
    : super(32, signedBigIntToList(32, parseWithUnderscores(value)));

  @override
  Int32 construct(TypedDataList<int> newUints) => Int32(newUints);

  static int maxAsInt = 0x7FFFFFFF;
  static Int32 max = Int32.fromInt(maxAsInt);
  static int minAsInt = -0x80000000;
  static Int32 min = Int32.fromInt(minAsInt);
}

class Int64 extends Int<Int64> {
  Int64(TypedDataList<int> newUints) : super(64, newUints);
  Int64.fromInt(int value) : super(64, signedIntToList(64, value));

  Int64.fromBigInt(BigInt value)
    : super(64, signedBigIntToList(64, value));

  Int64.parse(String value)
    : super(64, signedBigIntToList(64, parseWithUnderscores(value)));

  @override
  Int64 construct(TypedDataList<int> newUints) => Int64(newUints);

  static BigInt minAsBigInt = parseWithUnderscores("-0x8000_0000_0000_0000");
  static Int64 min = Int64.fromBigInt(minAsBigInt);
  static BigInt maxAsBigInt = parseWithUnderscores("0x7FFF_FFFF_FFFF_FFFF");
  static Int64 max = Int64.fromBigInt(maxAsBigInt);
}

void main() {
  BigInt bi = BigInt.from(-0x29a03d3a);
  print(bi.hex);
  IntX i = IntX.fromBigInt(33, bi);
  print(i);
  print(i.hex);
  print((~i).hex);
}
