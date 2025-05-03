import 'dart:math';
import 'dart:typed_data';

import 'package:sized_ints/uintx.dart';
import 'package:spec/spec.dart';

void main() {
  Random r = Random();

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

    test('less than', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => u1 < u2,
        (b1, b2) => b1 < b2,
      );
    });

    test('greater than', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => u1 > u2,
        (b1, b2) => b1 > b2,
      );
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
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 * u2).toBigInt(),
        (b1, b2) {
          BigInt mod = BigInt.one << max(b1.bitLength, b2.bitLength);
          return (b1 * b2) % mod;
        },
      );
    });

    test('int division', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 ~/ u2).toBigInt(),
        (b1, b2) {
          BigInt mod = BigInt.one << max(b1.bitLength, b2.bitLength);
          return (b1 ~/ b2) % mod;
        },
      );
    });

    test('int mod', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 % u2).toBigInt(),
        (b1, b2) => b1 % b2,
      );
    });

    test('double division', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => u1 / u2,
        (b1, b2) => b1 / b2,
      );
    });

    test('negation', () {
      expect(-UintX.fromInt(4, 15)).toEqual(UintX.fromInt(4, 1));
      expect(-UintX.fromInt(8, 100)).toEqual(UintX.fromInt(8, 156));
    });

    test('UintX', () {
      for (int i = 0; i <= 255; i++) {
        for (int j = 0; j <= 255; j++) {
          Uint8 a = Uint8(i);
          Uint8 b = Uint8(j);
          expect((a + b).toInt()).toEqual((i + j) % 256);
          expect((a - b).toInt()).toEqual((i - j) % 256);
          expect((a * b).toInt()).toEqual((i * j) % 256);
          if (j != 0) {
            expect((a ~/ b).toInt()).toEqual((i ~/ j) % 256);
            expect(a / b).toEqual(i / j);
            expect((a % b).toInt()).toEqual(i % j);
          }
          expect((a | b).toInt()).toEqual((i | j) % 256);
          expect((a & b).toInt()).toEqual((i & j) % 256);
          expect((a ^ b).toInt()).toEqual((i ^ j) % 256);
          expect((~a).toInt()).toEqual(~i % 256);
          expect((-a).toInt()).toEqual((256 - i) % 256);
        }
      }
    });
  });

  // TODO: Uint16, Uint32, Uint64, exceptions
}

void testAgainstRandomBigInts<T>(
  int numRuns,
  Random r,
  BigInt Function() biCreator,
  T Function(UintX, UintX) uintOp,
  T Function(BigInt, BigInt) biOp,
) {
  for (int i = 0; i < numRuns; i++) {
    BigInt one = biCreator();
    BigInt two = biCreator();
    int bits = max(one.bitLength, two.bitLength);
    UintX uone = UintX.fromBigInt(bits, one);
    UintX utwo = UintX.fromBigInt(bits, two);
    expect(uintOp(uone, utwo)).toEqual(biOp(one, two));
  }
}

BigInt randomBigInt(Random r, int numInts, BigInt Function(BigInt, BigInt) op) {
  List<BigInt> bigInts = List.generate(
    numInts,
    (i) => BigInt.from(r.nextInt(UintX.twoToThe32)),
  );
  BigInt result = bigInts[0];
  for (int i = 1; i < bigInts.length; i++) {
    result = op(result, bigInts[i]);
  }
  return result;
}
