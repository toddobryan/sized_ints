import 'dart:typed_data';

import 'package:sized_ints/sized_int.dart';

/// Unsigned int of arbitrary bit-length with wraparound for all arithmetic
/// operations. Values are stored as lists of 32-bit non-negative ints,
/// since those are supported on both native and web
abstract class Uint<T extends Uint<T>> extends SizedInt<T> {
  Uint(super.bits, super.uints);

  @override
  int toInt() => toUnsignedInt();

  @override
  String get suffix => 'u$bits';

  // Comparison methods

  bool _compare(T other, bool Function(int, int) op) {
    checkBitsAreSame(other);
    for (int i = 0; i < uints.length; i++) {
      if (op(uints[i], other.uints[i])) {
        return true;
      } else if (uints[i] == other.uints[i]) {
        // continue
      } else {
        return false;
      }
    }
    // they're equal
    return false;
  }

  bool operator <(T other) => _compare(other, (int t, int o) => t < o);
  bool operator >(T other) => _compare(other, (int t, int o) => t > o);
  bool operator <=(T other) => !(this > other);
  bool operator >=(T other) => !(this < other);

  // Bit-wise operations
  T operator ~() {
    TypedDataList<int> result = flipBits();
    result = SizedInt.extendZerothElementPositive(bits, result);
    return construct(result);
  }

  // Bit-shift operations
  T operator <<(int n) {
    if (n > bits) {
      return construct(SizedInt.newList(uints.length));
    }
    T result = this as T;
    for (int i = 0; i < n ~/ SizedInt.bitsPerListElement; i++) {
      result = result._shiftElementsLeft();
    }
    result = result._shiftBitsLeft(n % SizedInt.bitsPerListElement);
    return result;
  }

  T operator >>>(int n) {
    if (n > bits) {
      return construct(SizedInt.newList(uints.length));
    }
    T result = this as T;
    for (int i = 0; i < n ~/ SizedInt.bitsPerListElement; i++) {
      result = result._shiftElementsRight();
    }
    result = result._shiftBitsRight(n % SizedInt.bitsPerListElement);
    return result;
  }

  T operator >>(int n) => this >>> n; // for unsigned, >> is the same as >>>

  T _shiftElementsLeft() {
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length - 1; i++) {
      result[i] = uints[i + 1];
    }
    result = SizedInt.extendZerothElementPositive(bits, result);
    return construct(result);
  }

  T _shiftBitsLeft(int n) {
    if (n < 0 || n >= SizedInt.bitsPerListElement) {
      throw ArgumentError(
        'n must be in range [0, ${SizedInt.bitsPerListElement - 1}], '
        'given: $n',
      );
    }
    TypedDataList<int> result = SizedInt.newList(uints.length);
    int carry = 0;
    for (int i = uints.length - 1; i >= 0; i--) {
      result[i] = (uints[i] << n) + carry;
      carry = uints[i] >>> (SizedInt.bitsPerListElement - n);
    }
    result = SizedInt.extendZerothElementPositive(bits, result);
    return construct(result);
  }

  T _shiftElementsRight() {
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = uints.length - 1; i > 0; i--) {
      result[i] = uints[i - 1];
    }
    return construct(result);
  }

  T _shiftBitsRight(int n) {
    if (n < 0 || n >= SizedInt.bitsPerListElement) {
      throw ArgumentError(
        'n must be in range [0, ${SizedInt.bitsPerListElement - 1}], '
        'given: $n',
      );
    }
    TypedDataList<int> result = SizedInt.newList(uints.length);
    int carryMask = 0;
    for (int i = 0; i < uints.length; i++) {
      result[i] = (uints[i] >> n) | carryMask;
      carryMask = uints[i] << (SizedInt.bitsPerListElement - n);
    }
    return construct(result);
  }

  // Arithmetic operators

  T operator +(T other) {
    checkBitsAreSame(other);
    TypedDataList<int> result = SizedInt.newList(uints.length);
    int carry = 0;
    for (int i = uints.length - 1; i >= 0; i--) {
      int sum = uints[i] + other.uints[i] + carry;
      result[i] = sum % SizedInt.elementMod;
      carry = sum ~/ SizedInt.elementMod;
    }
    result = SizedInt.extendZerothElementPositive(bits, result);
    return construct(result);
  }

  T operator -(T other) {
    checkBitsAreSame(other);
    T max = this as T;
    T min = other;
    bool negate = false;
    if (max < min) {
      max = other;
      min = this as T;
      negate = true;
    }
    T result = -min + max;
    if (negate) {
      result = -result;
    }
    return result;
  }

  T operator -() {
    return ~this + construct(SizedInt.unsignedIntToList(bits, 1));
  }

  T operator *(T other) {
    checkBitsAreSame(other);
    T result = construct(SizedInt.unsignedIntToList(bits, 0));
    if (isZero || other.isZero) {
      return result;
    }
    T multiplicand = this as T;
    int count = 0;
    while (multiplicand.isNonZero) {
      if (multiplicand.uints.last & 1 == 1) {
        result = result + (other << count);
      }
      multiplicand = multiplicand >> 1;
      count++;
    }
    return result;
  }

  /// Convert both to double (with possible loss of precision)
  /// and divide
  double operator /(T other) =>
      toBigInt().toDouble() / other.toBigInt().toDouble();

  T operator ~/(T other) => _divAndMod(other).$1;

  T operator %(T other) => _divAndMod(other).$2;

  (T, T) _divAndMod(T other) {
    checkBitsAreSame(other);
    if (other.isZero) {
      throw UnsupportedError('Integer division by zero');
    }
    if (other > (this as T)) {
      return (construct(SizedInt.unsignedIntToList(bits, 0)), this as T);
    }
    T dividend = this as T;
    T quotient = construct(SizedInt.unsignedIntToList(bits, 0));
    T one = construct(SizedInt.unsignedIntToList(bits, 1));
    while (dividend.bitLength >= other.bitLength && dividend >= other) {
      int count = 0;
      int bitDiff = dividend.bitLength - other.bitLength;
      while (count < bitDiff && (other << (count + 1)) < dividend) {
        count++;
      }
      dividend = dividend - (other << count);
      quotient = quotient + (one << count);
    }
    return (quotient, dividend);
  }
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
    TypedDataList<int> list = SizedInt.unsignedBigIntToList(bits, value);
    return UintX(bits, list);
  }

  factory UintX.parse(int bits, String s) {
    // allow _ wherever in string and just delete it
    return UintX.fromBigInt(bits, BigInt.parse(s.replaceAll('_', '')));
  }

  @override
  UintX construct(TypedDataList<int> newUints) => UintX(bits, newUints);
}

class Uint8 extends Uint<Uint8> {
  Uint8(TypedDataList<int> uints) : super(8, uints);
  Uint8.fromInt(int value) : super(8, SizedInt.unsignedIntToList(8, value));

  static final Uint8 max = Uint8.fromInt(maxAsInt);
  static final int maxAsInt = 0xFF;

  @override
  Uint8 construct(TypedDataList<int> newUints) => Uint8(newUints);
}

class Uint16 extends Uint<Uint16> {
  Uint16(TypedDataList<int> uints) : super(16, uints);
  Uint16.fromInt(int value) : super(16, SizedInt.unsignedIntToList(16, value));

  static final Uint16 max = Uint16.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFF;

  @override
  Uint16 construct(TypedDataList<int> newUints) => Uint16(newUints);
}

class Uint32 extends Uint<Uint32> {
  Uint32(TypedDataList<int> uints) : super(32, uints);
  Uint32.fromInt(int value) : super(32, SizedInt.unsignedIntToList(32, value));

  static final Uint32 max = Uint32.fromInt(maxAsInt);
  static final int maxAsInt = 0xFFFFFFFF;

  @override
  Uint32 construct(TypedDataList<int> newUints) => Uint32(newUints);
}

class Uint64 extends Uint<Uint64> {
  Uint64(TypedDataList<int> uints) : super(64, uints);
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
  Uint64 construct(TypedDataList<int> newUints) => Uint64(newUints);
}

extension IntOp on int {
  String get hex => toRadixString(16);

  bool get safeCrossPlatform => bitLength <= 32;

  bool get safeUnsigned => safeCrossPlatform && this >= 0;
}

extension BigIntOp on BigInt {
  String get hex => toRadixString(16);
}
