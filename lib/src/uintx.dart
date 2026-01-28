import "dart:typed_data";

import "bit_list.dart";
import "sized_int.dart";

/// Unsigned int of arbitrary bit-length with wraparound for all arithmetic
/// operations. Values are stored as lists of 32-bit non-negative ints,
/// since those are supported on both native and web
abstract class Uint<T extends Uint<T>> extends SizedInt<T> {
  Uint(super.bitList);

  @override
  int toDartSafeInt() {
    if (bitLength > 32) {
      throw throw RangeError(
        "not safe to return $this as int, use toBigInt() instead",
      );
    }
    return bitList.toUnsignedSafeInt();
  }

  @override
  BigInt toBigInt() => bitList.toUnsignedBigInt();

  @override
  int get signBit => 0;

  @override
  String get suffix => "u$bits";

  @override
  // TODO: don't use BigInt
  T operator *(T other) {
    checkCompatible(other);
    BigInt asBigInt = (toBigInt() * other.toBigInt()) % (BigInt.one << bits);
    return construct(BitList.fromUnsignedBigInt(bits, asBigInt));
  }

  @override
  // TODO: don't use BigInt
  T operator ~/(T other) {
    checkCompatible(other);
    BigInt asBigInt = toBigInt() ~/ other.toBigInt();
    return construct(BitList.fromUnsignedBigInt(bits, asBigInt));
  }

  @override
  // TODO: don't use BigInt
  T operator %(T other) {
    checkCompatible(other);
    BigInt asBigInt = toBigInt() % other.toBigInt();
    return construct(BitList.fromUnsignedBigInt(bits, asBigInt));
  }

  @override
  // TODO: don't use BigInt
  T remainder(T other) {
    checkCompatible(other);
    BigInt asBigInt = toBigInt().remainder(other.toBigInt());
    return construct(BitList.fromUnsignedBigInt(bits, asBigInt));
  }
}

class UintX extends Uint<UintX> {
  UintX(super.bitList);

  UintX.fromInt(int bits, int value)
    : super(BitList.fromUnsignedInt(bits, value));

  factory UintX.fromBytes(int bits, Uint8List bytes) {
    BigInt value = BigInt.zero;
    BigInt bi256 = BigInt.from(256);
    for (int b in bytes) {
      value = value * bi256 + BigInt.from(b);
    }
    return UintX.fromBigInt(bits, value);
  }

  factory UintX.fromBigInt(int bits, BigInt value) {
    return UintX(BitList.fromUnsignedBigInt(bits, value));
  }

  factory UintX.parse(int bits, String s) {
    // allow _ wherever in string and just delete it
    return UintX.fromBigInt(bits, BigInt.parse(s.replaceAll("_", "")));
  }

  @override
  UintX construct(BitList bitList) {
    if (bitList.bits != bits) {
      throw ArgumentError(
          "expected BitList with $bits bits, "
              "given: ${bitList.bits} bits"
      );
    }
    return UintX(bitList);
  }
}

class Uint8 extends Uint<Uint8> {
  Uint8(Uint32List uints) : super(BitList(8, uints));
  Uint8.fromInt(int value) : super(BitList.fromUnsignedInt(8, value));

  static final Uint8 max = Uint8.fromInt(maxAsInt);
  static final int maxAsInt = 0xFF;

  @override
  Uint8 construct(BitList bitList) => Uint8(bitList.uints);
}

class Uint16 extends Uint<Uint16> {
  Uint16(Uint32List uints) : super(BitList(16, uints));
  Uint16.fromInt(int value) : super(BitList.fromUnsignedInt(16, value));

  static final Uint16 max = Uint16.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFF;

  @override
  Uint16 construct(BitList bitList) => Uint16(bitList.uints);
}

class Uint32 extends Uint<Uint32> {
  Uint32(Uint32List uints) : super(BitList(32, uints));
  Uint32.fromInt(int value) : super(BitList.fromUnsignedInt(32, value));

  static final Uint32 max = Uint32.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFFFFFF;
  static final Uint32 zero = Uint32.fromInt(0);
  static final Uint32 one = Uint32.fromInt(1);

  @override
  Uint32 construct(BitList bitList) => Uint32(bitList.uints);
}

class Uint64 extends Uint<Uint64> {
  Uint64(Uint32List uints) : super(BitList(64, uints));
  Uint64.fromInt(int value) : super(BitList.fromUnsignedInt(64, value));

  Uint64.fromBigInt(BigInt value)
    : super(BitList.fromUnsignedBigInt(64, value));

  factory Uint64.parse(String value) {
    return Uint64.fromBigInt(BigInt.parse(value.replaceAll("_", "")));
  }

  static Uint64 max = Uint64.fromBigInt(maxAsBigInt);
  static BigInt maxAsBigInt = BigInt.parse("0xFFFFFFFFFFFFFFFF");

  @override
  Uint64 construct(BitList bitList) => Uint64(bitList.uints);
}

class Uint128 extends Uint<Uint128> {
  Uint128(Uint32List uints) : super(BitList(128, uints));
  Uint128.fromInt(int value) : super(BitList.fromUnsignedInt(128, value));

  Uint128.fromBigInt(BigInt value)
      : super(BitList.fromUnsignedBigInt(128, value));

  factory Uint128.parse(String value) {
    return Uint128.fromBigInt(BigInt.parse(value.replaceAll("_", "")));
  }

  static Uint64 max = Uint64.fromBigInt(maxAsBigInt);
  static BigInt maxAsBigInt = BigInt.parse("0xFFFFFFFFFFFFFFFF");

  @override
  Uint128 construct(BitList bitList) => Uint128(bitList.uints);
}

extension IntOp on int {
  String get hex => toRadixString(16);

  bool get safeCrossPlatform => bitLength <= 32;

  bool get safeUnsigned => safeCrossPlatform && this >= 0;
}
