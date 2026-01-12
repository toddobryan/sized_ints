import 'dart:typed_data';

import 'package:sized_ints/typed_data_list_mixin.dart';

import 'config.dart';

final int maxUint32 = 0xFFFFFFFF;
final int maxInt32 = 0x7FFFFFFF;
final int minInt32 = -0x80000000;

int bitsMod(int bits) {
  int numBits = bits % bitsPerListElement;
  return numBits == 0  ? bitsPerListElement : numBits;
}

int elementMod(int bits, int index) {
  int numBits = index == 0 ? bitsMod(bits) : bitsPerListElement;
  return 1 << numBits;
}

int elementMask(int bits, int index) => elementMod(bits, index) - 1;

int expectedUintListLength(int bits) => (bits / bitsPerListElement).ceil();

int minInt(int bits) {
  if (bits < 1 || bits > 32) {
    throw ArgumentError("min only defined for 1 to 32 bits");
  }
  return -(1 << (bits - 1));
}

BigInt minBigInt(int bits) {
  if (bits < 1) {
    throw ArgumentError("bits must be greater than or equal to 1");
  }
  return -(BigInt.one << (bits - 1));
}

int maxInt(int bits) {
  if (bits < 1 || bits > 32) {
    throw ArgumentError("max only defined for 1 to 32 bits");
  }
  return (1 << (bits - 1)) - 1;
}

BigInt maxBigInt(int bits) {
  if (bits < 1) {
    throw ArgumentError("bits must be greater than or equal to 1");
  }
  return (BigInt.one << (bits - 1)) - BigInt.one;
  }

int maxUnsignedInt(int bits) {
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

TypedDataList<int> unsignedIntToList(int bits, int value) {
  if (value < 0 || value > maxUint32) {
    throw ArgumentError('value must be in range [0, 2^32-1], given: $value');
  }
  if (bits < value.bitLength) {
    throw ArgumentError('value $value will not fit in $bits bits');
  }
  TypedDataList<int> list = newList(expectedUintListLength(bits));
  int index = list.length - 1;
  while (value > 0) {
    list[index] = value % elementMod(bits, index);
    value = value >>> bitsPerListElement;
    index--;
  }
  return list;
}

TypedDataList<int> unsignedBigIntToList(int bits, BigInt value) {
  if (value < BigInt.zero) {
    throw ArgumentError('value must be >= 0, given: $value');
  }
  if (value.bitLength > bits) {
    throw ArgumentError('value can not be represented in $bits bits');
  }
  TypedDataList<int> list = newList(expectedUintListLength(bits));
  int index = list.length - 1;
  while (value > BigInt.zero) {
    list[index] = (value % BigInt.from(elementMod(bits, index))).toInt();
    value = value >> bitsPerListElement;
    index--;
  }
  return list;
}

TypedDataList<int> signedIntToList(int bits, int value) {
  if (value < minInt32 || value > maxInt32) {
    throw ArgumentError(
      'value must be in range [-2^31, 2^31-1], given: $value',
    );
  }
  if (bits < value.signedBitLength) {
    throw ArgumentError('value $value will not fit in $bits bits');
  }
  TypedDataList<int> list = newList(expectedUintListLength(bits));
  int absValue = value.abs();
  int index = list.length - 1;
  while (absValue > 0) {
    list[index] = absValue % elementMod(bits, index);
    absValue = absValue >>> bitsPerListElement;
    index--;
  }
  if (value < 0) {
    list = list.negated(bits);
  }
  return list;
}

TypedDataList<int> signedBigIntToList(int bits, BigInt value) {
  if (bits < value.signedBitLength) {
    throw ArgumentError('value $value will not fit in $bits bits');
  }
  TypedDataList<int> list = newList(expectedUintListLength(bits));
  BigInt absValue = value.abs();
  int index = list.length - 1;
  while (absValue > BigInt.zero) {
    list[index] = (absValue % BigInt.from(elementMod(bits, index))).toInt();
    absValue = absValue >> bitsPerListElement;
    index--;
  }
  if (value < BigInt.zero) {
    list = list.negated(bits);
  }
  return list;
}

extension BigIntOp on BigInt {
  int get signedBitLength => bitLength + 1;
  String get hex => toRadixString(16);
}

extension IntOp on int {
  int get signedBitLength => bitLength + 1;
}

BigInt parseWithUnderscores(String value) =>
    BigInt.parse(value.replaceAll('_', ''));