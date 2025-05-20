import 'dart:math';

import 'package:checks/checks.dart';

import 'package:sized_ints/intx.dart';
import 'package:sized_ints/sized_int.dart';
import 'package:sized_ints/uintx.dart';

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

void testAgainstRandomBigUints<T>(
  int numRuns,
  Random r,
  BigInt Function() biCreator,
  T Function(UintX, UintX) uintXOp,
  T Function(BigInt, BigInt) biOp,
) {
  for (int i = 0; i < numRuns; i++) {
    BigInt one = biCreator();
    BigInt two = biCreator();
    int bits = max(one.bitLength, two.bitLength);
    UintX uone = UintX.fromBigInt(bits, one);
    UintX utwo = UintX.fromBigInt(bits, two);
    T actual = uintXOp(uone, utwo);
    T checked = biOp(one, two);
    check(actual).equals(checked);
  }
}

BigInt randomBigUint(
  Random r,
  int numInts,
  BigInt Function(BigInt, BigInt) op,
) {
  List<BigInt> bigInts = List.generate(
    numInts,
    (i) => BigInt.from(r.nextInt(0x100000000)),
  );
  BigInt result = bigInts[0];
  for (int i = 1; i < bigInts.length; i++) {
    result = op(result, bigInts[i]);
  }
  return result;
}
