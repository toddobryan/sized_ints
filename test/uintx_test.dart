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

    test('simple multiplication', () {
      UintX a = UintX.fromInt(8, 13);
      UintX b = UintX.fromInt(8, 17);
      expect(a * b).toEqual(UintX.fromInt(8, 221));

      expect(
        UintX.fromInt(32, 65537) * UintX.fromInt(32, 65537),
      ).toEqual(UintX.fromInt(32, 131073));
    });

    test('multiplication', () {
      // Random check against BigInt
      Random r = Random();
      for (int i = 0; i < 100; i++) {
        BigInt a = BigInt.from(r.nextInt(UintX.twoToThe32));
        BigInt b = BigInt.from(r.nextInt(UintX.twoToThe32));
        BigInt c = BigInt.from(r.nextInt(UintX.twoToThe32));
        BigInt d = BigInt.from(r.nextInt(UintX.twoToThe32));
        BigInt one = a + b;
        BigInt two = c + d;
        print('one: ${one.hex}, two: ${two.hex}');
        int bits = max(one.bitLength, two.bitLength);
        print('bits: $bits');
        BigInt mod = BigInt.one << bits;
        print('mod: ${mod.hex}');
        print('bits: $bits, mod: $mod');
        UintX uone = UintX.fromBigInt(bits, one);
        UintX utwo = UintX.fromBigInt(bits, two);
        print('uone: ${uone.hex}, utwo: ${utwo.hex}');
        expect((uone * utwo).toBigInt()).toEqual((one * two) % mod);
        print('\u2713');
      }
    });

    test('negation', () {
      expect(-UintX.fromInt(4, 15)).toEqual(UintX.fromInt(4, 1));
      expect(-UintX.fromInt(8, 100)).toEqual(UintX.fromInt(8, 156));
    });
  });
}
