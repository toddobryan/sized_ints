import 'package:sized_ints/sized_int.dart';

/// Unsigned int of arbitrary bit-length with wraparound for all arithmetic
/// operations. Values are stored as lists of 32-bit non-negative ints,
/// since those are supported on both native and web
abstract class Uint<T extends Uint<T>> extends SizedInt<T> {
  Uint(super.bits, super.uints);

  @override
  int signBit = 0;

  @override
  int toInt() => toUnsignedInt();

  @override
  int signBitOf(IntList list) => 0;

  @override
  String get suffix => 'u$bits';
}

class UintX extends Uint<UintX> {
  UintX(super.bits, super.uints);

  UintX.fromInt(int bits, int value)
    : super(bits, SizedInt.unsignedIntToList(bits, value));

  factory UintX.fromBigInt(int bits, BigInt value) {
    if (value < BigInt.zero || value > maxUnsignedAsBigInt(bits)) {
      throw ArgumentError(
        'value must be in range [0, 2^$bits-1], given: $value',
      );
    }
    IntList list = SizedInt.unsignedBigIntToList(bits, value);
    return UintX(bits, list);
  }

  factory UintX.parse(int bits, String s) {
    // allow _ wherever in string and just delete it
    return UintX.fromBigInt(bits, BigInt.parse(s.replaceAll('_', '')));
  }

  @override
  UintX construct(IntList newUints) {
    newUints = SizedInt.extendZerothElementPositive(bits, newUints);
    for (int i = 1; i < newUints.length; i++) {
      uints[i] = uints[i] & SizedInt.elementMask;
    }
    return UintX(bits, newUints);
  }
}

class Uint8 extends Uint<Uint8> {
  Uint8(IntList uints) : super(8, uints);
  Uint8.fromInt(int value) : super(8, SizedInt.unsignedIntToList(8, value));

  static final Uint8 max = Uint8.fromInt(maxAsInt);
  static final int maxAsInt = 0xFF;

  @override
  Uint8 construct(IntList newUints) => Uint8(newUints);
}

class Uint16 extends Uint<Uint16> {
  Uint16(IntList uints) : super(16, uints);
  Uint16.fromInt(int value) : super(16, SizedInt.unsignedIntToList(16, value));

  static final Uint16 max = Uint16.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFF;

  @override
  Uint16 construct(IntList newUints) => Uint16(newUints);
}

class Uint32 extends Uint<Uint32> {
  Uint32(IntList uints) : super(32, uints);
  Uint32.fromInt(int value) : super(32, SizedInt.unsignedIntToList(32, value));

  static final Uint32 max = Uint32.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFFFFFF;

  @override
  Uint32 construct(IntList newUints) => Uint32(newUints);
}

class Uint64 extends Uint<Uint64> {
  Uint64(IntList uints) : super(64, uints);
  Uint64.fromInt(int value) : super(64, SizedInt.unsignedIntToList(64, value));

  Uint64.fromBigInt(BigInt value)
    : super(64, SizedInt.unsignedBigIntToList(64, value));

  factory Uint64.parse(String value) {
    return Uint64.fromBigInt(BigInt.parse(value.replaceAll('_', '')));
  }

  (int, int) get values => (uints[0], uints[1]);

  static Uint64 max = Uint64.fromBigInt(maxAsBigInt);
  static BigInt maxAsBigInt = BigInt.parse('0xFFFFFFFFFFFFFFFF');

  @override
  Uint64 construct(IntList newUints) => Uint64(newUints);
}

extension IntOp on int {
  String get hex => toRadixString(16);

  bool get safeCrossPlatform => bitLength <= 32;

  bool get safeUnsigned => safeCrossPlatform && this >= 0;
}

extension BigIntOp on BigInt {
  String get hex => toRadixString(16);
}
