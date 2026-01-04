import "dart:math" as math;
import "dart:typed_data";

import "package:sized_ints/intx.dart";

// Change this section to use a different bit size for elements of the list
final int bitsPerListElement = 16;

TypedDataList<int> newList(int length) => Uint16List(length);

TypedDataList<int> listFromInts(List<int> ints) => Uint16List.fromList(ints);
// Everything about bit size of uints should be encapsulated here ^^^

/*
final BigInt elementModAsBigInt = BigInt.one << bitsPerListElement;
final BigInt elementMaskAsBigInt = elementModAsBigInt - BigInt.one;
*/
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
  // add one since this is a signed int
  if (bits < value.bitLength + 1) {
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
    list = list.negated();
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
    list[index] = (absValue % elementModAsBigInt).toInt();
    absValue = absValue >> bitsPerListElement;
    index--;
  }
  if (value < BigInt.zero) {
    for (int i = list.length - 1; i >= 0; i--) {
      list[i] = ~list[i];
    }
    list = list.withOneAdded();
    return extendZerothElementNegative(bits, list);
  } else {
    return extendZerothElementPositive(bits, list);
  }
}

// a bunch of zeros followed by modBitSize(bits) - 1 ones.
int positiveMask(int bits) => (1 << modBitSize(bits)) - 1;

int negativeMask(int bits) => ~positiveMask(bits);

TypedDataList<int> extendZerothElementPositive(
  int bits,
  TypedDataList<int> list,
) {
  TypedDataList<int> result = listFromInts(list);
  result[0] = result[0] & positiveMask(bits);
  return result;
}

TypedDataList<int> extendZerothElementNegative(
  int bits,
  TypedDataList<int> list,
) {
  TypedDataList<int> result = listFromInts(list);
  result[0] = result[0] | negativeMask(bits);
  return result;
}

// number of (rightmost) bits that "count" in the most significant
// element of uints.
int modBitSize(int bits) {
  int mod = bits % bitsPerListElement;
  return mod == 0 ? bitsPerListElement : mod;
}

int expectedUintListLength(int bits) => (bits / bitsPerListElement).ceil();

int maxUnsignedAsInt(int bits) {
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

extension IntOp on int {
  int get signedBitLength => bitLength + 1;
}

extension TypedDataListExtensions on TypedDataList<int> {
  int get bitLength {
    for (int i = 0; i < length; i++) {
      int bl = this[i].bitLength;
      if (bl > 0) {
        return bl + (bitsPerListElement * (length - i - 1));
      }
    }
    return 0;
  }

  TypedDataList<int> withOneAdded() {
    int carry = 1;
    TypedDataList<int> result = listFromInts(this);
    for (int i = length - 1; i >= 0; i--) {
      // remember this is an addition to a Uint with rollover
      result[i] = this[i] + carry;
      if (result[i] == 0) {
        carry = 1;
      } else {
        carry = 0;
      }
    }
    return result;
  }

  TypedDataList<int> shiftedLeft(int n) {
    if (n == 0) {
      return listFromInts(this);
    }
    TypedDataList<int> result = newList(length);
    if (n >= length * bitsPerListElement) {
      return result;
    } else {
      int numElements = n ~/ bitsPerListElement;
      int numBits = n % bitsPerListElement;
      int carry = 0;
      for (int i = length - 1; i >= 0; i--) {
        int replacement =
            i + numElements > length
                ? 0 + carry
                : (this[i + numElements] << numBits) + carry;
        carry =
            i + numElements > length
                ? 0
                : this[i + numElements] >>> (bitsPerListElement - n);
        result[i] = replacement;
      }
    }
    return result;
  }
  
  TypedDataList<int> shiftedRight(int n, int signBit) {
    if (n == 0) {
      return listFromInts(this);
    }

    List<int> ints = List.generate(length, (_) => carryMask);
    TypedDataList<int> result = listFromInts(ints);
    if (n >= length * bitsPerListElement) {
      return result;
    }
    int numElements = n ~/ bitsPerListElement;
    int numBits = n % bitsPerListElement;
    for (int i = 0; i < length; i++) {
      int replacement =
          i - numElements < 0
              ? carryMask
              : (this[i - numElements] >> numBits) & carryMask;
      carryMask = this[i] << (bitsPerListElement - numBits);
      result[i] = replacement;
    }
    return result;
  }

  TypedDataList<int> zeroShiftedRight(int n) {
    if (n == 0) {
      return listFromInts(this);
    }
    TypedDataList<int> result = listFromInts(this);
    if (n >= length * bitsPerListElement) {
      return result;
    }
    int numElements = n ~/ bitsPerListElement;
    int numBits = n % bitsPerListElement;
    int carryMask = 0;
    for (int i = 0; i < length; i++) {
      int replacement = i - numElements < 0 ? 0 : this[i - numElements] | carryMask;
      carryMask = this[i] << (bitsPerListElement - numBits);
      result[i] = replacement;
    }
    return result;
  }

  TypedDataList<int> withBitsFlipped() {
    TypedDataList<int> result = newList(length);
    for (int i = 0; i < length; i++) {
      result[i] = ~this[i] & elementMask;
    }
    return result;
  }

  TypedDataList<int> negated() => withBitsFlipped().withOneAdded();

  TypedDataList<int> plus(TypedDataList<int> other) {
    TypedDataList<int> result = newList(length);
    int carry = 0;
    for (int i = length - 1; i >= 0; i--) {
      int sum = this[i] + other[i] + carry;
      result[i] = sum % elementMod;
      carry = sum ~/ elementMod;
    }
    return result;
  }

  TypedDataList<int> minus(TypedDataList<int> other) {
    return plus(other.negated());
  }
}
