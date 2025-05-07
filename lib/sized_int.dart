import 'dart:math';
import 'dart:typed_data';

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

abstract class SizedInt {
  SizedInt(this.bits, this.uints) {
    if (bits < 1) {
      throw ArgumentError('bits must be 1 one or greater, given: $bits');
    }
    int expectedLength = expectedUintListLength(bits);
    if (expectedLength != uints.length) {
      throw ArgumentError(
        'IntList32 argument must have length of $expectedLength, '
        'given: ${uints.length}',
      );
    } else if (uints.first.bitLength > modBitSize(bits)) {
      throw ArgumentError(
        'Significtant bits in first element must be <= ${modBitSize(bits)}, '
        'given: ${uints.first.bitLength}',
      );
    } else if (uints.any((elt) => elt.bitLength > bitsPerListElement)) {
      throw ArgumentError(
        'Max bit length of all elements in list must '
        'be <= $bitsPerListElement',
      );
    }
  }

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
    if (_bitLength == null) {
      for (int i = 0; i < uints.length; i++) {
        int bl = uints[i].bitLength;
        if (bl > 0) {
          _bitLength = bl + (bitsPerListElement * (uints.length - i - 1));
        }
      }
      _bitLength = 0;
    }
    return _bitLength!;
  }

  bool? _isNonZero;
  bool get isNonZero => _isNonZero ??= uints.any((x) => x != 0);
  bool get isZero => !isNonZero;

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
      value = value << SizedInt.bitsPerListElement + uints[i];
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
    } else if (runtimeType != other.runtimeType) {
      throw ArgumentError(
        'receiver and argument must be same time, given: '
        'receiver: $runtimeType, argument: ${other.runtimeType}',
      );
    }
  }
}
