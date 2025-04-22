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
    if (this.upper < 0 ||
        this.upper > Uint32.max ||
        this.lower < 0 ||
        this.upper > Uint32.max) {
      throw ArgumentError(
        'upper and lower must be between 0 and 4294967295, given: $upper, $lower',
      );
    }
  }

  int upper;
  int lower;
  static int bitSize = 64;
  static int max = 0xFFFF_FFFF_FFFF_FFFF;

  @override
  String toString() {
    if (upper == 0) {
      return '${lower}u64';
    } else {
      BigInt bi = BigInt.from(upper) * BigInt.from(max) + BigInt.from(lower);
      return '${bi}u64';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Uint64 && upper == other.upper && lower == other.lower;

  Uint64 operator +(Uint64 other) {
    int lowerSum = lower + other.lower;
    carry = lowerSum > pow(2, 32) ? 1 : 0, lowerSum % Uint32.max);
    Uint64((value + other.value) & max);
  }

  Uint64 operator -(Uint64 other) => Uint64((value - other.value) & max);

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
  }

  Uint64 operator >>>(int bits) => this >> bits;

  @override
  int get hashCode => value.hashCode;
}
