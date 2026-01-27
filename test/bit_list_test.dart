import "dart:typed_data";

import "package:checks/checks.dart";
import "package:sized_ints/bit_list.dart";
import "package:test/test.dart";

void main() {
  test("elementMod", () {
    check(elementMod(BitList.bitsPerListElement + 5, 0)).equals(32);
    check(elementMod(BitList.bitsPerListElement + 5, 2))
        .equals(1 << BitList.bitsPerListElement);
  });

  test("elementMask", () {
    check(elementMask(BitList.bitsPerListElement + 5, 0)).equals(31);
    check(elementMask(BitList.bitsPerListElement + 5, 2))
        .equals((1 << BitList.bitsPerListElement) - 1);
  });

  group("BitList", () {
    BitList zeroOne37 = BitList.ints(37, [0x0015, 0x5555_5555]);
    BitList zo37sl1 = BitList.ints(37, [0x000A, 0xAAAA_AAAA]);
    BitList zo37sl2 = BitList.ints(37, [0x0015, 0x5555_5554]);
    BitList zo37sl3 = BitList.ints(37, [0x000A, 0xAAAA_AAA8]);
    BitList zo37sl20 = BitList.ints(37, [0x0015, 0x5550_0000]);

    test("toString", () {
      check(zeroOne37.toString())
          .equals("BitList.ints(37, [0x0015, 0x5555_5555])");
      check(zo37sl1.toString())
          .equals("BitList.ints(37, [0x000A, 0xAAAA_AAAA])");
    });

    test("shiftedLeftOddBreak", () {
      check(zeroOne37 << 0).equals(zeroOne37);
      check(zeroOne37 << 40).equals(BitList(37, Uint32List(2)));
      check(zeroOne37 << 1).equals(zo37sl1);
      check(zeroOne37 << 2).equals(zo37sl2);
      check(zeroOne37 << 3).equals(zo37sl3);
      check(zeroOne37 << 20).equals(zo37sl20);
    });

    test("shiftedLeft8bits", () {
      int x = 0x25;
      BitList list = BitList.int(8, x);
      for (int i = 0; i < 10; i++) {
        check(list << i).equals(BitList.int(8, x));
        x = (2 * x) % 256;
      }
    });

    test("shiftedLeft16bits", () {
      int x = 0x0215;
      BitList list = BitList.int(16, x);
      for (int i = 0; i < 17; i++) {
        check(list << i).equals(BitList.int(16, x));
        x = (2 * x) % 65536;
      }
    });


    test("zeroShiftedRight", () {
      check(zeroOne37.zeroShiftedRight(0)).equals(zeroOne37);
      check(zeroOne37.zeroShiftedRight(37)).equals(BitList.ints(37, [0, 0]));
      check(zeroOne37.zeroShiftedRight(1))
          .equals(BitList.ints(37, [0x000A, 0xAAAA_AAAA]));
      check(zeroOne37.zeroShiftedRight(2))
          .equals(BitList.ints(37, [0x0005, 0x5555_5555]));
      check(zeroOne37.zeroShiftedRight(3))
          .equals(BitList.ints(37, [0x0002, 0xAAAA_AAAA]));
      check(zeroOne37.zeroShiftedRight(5))
          .equals(BitList.ints(37, [0x0, 0xAAAA_AAAA]));
      check(zeroOne37.zeroShiftedRight(8))
          .equals(BitList.ints(37, [0x0, 0x1555_5555]));
    });

    test("shiftedRight with signBit", () {
      check(zeroOne37.shiftedRight(0, 1)).equals(zeroOne37);
      check(zeroOne37.zeroShiftedRight(37)).equals(BitList.ints(37, [0, 0]));
      check(zeroOne37.shiftedRight(1, 1))
          .equals(BitList.ints(37, [0x001A, 0xAAAA_AAAA]));
      check(zeroOne37.shiftedRight(2, 1))
          .equals(BitList.ints(37, [0x001D, 0x5555_5555]));
      check(zeroOne37.shiftedRight(3, 1))
          .equals(BitList.ints(37, [0x001E, 0xAAAA_AAAA]));
      check(zeroOne37.shiftedRight(5, 1))
          .equals(BitList.ints(37, [0x001F, 0xAAAA_AAAA]));
      check(zeroOne37.shiftedRight(8, 1))
          .equals(BitList.ints(37, [0x001F, 0xF555_5555]));
      check(zeroOne37.shiftedRight(12, 1))
          .equals(BitList.ints(37, [0x001F, 0xFF55_5555]));
      check(zeroOne37.shiftedRight(13, 1))
          .equals(BitList.ints(37, [0x001F, 0xFFAA_AAAA]));
    });
  });
}

