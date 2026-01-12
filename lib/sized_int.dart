import "dart:math";
import "dart:typed_data";

import "package:sized_ints/typed_data_list_mixin.dart";

import "config.dart";
import "helpers.dart";
import "intx.dart";

abstract class SizedInt<T extends SizedInt<T>> {
  final int bits;
  final TypedDataList<int> uints;

  SizedInt(this.bits, this.uints) {
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
  }

  T construct(TypedDataList<int> newUints);

  int get signBit;

  TypedDataList<int> withZerothElementFixed(TypedDataList<int> list);

  TypedDataList<int> extendZerothElementPositive(TypedDataList<int> list) {
    TypedDataList<int> result = listFromInts(list);
    result[0] = result[0] & elementMod(bits, 0);
    return result;
  }

  TypedDataList<int> extendZerothElementNegative(TypedDataList<int> list) {
    TypedDataList<int> result = listFromInts(list);
    result[0] = result[0] | elementMod(bits, 0);
    return result;
  }

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

  int get signedBitLength => bitLength + 1;

  bool get isNonZero => uints.any((x) => x != 0);
  bool get isZero => !isNonZero;

  int toInt32();

  // only works for positive value; overridden in IntX
  BigInt toBigInt() {
    BigInt value = BigInt.from(uints[0]);
    for (int i = 1; i < uints.length; i++) {
      value = (value * BigInt.from(elementMod(bits, i))) + BigInt.from(uints[i]);
    }
    return value;
  }

  int toUnsignedInt() {
    if (bitLength > 32) {
      throw RangeError(
        "not safe to return $this as int, use toBigInt() instead",
      );
    }
    int lastIntIndex = max(uints.length - (32 ~/ bitsPerListElement), 0);
    int value = uints[lastIntIndex];
    for (int i = lastIntIndex + 1; i < uints.length; i++) {
      value = (value << bitsPerListElement) + uints[i];
    }
    return value;
  }

  String get suffix;

  String toRadixString(int radix) =>
      "${toBigInt().toRadixString(radix)}$suffix";

  @override
  String toString() => toRadixString(10);

  String get hex => toRadixString(16);

  String get bin =>
      "0b${uints.map((x) => x.toRadixString(2)).join("_")}$suffix";

  void checkBitsAreSame(SizedInt other) {
    if (bits != other.bits) {
      throw ArgumentError(
        "receiver and argument must have same number of bits,"
        "given: $bits and ${other.bits}",
      );
    } else if (this is Int != other is Int) {
      throw ArgumentError(
        "receiver and argument must be same type, given: "
        "receiver: $runtimeType, argument: ${other.runtimeType}",
      );
    }
  }

  T _binaryBinRel(T other, int Function(int, int) op) {
    checkBitsAreSame(other);
    TypedDataList<int> result = newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = op(uints[i], other.uints[i]);
    }
    return construct(result);
  }

  // Bit-wise operations
  T operator &(T other) => _binaryBinRel(other, (int t, int o) => t & o);
  T operator |(T other) => _binaryBinRel(other, (int t, int o) => t | o);
  T operator ^(T other) => _binaryBinRel(other, (int t, int o) => t ^ o);
  T operator ~() => withBitsFlipped();

  // Bit-shift operations
  T operator <<(int n) =>
      construct(withZerothElementFixed(listFromInts(uints).shiftedLeft(n)));
  T operator >>(int n) => construct(
    withZerothElementFixed(listFromInts(uints).shiftedRight(n, signBit)),
  );
  T operator >>>(int n) => construct(listFromInts(uints).zeroShiftedRight(n));

  // comparison operators
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

  bool _compare(T other, bool Function(int, int) op) {
    checkBitsAreSame(other);
    if (signBit != other.signBit) {
      return !op(signBit, other.signBit);
    }
    for (int i = 0; i < uints.length; i++) {
      if (op(uints[i], other.uints[i])) {
        return true;
      } else if (uints[i] == other.uints[i]) {
        // continue, because later uints may be different
      } else {
        return false;
      }
    }
    // they're equal
    return false;
  }

  bool operator <(T other) => _compare(other, (int t, int o) => t < o);
  bool operator >(T other) => _compare(other, (int t, int o) => t > o);
  bool operator <=(T other) => !(this > other);
  bool operator >=(T other) => !(this < other);

  // Arithmetic operators

  T operator +(T other) {
    checkBitsAreSame(other);
    TypedDataList<int> result = newList(uints.length);
    int carry = 0;
    for (int i = uints.length - 1; i >= 0; i--) {
      int sum = uints[i] + other.uints[i] + carry;
      result[i] = sum % elementMod(bits, i);
      carry = sum ~/ elementMod(bits, i);
    }
    return construct(withZerothElementFixed(result));
  }

  T operator -(T other) {
    checkBitsAreSame(other);
    TypedDataList<int> result = uints.minus(bits, other.uints);
    result = withZerothElementFixed(result);
    return construct(result);
  }

  T operator -() => construct(withZerothElementFixed(uints.negated(bits)));

  // Booth's algorithm for signed integer multiplication.
  //
  T operator *(T other) {
    checkBitsAreSame(other);
    TypedDataList<int> ac = newList(uints.length);
    TypedDataList<int> m = uints; // not mutated, so don't need copy
    TypedDataList<int> qr = listFromInts(other.uints); // is mutated
    int qNPlus1 = 0; // extra LSP for qr
    for (int count = other.bitLength; count > 0; count--) {
      if (qr.last.isOdd && qNPlus1 == 0) {
        ac = ac.plus(bits, m);
      } else if (qr.last.isEven && qNPlus1 == 1) {
        ac = ac.minus(bits, m);
      }
      qNPlus1 = qr.last & 1;
      qr = qr.shiftedRight(1, ac.last & 1);
      ac = ac.shiftedRight(1, ac.first >> (bitsPerListElement - 1));
    }
    return construct(withZerothElementFixed(qr));
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
      throw UnsupportedError("Integer division by zero");
    }
    if (other > (this as T)) {
      return (construct(unsignedIntToList(bits, 0)), this as T);
    }
    T dividend = this as T;
    T quotient = construct(unsignedIntToList(bits, 0));
    T one = construct(unsignedIntToList(bits, 1));
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

  T withBitsFlipped() {
    TypedDataList<int> result = newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = ~uints[i] & elementMask(bits, i);
    }
    return construct(result);
  }
}
