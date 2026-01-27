import "dart:math";

import "package:sized_ints/extensions.dart";
import "package:sized_ints/intx.dart";
import "package:checks/checks.dart";
import "package:test/test.dart";

void main() {
  Random r = Random();

  group("IntX", () {
    test("constructors", () {
      Int sixtyThree = IntX.fromInt(7, 63);
      check(sixtyThree.toInt32()).equals(63);
      check(sixtyThree.bitLength).equals(6);
      Int neg512 = IntX.fromInt(10, -512);
      check(neg512.toInt32()).equals(-512);
      check(neg512.bitLength).equals(9);

      Int neg1 = IntX.fromInt(4, -1);
      check(neg1.toInt32()).equals(-1);
      check(neg1.bitLength).equals(0);

      Int max64 = IntX.fromBigInt(64, Int64.maxAsBigInt);
      check(max64.toBigInt()).equals(Int64.maxAsBigInt);
      check(max64.bitLength).equals(63);
      Int min64 = IntX.fromBigInt(64, Int64.minAsBigInt);
      check(min64.toBigInt()).equals(Int64.minAsBigInt);
      check(min64.bitLength).equals(63);
    });

    test("simpleAddition", () {
      Int ten = IntX.fromInt(9, 10);
      Int fifteen = IntX.fromInt(9, 15);
      check(ten + fifteen).equals(IntX.fromInt(9, 25));
      check(ten + -fifteen).equals(IntX.fromInt(9, -5));
      Int twoFifty = IntX.fromInt(9, 250);
      Int five = IntX.fromInt(9, 5);
      check(twoFifty + five).equals(IntX.fromInt(9, 255));
      Int one = IntX.fromInt(9, 1);
      check(twoFifty + five + one).equals(IntX.fromInt(9, -256));
    });

    test("multiplication", () {
      IntX neg3 = IntX.fromInt(9, -3);
      IntX pos90 = IntX.fromInt(9, 90);
      check(neg3 * pos90).equals(IntX.fromInt(9, 242));
      check(neg3 * -pos90).equals(IntX.fromInt(9, -242));
    });

    test("random big ints are encoded correctly", () {
      for (int i = 0; i < 100; i++) {
        BigInt bi1 = randomBigInt(r, 3, (a, b) => a * b);
        BigInt bi2 = randomBigInt(r, 3, (a, b) => a * b);
        int bi1Bits = bi1.signedBitLength;
        int bi2Bits = bi2.signedBitLength;
        int bits = max(bi1Bits, bi2Bits);
        IntX ione = IntX.fromBigInt(bits, bi1);
        IntX itwo = IntX.fromBigInt(bits, bi2);
        check(ione.toBigInt()).equals(bi1);
        check(itwo.toBigInt()).equals(bi2);
      }
    });

    test("lessThan", () {
      IntX x = IntX.fromInt(24, 17);
      IntX y = IntX.fromInt(24, -8);
      check(x < y).isFalse();

      testAgainstRandomBigInts(
        100,
        r,
        () => randomBigInt(r, 3, (a, b) => a * b),
        (i1, i2) => i1 < i2,
        (b1, b2) => b1 < b2,
      );
    });

    test("greaterThan", () {
      testAgainstRandomBigInts(
          100,
          r,
          () => randomBigInt(r, 3, (a, b) => a * b),
          (i1, i2) => i1 > i2,
          (b1, b2) => b1 > b2,
      );
    });
  });
}

void testAgainstRandomBigInts<T>(
  int numRuns,
  Random r,
  BigInt Function() biCreator,
  T Function(IntX, IntX) intXOp,
  T Function(BigInt, BigInt) biOp,
) {
  for (int i = 0; i < numRuns; i++) {
    BigInt one = biCreator();
    BigInt two = biCreator();
    int bits = max(one.signedBitLength, two.signedBitLength);
    IntX ione = IntX.fromBigInt(bits, one);
    IntX itwo = IntX.fromBigInt(bits, two);
    T actual = intXOp(ione, itwo);
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
