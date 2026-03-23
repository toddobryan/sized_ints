import "bit_list.dart";

/// A super-class for fixed-size integer classes that work across all Dart
/// environments.
///
/// Internally, SizedInts are stored using BitLists, which are a wrapper
/// for Uint32List, which should be safe across native, web, and wasm backends.
abstract class SizedInt<T extends SizedInt<T>> {
  /// The BitList which represents this SizedInt.
  final BitList bitList;

  /// Constucts a SizedInt backed by the given BitList.
  SizedInt(this.bitList);

  /// A type-aware constructor which allows any SizedInt to construct an
  /// instance of itself.
  T construct(BitList newBitList);

  /// 0 or 1 depending on whether this SizedInt is positive or negative.
  int get signBit;

  /// The number of bits in this SizedInt
  int get bits => bitList.bits;

  /// The number of significant bits in this SizedInt, excluding the sign bit.
  int get bitLength => bitList.bitLength;

  /// The number of significant bits in this SizedInt, including the sign bit.
  int get signedBitLength => bitLength + 1;

  /// Whether this SizedInt represents a non-zero number.
  bool get isNonZero => bitList.isNonZero;

  /// Whether this SizedInt represents 0.
  bool get isZero => !isNonZero;

  /// The BigInt equivalent to this SizedInt.
  BigInt toBigInt();

  /// A safe int for this platform.
  ///
  /// If this SizedInt can't be safely returned as an int, this method throws
  /// an exception.
  int toSafeInt();

  /// The closest double to this SizedInt.
  double toDouble() => toBigInt().toDouble();

  /// A suffix for the String version of the SizedInt.
  ///
  /// It is u for unsigned or i for signed, followed by the number of bits.
  String get suffix;

  /// Special forms for base 2, 8, and 16 that include a suffix.
  String toRadixString(int radix) {
    String maybeMinus = signBit == 0 ? "" : "-";
    var (pre, suf) = switch(radix) {
      2 => ("0b", suffix),
      8 => ("0o", suffix),
      10 => ("", suffix),
      16 => ("0x", suffix),
      _ => ("", "__${radix}__$suffix"),
    };
    String num = signBit == 0
        ? bitList.toRadixString(radix).toUpperCase()
        : (-bitList).toRadixString(radix).toUpperCase();
    return "$pre$maybeMinus$num$suf";
  }

  @override
  /// A base-10 representation of the SizedInt with a suffix indicating whether
  /// signed or unsigned and the number of bits.
  String toString() => toRadixString(10);

  /// Equivalent to toRadixString(2).
  String get bin => toRadixString(2);
  /// Equivalent to toRadixString(8).
  String get oct => toRadixString(8);
  /// Equivalent to toRadixString(16).
  String get hex => toRadixString(16);

  /// Throws an error if other is a different type or bit size than this.
  void checkCompatible(SizedInt other) {
    if (runtimeType != other.runtimeType) {
      throw ArgumentError(
        "receiver and argument must be same type, given: "
            "receiver: $runtimeType, argument: ${other.runtimeType}",
      );
    }
    if (bitList.bits != other.bitList.bits) {
      throw ArgumentError(
        "receiver and argument must have same number of bits, "
            "given: ${bitList.bits} and ${other.bitList.bits}",
      );
    }
  }

  // Bit-wise operations
  /// Bitwise-& of this and other. this and other must be the same type and
  /// bit size.
  T operator &(T other) {
    checkCompatible(other);
    return construct(bitList & other.bitList);
  }

  /// Bitwise-| of this and other. this and other must be the same type and
  /// bit size.
  T operator |(T other) {
    checkCompatible(other);
    return construct(bitList | other.bitList);
  }

  /// Bitwise-^ of this and other. this and other must be the same type and
  /// bit size.
  T operator ^(T other) {
    checkCompatible(other);
    return construct(bitList ^ other.bitList);
  }

  /// Bitwise-~ of this.
  T operator ~() => construct(~bitList);

  // Bit-shift operations
  /// Left-shifts this SizedInt by n bits.
  ///
  /// Bits that fall off the left side are lost. Zero bits are added
  /// on the right.
  T operator <<(int n) => construct(bitList << n);

  /// Right-shifts this SizedInt by n bits.
  ///
  /// Bits that fall off the right side are lost. Bits added on the left match
  /// the sign bit.
  T operator >>(int n) =>
      construct(bitList.shiftedRight(n, signBit));

  /// Zero-right-shifts this SizedInt by n bits.
  ///
  /// Bits that fall off the right side are lost. Zero bits are added
  /// on the left.
  T operator >>>(int n) => construct(bitList.zeroShiftedRight(n));

  // comparison operators
  @override
  /// Whether this is the same type and bit size as other and contains the
  /// same bits.
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType ||
        (other as SizedInt).bitList.bits != bitList.bits) {
      return false;
    }
    return bitList == other.bitList;
  }

  @override
  int get hashCode => bitList.hashCode;

  /// If this and other are different types or have different bit sizes, throws
  /// an error. Otherwise, returns a negative integer, zero, or a positive
  /// integer depending on whether this SizedInt is less than, equal to, or
  /// greater than other.
  int compareTo(T other) {
    checkCompatible(other);
    return bitList.compareTo(signBit, other.bitList, other.signBit);
  }

  /// Whether this SizedInt is less than other.
  ///
  /// Throws an error if this and other are different types or have different
  /// bit sizes.
  bool operator <(T other) => compareTo(other) < 0;

  /// Whether this SizedInt is greater than other.
  ///
  /// Throws an error if this and other are different types or have different
  /// bit sizes.
  bool operator >(T other) => compareTo(other) > 0;

  /// Whether this SizedInt is less than or equal to other.
  ///
  /// Throws an error if this and other are different types or have different
  /// bit sizes.
  bool operator <=(T other) => compareTo(other) <= 0;

  /// Whether this SizedInt is greater than or equal to other.
  ///
  /// Throws an error if this and other are different types or have different
  /// bit sizes.
  bool operator >=(T other) => compareTo(other) >= 0;

  // Arithmetic operators

  /// If this and other are the same type and the same bit size, returns a
  /// SizedInt equivalent to this + other, rolling over at the bit size.
  /// Otherwise, throws an error.
  T operator +(T other) {
    checkCompatible(other);
    return construct(bitList + other.bitList);
  }

  /// If this and other are the same type and the same bit size, returns a
  /// SizedInt equivalent to this - other, rolling over at the bit size.
  /// Otherwise, throws an error.
  T operator -(T other) {
    checkCompatible(other);
    return construct(bitList - other.bitList);
  }

  /// Returns the SizedInt equivalent to -this. If this is an unsigned
  /// representation, returns 2^bits - this.
  T operator -() => construct(-bitList);

  /// Convert both to double (with possible loss of precision)
  /// and divide.
  double operator /(T other) =>
      toBigInt().toDouble() / other.toBigInt().toDouble();

  /// Multiplication with bit rollover.
  T operator *(T other);

  /// Integer division.
  T operator ~/(T other);

  /// The SizedInt equivalent to this % other.
  T operator %(T other);

  /// The SizedInt equivalent to this.remainder(other).
  T remainder(T other);
}
