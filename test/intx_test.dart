import 'dart:math';

import 'package:sized_ints/intx.dart';
import 'package:spec/spec.dart';

void main() {
  Random r = Random();

  group('IntX', () {
    test('constructors', () {
      IntX sixtyThree = IntX.fromInt(7, 63);
      expect(sixtyThree.toInt()).toEqual(63);
      expect(sixtyThree.bitLength).toEqual(6);
      IntX neg512 = IntX.fromInt(10, -512);
      expect(neg512.toInt()).toEqual(-512);
      expect(neg512.bitLength).toEqual(10);
      IntX neg1 = IntX.fromInt(4, -1);
      expect(neg1.toInt()).toEqual(-1);
      expect(neg1.bitLength).toEqual(1);

      IntX max64 = IntX.fromBigInt(64, Int64.maxAsBigInt);
      expect(max64.toBigInt()).toEqual(Int64.maxAsBigInt);
      expect(max64.bitLength).toEqual(63);
      IntX min64 = IntX.fromBigInt(64, Int64.minAsBigInt);
      expect(min64.toBigInt()).toEqual(Int64.minAsBigInt);
      expect(min64.bitLength).toEqual(64);
    });
  });
}
