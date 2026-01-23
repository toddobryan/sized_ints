import "package:sized_ints/config.dart";
import "package:checks/checks.dart";
import "package:sized_ints/helpers.dart";
import "package:sized_ints/typed_data_list_extensions.dart";
import "package:test/test.dart";

void main() {
  print(-1 << 2);

  test("elementMod", () {
    check(elementMod(Config.bitsPerListElement + 5, 0)).equals(32);
    check(elementMod(Config.bitsPerListElement + 5, 2)).equals(1 << Config.bitsPerListElement);
  });

  test("elementMask", () {
    check(elementMask(Config.bitsPerListElement + 5, 0)).equals(31);
    check(elementMask(Config.bitsPerListElement + 5, 2))
        .equals((1 << Config.bitsPerListElement) - 1);
  });

  group("TypedDataList", () {
    /*test("carry", () {
      check(Config.listFromInts([0xAA, 0xAA]).carry(3, 0)).equals(2);
    });*/

    test("shiftedLeft", () {
      List<int> zeroOne8 = [0x00, 0x55, 0x55, 0x55];
      check(Config.listFromInts(zeroOne8).shiftedLeft(25, 0))
        .containsEqualInOrder(zeroOne8);
      check(Config.listFromInts(zeroOne8).shiftedLeft(25, 30))
        .containsEqualInOrder([0, 0, 0 ,0]);
      check(Config.listFromInts(zeroOne8).shiftedLeft(25, 1))
          .containsEqualInOrder([0xAA, 0xAA, 0xAA]);
      check(Config.listFromInts(zeroOne8).shiftedLeft(24, 2))
          .containsEqualInOrder([0x55, 0x55, 0x54]);
      check(Config.listFromInts(zeroOne8).shiftedLeft(24, 3))
          .containsEqualInOrder([0xAA, 0xAA, 0xA8]);
      check(Config.listFromInts(zeroOne8).shiftedLeft(24, 10))
          .containsEqualInOrder([0x55, 0x54, 0x00]);
    });

    test("zeroShiftedRight", () {
      List<int> zeroOne8 = [0x55, 0x55, 0x55];
      check(Config.listFromInts(zeroOne8).zeroShiftedRight(24, 0))
        .containsEqualInOrder(zeroOne8);
      check(Config.listFromInts(zeroOne8).zeroShiftedRight(24, 24))
        .containsEqualInOrder([0, 0, 0]);
      check(Config.listFromInts(zeroOne8).zeroShiftedRight(24, 1))
          .containsEqualInOrder([0x2A, 0xAA, 0xAA]);


      /*check(Config.listFromInts([0xAA, 0xAA]).zeroShiftedRight(16, 1))
          .containsEqualInOrder(Config.listFromInts([0x55, 0x55]));
      check(Config.listFromInts([0x55, 0x55]).zeroShiftedRight(16, 1))
          .containsEqualInOrder(Config.listFromInts([0x2A, 0xAA]));
      check(Config.listFromInts([0x10, 0x00]).zeroShiftedRight(13, 1))
          .containsEqualInOrder(Config.listFromInts([0x08, 0x00]));*/
    });

    test("shiftedRight", () {
      check(Config.listFromInts([0x0A, 0xAA]).shiftedRight(13, 1, 0))
          .containsEqualInOrder(Config.listFromInts([0x05, 0x55]));
      check(Config.listFromInts([0x1A, 0xAA]).shiftedRight(13, 1, 1))
          .containsEqualInOrder(Config.listFromInts([0x1D, 0x55]));
      check(Config.listFromInts([0x6A, 0xAA]).shiftedRight(15, 11, 1))
          .containsEqualInOrder(Config.listFromInts([0x7F, 0xED]));
    });
  });
}

