import 'dart:math';

import 'package:sized_ints/intx.dart';
import 'package:checks/checks.dart';
import 'package:sized_ints/sized_int.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  Random r = Random();

  group('IntX', () {
    test('constructors', () {
      Int sixtyThree = IntX.fromInt(7, 63);
      check(sixtyThree.toInt()).equals(63);
      check(sixtyThree.bitLength).equals(6);
      Int neg512 = IntX.fromInt(10, -512);
      check(neg512.toInt()).equals(-512);
      check(neg512.bitLength).equals(10);
      Int neg1 = IntX.fromInt(4, -1);
      check(neg1.toInt()).equals(-1);
      check(neg1.bitLength).equals(1);

      Int max64 = IntX.fromBigInt(64, Int64.maxAsBigInt);
      check(max64.toBigInt()).equals(Int64.maxAsBigInt);
      check(max64.bitLength).equals(63);
      Int min64 = IntX.fromBigInt(64, Int64.minAsBigInt);
      check(min64.toBigInt()).equals(Int64.minAsBigInt);
      check(min64.bitLength).equals(64);
    });

    test('lessThan', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (i1, i2) => i1 < i2,
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
      check(
        IntX.fromInt(8, -128) + IntX.fromInt(8, -1),
      ).equals(IntX.fromInt(8, 127));
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 + u2).toBigInt(),
        (b1, b2) {
          BigInt mod =
              BigInt.one << max(b1.signedBitLength, b2.signedBitLength);
          return (b1 + b2).remainder(mod);
        },
      );
    });

    test('subtraction', () {
      check(
        IntX.fromInt(8, -128) - IntX.fromInt(8, 1),
      ).equals(IntX.fromInt(8, 1));
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 - u2).toBigInt(),
        (b1, b2) {
          BigInt mod =
              BigInt.one << max(b1.signedBitLength, b2.signedBitLength);
          return (b1 - b2).remainder(mod);
        },
      );
    });

    test('multiplication', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 * u2).toBigInt(),
        (b1, b2) {
          BigInt mod =
              BigInt.one << max(b1.signedBitLength, b2.signedBitLength);
          return (b1 * b2).remainder(mod);
        },
      );
    });

    test('int division', () {
      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (u1, u2) => (u1 ~/ u2).toBigInt(),
        (b1, b2) => b1 ~/ b2,
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
  });
}
