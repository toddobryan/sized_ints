import 'dart:typed_data';

class IntX {
  IntX(this.bits, this.isNonNeg, this.byteData) {
    int bl = byteData.bitLength;
    if (bl > bits) {
      throw ArgumentError(
        "byteData has bitLength $bl, which won't fit in $bits bits",
      );
    }
  }

  factory IntX.fromBytes(int bits, bool isNeg, Uint8List bytes) {
    return IntX(bits, isNeg, bytes.buffer.asByteData());
  }

  factory IntX.fromInt(int bits, int value) {
    BigInt bi = BigInt.from(value);
    BigInt max = maxSigned(bits);
    BigInt min = minSigned(bits);
    if (bi > max || bi < min) {
      throw RangeError(
        'a $bits-bit value must be between $min and $max, given $value',
      );
    }
    Uint8List bytes = Uint8List((bits / 8.0).ceil());
    for (int i = bytes.length - 1; i >= 0; i++) {
      bytes[i] = value & 0xFF;
      value = value >> 8;
    }
    return IntX.fromBytes(bits, value < 0, bytes);
  }

  int bits;
  bool isNonNeg;
  ByteData byteData;

  int get bitLength => byteData.bitLength;

  /// Returns the bit at index (counting from the right, starting at 0)
  /// If bitAt(bits) is 1, this represents a negative number.
  int bitAt(int index) {
    if (index < 0 || index >= bits) {
      throw RangeError('index must be between 0 and $bits, given $index');
    }
    int byte = byteData.getUint8((byteData.lengthInBytes - 1) - (index ~/ 8));
    int mask = 1 << (index % 8);
    return (byte & mask) >>> (index % 8);
  }

  int toInt() {
    if (bitLength > 32) {
      throw RangeError(
        'value with bitLength $bitLength can not be represented '
        'as an int on all platforms',
      );
    }
    int value = byteData.getUint8(0);
    for (int i = 1; i < byteData.lengthInBytes; i++) {
      value = (value << 8) | byteData.getUint8(i);
    }
    return value * (isNonNeg ? 1 : -1);
  }
}

extension ByteDataOps on ByteData {
  int get bitLength {
    for (int i = 0; i < lengthInBytes; i++) {
      int bl = getInt8(i).bitLength;
      if (bl > 0) {
        return bl + 8 * (lengthInBytes - 1 - i);
      }
    }
    return 0;
  }
}

BigInt maxSigned(int bits) => (BigInt.from(1) << (bits - 1)) - BigInt.from(1);

BigInt minSigned(int bits) => -(BigInt.from(1) << (bits - 1));
