import 'dart:typed_data';

import 'package:uints/intx.dart';
import 'package:spec/spec.dart';

void main() {
  group('intx', () {
    test('constructor works', () {
      IntX x = IntX.fromBytes(4, false, Uint8List.fromList([0x05]));
      expect(x.toInt()).toEqual(-5);
    });

    test('bitAt', () {
      IntX x = IntX.fromBytes(16, true, Uint8List.fromList([0x80, 0x42]));
      Set<int> ones = <int>{15, 6, 1};
      for (int i = 0; i < 16; i++) {
        expect(x.bitAt(i)).toEqual(ones.contains(i) ? 1 : 0);
      }
    });

    test('constructor throws if bitLength > bits', () {
      expect(
        () => IntX.fromBytes(8, true, Uint8List.fromList([0x01, 0x0])),
      ).throws.isArgumentError();
      expect(
        () => IntX.fromBytes(4, true, Uint8List.fromList([0x10])),
      ).throws.isArgumentError();
    });
  });

  group('helper functions', () {
    test('maxSigned', () {
      expect(maxSigned(1).toInt()).toEqual(0);
      expect(maxSigned(2).toInt()).toEqual(1);
      expect(maxSigned(8).toInt()).toEqual(127);
      expect(maxSigned(12).toInt()).toEqual(2047);
      expect(maxSigned(64)).toEqual(BigInt.parse('0x7FFFFFFFFFFFFFFF'));
    });

    test('minSigned', () {
      expect(minSigned(1).toInt()).toEqual(-1);
      expect(minSigned(2).toInt()).toEqual(-2);
      expect(minSigned(8).toInt()).toEqual(-128);
      expect(minSigned(12).toInt()).toEqual(-2048);
      expect(minSigned(64)).toEqual(BigInt.parse('-0x8000000000000000'));
    });
  });
}
