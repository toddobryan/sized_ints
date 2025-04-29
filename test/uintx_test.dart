import 'dart:math';
import 'dart:typed_data';

import 'package:spec/spec.dart';
import 'package:uints/uintx.dart';

void main() {
  group('uintx', () {
    test('constructor', () {
      expect(UintX(8, Uint32List.fromList([255])).toInt()).toEqual(255);
      expect(UintX(16, Uint32List.fromList([0xABCD])).toInt()).toEqual(0xABCD);
      expect(
        UintX(64, Uint32List.fromList([0x10203040, 0xFFFFFFFF])).toBigInt(),
      ).toEqual(BigInt.parse('0x10203040FFFFFFFF'));
    });

    test('bitLength', () {
      expect(UintX(8, Uint32List.fromList([8])).bitLength).toEqual(4);
      expect(
        UintX(64, Uint32List.fromList([0x10203040, 0xFFFFFFFF])).bitLength,
      ).toEqual(61);
    });

    test('addition', () {
      expect(
        UintX.fromInt(8, 100) + UintX.fromInt(8, 100),
      ).toEqual(UintX.fromInt(8, 200));
      expect(
        UintX.fromInt(8, 200) + UintX.fromInt(8, 100),
      ).toEqual(UintX.fromInt(8, 44));
      expect(
        UintX.fromInt(16, 33000) + UintX.fromInt(16, 33000),
      ).toEqual(UintX.fromInt(16, 66000 - 65536));
      expect(
        UintX.parse(63, '0xFFF_FFFF_FFFF_FFFF') +
            UintX.parse(63, '0x7000_0000_0000_0001'),
      ).toEqual(UintX.fromInt(63, 0));
    });

    test('subtraction', () {
      expect(
        (UintX.fromInt(8, 255) - UintX.fromInt(8, 251)).toInt(),
      ).toEqual(4);
      expect(
        (UintX.fromInt(8, 251) - UintX.fromInt(8, 255)).toInt(),
      ).toEqual(252);
    });

    test('multiplication', () {
      // Random check against BigInt 
    })

    test('negation', () {
      expect(-UintX.fromInt(4, 15)).toEqual(UintX.fromInt(4, 1));
      expect(-UintX.fromInt(8, 100)).toEqual(UintX.fromInt(8, 156));
    });
  });
}
