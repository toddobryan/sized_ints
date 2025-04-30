import 'dart:math';
import 'dart:typed_data';

/// Unsigned int of arbitrary bit-length with wraparound for all arithmetic
/// operations. Values are store as lists of 32-bit non-negative ints,
/// since those are supported on both native and web
class UintX {
  UintX(this.bits, this.uint32List);

  factory UintX.fromInt(int bits, int value) {
    if (value < 0 || value >= maxUint32) {
      throw ArgumentError('value must be in range [0, 2^32-1], given: $value');
    }
    if (bits < 1) {
      throw ArgumentError('bits must be 1 one or greater, given: $bits');
    }
    if (bits < value.bitLength) {
      throw ArgumentError('value $value will not fit in $bits bits');
    }
    List<int> zeros = List.generate((bits / 32).ceil() - 1, (i) => 0);
    return UintX(bits, Uint32List.fromList(zeros + [value]));
  }

  factory UintX.fromBigInt(int bits, BigInt value) {
    BigInt max = (BigInt.one << bits) - BigInt.one;
    if (value < BigInt.zero || value > max) {
      throw ArgumentError(
        'value must be in range [0, 2^$bits-1], given: $value',
      );
    }
    Uint32List l = Uint32List((bits / listIntSize).ceil());
    for (int i = l.length - 1; i >= 0; i--) {
      l[i] = (value % twoToThe32AsBigInt).toInt();
      value = value ~/ twoToThe32AsBigInt;
    }
    return UintX(bits, l);
  }

  factory UintX.parse(int bits, String s) {
    // allow _ wherever in string and just delete it
    return UintX.fromBigInt(bits, BigInt.parse(s.replaceAll('_', '')));
  }

  static int maxUint32 = 0xFFFFFFFF;
  static int twoToThe32 = 0x100000000;
  static BigInt twoToThe32AsBigInt = BigInt.from(0x100000000);
  static int listIntSize = 32;

  int bits;
  Uint32List uint32List;

  int? _zerothIntMask;

  int get zerothIntMask {
    if (_zerothIntMask == null) {
      int modBits = bits % listIntSize;
      int numBits = modBits == 0 ? listIntSize : modBits;
      _zerothIntMask = numBits == listIntSize ? maxUint32 : (1 << numBits) - 1;
    }
    return _zerothIntMask!;
  }

  int get bitLength {
    for (int i = 0; i < uint32List.length; i++) {
      int bl = uint32List[i].bitLength;
      if (bl > 0) {
        return bl + listIntSize * (uint32List.length - 1);
      }
    }
    return 0;
  }

  bool nonZero() {
    for (int i = 0; i < uint32List.length; i++) {
      if (uint32List[i] != 0) {
        return true;
      }
    }
    return false;
  }

  bool zero() => !nonZero();

  int toInt() {
    if (bitLength > 31) {
      throw RangeError(
        'not safe to return $this as int, use toBigInt() instead',
      );
    }
    return uint32List.last;
  }

  BigInt toBigInt() {
    BigInt value = BigInt.from(uint32List[0]);
    for (int i = 1; i < uint32List.length; i++) {
      value = (value * twoToThe32AsBigInt) + BigInt.from(uint32List[i]);
    }
    return value;
  }

  void _checkBits(UintX other) {
    if (bits != other.bits) {
      throw ArgumentError(
        'receiver and argument must have same number of bits,'
        'given: $bits and ${other.bits}',
      );
    }
  }

  String toRadixString(int radix) => toBigInt().toRadixString(radix);

  @override
  String toString() => toRadixString(10);

  String get hex => toRadixString(16);

  // Comparison methods

  @override
  bool operator ==(Object other) {
    if (other is! UintX || other.bits != bits) {
      return false;
    }
    for (int i = 0; i < uint32List.length; i++) {
      if (uint32List[i] != other.uint32List[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(bits, uint32List);

  bool _compare(UintX other, bool Function(int, int) op) {
    _checkBits(other);
    for (int i = 0; i < uint32List.length; i++) {
      if (op(uint32List[i], other.uint32List[i])) {
        return true;
      } else if (uint32List[i] == other.uint32List[i]) {
        // continue
      } else {
        return false;
      }
    }
    // they're equal
    return false;
  }

  bool operator <(UintX other) => _compare(other, (int t, int o) => t < o);
  bool operator >(UintX other) => _compare(other, (int t, int o) => t > o);
  bool operator <=(UintX other) => !(this > other);
  bool operator >=(UintX other) => !(this < other);

  // Bit-wise operations
  UintX operator ~() {
    Uint32List result = Uint32List(uint32List.length);
    for (int i = 0; i < uint32List.length; i++) {
      result[i] = ~uint32List[i];
    }
    result[0] = result[0] & zerothIntMask;
    return UintX(bits, result);
  }

  UintX _binaryBinOp(UintX other, int Function(int, int) op) {
    _checkBits(other);
    Uint32List result = Uint32List(uint32List.length);
    for (int i = 0; i < uint32List.length; i++) {
      result[i] = op(uint32List[i], other.uint32List[i]);
    }
    return UintX(bits, result);
  }

  UintX operator &(UintX other) => _binaryBinOp(other, (int t, int o) => t & o);
  UintX operator |(UintX other) => _binaryBinOp(other, (int t, int o) => t | o);
  UintX operator ^(UintX other) => _binaryBinOp(other, (int t, int o) => t ^ o);

  // Bit-shift operations
  UintX operator <<(int n) {
    if (n > bits) {
      return UintX(bits, Uint32List(uint32List.length));
    }
    UintX result = this;
    for (int i = 0; i < n ~/ listIntSize; i++) {
      result = result._shiftLeft32Bits();
    }
    result = result._shiftLeftLessThan32Bits(n % listIntSize);
    return result;
  }

  UintX operator >>>(int n) {
    if (n > bits) {
      return UintX(bits, Uint32List(uint32List.length));
    }
    UintX result = this;
    for (int i = 0; i < n ~/ listIntSize; i++) {
      result = result._shiftRightUnsigned32Bits();
    }
    result = result._shiftRightLessThan32Bits(n % listIntSize);
    return result;
  }

  UintX operator >>(int n) => this >>> n; // for unsigned, >> is the same as >>>

  UintX _shiftLeft32Bits() {
    Uint32List result = Uint32List(uint32List.length);
    for (int i = 0; i < uint32List.length - 1; i++) {
      result[i] = uint32List[i + 1];
    }
    result[0] = result[0] & zerothIntMask;
    return UintX(bits, result);
  }

  UintX _shiftLeftLessThan32Bits(int n) {
    if (n < 0 || n >= 32) {
      throw ArgumentError('n must be in range [0, 31], given: $n');
    }
    Uint32List result = Uint32List(uint32List.length);
    int carry = 0;
    for (int i = uint32List.length - 1; i >= 0; i--) {
      result[i] = (uint32List[i] << n) + carry;
      carry = uint32List[i] >>> (32 - n);
    }
    result[0] = result[0] & zerothIntMask;
    return UintX(bits, result);
  }

  UintX _shiftRightUnsigned32Bits() {
    Uint32List result = Uint32List(uint32List.length);
    for (int i = uint32List.length - 1; i > 0; i--) {
      result[i] = uint32List[i - 1];
    }
    return UintX(bits, result);
  }

  UintX _shiftRightLessThan32Bits(int n) {
    if (n < 0 || n > 31) {
      throw ArgumentError('n must be in range [0, 31], given: $n');
    }
    Uint32List result = Uint32List(uint32List.length);
    int carryMask = 0;
    for (int i = 0; i < uint32List.length; i++) {
      result[i] = (uint32List[i] >> n) | carryMask;
      carryMask = uint32List[i] << (32 - n);
    }
    return UintX(bits, result);
  }

  // Arithmetic operators

  UintX operator +(UintX other) {
    _checkBits(other);
    Uint32List result = Uint32List(uint32List.length);
    int carry = 0;
    for (int i = uint32List.length - 1; i >= 0; i--) {
      int sum = uint32List[i] + other.uint32List[i] + carry;
      result[i] = sum % twoToThe32;
      carry = sum ~/ twoToThe32;
    }
    result[0] = result[0] & zerothIntMask;
    return UintX(bits, result);
  }

  UintX operator -(UintX other) {
    _checkBits(other);
    UintX max = this;
    UintX min = other;
    bool negate = false;
    if (max < min) {
      max = other;
      min = this;
      negate = true;
    }
    UintX result = -min + max;
    if (negate) {
      result = -result;
    }
    return result;
  }

  UintX operator -() {
    return ~this + UintX.fromInt(bits, 1);
  }

  UintX operator *(UintX other) {
    _checkBits(other);
    UintX result = UintX.fromInt(bits, 0);
    if (zero() || other.zero()) {
      return result;
    }
    UintX multiplicand = this;
    int count = 0;
    while (multiplicand.nonZero()) {
      if (multiplicand.uint32List.last & 1 == 1) {
        result = result + (other << count);
      }
      multiplicand = multiplicand >> 1;
      count++;
    }
    return result;
  }

  /// Convert both to double (with possible loss of precision)
  /// and divide
  double operator /(UintX other) =>
      toBigInt().toDouble() / other.toBigInt().toDouble();

  UintX operator ~/(UintX other) {
    _checkBits(other);
    if (other.zero()) {
      throw UnsupportedError('Integer division by zero');
    }
    if (other > this) {
      return UintX.fromInt(bits, 0);
    }
    UintX dividend = this;
    UintX quotient = UintX.fromInt(bits, 0);
    UintX one = UintX.fromInt(bits, 1);
    while (dividend > other) {
      int count = 0;
      while (count < bits && (other << (count + 1)) < dividend) {
        count++;
      }
      dividend = dividend - (other << count);
      quotient = quotient + (one << count);
    }
    return quotient;
  }
}

extension IntOp on int {
  String get hex => toRadixString(16);
}

extension BigIntOp on BigInt {
  String get hex => toRadixString(16);
}

void main() {
  BigInt one = BigInt.parse('0x3063e10415d6b1036137f54');
  BigInt two = BigInt.parse('0x1742122f2680be6cccbfd20');
  int bits = max(one.bitLength, two.bitLength);
  UintX uone = UintX.fromBigInt(bits, one);
  UintX utwo = UintX.fromBigInt(bits, two);
  print((one - two).hex);
  print((uone - utwo).hex);
  UintX div = uone ~/ utwo;
}
