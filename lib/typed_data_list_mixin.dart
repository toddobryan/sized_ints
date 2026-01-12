import 'dart:typed_data';

import 'config.dart';
import 'helpers.dart';

extension TypedDataListOps on TypedDataList<int> {

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

  // TODO: fix this
  TypedDataList<int> shiftedRight(int n, int signBit) => zeroShiftedRight(n);


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

  TypedDataList<int> withBitsFlipped(int bits) {
    TypedDataList<int> result = newList(length);
    for (int i = 0; i < length; i++) {
      result[i] = ~this[i] & elementMask(bits, i);
    }
    return result;
  }

  TypedDataList<int> negated(int bits) => withBitsFlipped(bits).withOneAdded();


  // TODO: this is just wrong
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
  TypedDataList<int> plus(int bits, TypedDataList<int> other) {
    TypedDataList<int> result = newList(length);
    int carry = 0;
    for (int i = length - 1; i >= 0; i--) {
      int sum = this[i] + other[i] + carry;
      result[i] = sum % elementMod(bits, i);
      carry = sum ~/ elementMod(bits, i);
    }
    return result;
  }

  TypedDataList<int> minus(int bits, TypedDataList<int> other) {
    return plus(bits, other.negated(bits));
  }
}

