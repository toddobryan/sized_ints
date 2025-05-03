import 'dart:math';
import 'package:sized_ints/uints.dart';
import 'package:spec/spec.dart';

void main() {
  group('Uint8', () {
    test('constructor', () {
      expect(Uint8(0).value).toEqual(0);
      expect(Uint8(255).value).toEqual(255);
      expect(Uint8(20).value).toEqual(20);
      expect(() => Uint8(-5)).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint8(0).toString()).toEqual("0u8");
      expect('${Uint8(255)}').toEqual('255u8');
    });

    test('add', () {
      expect(Uint8(32) + Uint8(64)).toEqual(Uint8(96));
      expect(Uint8(255) + Uint8(1)).toEqual(Uint8(0));
      expect(Uint8(128) + Uint8(129)).toEqual(Uint8(1));
    });

    test('subtract', () {
      expect(Uint8(0) - Uint8(1)).toEqual(Uint8(255));
      expect(Uint8(255) - Uint8(128)).toEqual(Uint8(127));
      expect(Uint8(20) - Uint8(50)).toEqual(Uint8(226));
    });

    test('multiply', () {
      expect(Uint8(0) * Uint8(255)).toEqual(Uint8(0));
      expect(Uint8(255) * Uint8(255)).toEqual(Uint8(1));
      expect(Uint8(32) * Uint8(32)).toEqual(Uint8(0));
    });

    test('divide', () {
      expect(Uint8(0) ~/ Uint8(25)).toEqual(Uint8(0));
      expect(() => Uint8(10) ~/ Uint8(0)).throws.isUnsupportedError();
      expect(Uint8(25) ~/ Uint8(4)).toEqual(Uint8(6));
    });

    test('mod', () {
      expect(Uint8(255) % Uint8(16)).toEqual(Uint8(15));
      expect(Uint8(254) % Uint8(250)).toEqual(Uint8(4));
      expect(Uint8(5) % Uint8(32)).toEqual(Uint8(5));
    });

    test('bit complement', () {
      expect(~Uint8(255)).toEqual(Uint8(0));
      expect(~Uint8(3)).toEqual(Uint8(252));
    });

    test('bitwise and', () {
      expect(Uint8(255) & Uint8(17)).toEqual(Uint8(17));
      expect(Uint8(21) & Uint8(42)).toEqual(Uint8(0));
    });

    test('bitwise or', () {
      expect(Uint8(255) | Uint8(17)).toEqual(Uint8(255));
      expect(Uint8(21) | Uint8(42)).toEqual(Uint8(63));
    });

    test('bitwise xor', () {
      expect(Uint8(255) ^ Uint8(17)).toEqual(Uint8(238));
      expect(Uint8(21) ^ Uint8(42)).toEqual(Uint8(63));
    });

    test('bitshift left', () {
      expect(Uint8(3) << 3).toEqual(Uint8(24));
      expect(Uint8(3) << 0).toEqual(Uint8(3));
      expect(Uint8(3) << 7).toEqual(Uint8(128));
      expect(Uint8(3) << 8).toEqual(Uint8(0));
    });

    test('bitshift right', () {
      expect(Uint8(3) >> 3).toEqual(Uint8(0));
      expect(Uint8(3) >> 0).toEqual(Uint8(3));
      expect(Uint8(250) >> 7).toEqual(Uint8(1));
      expect(Uint8(250) >> 10).toEqual(Uint8(0));
    });

    test('unsigned bitshift right', () {
      expect(Uint8(3) >>> 3).toEqual(Uint8(0));
      expect(Uint8(3) >>> 0).toEqual(Uint8(3));
      expect(Uint8(250) >>> 7).toEqual(Uint8(1));
      expect(Uint8(250) >>> 10).toEqual(Uint8(0));
    });

    test('hashcode', () {
      expect(Uint8(37).hashCode).toEqual(37.hashCode);
    });
  });

  group('Uint16', () {
    test('constructor', () {
      expect(Uint16(0).value).toEqual(0);
      expect(Uint16(255).value).toEqual(255);
      expect(Uint16(20).value).toEqual(20);
      expect(() => Uint16(-5)).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint16(0).toString()).toEqual("0u16");
      expect('${Uint16(255)}').toEqual('255u16');
    });

    test('add', () {
      expect(Uint16(32) + Uint16(64)).toEqual(Uint16(96));
      expect(Uint16(65535) + Uint16(1)).toEqual(Uint16(0));
      expect(Uint16(33000) + Uint16(33000)).toEqual(Uint16(464));
    });

    test('subtract', () {
      expect(Uint16(0) - Uint16(1)).toEqual(Uint16(65535));
      expect(Uint16(65535) - Uint16(32768)).toEqual(Uint16(32767));
      expect(Uint16(20) - Uint16(50)).toEqual(Uint16(65506));
    });

    test('multiply', () {
      expect(Uint16(0) * Uint16(255)).toEqual(Uint16(0));
      expect(Uint16(255) * Uint16(255)).toEqual(Uint16(65025));
      expect(Uint16(32768) * Uint16(32768)).toEqual(Uint16(0));
    });

    test('divide', () {
      expect(Uint16(0) ~/ Uint16(25)).toEqual(Uint16(0));
      expect(() => Uint16(10) ~/ Uint16(0)).throws.isUnsupportedError();
      expect(Uint16(302) ~/ Uint16(75)).toEqual(Uint16(4));
    });

    test('mod', () {
      expect(Uint16(65535) % Uint16(1024)).toEqual(Uint16(1023));
      expect(Uint16(254) % Uint16(250)).toEqual(Uint16(4));
      expect(Uint16(5) % Uint16(16)).toEqual(Uint16(5));
    });

    test('bit complement', () {
      expect(~Uint16(255)).toEqual(Uint16(65280));
      expect(~Uint16(3)).toEqual(Uint16(65532));
    });

    test('bitwise and', () {
      expect(Uint16(255) & Uint16(17)).toEqual(Uint16(17));
      expect(Uint16(21) & Uint16(42)).toEqual(Uint16(0));
    });

    test('bitwise or', () {
      expect(Uint16(255) | Uint16(17)).toEqual(Uint16(255));
      expect(Uint16(21) | Uint16(42)).toEqual(Uint16(63));
    });

    test('bitwise xor', () {
      expect(Uint16(255) ^ Uint16(17)).toEqual(Uint16(238));
      expect(Uint16(21) ^ Uint16(42)).toEqual(Uint16(63));
    });

    test('bitshift left', () {
      expect(Uint16(3) << 3).toEqual(Uint16(24));
      expect(Uint16(3) << 0).toEqual(Uint16(3));
      expect(Uint16(1) << 7).toEqual(Uint16(128));
      expect(Uint16(3) << 15).toEqual(Uint16(32768));
      expect(Uint16(3) << 16).toEqual(Uint16(0));
    });

    test('bitshift right', () {
      expect(Uint16(3) >> 3).toEqual(Uint16(0));
      expect(Uint16(3) >> 0).toEqual(Uint16(3));
      expect(Uint16(250) >> 7).toEqual(Uint16(1));
      expect(Uint16(250) >> 10).toEqual(Uint16(0));
    });

    test('unsigned bitshift right', () {
      expect(Uint16(3) >>> 3).toEqual(Uint16(0));
      expect(Uint16(3) >>> 0).toEqual(Uint16(3));
      expect(Uint16(250) >>> 7).toEqual(Uint16(1));
      expect(Uint16(250) >>> 10).toEqual(Uint16(0));
    });

    test('hashcode', () {
      expect(Uint16(37).hashCode).toEqual(37.hashCode);
    });
  });

  group('Uint32', () {
    test('constructor', () {
      expect(Uint32(0).value).toEqual(0);
      expect(Uint32(255).value).toEqual(255);
      expect(Uint32(20).value).toEqual(20);
      expect(() => Uint32(-5)).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint32(0).toString()).toEqual("0u32");
      expect('${Uint32(255)}').toEqual('255u32');
    });

    test('add', () {
      expect(Uint32(32) + Uint32(64)).toEqual(Uint32(96));
      expect(Uint32(Uint32.max) + Uint32(1)).toEqual(Uint32(0));
      expect(
        Uint32(2_200_000_000) + Uint32(2_200_000_000),
      ).toEqual(Uint32(105_032_704));
    });

    test('subtract', () {
      expect(Uint32(0) - Uint32(1)).toEqual(Uint32(Uint32.max));
      expect(
        Uint32(Uint32.max) - Uint32(pow(2, 31) as int),
      ).toEqual(Uint32((pow(2, 31) as int) - 1));
      expect(Uint32(20) - Uint32(50)).toEqual(Uint32(Uint32.max - 29));
    });

    test('multiply', () {
      expect(Uint32(0) * Uint32(255)).toEqual(Uint32(0));
      expect(Uint32(Uint32.max) * Uint32(Uint32.max)).toEqual(Uint32(1));
      expect(
        Uint32(pow(2, 31) as int) * Uint32(pow(2, 31) as int),
      ).toEqual(Uint32(0));
    });

    test('divide', () {
      expect(Uint32(0) ~/ Uint32(25)).toEqual(Uint32(0));
      expect(() => Uint32(10) ~/ Uint32(0)).throws.isUnsupportedError();
      expect(Uint32(302) ~/ Uint32(75)).toEqual(Uint32(4));
    });

    test('mod', () {
      expect(Uint32(65535) % Uint32(1024)).toEqual(Uint32(1023));
      expect(Uint32(254) % Uint32(250)).toEqual(Uint32(4));
      expect(Uint32(5) % Uint32(32)).toEqual(Uint32(5));
    });

    test('bit complement', () {
      expect(~Uint32(255)).toEqual(Uint32(Uint32.max - 255));
      expect(~Uint32(3)).toEqual(Uint32(Uint32.max - 3));
    });

    test('bitwise and', () {
      expect(Uint32(255) & Uint32(17)).toEqual(Uint32(17));
      expect(Uint32(21) & Uint32(42)).toEqual(Uint32(0));
    });

    test('bitwise or', () {
      expect(Uint32(255) | Uint32(17)).toEqual(Uint32(255));
      expect(Uint32(21) | Uint32(42)).toEqual(Uint32(63));
      expect(
        Uint32(Uint32.max) | Uint32(Uint32.max),
      ).toEqual(Uint32(Uint32.max));
    });

    test('bitwise xor', () {
      expect(Uint32(255) ^ Uint32(17)).toEqual(Uint32(238));
      expect(Uint32(21) ^ Uint32(42)).toEqual(Uint32(63));
      expect(Uint32(Uint32.max) ^ Uint32(Uint32.max)).toEqual(Uint32(0));
    });

    test('bitshift left', () {
      expect(Uint32(3) << 3).toEqual(Uint32(24));
      expect(Uint32(3) << 0).toEqual(Uint32(3));
      expect(Uint32(1) << 7).toEqual(Uint32(128));
      expect(Uint32(3) << 15).toEqual(Uint32(98304));
      expect(Uint32(3) << 32).toEqual(Uint32(0));
    });

    test('bitshift right', () {
      expect(Uint32(3) >> 3).toEqual(Uint32(0));
      expect(Uint32(3) >> 0).toEqual(Uint32(3));
      expect(Uint32(250) >> 7).toEqual(Uint32(1));
      expect(Uint32(250) >> 10).toEqual(Uint32(0));
    });

    test('unsigned bitshift right', () {
      expect(Uint32(3) >>> 3).toEqual(Uint32(0));
      expect(Uint32(3) >>> 0).toEqual(Uint32(3));
      expect(Uint32(250) >>> 7).toEqual(Uint32(1));
      expect(Uint32(250) >>> 10).toEqual(Uint32(0));
    });

    test('hashcode', () {
      expect(Uint32(37).hashCode).toEqual(37.hashCode);
    });
  });

  /*group('Uint64', () {
    test('constructor', () {
      expect(Uint64.fromInt(0).values).toEqual((0, 0));
      expect(Uint64(0xFFFFFFFF, 0xFFFFFFFF)).toEqual(Uint64.max);
      expect(Uint64.fromString('0xFFFFFFFF')).toEqual(Uint64(0, Uint32.max));
      expect(Uint64.fromString('0xFFFFFFFFFFFFFFFF')).toEqual(Uint64.max);
      expect(() => Uint64.fromInt(pow(2, 51) as int)).throws.isArgumentError();
      expect(() => Uint64.fromInt(-3)).throws.isArgumentError();
      expect(() => Uint64(Uint32.max + 1, 0)).throws.isArgumentError();
      expect(() => Uint64(-100, Uint32.max)).throws.isArgumentError();
      expect(() => Uint64(2, -3)).throws.isArgumentError();
      expect(() => Uint64.fromString('-27')).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint64.max.toString()).toEqual('18446744073709551615u64');
      expect(Uint64(1, 0).toString()).toEqual('${Uint64.upperRightmostCol}u64');
    });

    test('hashCode', () {
      expect(Uint64(3, 5).hashCode).toEqual(Object.hash(3, 5));
    });
  });*/
}
