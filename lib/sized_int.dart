import "dart:math";
import "dart:typed_data";

import "helpers.dart";
import "intx.dart";
import "uintx.dart";

abstract class SizedInt<T extends SizedInt<T>> {
  final int bits;
  final TypedDataList<int> uints;
  
  SizedInt(this.bits, this.uints) {
    if (bits < 1) {
      throw ArgumentError("bits must be 1 one or greater, given: $bits");
    }
    int expectedLength = expectedUintListLength(bits);
    if (expectedLength != uints.length) {
      throw ArgumentError(
        "uints argument must have length of $expectedLength, "
        "given: ${uints.length}",
      );
    } /*else if (uints.first.bitLength > modBitSize(bits)) {
      throw ArgumentError(
        "Significant bits in first element must be <= ${modBitSize(bits)}, "
        "given: ${uints.first.bitLength}",
      );
    }*/ else if (uints.any((elt) => elt.bitLength > bitsPerListElement)) {
      throw ArgumentError(
        "Max bit length of all elements in list must "
        "be <= $bitsPerListElement",
      );
    }
  }

  T construct(TypedDataList<int> newUints);

  TypedDataList<int> withZerothElementFixed(TypedDataList<int> list);
  
  int get bitLength => calculateBitLength();

  int calculateBitLength() {
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

  String get bin => uints.map((x) => x.toRadixString(2)).join("_");

  int toInt();

  BigInt toBigInt() {
    BigInt value = BigInt.from(uints[0]);
    for (int i = 1; i < uints.length; i++) {
      value = (value * elementModAsBigInt) + BigInt.from(uints[i]);
    }
    return value;
  }

  int toUnsignedInt() {
    if (bitLength > 32) {
      throw RangeError(
        "not safe to return $this as int, use toBigInt() instead",
      );
    }
    int lastIntIndex = max(
      uints.length - (32 ~/ bitsPerListElement),
      0,
    );
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
  String get binary {
    String s = "0b${uints[0].toRadixString(2)}";
    for (int i = 1; i < uints.length; i++) {
      s = "${s}_${uints[i].toRadixString(2)}";
    }
    return "$s$suffix";
  }

  void checkBitsAreSame(SizedInt other) {
    if (bits != other.bits) {
      throw ArgumentError(
        "receiver and argument must have same number of bits,"
        "given: $bits and ${other.bits}",
      );
    } else if (this is Int && other is Uint || other is Int && this is Uint) {
      throw ArgumentError(
        "receiver and argument must be same type, given: "
        "receiver: $runtimeType, argument: ${other.runtimeType}",
      );
    }
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
    TypedDataList<int> result = newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = ~uints[i];
    }
    return result;
  }

  T _binaryBinOp(T other, int Function(int, int) op) {
    checkBitsAreSame(other);
    TypedDataList<int> result = newList(uints.length);
    for (int i = 0; i < uints.length; i++) {
      result[i] = op(uints[i], other.uints[i]);
    }
    return construct(result);
  }

  // Bit-wise operations
  T operator &(T other) => _binaryBinOp(other, (int t, int o) => t & o);
  T operator |(T other) => _binaryBinOp(other, (int t, int o) => t | o);
  T operator ^(T other) => _binaryBinOp(other, (int t, int o) => t ^ o);
  T operator ~() => construct(withZerothElementFixed(flipBits()));

  // Bit-shift operations
  T operator <<(int n) {
    if (n > bits) {
      return construct(newList(uints.length));
    } else {
      TypedDataList<int> result = listFromInts(uints);

    }
  }
}

