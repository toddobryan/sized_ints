import "dart:typed_data";

import "config.dart";
import "sized_int.dart";

/// Unsigned int of arbitrary bit-length with wraparound for all arithmetic
/// operations. Values are stored as lists of 32-bit non-negative ints,
/// since those are supported on both native and web
abstract class Uint<T extends Uint<T>> extends SizedInt<T> {
  Uint(super.bits, super.uints);

  @override
  int toInt32() => toUnsignedInt();

  @override
  int get signBit => 0;

  @override
  String get suffix => "u$bits";

  @override
  TypedDataList<int> withZerothElementFixed(TypedDataList<int> list) {
    TypedDataList<int> result = listFromInts(list);
    result[0] = result[0] & positiveMask(bits);
    return result;
  }

  @override
  int bitLengthOfInt(int i) => i.bitLength;

  @override
  int bitLengthOfBigInt(BigInt bi) => bi.bitLength;
}

class UintX extends Uint<UintX> {
  UintX(super.bits, super.uints);

  UintX.fromInt(int bits, int value)
    : super(bits, unsignedIntToList(bits, value));

  factory UintX.fromBytes(int bits, Uint8List bytes) {
    BigInt value = BigInt.zero;
    BigInt bi256 = BigInt.from(256);
    for (int b in bytes) {
      value = value * bi256 + BigInt.from(b);
    }
    return UintX.fromBigInt(bits, value);
  }

  factory UintX.fromBigInt(int bits, BigInt value) {
    if (value < BigInt.zero || value > maxUnsignedAsBigInt(bits)) {
      throw ArgumentError(
        "value must be in range [0, 2^$bits-1], given: $value",
      );
    }
    TypedDataList<int> list = unsignedBigIntToList(bits, value);
    return UintX(bits, list);
  }

  factory UintX.parse(int bits, String s) {
    // allow _ wherever in string and just delete it
    return UintX.fromBigInt(bits, BigInt.parse(s.replaceAll("_", "")));
  }

  @override
  UintX construct(TypedDataList<int> newUints) => UintX(bits, newUints);
}

class Uint8 extends Uint<Uint8> {
  Uint8(TypedDataList<int> uints) : super(8, uints);
  Uint8.fromInt(int value) : super(8, unsignedIntToList(8, value));
  Uint8.fromBytes(Uint8List bytes) : super(8, bytes);

  static final Uint8 max = Uint8.fromInt(maxAsInt);
  static final int maxAsInt = 0xFF;

  @override
  Uint8 construct(TypedDataList<int> newUints) => Uint8(newUints);
}

class Uint16 extends Uint<Uint16> {
  Uint16(TypedDataList<int> uints) : super(16, uints);
  Uint16.fromInt(int value) : super(16, unsignedIntToList(16, value));
  Uint16.fromBytes(Uint8List bytes) : super(16, bytes);

  static final Uint16 max = Uint16.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFF;

  @override
  Uint16 construct(TypedDataList<int> newUints) => Uint16(newUints);
}

class Uint32 extends Uint<Uint32> {
  Uint32(TypedDataList<int> uints) : super(32, uints);
  Uint32.fromInt(int value) : super(32, unsignedIntToList(32, value));
  Uint32.fromBytes(Uint8List bytes) : super(32, bytes);

  static final Uint32 max = Uint32.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFFFFFF;

  @override
  Uint32 construct(TypedDataList<int> newUints) => Uint32(newUints);
}

class Uint64 extends Uint<Uint64> {
  Uint64(TypedDataList<int> uints) : super(64, uints);
  Uint64.fromInt(int value) : super(64, unsignedIntToList(64, value));
  Uint64.fromBytes(Uint8List bytes) : super(64, bytes);

  Uint64.fromBigInt(BigInt value)
    : super(64, unsignedBigIntToList(64, value));

  factory Uint64.parse(String value) {
    return Uint64.fromBigInt(BigInt.parse(value.replaceAll("_", "")));
  }

  (int, int) get values => (uints[0], uints[1]);

  static Uint64 max = Uint64.fromBigInt(maxAsBigInt);
  static BigInt maxAsBigInt = BigInt.parse("0xFFFFFFFFFFFFFFFF");

  @override
  Uint64 construct(TypedDataList<int> newUints) => Uint64(newUints);
}

extension IntOp on int {
  String get hex => toRadixString(16);

  bool get safeCrossPlatform => bitLength <= 32;

  bool get safeUnsigned => safeCrossPlatform && this >= 0;
}
