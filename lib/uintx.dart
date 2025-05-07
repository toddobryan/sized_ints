import 'dart:typed_data';

import 'package:sized_ints/sized_int.dart';

/// Unsigned int of arbitrary bit-length with wraparound for all arithmetic
/// operations. Values are stored as lists of 32-bit non-negative ints,
/// since those are supported on both native and web
class UintX extends SizedInt {
  UintX(super.bits, super.uints);

  factory UintX.fromInt(int bits, int value) {
    if (value < 0 || value >= SizedInt.maxUint32) {
      throw ArgumentError('value must be in range [0, 2^32-1], given: $value');
    }
    if (bits < value.bitLength) {
      throw ArgumentError('value $value will not fit in $bits bits');
    }
    TypedDataList<int> list = SizedInt.newList(expectedUintListLength(bits));
    int index = list.length - 1;
    while (value > 0) {
      list[index] = value % SizedInt.elementMod;
      value = value >>> SizedInt.bitsPerListElement;
      index--;
    }
    return UintX(bits, list);
  }

  factory UintX.fromBigInt(int bits, BigInt value) {
    if (value < BigInt.zero || value > maxUnsignedAsBigInt(bits)) {
      throw ArgumentError(
        'value must be in range [0, 2^$bits-1], given: $value',
      );
    }
    TypedDataList<int> list = SizedInt.newList(expectedUintListLength(bits));
    int index = list.length - 1;
    while (value > BigInt.zero) {
      list[index] = (value % SizedInt.elementModAsBigInt).toInt();
      value = value >> SizedInt.bitsPerListElement;
      index--;
    }
    return UintX(bits, list);
  }

  factory UintX.parse(int bits, String s) {
    // allow _ wherever in string and just delete it
    return UintX.fromBigInt(bits, BigInt.parse(s.replaceAll('_', '')));
  }

  @override
  int toInt() => toUnsignedInt();

  @override
  String get suffix => 'u$bits';

  // Comparison methods

  @override
  bool operator ==(Object other) {
    if (other is! UintX || other.bits != bits) {
      return false;
    }
    for (int i = 0; i < uints.length; i++) {
      if (uints[i] != other.uints[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(bits, Object.hashAll(uints.toList()));

  bool _compare(UintX other, bool Function(int, int) op) {
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

  bool operator <(UintX other) => _compare(other, (int t, int o) => t < o);
  bool operator >(UintX other) => _compare(other, (int t, int o) => t > o);
  bool operator <=(UintX other) => !(this > other);
  bool operator >=(UintX other) => !(this < other);

  // Bit-wise operations
  UintX operator ~() {
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = ~uints[i];
    }
    extendZerothElement(result);
    return UintX(bits, result);
  }

  void extendZerothElement(TypedDataList<int> list) {
    list[0] = list[0] & (1 << modBitSize(bits));
  }

  UintX _binaryBinOp(UintX other, int Function(int, int) op) {
    checkBitsAreSame(other);
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = op(uints[i], other.uints[i]);
    }
    return UintX(bits, result);
  }

  UintX operator &(UintX other) => _binaryBinOp(other, (int t, int o) => t & o);
  UintX operator |(UintX other) => _binaryBinOp(other, (int t, int o) => t | o);
  UintX operator ^(UintX other) => _binaryBinOp(other, (int t, int o) => t ^ o);

  // Bit-shift operations
  UintX operator <<(int n) {
    if (n > bits) {
      return UintX(bits, SizedInt.newList(uints.length));
    }
    UintX result = this;
    for (int i = 0; i < n ~/ SizedInt.bitsPerListElement; i++) {
      result = result._shiftElementsLeft();
    }
    result = result._shiftBitsLeft(n % SizedInt.bitsPerListElement);
    return result;
  }

  UintX operator >>>(int n) {
    if (n > bits) {
      return UintX(bits, SizedInt.newList(uints.length));
    }
    UintX result = this;
    for (int i = 0; i < n ~/ SizedInt.bitsPerListElement; i++) {
      result = result._shiftElementsRight();
    }
    result = result._shiftBitsRight(n % SizedInt.bitsPerListElement);
    return result;
  }

  UintX operator >>(int n) => this >>> n; // for unsigned, >> is the same as >>>

  UintX _shiftElementsLeft() {
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length - 1; i++) {
      result[i] = uints[i + 1];
    }
    extendZerothElement(result);
    return UintX(bits, result);
  }

  UintX _shiftBitsLeft(int n) {
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
    extendZerothElement(result);
    return UintX(bits, result);
  }

  UintX _shiftElementsRight() {
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = uints.length - 1; i > 0; i--) {
      result[i] = uints[i - 1];
    }
    return UintX(bits, result);
  }

  UintX _shiftBitsRight(int n) {
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
    return UintX(bits, result);
  }

  // Arithmetic operators

  UintX operator +(UintX other) {
    checkBitsAreSame(other);
    TypedDataList<int> result = SizedInt.newList(uints.length);
    int carry = 0;
    for (int i = uints.length - 1; i >= 0; i--) {
      int sum = uints[i] + other.uints[i] + carry;
      result[i] = sum % SizedInt.elementMod;
      carry = sum ~/ SizedInt.elementMod;
    }
    extendZerothElement(result);
    return UintX(bits, result);
  }

  UintX operator -(UintX other) {
    checkBitsAreSame(other);
    UintX max = this;
    UintX min = other;
    bool negate = false;
    if (max < min) {
      max = other;
      min = this;
      negate = true;
    }
    UintX result = -min + max;
    if (negate) {
      result = -result;
    }
    return result;
  }

  UintX operator -() {
    return ~this + UintX.fromInt(bits, 1);
  }

  UintX operator *(UintX other) {
    checkBitsAreSame(other);
    UintX result = UintX.fromInt(bits, 0);
    if (isZero || other.isZero) {
      return result;
    }
    UintX multiplicand = this;
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
  double operator /(UintX other) =>
      toBigInt().toDouble() / other.toBigInt().toDouble();

  UintX operator ~/(UintX other) => _divAndMod(other).$1;

  UintX operator %(UintX other) => _divAndMod(other).$2;

  (UintX, UintX) _divAndMod(UintX other) {
    checkBitsAreSame(other);
    if (other.isZero) {
      throw UnsupportedError('Integer division by zero');
    }
    if (other > this) {
      return (UintX.fromInt(bits, 0), this);
    }
    UintX dividend = this;
    UintX quotient = UintX.fromInt(bits, 0);
    UintX one = UintX.fromInt(bits, 1);
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

class Uint8 extends UintX {
  Uint8.fromInt(int value) : super(8, SizedInt.listFromInts([value]));
}

class Uint16 extends UintX {
  Uint16.fromInt(int value) : super(16, SizedInt.listFromInts([value]));
}

class Uint32 extends UintX {
  Uint32._(TypedDataList<int> list) : super(32, list);

  factory Uint32.fromInt(int value) {
    if (value < 0) {
      throw ArgumentError('value must be non-negative, given: $value');
    } else if (value.bitLength > 32) {
      throw ArgumentError(
        'use Uint64.fromBigInt() or Uint64(upper, lower) for value with bitLength > 32',
      );
    }
    return Uint32._(SizedInt.listFromInts([value]));
  }

  static final int max = 0xFFFFFFFF;
}

class Uint64 extends UintX {
  Uint64._(TypedDataList<int> list) : super(64, list);

  factory Uint64(int upper, int lower) {
    if (!upper.safeUnsigned) {
      throw ArgumentError('upper must be in range [0, 2^32-1], given: $upper');
    } else if (!lower.safeUnsigned) {
      throw ArgumentError('lower must be in range [0, 2^32-1], given: $lower');
    } else {
      return Uint64.fromBigInt((BigInt.from(upper) << 32) + BigInt.from(lower));
    }
  }

  factory Uint64.fromInt(int value) {
    if (value < 0) {
      throw ArgumentError('value must be non-negative, given: $value');
    } else if (value.bitLength > 32) {
      throw ArgumentError(
        'use Uint64.fromBigInt() or Uint64(upper, lower) for value with bitLength > 32',
      );
    }
    return Uint64(0, value);
  }

  factory Uint64.fromBigInt(BigInt value) {
    if (value.bitLength > 64) {
      throw ArgumentError(
        'value must have bitLength <= 64, given: ${value.bitLength}',
      );
    }
    int upper = (value ~/ (BigInt.one << 32)).toInt();
    int lower = (value % (BigInt.one << 32)).toInt();
    return Uint64(upper, lower);
  }

  factory Uint64.parse(String value) {
    UintX v = UintX.parse(64, value);
    return Uint64(v.uints[0], v.uints[1]);
  }

  static Uint64 max = Uint64(0xFFFFFFFF, 0xFFFFFFFF);

  (int, int) get values => (uints[0], uints[1]);
}

extension IntOp on int {
  String get hex => toRadixString(16);

  bool get safeCrossPlatform => bitLength <= 32;

  bool get safeUnsigned => safeCrossPlatform && this >= 0;
}

extension BigIntOp on BigInt {
  String get hex => toRadixString(16);
}
