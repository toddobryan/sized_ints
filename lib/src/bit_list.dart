import "dart:math";
import "dart:typed_data";

import "package:collection/collection.dart";

import "extensions.dart";
import "safe_int/env_for_safe_int.dart";

ListEquality<int> leq = ListEquality();

class BitList {
  final int bits;
  // note that these are coupled, if bitsPerListElement were changed to
  // 16 or 64, the type of uints would need to be Uint16List or Uint64List,
  // for example
  final Uint32List uints;
  static const bitsPerListElement = 32;

  BitList._(this.bits, this.uints);

  factory BitList(int bits, Uint32List uints) {
    if (bits < 1) {
      throw ArgumentError("bits must be 1 one or greater, given: $bits");
    }
    int expectedLength = (bits / bitsPerListElement).ceil();
    if (expectedLength != uints.length) {
      throw ArgumentError(
        "uints argument must have length of $expectedLength, "
        "given: ${uints.length}",
      );
    } else if (uints.any((elt) => elt.bitLength > bitsPerListElement)) {
      throw ArgumentError(
        "Max bit length of all elements in list must "
        "be <= $bitsPerListElement",
      );
    }
    return BitList._(bits, uints);
  }

  factory BitList.ints(int bits, List<int> uints) {
    return BitList(bits, Uint32List.fromList(uints));
  }

  factory BitList.int(int bits, int uint) {
    return BitList(bits, Uint32List.fromList([uint]));
  }

  factory BitList.fromUnsignedInt(int bits, int value) {
    if (value < 0) {
      throw ArgumentError("value must be >= 0, given: $value");
    }
    _checkIntSafeForPlatform(value);
    _checkIntFitsInGivenBits(bits, value, isSigned: false);
    Uint32List result = Uint32List(expectedLength(bits));
    int index = result.length - 1;
    while (value > 0) {
      result[index] = value % _elementMod(bits, index);
      value = value >>> bitsPerListElement;
      index--;
    }
    return BitList(bits, result);
  }

  factory BitList.fromUnsignedBigInt(int bits, BigInt value) {
    if (value < BigInt.zero) {
      throw ArgumentError("value must be >= 0, given: $value");
    }
    _checkBigIntFitsInGivenBits(bits, value, isSigned: false);
    Uint32List result = Uint32List(expectedLength(bits));
    int index = result.length - 1;
    while (value > BigInt.zero) {
      result[index] = (value % BigInt.from(_elementMod(bits, index))).toInt();
      value = value >> bitsPerListElement;
      index--;
    }
    return BitList(bits, result);
  }

  factory BitList.fromSignedInt(int bits, int value) {
    _checkIntSafeForPlatform(value);
    _checkIntFitsInGivenBits(bits, value, isSigned: true);
    if (bits < value.signedBitLength) {
      throw ArgumentError("value $value will not fit in $bits bits");
    }
    Uint32List result = Uint32List(expectedLength(bits));
    int absValue = value.abs();
    int index = result.length - 1;
    while (absValue > 0) {
      result[index] = absValue % _elementMod(bits, index);
      absValue = absValue >>> bitsPerListElement;
      index--;
    }
    BitList newValue = BitList(bits, result);
    if (value < 0) {
      newValue = -newValue;
    }
    return newValue;
  }

  factory BitList.fromSignedBigInt(int bits, BigInt value) {
    _checkBigIntFitsInGivenBits(bits, value, isSigned: true);
    Uint32List result = Uint32List(expectedLength(bits));
    BigInt absValue = value.abs();
    int index = result.length - 1;
    while (absValue > BigInt.zero) {
      result[index] = (absValue % BigInt.from(_elementMod(bits, index)))
          .toInt();
      absValue = absValue >> bitsPerListElement;
      index--;
    }
    BitList newValue = BitList(bits, result);
    if (value < BigInt.zero) {
      newValue = -newValue;
    }
    return newValue;
  }

  int get length => uints.length;

  static int expectedLength(int bits) => (bits / bitsPerListElement).ceil();

  BitList copy() {
    return BitList(bits, uints);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BitList &&
          runtimeType == other.runtimeType &&
          bits == other.bits &&
          leq.equals(uints, other.uints);

  @override
  int get hashCode => Object.hash(bits, leq.hash(uints));
  int? _bitLength;

  int get bitLength {
    _bitLength ??= _calculateBitLength();
    return _bitLength!;
  }

  int _calculateBitLength() {
    for (int i = 0; i < uints.length; i++) {
      int bl = uints[i].bitLength;
      if (bl > 0) {
        return bl + (bitsPerListElement * (uints.length - i - 1));
      }
    }
    return 0;
  }

  bool get isNonZero => uints.any((x) => x != 0);
  bool get isZero => !isNonZero;

  /// Finds the nth bit in this BitList, 0-indexed, counting from the right
  int bit(int n) {
    if (n < 0 || n >= bitLength) {
      throw ArgumentError("n must be in range [0, $bitLength), but given $n");
    }
    int index = n ~/ bitsPerListElement;
    int bitIndex = n - (bitsPerListElement * index);
    return (uints[index] & (1 << bitIndex)) >>> bitIndex;
  }

  String toRadixString(int radix) => toUnsignedBigInt().toRadixString(radix);

  BigInt toUnsignedBigInt() {
    BigInt value = BigInt.from(uints[0]);
    for (int i = 1; i < uints.length; i++) {
      value =
          (value * BigInt.from(_elementMod(bits, i))) + BigInt.from(uints[i]);
    }
    return value;
  }

  // may be unsafe, should check for platform safety before calling
  int toUnsignedInt() {
    int lastIntIndex = max(
      uints.length - (EnvForSafeInt.current.maxBitLength ~/ bitsPerListElement),
      0,
    );
    int value = uints[lastIntIndex];
    for (int i = lastIntIndex + 1; i < uints.length; i++) {
      value = (value << bitsPerListElement) + uints[i];
    }
    return value;
  }

  BigInt toSignedBigInt(int signBit) {
    if (signBit == 0) {
      return toUnsignedBigInt();
    } else {
      BigInt abs = (-this).toUnsignedBigInt();
      return -abs;
    }
  }

  // may be unsafe, should check for Platform safety before calling
  int toSignedInt(int signBit) {
    if (signBit == 0) {
      return toUnsignedInt();
    } else {
      int abs = (-this).toUnsignedInt();
      return -abs;
    }
  }

  BitList _binaryBinOp(BitList other, int Function(int, int) op) {
    _checkSameNumberOfBits(this, other);
    Uint32List result = Uint32List(length);
    for (int i = 0; i < length; i++) {
      result[i] = op(uints[i], other.uints[i]);
    }
    return BitList(bits, result);
  }

  BitList operator &(BitList other) =>
      _binaryBinOp(other, (int t, int o) => t & o);

  BitList operator |(BitList other) =>
      _binaryBinOp(other, (int t, int o) => t | o);

  BitList operator ^(BitList other) =>
      _binaryBinOp(other, (int t, int o) => t ^ o);

  BitList operator ~() {
    Uint32List result = Uint32List(length);
    for (int i = 0; i < length; i++) {
      result[i] = ~uints[i] & _elementMask(bits, i);
    }
    return BitList(bits, result);
  }

  BitList operator <<(int n) {
    if (n == 0) {
      return copy();
    }
    Uint32List result = Uint32List(uints.length);
    if (n >= bits) {
      return BitList(bits, result);
    } else {
      for (int i = length - 1; i >= 0; i--) {
        result[i] = _leftReplacement(i, n);
      }
    }
    return BitList(bits, result);
  }

  BitList shiftedRight(int n, int signBit) {
    if (n == 0) {
      return copy();
    }
    Uint32List result = Uint32List.fromList(
      List.generate(length, (i) => signBit == 1 ? _elementMask(bits, i) : 0),
    );
    if (n >= bits) {
      return BitList(bits, result);
    }
    for (int i = n ~/ bitsPerListElement; i < length; i++) {
      result[i] = _rightReplacement(i, n, signBit);
    }
    return BitList(bits, result);
  }

  BitList zeroShiftedRight(int n) => shiftedRight(n, 0);

  BitList operator -() => (~this).withOneAdded();

  BitList withOneAdded() {
    int carry = 1;
    Uint32List result = Uint32List.fromList(uints);
    for (int i = length - 1; i >= 0; i--) {
      result[i] = (uints[i] + carry) & _elementMask(bits, i);
      if (result[i] == 0) {
        carry = 1;
      } else {
        carry = 0;
      }
    }
    return BitList(bits, result);
  }

  BitList operator +(BitList other) {
    _checkSameNumberOfBits(this, other);

    Uint32List result = Uint32List(length);
    int carry = 0;
    for (int i = length - 1; i >= 0; i--) {
      int sum = uints[i] + other.uints[i] + carry;
      result[i] = sum & _elementMask(bits, i);
      carry = sum >>> bitsPerListElement;
    }
    return BitList(bits, result);
  }

  BitList operator -(BitList other) => this + -other;

  int compareTo(int signBit, BitList other, int otherSignBit) {
    if (signBit > otherSignBit) {
      return -1;
    } else if (signBit < otherSignBit) {
      return 1;
    }
    for (int i = 0; i < uints.length; i++) {
      if (uints[i] < other.uints[i]) {
        return -1;
      } else if (uints[i] > other.uints[i]) {
        return 1;
      }
    }
    return 0;
  }

  int _leftReplacement(int index, int n) {
    var (numElements, numBits) = _numElementsAndBits(n);
    int carry = _leftCarry(index, numElements, numBits);
    if (index + numElements >= length) {
      return carry;
    } else {
      int leftShiftedElt = uints[index + numElements] << numBits;
      int plusCarry = leftShiftedElt | carry;
      int eltMask = _elementMask(bits, index);
      return plusCarry & eltMask;
    }
  }

  int _leftCarry(int index, int numElts, int numBits) {
    if (index + numElts + 1 >= length) {
      return 0;
    } else {
      return firstNBits(index + numElts + 1, numBits);
    }
  }

  int _rightReplacement(int index, int n, int signBit) {
    var (numElements, numBits) = _numElementsAndBits(n);
    int carry = _rightCarry(index, numElements, numBits, signBit);
    if (index - numElements < 0) {
      return carry;
    } else {
      int rightShiftedElt = uints[index - numElements] >>> numBits;
      int plusCarry = rightShiftedElt | carry;
      int eltMask = _elementMask(bits, index);
      return plusCarry & eltMask;
    }
  }

  // returns the value at uints[index] padded with the signBit,
  // indexes below 0 return 0 or 0xFFFF_FFFF
  int _valueWithPadding(int index, int signBit) {
    if (index < 0) {
      return signBit == 0 ? 0 : 0xFFFF_FFFF;
    } else {
      return signBit == 0
          ? uints[index]
          : (0xFFFF_FFFF << _bitsMod(bits, index)) | uints[index];
    }
  }

  int _rightCarry(int index, int numElts, int numBits, int signBit) {
    int prevWithPadding = _valueWithPadding(index - numElts - 1, signBit);
    int rightShifted =
        prevWithPadding << max(0, _bitsMod(bits, index) - numBits);
    return rightShifted;
  }

  // finds the first n bits in uints[index]
  int firstNBits(int index, int n) {
    if (n > bitsPerListElement) {
      throw ArgumentError("n should be <= $bitsPerListElement, given $n");
    }
    int nOnes = (1 << n) - 1;
    int movedToFront = nOnes << (_bitsMod(bits, index) - n);
    int bitsInList = uints[index] & movedToFront;
    int movedToEnd = bitsInList >>> (_bitsMod(bits, index) - n);
    return movedToEnd;
  }

  (int, int) _numElementsAndBits(int n) {
    return (n ~/ bitsPerListElement, n % bitsPerListElement);
  }

  @override
  String toString() {
    String vals = uints.map((int x) => _hexFormat(x)).join(", ");
    return "BitList.ints($bits, [$vals])";
  }

  String _hexFormat(int x) {
    String formattedNum = _insertUnderscoresFromRight(x.toRadixString(16));
    return "0x${formattedNum.toUpperCase()}";
  }

  String _insertUnderscoresFromRight(String input) {
    int leftOvers = input.length % 4;
    String leadingZeros = "0" * (leftOvers == 0 ? 0 : 4 - leftOvers);
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buffer.write(input[input.length - 1 - i]);
      if ((i + 1) % 4 == 0 && (i + 1) != input.length) {
        buffer.write("_");
      }
    }
    buffer.write(leadingZeros);
    return buffer.toString().split("").reversed.join("");
  }

  static void _checkIntSafeForPlatform(int value) {
    if (value < EnvForSafeInt.current.minInteger ||
        value > EnvForSafeInt.current.maxInteger) {
      throw ArgumentError(
        "value $value is not in the safe int range for the current platform",
      );
    }
  }

  static void _checkIntFitsInGivenBits(
      int bits,
      int value, {
        required bool isSigned,
      }) {
    int valueBitLength = isSigned ? value.signedBitLength : value.bitLength;
    if (bits < valueBitLength) {
      throw ArgumentError(
        "value can not be represented in $bits bits "
            "(needs $valueBitLength bits)",
      );
    }
  }

  static void _checkBigIntFitsInGivenBits(
      int bits,
      BigInt value, {
        required bool isSigned,
      }) {
    int valueBitLength = isSigned ? value.signedBitLength : value.bitLength;
    if (bits < valueBitLength) {
      throw ArgumentError(
        "value can not be represented in $bits bits "
            "(needs $valueBitLength bits)",
      );
    }
  }

  static void _checkSameNumberOfBits(BitList one, BitList other) {
    if (one.bits != other.bits) {
      throw ArgumentError(
        "both BitLists should have the same number of bits; "
            "given ${one.bits} and ${other.bits}, respectively",
      );
    }
  }

}

/// Returns the number of significant bits at the given index of the list
int _bitsMod(int bits, int index) {
  int numBits = bits % BitList.bitsPerListElement;
  if (index == 0 && numBits != 0) {
    return numBits;
  }
  return BitList.bitsPerListElement;
}

int _elementMod(int bits, int index) {
  int numBits = index == 0 ? _bitsMod(bits, index) : BitList.bitsPerListElement;
  return 1 << numBits;
}

int _elementMask(int bits, int index) => _elementMod(bits, index) - 1;
