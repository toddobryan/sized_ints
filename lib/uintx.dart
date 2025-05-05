import 'dart:typed_data';

/// Unsigned int of arbitrary bit-length with wraparound for all arithmetic
/// operations. Values are stored as lists of 32-bit non-negative ints,
/// since those are supported on both native and web
class UintX {
  UintX(this.bits, this.uint32List) {
    int expectedLength = (bits / _bitSize).ceil();
    if (expectedLength != uint32List.length) {
      throw ArgumentError(
        'IntList32 argument must have length of $expectedLength, '
        'given: ${uint32List.length}',
      );
    } else if (uint32List.first.bitLength > _modBitSize(bits)) {
      throw ArgumentError(
        'Significtant bits in first element must be <= ${_modBitSize(bits)}, '
        'given: ${uint32List.first.bitLength}',
      );
    } else if (uint32List.any((elt) => elt.bitLength > _bitSize)) {
      throw ArgumentError(
        'Max bit length of all elements in list must be <= $_bitSize',
      );
    }
  }

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
    List<int> zeros = List.generate((bits / _bitSize).ceil() - 1, (i) => 0);
    return UintX(bits, Uint32List.fromList(zeros + [value]));
  }

  factory UintX.fromBigInt(int bits, BigInt value) {
    BigInt max = (BigInt.one << bits) - BigInt.one;
    if (value < BigInt.zero || value > max) {
      throw ArgumentError(
        'value must be in range [0, 2^$bits-1], given: $value',
      );
    }
    Uint32List l = Uint32List((bits / _bitSize).ceil());
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

  static final int maxUint32 = 0xFFFFFFFF;
  static final int twoToThe32 = 0x100000000;
  static final BigInt twoToThe32AsBigInt = BigInt.from(0x100000000);
  // The number of bits used in each element. Limited to 32 since that
  // is consistent for both native and web.
  static final int _bitSize = 32;

  // number of (rightmost) bits that "count" in the most significant Uint32.
  static int _modBitSize(int bits) {
    int mod = bits % _bitSize;
    return mod == 0 ? _bitSize : mod;
  }

  /// Number of bits of precision
  int bits;

  /// List of bits representing this number, most to least significant order
  Uint32List uint32List;

  // cache the value after the first time
  int? _zerothIntMask;

  /// A bitset of 1s to apply to the most significant uint32.
  int get zerothIntMask {
    if (_zerothIntMask == null) {
      int numBits = _modBitSize(bits);
      _zerothIntMask = numBits == _bitSize ? maxUint32 : (1 << numBits) - 1;
    }
    return _zerothIntMask!;
  }

  /// Number of actual bits used in this UintX. Must be <= bits.
  int get bitLength {
    for (int i = 0; i < uint32List.length; i++) {
      int bl = uint32List[i].bitLength;
      if (bl > 0) {
        return bl + _bitSize * (uint32List.length - i - 1);
      }
    }
    return 0;
  }

  bool nonZero() => uint32List.any((x) => x != 0);

  bool zero() => !nonZero();

  int toInt() {
    if (bitLength > 32) {
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

  /// Converts to BigInt and calls toRadixString(radix)
  String toRadixString(int radix) => '${toBigInt().toRadixString(radix)}u$bits';

  /// Calls toRadixString(10)
  @override
  String toString() => toRadixString(10);

  /// Shortcut for toRadixString(16)
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
    for (int i = 0; i < n ~/ _bitSize; i++) {
      result = result._shiftLeft32Bits();
    }
    result = result._shiftLeftLessThan32Bits(n % _bitSize);
    return result;
  }

  UintX operator >>>(int n) {
    if (n > bits) {
      return UintX(bits, Uint32List(uint32List.length));
    }
    UintX result = this;
    for (int i = 0; i < n ~/ _bitSize; i++) {
      result = result._shiftRightUnsigned32Bits();
    }
    result = result._shiftRightLessThan32Bits(n % _bitSize);
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

  UintX operator ~/(UintX other) => _divAndMod(other).$1;

  UintX operator %(UintX other) => _divAndMod(other).$2;

  (UintX, UintX) _divAndMod(UintX other) {
    _checkBits(other);
    if (other.zero()) {
      throw UnsupportedError('Integer division by zero');
    }
    if (other > this) {
      return (UintX.fromInt(bits, 0), this);
    }
    UintX dividend = this;
    UintX quotient = UintX.fromInt(bits, 0);
    UintX one = UintX.fromInt(bits, 1);
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
}

class Uint8 extends UintX {
  Uint8.fromInt(int value) : super(8, Uint32List.fromList([value]));
}

class Uint16 extends UintX {
  Uint16.fromInt(int value) : super(16, Uint32List.fromList([value]));
}

class Uint32 extends UintX {
  Uint32._(Uint32List list) : super(32, list);

  factory Uint32.fromInt(int value) {
    if (value < 0) {
      throw ArgumentError('value must be non-negative, given: $value');
    } else if (value.bitLength > 32) {
      throw ArgumentError(
        'use Uint64.fromBigInt() or Uint64(upper, lower) for value with bitLength > 32',
      );
    }
    return Uint32._(Uint32List.fromList([value]));
  }

  static final int max = 0xFFFFFFFF;
}

class Uint64 extends UintX {
  Uint64._(Uint32List list) : super(64, list);

  factory Uint64(int upper, int lower) {
    if (!upper.safeUnsigned || !lower.safeUnsigned) {
      return Uint64._(Uint32List.fromList([upper, lower]));
    } else {

    }
    
    super(64, Uint32List.fromList([upper, lower]));

  factory Uint64.fromInt(int value) {
    if (value < 0) {
      throw ArgumentError('value must be non-negative, given: $value');
    } else if (value.bitLength > 32) {
      throw ArgumentError(
        'use Uint64.fromBigInt() or Uint64(upper, lower) for value with bitLength > 32',
      );
    }
    return Uint64(0, value);
  }

  factory Uint64.fromBigInt(BigInt value) {
    if (value.bitLength > 64) {
      throw ArgumentError(
        'value must have bitLength <= 64, given: ${value.bitLength}',
      );
    }
    int upper = (value ~/ UintX.twoToThe32AsBigInt).toInt();
    int lower = (value % UintX.twoToThe32AsBigInt).toInt();
    return Uint64(upper, lower);
  }

  factory Uint64.parse(String value) {
    UintX v = UintX.parse(64, value);
    return Uint64(v.uint32List[0], v.uint32List[1]);
  }

  static Uint64 max = Uint64(0xFFFFFFFF, 0xFFFFFFFF);

  (int, int) get values => (uint32List[0], uint32List[1]);
}

extension IntOp on int {
  String get hex => toRadixString(16);

  bool get safeCrossPlatform => bitLength <= 32;

  bool get safeUnsigned => safeCrossPlatform && this >= 0;
}

extension BigIntOp on BigInt {
  String get hex => toRadixString(16);
}

