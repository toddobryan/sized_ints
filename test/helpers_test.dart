import "package:sized_ints/config.dart";
import "package:checks/checks.dart";
import "package:sized_ints/helpers.dart";
import "package:test/test.dart";

void main() {
  test("elementMod", () {
    check(elementMod(bitsPerListElement + 5, 0)).equals(32);
    check(elementMod(bitsPerListElement + 5, 2)).equals(1 << bitsPerListElement);
  });

  /*group("statics", () {
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
          .containsEqualInOrder(Uint16List.fromList([0xFFFF]));
    });

    test("sizedBigIntToList", () {
      check(signedBigIntToList(8, BigInt.from(127)))
          .containsEqualInOrder(Uint16List.fromList([0x7F]));
      check(signedBigIntToList(8, BigInt.from(-128)))
          .containsEqualInOrder(Uint16List.fromList([0xFF80]));
    });
  });

  group("extensions on TypedDataList<int>", () {
    test("withOneAdded", () {
      TypedDataList<int> list = listFromInts([14]);
      check(list.withOneAdded()).containsEqualInOrder(listFromInts([15]));
      check(listFromInts([0x7fffffffffffffff]).withOneAdded()).containsEqualInOrder(listFromInts([0]));
    });
  });*/
}

