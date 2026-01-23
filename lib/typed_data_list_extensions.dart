import 'dart:typed_data';

import "config.dart";
import 'helpers.dart';

class BitList {
  final int bits;
  final TypedDataList<int> uints;

  BitList(this.bits, this.uints) {
    if (bits < 1) {
      throw ArgumentError("bits must be 1 one or greater, given: $bits");
    }
    int expectedLength = (bits / Config.bitsPerListElement).ceil();
    if (expectedLength != uints.length) {
      throw ArgumentError(
        "uints argument must have length of $expectedLength, "
            "given: ${uints.length}",
      );
    } else if (uints.any((elt) => elt.bitLength > Config.bitsPerListElement)) {
      throw ArgumentError(
        "Max bit length of all elements in list must "
            "be <= ${Config.bitsPerListElement}",
      );
    }
  }

  int? _bitLength;

  int get bitLength {
    _bitLength ??= _calculateBitLength();
    return _bitLength!;
  }

  int _calculateBitLength() {
    for (int i = 0; i < uints.length; i++) {
      int bl = uints[i].bitLength;
      if (bl > 0) {
        return bl + (Config.bitsPerListElement * (uints.length - i - 1));
      }
    }
    return 0;
  }

  bool get isNonZero => uints.any((x) => x != 0);
  bool get isZero => !isNonZero;
}

extension TypedDataListOps on TypedDataList<int> {
  TypedDataList<int> shiftedLeft(int bits, int n) {
    if (n == 0) {
      return Config.listFromInts(this);
    }
    TypedDataList<int> result = Config.newList(length);
    if (n >= length * Config.bitsPerListElement) {
      return result;
    } else {
      int numElements = n ~/ Config.bitsPerListElement;
      int numBits = n % Config.bitsPerListElement;
      int carry = 0;
      for (int i = length - 1; i >= 0; i--) {
        int replacement =
            i + numElements >= length
                ? carry
                : ((this[i + numElements] << numBits) & elementMask(bits, i)) |
                    carry;
        carry =
            i + numElements >= length
                ? 0
                : this[i + numElements] >>>
                    (Config.bitsPerListElement - numBits);
        result[i] = replacement;
      }
    }
    return result;
  }

  TypedDataList<int> shiftedRight(int bits, int n, int signBit) {
    if (n == 0) {
      return Config.listFromInts(this);
    }
    TypedDataList<int> result = Config.listFromInts(
      List.generate(length, (i) => signBit == 1 ? elementMask(bits, i) : 0),
    );
    if (n >= length * Config.bitsPerListElement) {
      return result;
    }
    int numElements = n ~/ Config.bitsPerListElement;
    int numBits = n % Config.bitsPerListElement;
    int carryMask = 0;
    for (int i = numElements; i < length; i++) {
      int replacement = (this[i - numElements] >>> numBits) | carryMask;
      result[i] = replacement;
      carryMask = 0;
    }
    return result;
  }

  TypedDataList<int> zeroShiftedRight(int bits, int n) =>
      shiftedRight(bits, n, 0);

  TypedDataList<int> withBitsFlipped(int bits) {
    TypedDataList<int> result = Config.newList(length);
    for (int i = 0; i < length; i++) {
      result[i] = ~this[i] & elementMask(bits, i);
    }
    return result;
  }

  TypedDataList<int> negated(int bits) =>
      withBitsFlipped(bits).withOneAdded(bits);

  // TODO: this is just wrong
  TypedDataList<int> withOneAdded(int bits) {
    int carry = 1;
    TypedDataList<int> result = Config.listFromInts(this);
    for (int i = length - 1; i >= 0; i--) {
      result[i] = (this[i] + carry) & elementMask(bits, i);
      if (result[i] == 0) {
        carry = 1;
      } else {
        carry = 0;
      }
    }
    return result;
  }

  TypedDataList<int> plus(int bits, TypedDataList<int> other) {
    TypedDataList<int> result = Config.newList(length);
    int carry = 0;
    for (int i = length - 1; i >= 0; i--) {
      int sum = this[i] + other[i] + carry;
      result[i] = sum & elementMask(bits, i);
      carry = sum >>> Config.bitsPerListElement;
    }
    return result;
  }

  TypedDataList<int> minus(int bits, TypedDataList<int> other) {
    return plus(bits, other.negated(bits));
  }
}
