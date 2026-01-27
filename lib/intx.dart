import "dart:typed_data";

import "bit_list.dart";
import "extensions.dart";
import "sized_int.dart";

/// Value is stored as a big-endian int. If the value is negative,
/// uint32List.first is padded with 1s.
abstract class Int<T extends Int<T>> extends SizedInt<T> {
  Int(super.bitList);

  @override
  int toInt32() {
    if (signedBitLength > 32) {
      throw throw RangeError(
        "not safe to return $this as int, use toBigInt() instead",
      );
    }
    return bitList.toSignedInt32(signBit);
  }

  @override
  BigInt toBigInt() => bitList.toSignedBigInt(signBit);

  @override
  int get bitLength => signBit == 0 ? bitList.bitLength : (~bitList).bitLength;

  @override
  int get signBit => bitList.firstNBits(0, 1);

  @override
  String get suffix => "i$bits";

  @override
  // TODO: don't use BigInt
  T operator *(T other) {
    checkCompatible(other);
    BigInt thisBigInt = toBigInt();
    BigInt otherBigInt = other.toBigInt();
    BigInt mod = BigInt.one << bits;
    BigInt signBreak = mod >> 1;

    BigInt modded = (thisBigInt * otherBigInt) % mod;
    if (modded >= signBreak) {
      return construct(BitList.fromSignedBigInt(bits, modded - mod));
    } else {
      return construct(BitList.fromSignedBigInt(bits, modded));
    }
  }

  @override
  // TODO: don't use BigInt
  T operator ~/(T other) {
    checkCompatible(other);
    BigInt asBigInt = toBigInt() ~/ other.toBigInt();
    return construct(BitList.fromSignedBigInt(bits, asBigInt));
  }

  @override
  // TODO: don't use BigInt
  T operator %(T other) {
    checkCompatible(other);
    BigInt asBigInt = toBigInt() % other.toBigInt();
    return construct(BitList.fromSignedBigInt(bits, asBigInt));
  }

  @override
  // TODO: don't use BigInt
  T remainder(T other) {
    checkCompatible(other);
    BigInt asBigInt = toBigInt().remainder(other.toBigInt());
    return construct(BitList.fromSignedBigInt(bits, asBigInt));
  }
}


class IntX extends Int<IntX> {
  IntX._(super.bitList);

  factory IntX.fromInt(int bits, int value) => IntX._(BitList.fromSignedInt(bits, value));

  factory IntX.fromBigInt(int bits, BigInt value) =>
      IntX._(BitList.fromSignedBigInt(bits, value));

  factory IntX.parse(int bits, String value) {
    return IntX.fromBigInt(bits, parseWithUnderscores(value));
  }

  @override
  IntX construct(BitList bitList) {
    if (bitList.bits != bits) {
      throw ArgumentError(
          "expected BitList with $bits bits, "
              "given: ${bitList.bits} bits"
      );
    }
    return IntX._(bitList);
  }
}

class Int8 extends Int<Int8> {
  Int8(Uint32List uints) : super(BitList(8, uints));
  Int8.fromInt(int value) : super(BitList.fromSignedInt(8, value));

  @override
  Int8 construct(BitList bitList) => Int8(bitList.uints);

  static int maxAsInt = 127;
  static Int8 max = Int8.fromInt(maxAsInt);
  static int minAsInt = -128;
  static Int8 min = Int8.fromInt(minAsInt);
}

class Int16 extends Int<Int16> {
  Int16(Uint32List uints) : super(BitList(16, uints));
  Int16.fromInt(int value) : super(BitList.fromSignedInt(16, value));

  @override
  Int16 construct(BitList bitList) => Int16(bitList.uints);

  static int maxAsInt = 0x7FFF;
  static Int16 max = Int16.fromInt(maxAsInt);
  static int minAsInt = -0x8000;
  static Int16 min = Int16.fromInt(minAsInt);
}

class Int32 extends Int<Int32> {
  Int32(Uint32List uints) : super(BitList(32, uints));
  Int32.fromInt(int value) : super(BitList.fromSignedInt(32, value));

  @override
  Int32 construct(BitList bitList) => Int32(bitList.uints);

  Int32.fromBigInt(BigInt value) : super(BitList.fromSignedBigInt(32, value));

  Int32.parse(String value) :
        super(BitList.fromSignedBigInt(32, parseWithUnderscores(value)));

  static int maxAsInt = 0x7FFFFFFF;
  static Int32 max = Int32.fromInt(maxAsInt);
  static int minAsInt = -0x80000000;
  static Int32 min = Int32.fromInt(minAsInt);
}

class Int64 extends Int<Int64> {
  Int64(Uint32List uints) : super(BitList(64, uints));
  Int64.fromInt(int value) : super(BitList.fromSignedInt(64, value));

  @override
  Int64 construct(BitList bitList) => Int64(bitList.uints);

  Int64.fromBigInt(BigInt value) : super(BitList.fromSignedBigInt(64, value));

  Int64.parse(String value)
    : super(BitList.fromSignedBigInt(64, parseWithUnderscores(value)));

  static BigInt minAsBigInt = parseWithUnderscores("-0x8000_0000_0000_0000");
  static Int64 min = Int64.fromBigInt(minAsBigInt);
  static BigInt maxAsBigInt = parseWithUnderscores("0x7FFF_FFFF_FFFF_FFFF");
  static Int64 max = Int64.fromBigInt(maxAsBigInt);
}

class Int128 extends Int<Int128> {
  Int128(Uint32List uints) : super(BitList(128, uints));
  Int128.fromInt(int value) : super(BitList.fromSignedInt(128, value));

  @override
  Int128 construct(BitList bitList) => Int128(bitList.uints);

  Int128.fromBigInt(BigInt value) : super(BitList.fromSignedBigInt(128, value));

  Int128.parse(String value)
      : super(BitList.fromSignedBigInt(128, parseWithUnderscores(value)));

  static BigInt minAsBigInt = -(BigInt.one << 127);
  static Int128 min = Int128.fromBigInt(minAsBigInt);
  static BigInt maxAsBigInt = (BigInt.one << 128) - BigInt.one;
  static Int128 max = Int128.fromBigInt(maxAsBigInt);
}
