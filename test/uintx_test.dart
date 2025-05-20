import 'dart:math';

import 'package:sized_ints/uintx.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  Random r = Random();

  group('uintx', () {
    test('constructor', () {
      UintX twoFiftyFive = UintX.fromInt(8, 255);
      check(twoFiftyFive.toInt()).equals(255);
      check(twoFiftyFive.bitLength).equals(8);
      UintX abcd = UintX.fromInt(16, 0xABCD);
      check(abcd.toInt()).equals(0xABCD);
      check(abcd.bitLength).equals(16);
      UintX bi = UintX.fromBigInt(64, BigInt.parse('0x10203040FFFFFFFF'));
      check(bi.toBigInt()).equals(BigInt.parse('0x10203040FFFFFFFF'));
      check(bi.bitLength).equals(61);
    });

    test('less than', () {
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => u1 < u2,
        (b1, b2) => b1 < b2,
      );
    });

    test('greater than', () {
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => u1 > u2,
        (b1, b2) => b1 > b2,
      );
    });

    test('addition', () {
      check(
        UintX.fromInt(8, 100) + UintX.fromInt(8, 100),
      ).equals(UintX.fromInt(8, 200));
      check(
        UintX.fromInt(8, 200) + UintX.fromInt(8, 100),
      ).equals(UintX.fromInt(8, 44));
      check(
        UintX.fromInt(16, 33000) + UintX.fromInt(16, 33000),
      ).equals(UintX.fromInt(16, 66000 - 65536));
      check(
        UintX.parse(63, '0xFFF_FFFF_FFFF_FFFF') +
            UintX.parse(63, '0x7000_0000_0000_0001'),
      ).equals(UintX.fromInt(63, 0));
      check(
        UintX.fromInt(10, 1023) + UintX.fromInt(10, 21),
      ).equals(UintX.fromInt(10, 20));
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 + u2).toBigInt(),
        (b1, b2) {
          BigInt mod = BigInt.one << max(b1.bitLength, b2.bitLength);
          return (b1 + b2) % mod;
        },
      );
    });

    test('subtraction', () {
      check((UintX.fromInt(8, 255) - UintX.fromInt(8, 251)).toInt()).equals(4);
      check(
        (UintX.fromInt(8, 251) - UintX.fromInt(8, 255)).toInt(),
      ).equals(252);
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 + u2).toBigInt(),
        (b1, b2) {
          BigInt mod = BigInt.one << max(b1.bitLength, b2.bitLength);
          return (b1 + b2).remainder(mod);
        },
      );
    });

    test('simple multiplication', () {
      UintX a = UintX.fromInt(8, 13);
      UintX b = UintX.fromInt(8, 17);
      check(a * b).equals(UintX.fromInt(8, 221));

      check(
        UintX.fromInt(32, 65537) * UintX.fromInt(32, 65537),
      ).equals(UintX.fromInt(32, 131073));
    });

    test('multiplication', () {
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 * u2).toBigInt(),
        (b1, b2) {
          BigInt mod = BigInt.one << max(b1.bitLength, b2.bitLength);
          return (b1 * b2) % mod;
        },
      );
    });

    test('int division', () {
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 ~/ u2).toBigInt(),
        (b1, b2) {
          BigInt mod = BigInt.one << max(b1.bitLength, b2.bitLength);
          return (b1 ~/ b2) % mod;
        },
      );
    });

    test('int mod', () {
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 % u2).toBigInt(),
        (b1, b2) => b1 % b2,
      );
    });

    test('double division', () {
      testAgainstRandomBigUints(
        100,
        r,
        () => randomBigUint(r, 3, (a, b) => a * b),
        (u1, u2) => u1 / u2,
        (b1, b2) => b1 / b2,
      );
    });

    test('negation', () {
      check(-UintX.fromInt(4, 15)).equals(UintX.fromInt(4, 1));
      check(-UintX.fromInt(8, 100)).equals(UintX.fromInt(8, 156));
    });

    test('UintX', () {
      for (int i = 0; i <= 255; i++) {
        for (int j = 0; j <= 255; j++) {
          Uint8 a = Uint8.fromInt(i);
          Uint8 b = Uint8.fromInt(j);
          check((a + b).toInt()).equals((i + j) % 256);
          check((a - b).toInt()).equals((i - j) % 256);
          check((a * b).toInt()).equals((i * j) % 256);
          if (j != 0) {
            check((a ~/ b).toInt()).equals((i ~/ j) % 256);
            check(a / b).equals(i / j);
            check((a % b).toInt()).equals(i % j);
          }
          check((a | b).toInt()).equals((i | j) % 256);
          check((a & b).toInt()).equals((i & j) % 256);
          check((a ^ b).toInt()).equals((i ^ j) % 256);
          check((~a).toInt()).equals(~i % 256);
          check((-a).toInt()).equals((256 - i) % 256);
        }
      }
    });
  });

  // TODO: UintX16, UintX32, UintX64, exceptions
}
