import 'dart:math';

import 'package:sized_ints/intx.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

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
  });
}

void testAgainstRandomBigInts<T>(
  int numRuns,
  Random r,
  BigInt Function() biCreator,
  T Function(IntX, IntX) uintXOp,
  T Function(BigInt, BigInt) biOp,
) {
  for (int i = 0; i < numRuns; i++) {
    BigInt one = biCreator();
    BigInt two = biCreator();
    int bits = max(one.bitLength, two.bitLength);
    IntX uone = IntX.fromBigInt(bits, one);
    IntX utwo = IntX.fromBigInt(bits, two);
    T actual = uintXOp(uone, utwo);
    T checked = biOp(one, two);
    check(actual).equals(checked);
  }
}

BigInt randomBigInt(Random r, int numInts, BigInt Function(BigInt, BigInt) op) {
  List<BigInt> bigInts = List.generate(
    numInts,
    (i) => BigInt.from(r.nextInt(0x100000000) * (r.nextBool() ? 1 : -1)),
  );
  BigInt result = bigInts[0];
  for (int i = 1; i < bigInts.length; i++) {
    result = op(result, bigInts[i]);
  }
  return result;
}
