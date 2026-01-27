import "bit_list.dart";

abstract class SizedInt<T extends SizedInt<T>> {
  final BitList bitList;

  SizedInt(this.bitList);

  T construct(BitList newBitList);

  int get signBit;

  int get bits => bitList.bits;

  int get bitLength => bitList.bitLength;

  int get signedBitLength => bitLength + 1;

  bool get isNonZero => bitList.isNonZero;

  bool get isZero => !isNonZero;

  BigInt toBigInt();

  int toInt32();

  String get suffix;

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
        ? bitList.toRadixString(radix)
        : (-bitList).toRadixString(radix);
    return "$pre$maybeMinus$num$suf";
  }

  @override
  String toString() => toRadixString(10);
  String get bin => toRadixString(2);
  String get oct => toRadixString(8);
  String get hex => toRadixString(16);

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
  T operator &(T other) {
    checkCompatible(other);
    return construct(bitList & other.bitList);
  }

  T operator |(T other) {
    checkCompatible(other);
    return construct(bitList | other.bitList);
  }

  T operator ^(T other) {
    checkCompatible(other);
    return construct(bitList ^ other.bitList);
  }

  T operator ~() => construct(~bitList);

  // Bit-shift operations
  T operator <<(int n) => construct(bitList << n);

  T operator >>(int n) =>
      construct(bitList.shiftedRight(n, signBit));

  T operator >>>(int n) => construct(bitList.zeroShiftedRight(n));

  // comparison operators
  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType ||
        (other as SizedInt).bitList.bits != bitList.bits) {
      return false;
    }
    return bitList == other.bitList;
  }

  @override
  int get hashCode => bitList.hashCode;

  int compareTo(T other) {
    checkCompatible(other);
    return bitList.compareTo(signBit, other.bitList, other.signBit);
  }

  bool operator <(T other) => compareTo(other) < 0;

  bool operator >(T other) => compareTo(other) > 0;

  bool operator <=(T other) => compareTo(other) <= 0;

  bool operator >=(T other) => compareTo(other) >= 0;

  // Arithmetic operators

  T operator +(T other) {
    checkCompatible(other);
    return construct(bitList + other.bitList);
  }

  T operator -(T other) {
    checkCompatible(other);
    return construct(bitList - other.bitList);
  }

  T operator -() => construct(-bitList);

  // TODO: don't rely on BigInt


  /// Convert both to double (with possible loss of precision)
  /// and divide
  double operator /(T other) =>
      toBigInt().toDouble() / other.toBigInt().toDouble();

  T operator *(T other);
  T operator ~/(T other);
  T operator %(T other);
  T remainder(T other);
}
