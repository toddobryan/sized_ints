import 'dart:math';
import 'dart:typed_data';

import 'package:sized_ints/intx.dart';
import 'package:sized_ints/uintx.dart';

typedef IntList = TypedDataList<int>;

// number of (rightmost) bits that "count" in the most significant Uint32.
int modBitSize(int bits) {
  int mod = (bits % SizedInt.bitsPerListElement).toInt();
  return mod == 0 ? SizedInt.bitsPerListElement : mod;
}

int expectedUintListLength(int bits) =>
    (bits / SizedInt.bitsPerListElement).ceil();

int maxUnsigned(int bits) {
  if (bits < 1 || bits > 32) {
    throw ArgumentError(
      'bits must be in range [1, 32], given: $bits; '
      'use maxUnsignedAsBigInt for larger values',
    );
  }
  return 1 << bits;
}

BigInt maxUnsignedAsBigInt(int bits) {
  if (bits < 1) {
    throw ArgumentError('bits must be >= 1, given $bits');
  }
  return BigInt.one << bits;
}

BigInt parseWithUnderscores(String value) =>
    BigInt.parse(value.replaceAll('_', ''));

abstract class SizedInt<T extends SizedInt<T>> {
  SizedInt(this.bits, this.uints) {
    if (bits < 1) {
      throw ArgumentError('bits must be 1 one or greater, given: $bits');
    }
    int expectedLength = expectedUintListLength(bits);
    if (expectedLength != uints.length) {
      throw ArgumentError(
        'uints argument must have length of $expectedLength, '
        'given: ${uints.length}',
      );
    } /*else if (uints.first.bitLength > modBitSize(bits)) {
      throw ArgumentError(
        'Significtant bits in first element must be <= ${modBitSize(bits)}, '
        'given: ${uints.first.bitLength}',
      );
    }*/ else if (uints.any((elt) => elt.bitLength > bitsPerListElement)) {
      throw ArgumentError(
        'Max bit length of all elements in list must '
        'be <= $bitsPerListElement',
      );
    }
  }

  T construct(IntList newUints);

  // 0 for non-neg, 1 for neg
  int get signBit;

  // Change this section to use a different bit size for elements of the list
  static final int bitsPerListElement = 16;

  static IntList newList(int length) => Uint16List(length);

  static IntList listFromInts(List<int> ints) => Uint16List.fromList(ints);
  // Everything about bit size of uints should be encapsulated here ^^^

  final int bits;
  final IntList uints;

  // need to use pow instead of << since 32 bitsPerListElement would get cut
  // off in JS
  static final int elementMod = pow(2, bitsPerListElement).toInt();
  static final int elementMask = elementMod - 1;

  static final BigInt elementModAsBigInt = BigInt.one << bitsPerListElement;
  static final BigInt elementMaskAsBigInt = elementModAsBigInt - BigInt.one;

  static final int maxUint32 = 0xFFFFFFFF;
  static final int maxInt32 = 0x7FFFFFFF;
  static final int minInt32 = -0x80000000;

  int? _bitLength;
  int get bitLength {
    _bitLength ??= calculateBitLength();
    return _bitLength!;
  }

  int calculateBitLength() {
    int bl = min(uints[0].bitLength, modBitSize(bits));
    if (bl > 0) {
      return bl + (bitsPerListElement * (uints.length - 1));
    }
    for (int i = 1; i < uints.length; i++) {
      int bl = uints[i].bitLength;
      if (bl > 0) {
        return bl + (bitsPerListElement * (uints.length - i - 1));
      }
    }
    return 0;
  }

  bool? _isNonZero;
  bool get isNonZero => _isNonZero ??= uints.any((x) => x != 0);
  bool get isZero => !isNonZero;

  String get bin => uints.map((x) => x.toRadixString(2)).join('_');

  int toInt();

  BigInt toBigInt() {
    BigInt value = BigInt.from(uints[0]);
    for (int i = 1; i < uints.length; i++) {
      value = (value * SizedInt.elementModAsBigInt) + BigInt.from(uints[i]);
    }
    return value;
  }

  int toUnsignedInt() {
    if (bitLength > 32) {
      throw RangeError(
        'not safe to return $this as int, use toBigInt() instead',
      );
    }
    int lastIntIndex = max(
      uints.length - (32 ~/ SizedInt.bitsPerListElement),
      0,
    );
    int value = uints[lastIntIndex] & SizedInt.elementMask;
    for (int i = lastIntIndex + 1; i < uints.length; i++) {
      value = (value << SizedInt.bitsPerListElement) + uints[i];
    }
    return value;
  }

  String get suffix;

  String toRadixString(int radix) =>
      '${toBigInt().toRadixString(radix)}$suffix';

  @override
  String toString() => toRadixString(10);

  String get hex => toRadixString(16);
  String get binary {
    String s = '0b${uints[0].toRadixString(2)}';
    for (int i = 1; i < uints.length; i++) {
      s = '${s}_${uints[i].toRadixString(2)}';
    }
    return '$s$suffix';
  }

  void checkBitsAreSame(SizedInt other) {
    if (bits != other.bits) {
      throw ArgumentError(
        'receiver and argument must have same number of bits,'
        'given: $bits and ${other.bits}',
      );
    } else if (this is Int && other is Uint || other is Int && this is Uint) {
      throw ArgumentError(
        'receiver and argument must be same type, given: '
        'receiver: $runtimeType, argument: ${other.runtimeType}',
      );
    }
  }

  // TODO: any way to combine these four? Hard since BigInt doesn't extend num
  static IntList unsignedIntToList(int bits, int value) {
    if (value < 0 || value > SizedInt.maxUint32) {
      throw ArgumentError('value must be in range [0, 2^32-1], given: $value');
    }
    if (bits < value.bitLength) {
      throw ArgumentError('value $value will not fit in $bits bits');
    }
    IntList list = SizedInt.newList(expectedUintListLength(bits));
    int index = list.length - 1;
    while (value > 0) {
      list[index] = value % SizedInt.elementMod;
      value = value >>> SizedInt.bitsPerListElement;
      index--;
    }
    return list;
  }

  static IntList unsignedBigIntToList(int bits, BigInt value) {
    if (value < BigInt.zero) {
      throw ArgumentError('value must be >= 0, given: $value');
    }
    if (value.bitLength > bits) {
      throw ArgumentError('value can not be represented in $bits bits');
    }
    IntList list = SizedInt.newList(expectedUintListLength(bits));
    int index = list.length - 1;
    while (value > BigInt.zero) {
      list[index] = (value % SizedInt.elementModAsBigInt).toInt();
      value = value >> SizedInt.bitsPerListElement;
      index--;
    }
    return list;
  }

  static IntList signedIntToList(int bits, int value) {
    if (value < Int32.minAsInt || value > Int32.maxAsInt) {
      throw ArgumentError(
        'value must be in range [-2^31, 2^31-1], given: $value',
      );
    }
    if (bits < value.signedBitLength) {
      throw ArgumentError('value $value will not fit in $bits bits');
    }
    IntList list = SizedInt.newList(expectedUintListLength(bits));
    int absValue = value.abs();
    int index = list.length - 1;
    while (absValue > 0) {
      list[index] = absValue % SizedInt.elementMod;
      absValue = absValue >>> SizedInt.bitsPerListElement;
      index--;
    }
    if (value < 0) {
      list = list.negate();
      list = extendZerothElementNegative(bits, list);
    } else {
      list = extendZerothElementPositive(bits, list);
    }
    return list;
  }

  static IntList signedBigIntToList(int bits, BigInt value) {
    if (value.signedBitLength > bits) {
      throw ArgumentError('value $value will not fit in $bits bits');
    }
    IntList list = SizedInt.newList(expectedUintListLength(bits));
    BigInt absValue = value.abs();
    int index = list.length - 1;
    while (absValue > BigInt.zero) {
      list[index] = (absValue % SizedInt.elementModAsBigInt).toInt();
      absValue = absValue >> SizedInt.bitsPerListElement;
      index--;
    }
    if (value < BigInt.zero) {
      list = list.negate();
      list = extendZerothElementNegative(bits, list);
    } else {
      list = extendZerothElementPositive(bits, list);
    }
    return list;
  }

  // a bunch of zeros followed by modBitSize(bits) - 1 ones.
  static int positiveMask(int bits) => (1 << modBitSize(bits)) - 1;

  static int negativeMask(int bits) => (~positiveMask(bits)).toSigned(32);

  static IntList extendZerothElementPositive(int bits, IntList list) {
    list[0] = list[0] & positiveMask(bits);
    return list;
  }

  static IntList extendZerothElementNegative(int bits, IntList list) {
    list[0] = list[0] | negativeMask(bits);
    return list;
  }

  int signBitOf(IntList list) => list.signBit(bits);

  // Bitwise operations

  T _binaryBinOp(T other, int Function(int, int) op) {
    checkBitsAreSame(other);
    IntList result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = op(uints[i], other.uints[i]);
    }
    return construct(result);
  }

  T operator &(T other) => _binaryBinOp(other, (int t, int o) => t & o);
  T operator |(T other) => _binaryBinOp(other, (int t, int o) => t | o);
  T operator ^(T other) => _binaryBinOp(other, (int t, int o) => t ^ o);

  T operator ~() {
    IntList result = uints.flipBits();
    result =
        (signBit == 1)
            ? SizedInt.extendZerothElementNegative(bits, result)
            : SizedInt.extendZerothElementPositive(bits, result);
    return construct(result);
  }

  // Comparison methods

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType || (other as SizedInt).bits != bits) {
      return false;
    }
    return uints.equals(other.uints);
  }

  @override
  int get hashCode => Object.hash(bits, Object.hashAll(uints.toList()));

  bool _compare(
    T other,
    bool Function(IntList, IntList) posPos,
    bool Function(IntList, IntList) negNeg,
    bool posNeg,
    bool negPos,
  ) {
    checkBitsAreSame(other);
    if (signBit == 0 && other.signBit == 0) {
      return posPos(this.uints, other.uints);
    } else if (signBit == 1 && other.signBit == 1) {
      return negNeg(this.uints, other.uints);
    } else if (signBit == 0 && other.signBit == 1) {
      return posNeg;
    } else {
      // both negative
      return negPos;
    }
  }

  bool operator <(T other) => _compare(
    other,
    (IntList t, IntList o) => t.lessThan(o),
    (IntList t, IntList o) => o.negate().lessThan(t.negate()),
    false,
    true,
  );
  bool operator >(T other) => _compare(
    other,
    (IntList t, IntList o) => t.greaterThan(o),
    (IntList t, IntList o) => o.negate().greaterThan(t.negate()),
    true,
    false,
  );
  bool operator <=(T other) => !(this > other);
  bool operator >=(T other) => !(this < other);

  // Bit-shift operations
  T operator <<(int n) {
    IntList result = uints.shiftBitsLeft(n);
    if (signBitOf(result) == 1) {
      result = SizedInt.extendZerothElementNegative(bits, result);
    } else {
      result = SizedInt.extendZerothElementPositive(bits, result);
    }
    return construct(result);
  }

  T operator >>>(int n) => construct(uints.shiftBitsRightUnsigned(n));

  T operator >>(int n) => construct(uints.shiftBitsRightSigned(n));

  // Arithmetic operators
  T operator +(T other) {
    checkBitsAreSame(other);
    IntList result = SizedInt.newList(uints.length);
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
    T multiplicand = construct(SizedInt.listFromInts(uints));
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

extension IntOp on int {
  int get signedBitLength => bitLength + 1;
}

extension BigIntOp on BigInt {
  int get signedBitLength => bitLength + 1;
}

extension IntListOp on IntList {
  int signBit(int bits) {
    int signBitMask = (1 << modBitSize(bits)) - 1;
    return (first & signBitMask) >> (modBitSize(bits) - 1);
  }

  IntList flipBits() {
    IntList result = SizedInt.newList(length);
    result[0] = ~this[0] & SizedInt.elementMask;
    for (int i = 1; i < length; i++) {
      result[i] = ~this[i];
    }
    return result;
  }

  IntList negate() {
    IntList result = SizedInt.newList(length);
    int carry = 1; // add 1 to negate
    for (int i = result.length - 1; i >= 0; i--) {
      int newVal = (~this[i] & SizedInt.elementMask) + carry;
      result[i] = newVal & SizedInt.elementMask;
      carry = (newVal.bitLength > elementSizeInBytes * 8) ? 1 : 0;
    }
    return result;
  }

  bool lessThan(IntList other) {
    assert(
      length == other.length && elementSizeInBytes == other.elementSizeInBytes,
    );
    for (int i = 0; i < length; i++) {
      if (this[i] < other[i]) {
        return true;
      } else if (this[i] == other[i]) {
        // continue
      } else {
        return false;
      }
    }
    return false;
  }

  bool greaterThan(IntList other) {
    assert(
      length == other.length && elementSizeInBytes == other.elementSizeInBytes,
    );
    for (int i = 0; i < length; i++) {
      if (this[i] > other[i]) {
        return true;
      } else if (this[i] == other[i]) {
        // continue
      } else {
        return false;
      }
    }
    return false;
  }

  bool equals(IntList other) {
    assert(
      length == other.length && elementSizeInBytes == other.elementSizeInBytes,
    );
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }

  IntList _shiftElementsLeft(int slots) {
    if (slots == 0) {
      return SizedInt.listFromInts(toList());
    } else if (slots >= length) {
      return SizedInt.newList(length);
    } else {
      IntList result = SizedInt.newList(length);
      for (int i = 0; i < length - slots; i++) {
        result[i] = this[i + slots];
      }
      return result;
    }
  }

  IntList shiftBitsLeft(int n) {
    int elts = n ~/ SizedInt.bitsPerListElement;
    IntList result = _shiftElementsLeft(elts);
    int bits = n % SizedInt.bitsPerListElement;
    int carry = 0;
    for (int i = length - 1 - elts; i >= 0; i--) {
      result[i] = (this[i + elts] << bits) + carry;
      carry = this[i + elts] >>> (SizedInt.bitsPerListElement - bits);
    }
    return result;
  }

  IntList _shiftElementsRightUnsigned(int slots) {
    if (slots == 0) {
      return SizedInt.listFromInts(toList());
    } else if (slots >= length) {
      return SizedInt.newList(length);
    } else {
      IntList result = SizedInt.newList(length);
      for (int i = length - 1; i > 0; i--) {
        result[i] = this[i - slots];
      }
      for (int i = 0; i < slots; i++) {
        result[i] = 0;
      }
      return result;
    }
  }

  IntList shiftBitsRightUnsigned(int n) {
    IntList result = SizedInt.newList(length);
    int bits = n % SizedInt.bitsPerListElement;
    int carryMask = 0;
    for (int i = 0; i < length; i++) {
      result[i] = (this[i] >>> bits) | carryMask;
      carryMask = this[i] << (SizedInt.bitsPerListElement - bits);
    }
    int slots = n ~/ SizedInt.bitsPerListElement;
    return result._shiftElementsRightUnsigned(slots);
  }

  IntList shiftBitsRightSigned(int n) {
    // TODO
    return shiftBitsRightUnsigned(n);
  }
}
