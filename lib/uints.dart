import 'dart:math';

class Uint8 {
  Uint8(this.value) {
    if (value < 0 || value > 255) {
      throw ArgumentError('value must be between 0 and 255, given: $value');
    }
  }

  int value;
  static int max = 0xFF;
  static int bitSize = 8;

  @override
  String toString() => '${value}u8';

  @override
  bool operator ==(Object other) => other is Uint8 && value == other.value;

  Uint8 operator +(Uint8 other) => Uint8((value + other.value) & max);

  Uint8 operator -(Uint8 other) => Uint8((value - other.value) & max);

  Uint8 operator *(Uint8 other) => Uint8((value * other.value) & max);

  Uint8 operator ~/(Uint8 other) => Uint8(value ~/ other.value);

  Uint8 operator %(Uint8 other) => Uint8(value % other.value);

  Uint8 operator ^(Uint8 other) => Uint8(value ^ other.value);

  Uint8 operator &(Uint8 other) => Uint8(value & other.value);

  Uint8 operator |(Uint8 other) => Uint8(value | other.value);

  Uint8 operator ~() => Uint8(~value & max);

  Uint8 operator <<(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= 8) {
      return Uint8(0);
    } else {
      return Uint8((value << bits) & max);
    }
  }

  Uint8 operator >>(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= bitSize) {
      return Uint8(0);
    } else {
      return Uint8(value >> bits);
    }
  }

  Uint8 operator >>>(int bits) => this >> bits;

  @override
  int get hashCode => value.hashCode;
}

class Uint16 {
  Uint16(this.value) {
    if (value < 0 || value > 65535) {
      throw ArgumentError('value must be between 0 and 65535, given: $value');
    }
  }

  int value;
  static int bitSize = 16;
  static int max = 0xFFFF;

  @override
  String toString() => '${value}u16';

  @override
  bool operator ==(Object other) => other is Uint16 && value == other.value;

  Uint16 operator +(Uint16 other) => Uint16((value + other.value) & max);

  Uint16 operator -(Uint16 other) => Uint16((value - other.value) & max);

  Uint16 operator *(Uint16 other) => Uint16((value * other.value) & max);

  Uint16 operator ~/(Uint16 other) => Uint16(value ~/ other.value);

  Uint16 operator %(Uint16 other) => Uint16(value % other.value);

  Uint16 operator ^(Uint16 other) => Uint16(value ^ other.value);

  Uint16 operator &(Uint16 other) => Uint16(value & other.value);

  Uint16 operator |(Uint16 other) => Uint16(value | other.value);

  Uint16 operator ~() => Uint16(~value & max);

  Uint16 operator <<(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= 16) {
      return Uint16(0);
    } else {
      return Uint16((value << bits) & max);
    }
  }

  Uint16 operator >>(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= bitSize) {
      return Uint16(0);
    } else {
      return Uint16(value >> bits);
    }
  }

  Uint16 operator >>>(int bits) => this >> bits;

  @override
  int get hashCode => value.hashCode;
}

class Uint32 {
  Uint32(this.value) {
    if (value < 0 || value > 4294967295) {
      throw ArgumentError(
        'value must be between 0 and 4294967295, given: $value',
      );
    }
  }

  int value;
  static int bitSize = 32;
  static int max = 0xFF_FF_FF_FF;

  @override
  String toString() => '${value}u32';

  @override
  bool operator ==(Object other) => other is Uint32 && value == other.value;

  Uint32 operator +(Uint32 other) => Uint32((value + other.value) & max);

  Uint32 operator -(Uint32 other) => Uint32((value - other.value) & max);

  Uint32 operator *(Uint32 other) => Uint32((value * other.value) & max);

  Uint32 operator ~/(Uint32 other) => Uint32(value ~/ other.value);

  Uint32 operator %(Uint32 other) => Uint32(value % other.value);

  Uint32 operator ^(Uint32 other) => Uint32(value ^ other.value);

  Uint32 operator &(Uint32 other) => Uint32(value & other.value);

  Uint32 operator |(Uint32 other) => Uint32(value | other.value);

  Uint32 operator ~() => Uint32(~value & max);

  Uint32 operator <<(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= 32) {
      return Uint32(0);
    } else {
      return Uint32((value << bits) & max);
    }
  }

  Uint32 operator >>(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= bitSize) {
      return Uint32(0);
    } else {
      return Uint32(value >> bits);
    }
  }

  Uint32 operator >>>(int bits) => this >> bits;

  @override
  int get hashCode => value.hashCode;
}

class Uint64 {
  Uint64(this.upper, this.lower) {
    if (upper < 0 || upper > Uint32.max || lower < 0 || lower > Uint32.max) {
      throw ArgumentError(
        'upper and lower must be between 0 and 4294967295, given: '
        '$upper, $lower',
      );
    }
  }

  factory Uint64.fromInt(int value) {
    if (value < 0) {
      throw ArgumentError('value must be non-negative, given: $value');
    } else if (value > (1 << 50)) {
      throw ArgumentError(
        'use the Uint64(upper, lower) constructor for values above '
        '2 to the 50th to avoid platform differences',
      );
    }
    int upper = value > (Uint32.max + 1) ? value ~/ (Uint32.max + 1) : 0;
    int lower = value % (Uint32.max + 1);
    return Uint64(upper, lower);
  }

  factory Uint64.fromString(String value) {
    BigInt bi;
    try {
      bi = BigInt.parse(value);
    } on FormatException {
      throw FormatException('Could not parse Uint64: $value');
    }
    if (bi < zeroAsBigInt || bi > maxAsBigInt) {
      throw ArgumentError(
        'value must be between 0 and 18446744073709551615, given: $value',
      );
    }
    return Uint64(
      (bi ~/ upperRightMostAsBigInt).toInt(),
      (bi % upperRightMostAsBigInt).toInt(),
    );
  }

  int upper;
  int lower;
  static int bitSize = 64;
  static int upperRightmostCol = Uint32.max + 1;
  static BigInt upperRightMostAsBigInt = BigInt.from(upperRightmostCol);
  static Uint64 max = Uint64(0xFF_FF_FF_FF, 0xFF_FF_FF_FF);
  static BigInt maxAsBigInt = BigInt.parse('0xFFFFFFFFFFFFFFFF');
  static BigInt zeroAsBigInt = BigInt.from(0);

  (int, int) get values => (upper, lower);

  @override
  String toString() {
    if (upper == 0) {
      return '${lower}u64';
    } else {
      BigInt bi =
          BigInt.from(upper) * upperRightMostAsBigInt + BigInt.from(lower);
      return '${bi}u64';
    }
  }

  @override
  bool operator ==(Object other) => other is Uint64 && values == other.values;

  Uint64 operator +(Uint64 other) {
    int lowerSum = lower + other.lower;
    int lowerCarry = lowerSum > pow(2, 32) ? 1 : 0;
    int lowerMod = lowerSum % Uint32.max;
    int upperSum = upper + other.upper + lowerCarry;
    int upperCarry = upperSum > pow(2, 32) ? 1 : 0;
    int upperMod = (upperSum + upperCarry) % Uint32.max;
    return Uint64(upperMod, lowerMod);
  }

  Uint64 _andMax() {
    return Uint64(
      (upper + lower ~/ Uint32.max) % Uint32.max,
      lower % Uint32.max,
    );
  }

  /*Uint64 operator -(Uint64 other) => Uint64((value - other.value) & max);

  Uint64 operator *(Uint64 other) => Uint64((value * other.value) & max);

  Uint64 operator ~/(Uint64 other) => Uint64(value ~/ other.value);

  Uint64 operator %(Uint64 other) => Uint64(value % other.value);

  Uint64 operator ^(Uint64 other) => Uint64(value ^ other.value);

  Uint64 operator &(Uint64 other) => Uint64(value & other.value);

  Uint64 operator |(Uint64 other) => Uint64(value | other.value);

  Uint64 operator ~() => Uint64(~value & max);

  Uint64 operator <<(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= 64) {
      return Uint64(0);
    } else {
      return Uint64((value << bits) & max);
    }
  }

  Uint64 operator >>(int bits) {
    if (bits == 0) {
      return this;
    } else if (bits >= bitSize) {
      return Uint64(0);
    } else {
      return Uint64(value >> bits);
    }
  }*/

  /*Uint64 operator >>>(int bits) => this >> bits;*/

  @override
  int get hashCode => Object.hash(upper, lower);
}
