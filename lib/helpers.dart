import "dart:math" as math;
import "dart:typed_data";

import "package:sized_ints/sized_int.dart";
import "package:sized_ints/intx.dart";

// Change this section to use a different bit size for elements of the list
final int bitsPerListElement = 32;

TypedDataList<int> newList(int length) => Uint32List(length);

TypedDataList<int> listFromInts(List<int> ints) => Uint32List.fromList(ints);
// Everything about bit size of uints should be encapsulated here ^^^

final int elementMod = 1 << bitsPerListElement;
final int elementMask = elementMod - 1;

final BigInt elementModAsBigInt = BigInt.one << bitsPerListElement;
final BigInt elementMaskAsBigInt = elementModAsBigInt - BigInt.one;

final int maxUint32 = 0xFFFFFFFF;
final int maxInt32 = 0x7FFFFFFF;
final int minInt32 = -0x80000000;

int minExpressibleAsInt(int bits) {
  if (bits < 1 || bits > 32) {
    throw ArgumentError("min only defined for 1 to 32 bits");
  }
  return -math.pow(2, bits - 1).toInt();
}

BigInt minExpressibleAsBigInt(int bits) {
  if (bits < 1) {
    throw ArgumentError("bits must be greater than or equal to 1");
  }
  return -(BigInt.one << bits);
}

int maxExpressibleAsInt(int bits) {
  if (bits < 1 || bits > 32) {
    throw ArgumentError("max only defined for 1 to 32 bits");
  }
  return math.pow(2, bits - 1).toInt() - 1;
}

BigInt maxExpressibleAsBigInt(int bits) {
  if (bits < 1) {
    throw ArgumentError("bits must be greater than or equal to 1");
  }
  return (BigInt.one << bits) - BigInt.one;
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
    list[index] = value % elementMod;
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
    list[index] = (value % elementModAsBigInt).toInt();
    value = value >> bitsPerListElement;
    index--;
  }
  return list;
}

TypedDataList<int> signedIntToList(int bits, int value) {
  if (value < Int32.minAsInt || value > Int32.maxAsInt) {
    throw ArgumentError(
      'value must be in range [-2^31, 2^31-1], given: $value',
    );
  }
  if (bits < value.bitLength) {
    throw ArgumentError('value $value will not fit in $bits bits');
  }
  TypedDataList<int> list = newList(expectedUintListLength(bits));
  int absValue = value.abs();
  int index = list.length - 1;
  while (absValue > 0) {
    list[index] = absValue % elementMod;
    absValue = absValue >>> bitsPerListElement;
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

TypedDataList<int> signedBigIntToList(int bits, BigInt value) {
  if (value.signedBitLength > bits) {
    throw ArgumentError('value $value will not fit in $bits bits');
  }
  TypedDataList<int> list = newList(expectedUintListLength(bits));
  BigInt absValue = value.abs();
  int index = list.length - 1;
  while (absValue > BigInt.zero) {
    list[index] = (absValue % elementModAsBigInt).toInt();
    absValue = absValue >> bitsPerListElement;
    index--;
  }
  if (value < BigInt.zero) {
    for (int i = list.length - 1; i >= 0; i--) {
      list[i] = ~list[i];
    }
    list = withOneAddedToUints(list, list.length - 1, 0);
  } else {
    list = extendZerothElementPositive(bits, list);
  }
  return list;
}

TypedDataList<int> withOneAddedToUints(
  TypedDataList<int> list,
  int index,
  int carry,
) {
  list[index] = (list[index] + 1) % elementMod;
  if (list[index] == 0 && index > 0) {
    return withOneAddedToUints(list, index - 1, 1);
  } else {
    return list;
  }
}

// a bunch of zeros followed by modBitSize(bits) - 1 ones.
int positiveMask(int bits) => (1 << modBitSize(bits)) - 1;

int negativeMask(int bits) => ~positiveMask(bits);

TypedDataList<int> extendZerothElementPositive(
  int bits,
  TypedDataList<int> list,
) {
  list[0] = list[0] & positiveMask(bits);
  return list;
}

TypedDataList<int> extendZerothElementNegative(
  int bits,
  TypedDataList<int> list,
) {
  list[0] = list[0] | negativeMask(bits);
  return list;
}

// number of (rightmost) bits that "count" in the most significant
// element of uints.
int modBitSize(int bits) {
  int mod = bits % bitsPerListElement;
  return mod == 0 ? bitsPerListElement : mod;
}

int expectedUintListLength(int bits) => (bits / bitsPerListElement).ceil();

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

extension BigIntOp on BigInt {
  int get signedBitLength => bitLength + 1;
  String get hex => toRadixString(16);
}
