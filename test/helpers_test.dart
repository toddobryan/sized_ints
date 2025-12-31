import "dart:typed_data";

import "package:sized_ints/helpers.dart";
import "package:checks/checks.dart";
import "package:test/test.dart";

void main() {
  group("statics", () {
    test("positiveMask", () {
      check(positiveMask(1)).equals(1);
      check(positiveMask(2)).equals(3);
      check(positiveMask(8)).equals(255);
    });
    test("negativeMask", () {
      check(negativeMask(1)).equals(-2);
      check(negativeMask(3)).equals(-8);
      check(negativeMask(8)).equals(-256);
    });
    test("sizedIntToList", () {
      check(signedIntToList(8, -1))
          .containsEqualInOrder(Uint32List.fromList([0xFFFFFFFF]));
    });
    test("sizedBigIntToList", () {
      check(signedBigIntToList(8, BigInt.from(127)))
          .containsEqualInOrder(Uint32List.fromList([0x7F]));
      check(signedBigIntToList(8, BigInt.from(-128)))
          .containsEqualInOrder(Uint32List.fromList([0xFFFFFF80]));
    });
  });
}
