import "dart:typed_data";

import "package:sized_ints/sized_int.dart";
import "package:checks/checks.dart";
import "package:test/test.dart";

void main() {
  group("statics", () {
    test("positiveMask", () {
      check(SizedInt.positiveMask(1)).equals(1);
      check(SizedInt.positiveMask(2)).equals(3);
      check(SizedInt.positiveMask(8)).equals(255);
    });
    test("negativeMask", () {
      check(SizedInt.negativeMask(1)).equals(-2);
      check(SizedInt.negativeMask(3)).equals(-8);
      check(SizedInt.negativeMask(8)).equals(-256);
    });
    test("sizedIntToList", () {
      check(SizedInt.signedIntToList(8, -1))
          .containsEqualInOrder(Uint32List.fromList([0xFFFFFFFF]));
    });
    test("sizedBigIntToList", () {
      check(SizedInt.signedBigIntToList(8, BigInt.from(127)))
          .containsEqualInOrder(Uint32List.fromList([0x7F]));
      check(SizedInt.signedBigIntToList(8, BigInt.from(-128)))
          .containsEqualInOrder(Uint32List.fromList([0xFFFFFF80]));
    });
  });
}
