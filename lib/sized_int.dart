import 'dart:math';
import 'dart:typed_data';

import 'package:sized_ints/intx.dart';
import 'package:sized_ints/uintx.dart';

// number of (rightmost) bits that "count" in the most significant Uint32.
int modBitSize(int bits) {
  int mod = bits % SizedInt.bitsPerListElement;
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

  T construct(TypedDataList<int> newUints);

  // Change this section to use a different bit size for elements of the list
  static final int bitsPerListElement = 8;

  static TypedDataList<int> newList(int length) => Uint8List(length);

  static TypedDataList<int> listFromInts(List<int> ints) =>
      Uint8List.fromList(ints);
  // Everything about bit size of uints should be encapsulated here ^^^

  final int bits;
  final TypedDataList<int> uints;

  static final int elementMod = 1 << bitsPerListElement;
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
    for (int i = 0; i < uints.length; i++) {
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
    int value = uints[lastIntIndex];
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

  static TypedDataList<int> unsignedIntToList(int bits, int value) {
    if (value < 0 || value > SizedInt.maxUint32) {
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
    return list;
  }

  static TypedDataList<int> unsignedBigIntToList(int bits, BigInt value) {
    if (value < BigInt.zero) {
      throw ArgumentError('value must be >= 0, given: $value');
    }
    if (value.bitLength > bits) {
      throw ArgumentError('value can not be represented in $bits bits');
    }
    TypedDataList<int> list = SizedInt.newList(expectedUintListLength(bits));
    int index = list.length - 1;
    while (value > BigInt.zero) {
      list[index] = (value % SizedInt.elementModAsBigInt).toInt();
      value = value >> SizedInt.bitsPerListElement;
      index--;
    }
    return list;
  }

  static TypedDataList<int> signedIntToList(int bits, int value) {
    if (value < Int32.minAsInt || value > Int32.maxAsInt) {
      throw ArgumentError(
        'value must be in range [-2^31, 2^31-1], given: $value',
      );
    }
    if (bits < value.bitLength) {
      throw ArgumentError('value $value will not fit in $bits bits');
    }
    TypedDataList<int> list = SizedInt.newList(expectedUintListLength(bits));
    int absValue = value.abs();
    int index = list.length - 1;
    while (absValue > 0) {
      list[index] = absValue % SizedInt.elementMod;
      absValue = absValue >>> SizedInt.bitsPerListElement;
      index--;
    }
    if (value < 0) {
      for (int i = list.length - 1; i >= 0; i--) {
        list[i] = ~list[i] + 1;
      }
      list = extendZerothElementNegative(bits, list);
    } else {
      list = extendZerothElementPositive(bits, list);
    }
    return list;
  }

  static TypedDataList<int> signedBigIntToList(int bits, BigInt value) {
    if (value.signedBitLength > bits) {
      throw ArgumentError('value $value will not fit in $bits bits');
    }
    TypedDataList<int> list = SizedInt.newList(expectedUintListLength(bits));
    BigInt absValue = value.abs();
    int index = list.length - 1;
    while (absValue > BigInt.zero) {
      list[index] = (absValue % SizedInt.elementModAsBigInt).toInt();
      absValue = absValue >> SizedInt.bitsPerListElement;
      index--;
    }
    if (value < BigInt.zero) {
      for (int i = list.length - 1; i >= 0; i--) {
        list[i] = ~list[i];
      }
      // add 1
      list = extendZerothElementNegative(bits, list);
    } else {
      list = extendZerothElementPositive(bits, list);
    }
    return list;
  }

  // a bunch of zeros followed by modBitSize(bits) - 1 ones.
  static int positiveMask(int bits) => (1 << modBitSize(bits)) - 1;

  static int negativeMask(int bits) => (~positiveMask(bits)).toSigned(32);

  static TypedDataList<int> extendZerothElementPositive(
    int bits,
    TypedDataList<int> list,
  ) {
    list[0] = list[0] & positiveMask(bits);
    return list;
  }

  static TypedDataList<int> extendZerothElementNegative(
    int bits,
    TypedDataList<int> list,
  ) {
    list[0] = list[0] | negativeMask(bits);
    return list;
  }

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType || (other as SizedInt).bits != bits) {
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

  TypedDataList<int> flipBits() {
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = ~uints[i];
    }
    return result;
  }

  T _binaryBinOp(T other, int Function(int, int) op) {
    checkBitsAreSame(other);
    TypedDataList<int> result = SizedInt.newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = op(uints[i], other.uints[i]);
    }
    return construct(result);
  }

  T operator &(T other) => _binaryBinOp(other, (int t, int o) => t & o);
  T operator |(T other) => _binaryBinOp(other, (int t, int o) => t | o);
  T operator ^(T other) => _binaryBinOp(other, (int t, int o) => t ^ o);
}

extension BigIntOp on BigInt {
  int get signedBitLength => bitLength + (isNegative ? 1 : 0);
}
