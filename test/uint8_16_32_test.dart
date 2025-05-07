import 'dart:math';
import 'dart:typed_data';
import 'package:sized_ints/uintx.dart';
import 'package:spec/spec.dart';

void main() {
  group('Uint8', () {
    test('constructor', () {
      expect(Uint8.fromInt(0).toInt()).toEqual(0);
      expect(Uint8.fromInt(255).toInt()).toEqual(255);
      expect(Uint8.fromInt(20).toInt()).toEqual(20);
      expect(() => Uint8.fromInt(-5)).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint8.fromInt(0).toString()).toEqual("0u8");
      expect('${Uint8.fromInt(255)}').toEqual('255u8');
    });

    test('add', () {
      expect(Uint8.fromInt(32) + Uint8.fromInt(64)).toEqual(Uint8.fromInt(96));
      expect(Uint8.fromInt(255) + Uint8.fromInt(1)).toEqual(Uint8.fromInt(0));
      expect(Uint8.fromInt(128) + Uint8.fromInt(129)).toEqual(Uint8.fromInt(1));
    });

    test('subtract', () {
      expect(Uint8.fromInt(0) - Uint8.fromInt(1)).toEqual(Uint8.fromInt(255));
      expect(
        Uint8.fromInt(255) - Uint8.fromInt(128),
      ).toEqual(Uint8.fromInt(127));
      expect(Uint8.fromInt(20) - Uint8.fromInt(50)).toEqual(Uint8.fromInt(226));
    });

    test('multiply', () {
      expect(Uint8.fromInt(0) * Uint8.fromInt(255)).toEqual(Uint8.fromInt(0));
      expect(Uint8.fromInt(255) * Uint8.fromInt(255)).toEqual(Uint8.fromInt(1));
      expect(Uint8.fromInt(32) * Uint8.fromInt(32)).toEqual(Uint8.fromInt(0));
    });

    test('divide', () {
      expect(Uint8.fromInt(0) ~/ Uint8.fromInt(25)).toEqual(Uint8.fromInt(0));
      expect(
        () => Uint8.fromInt(10) ~/ Uint8.fromInt(0),
      ).throws.isUnsupportedError();
      expect(Uint8.fromInt(25) ~/ Uint8.fromInt(4)).toEqual(Uint8.fromInt(6));
    });

    test('mod', () {
      expect(Uint8.fromInt(255) % Uint8.fromInt(16)).toEqual(Uint8.fromInt(15));
      expect(Uint8.fromInt(254) % Uint8.fromInt(250)).toEqual(Uint8.fromInt(4));
      expect(Uint8.fromInt(5) % Uint8.fromInt(32)).toEqual(Uint8.fromInt(5));
    });

    test('bit complement', () {
      expect(~Uint8.fromInt(255)).toEqual(Uint8.fromInt(0));
      expect(~Uint8.fromInt(3)).toEqual(Uint8.fromInt(252));
    });

    test('bitwise and', () {
      expect(Uint8.fromInt(255) & Uint8.fromInt(17)).toEqual(Uint8.fromInt(17));
      expect(Uint8.fromInt(21) & Uint8.fromInt(42)).toEqual(Uint8.fromInt(0));
    });

    test('bitwise or', () {
      expect(
        Uint8.fromInt(255) | Uint8.fromInt(17),
      ).toEqual(Uint8.fromInt(255));
      expect(Uint8.fromInt(21) | Uint8.fromInt(42)).toEqual(Uint8.fromInt(63));
    });

    test('bitwise xor', () {
      expect(
        Uint8.fromInt(255) ^ Uint8.fromInt(17),
      ).toEqual(Uint8.fromInt(238));
      expect(Uint8.fromInt(21) ^ Uint8.fromInt(42)).toEqual(Uint8.fromInt(63));
    });

    test('bitshift left', () {
      expect(Uint8.fromInt(3) << 3).toEqual(Uint8.fromInt(24));
      expect(Uint8.fromInt(3) << 0).toEqual(Uint8.fromInt(3));
      expect(Uint8.fromInt(3) << 7).toEqual(Uint8.fromInt(128));
      expect(Uint8.fromInt(3) << 8).toEqual(Uint8.fromInt(0));
    });

    test('bitshift right', () {
      expect(Uint8.fromInt(3) >> 3).toEqual(Uint8.fromInt(0));
      expect(Uint8.fromInt(3) >> 0).toEqual(Uint8.fromInt(3));
      expect(Uint8.fromInt(250) >> 7).toEqual(Uint8.fromInt(1));
      expect(Uint8.fromInt(250) >> 10).toEqual(Uint8.fromInt(0));
    });

    test('unsigned bitshift right', () {
      expect(Uint8.fromInt(3) >>> 3).toEqual(Uint8.fromInt(0));
      expect(Uint8.fromInt(3) >>> 0).toEqual(Uint8.fromInt(3));
      expect(Uint8.fromInt(250) >>> 7).toEqual(Uint8.fromInt(1));
      expect(Uint8.fromInt(250) >>> 10).toEqual(Uint8.fromInt(0));
    });
  });

  group('Uint16', () {
    test('constructor', () {
      expect(Uint16.fromInt(0).toInt()).toEqual(0);
      expect(Uint16.fromInt(255).toInt()).toEqual(255);
      expect(Uint16.fromInt(20).toInt()).toEqual(20);
      expect(() => Uint16.fromInt(-5)).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint16.fromInt(0).toString()).toEqual("0u16");
      expect('${Uint16.fromInt(255)}').toEqual('255u16');
    });

    test('add', () {
      expect(
        Uint16.fromInt(32) + Uint16.fromInt(64),
      ).toEqual(Uint16.fromInt(96));
      expect(
        Uint16.fromInt(65535) + Uint16.fromInt(1),
      ).toEqual(Uint16.fromInt(0));
      expect(
        Uint16.fromInt(33000) + Uint16.fromInt(33000),
      ).toEqual(Uint16.fromInt(464));
    });

    test('subtract', () {
      expect(
        Uint16.fromInt(0) - Uint16.fromInt(1),
      ).toEqual(Uint16.fromInt(65535));
      expect(
        Uint16.fromInt(65535) - Uint16.fromInt(32768),
      ).toEqual(Uint16.fromInt(32767));
      expect(
        Uint16.fromInt(20) - Uint16.fromInt(50),
      ).toEqual(Uint16.fromInt(65506));
    });

    test('multiply', () {
      expect(
        Uint16.fromInt(0) * Uint16.fromInt(255),
      ).toEqual(Uint16.fromInt(0));
      expect(
        Uint16.fromInt(255) * Uint16.fromInt(255),
      ).toEqual(Uint16.fromInt(65025));
      expect(
        Uint16.fromInt(32768) * Uint16.fromInt(32768),
      ).toEqual(Uint16.fromInt(0));
    });

    test('divide', () {
      expect(
        Uint16.fromInt(0) ~/ Uint16.fromInt(25),
      ).toEqual(Uint16.fromInt(0));
      expect(
        () => Uint16.fromInt(10) ~/ Uint16.fromInt(0),
      ).throws.isUnsupportedError();
      expect(
        Uint16.fromInt(302) ~/ Uint16.fromInt(75),
      ).toEqual(Uint16.fromInt(4));
    });

    test('mod', () {
      expect(
        Uint16.fromInt(65535) % Uint16.fromInt(1024),
      ).toEqual(Uint16.fromInt(1023));
      expect(
        Uint16.fromInt(254) % Uint16.fromInt(250),
      ).toEqual(Uint16.fromInt(4));
      expect(Uint16.fromInt(5) % Uint16.fromInt(16)).toEqual(Uint16.fromInt(5));
    });

    test('bit complement', () {
      expect(~Uint16.fromInt(255)).toEqual(Uint16.fromInt(65280));
      expect(~Uint16.fromInt(3)).toEqual(Uint16.fromInt(65532));
    });

    test('bitwise and', () {
      expect(
        Uint16.fromInt(255) & Uint16.fromInt(17),
      ).toEqual(Uint16.fromInt(17));
      expect(
        Uint16.fromInt(21) & Uint16.fromInt(42),
      ).toEqual(Uint16.fromInt(0));
    });

    test('bitwise or', () {
      expect(
        Uint16.fromInt(255) | Uint16.fromInt(17),
      ).toEqual(Uint16.fromInt(255));
      expect(
        Uint16.fromInt(21) | Uint16.fromInt(42),
      ).toEqual(Uint16.fromInt(63));
    });

    test('bitwise xor', () {
      expect(
        Uint16.fromInt(255) ^ Uint16.fromInt(17),
      ).toEqual(Uint16.fromInt(238));
      expect(
        Uint16.fromInt(21) ^ Uint16.fromInt(42),
      ).toEqual(Uint16.fromInt(63));
    });

    test('bitshift left', () {
      expect(Uint16.fromInt(3) << 3).toEqual(Uint16.fromInt(24));
      expect(Uint16.fromInt(3) << 0).toEqual(Uint16.fromInt(3));
      expect(Uint16.fromInt(1) << 7).toEqual(Uint16.fromInt(128));
      expect(Uint16.fromInt(3) << 15).toEqual(Uint16.fromInt(32768));
      expect(Uint16.fromInt(3) << 16).toEqual(Uint16.fromInt(0));
    });

    test('bitshift right', () {
      expect(Uint16.fromInt(3) >> 3).toEqual(Uint16.fromInt(0));
      expect(Uint16.fromInt(3) >> 0).toEqual(Uint16.fromInt(3));
      expect(Uint16.fromInt(250) >> 7).toEqual(Uint16.fromInt(1));
      expect(Uint16.fromInt(250) >> 10).toEqual(Uint16.fromInt(0));
    });

    test('unsigned bitshift right', () {
      expect(Uint16.fromInt(3) >>> 3).toEqual(Uint16.fromInt(0));
      expect(Uint16.fromInt(3) >>> 0).toEqual(Uint16.fromInt(3));
      expect(Uint16.fromInt(250) >>> 7).toEqual(Uint16.fromInt(1));
      expect(Uint16.fromInt(250) >>> 10).toEqual(Uint16.fromInt(0));
    });
  });

  group('Uint32', () {
    test('constructor', () {
      expect(Uint32.fromInt(0).toInt()).toEqual(0);
      expect(Uint32.fromInt(255).toInt()).toEqual(255);
      expect(Uint32.fromInt(20).toInt()).toEqual(20);
      expect(() => Uint32.fromInt(-5)).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint32.fromInt(0).toString()).toEqual("0u32");
      expect('${Uint32.fromInt(255)}').toEqual('255u32');
    });

    test('add', () {
      expect(
        Uint32.fromInt(32) + Uint32.fromInt(64),
      ).toEqual(Uint32.fromInt(96));
      expect(
        Uint32.fromInt(Uint32.max) + Uint32.fromInt(1),
      ).toEqual(Uint32.fromInt(0));
      expect(
        Uint32.fromInt(2_200_000_000) + Uint32.fromInt(2_200_000_000),
      ).toEqual(Uint32.fromInt(105_032_704));
    });

    test('subtract', () {
      expect(
        Uint32.fromInt(0) - Uint32.fromInt(1),
      ).toEqual(Uint32.fromInt(Uint32.max));
      expect(
        Uint32.fromInt(Uint32.max) - Uint32.fromInt(pow(2, 31) as int),
      ).toEqual(Uint32.fromInt((pow(2, 31) as int) - 1));
      expect(
        Uint32.fromInt(20) - Uint32.fromInt(50),
      ).toEqual(Uint32.fromInt(Uint32.max - 29));
    });

    test('multiply', () {
      expect(
        Uint32.fromInt(0) * Uint32.fromInt(255),
      ).toEqual(Uint32.fromInt(0));
      expect(
        Uint32.fromInt(Uint32.max) * Uint32.fromInt(Uint32.max),
      ).toEqual(Uint32.fromInt(1));
      expect(
        Uint32.fromInt(pow(2, 31) as int) * Uint32.fromInt(pow(2, 31) as int),
      ).toEqual(Uint32.fromInt(0));
    });

    test('divide', () {
      expect(
        Uint32.fromInt(0) ~/ Uint32.fromInt(25),
      ).toEqual(Uint32.fromInt(0));
      expect(
        () => Uint32.fromInt(10) ~/ Uint32.fromInt(0),
      ).throws.isUnsupportedError();
      expect(
        Uint32.fromInt(302) ~/ Uint32.fromInt(75),
      ).toEqual(Uint32.fromInt(4));
    });

    test('mod', () {
      expect(
        Uint32.fromInt(65535) % Uint32.fromInt(1024),
      ).toEqual(Uint32.fromInt(1023));
      expect(
        Uint32.fromInt(254) % Uint32.fromInt(250),
      ).toEqual(Uint32.fromInt(4));
      expect(Uint32.fromInt(5) % Uint32.fromInt(32)).toEqual(Uint32.fromInt(5));
    });

    test('bit complement', () {
      expect(~Uint32.fromInt(255)).toEqual(Uint32.fromInt(Uint32.max - 255));
      expect(~Uint32.fromInt(3)).toEqual(Uint32.fromInt(Uint32.max - 3));
    });

    test('bitwise and', () {
      expect(
        Uint32.fromInt(255) & Uint32.fromInt(17),
      ).toEqual(Uint32.fromInt(17));
      expect(
        Uint32.fromInt(21) & Uint32.fromInt(42),
      ).toEqual(Uint32.fromInt(0));
    });

    test('bitwise or', () {
      expect(
        Uint32.fromInt(255) | Uint32.fromInt(17),
      ).toEqual(Uint32.fromInt(255));
      expect(
        Uint32.fromInt(21) | Uint32.fromInt(42),
      ).toEqual(Uint32.fromInt(63));
      expect(
        Uint32.fromInt(Uint32.max) | Uint32.fromInt(Uint32.max),
      ).toEqual(Uint32.fromInt(Uint32.max));
    });

    test('bitwise xor', () {
      expect(
        Uint32.fromInt(255) ^ Uint32.fromInt(17),
      ).toEqual(Uint32.fromInt(238));
      expect(
        Uint32.fromInt(21) ^ Uint32.fromInt(42),
      ).toEqual(Uint32.fromInt(63));
      expect(
        Uint32.fromInt(Uint32.max) ^ Uint32.fromInt(Uint32.max),
      ).toEqual(Uint32.fromInt(0));
    });

    test('bitshift left', () {
      expect(Uint32.fromInt(3) << 3).toEqual(Uint32.fromInt(24));
      expect(Uint32.fromInt(3) << 0).toEqual(Uint32.fromInt(3));
      expect(Uint32.fromInt(1) << 7).toEqual(Uint32.fromInt(128));
      expect(Uint32.fromInt(3) << 15).toEqual(Uint32.fromInt(98304));
      expect(Uint32.fromInt(3) << 32).toEqual(Uint32.fromInt(0));
    });

    test('bitshift right', () {
      expect(Uint32.fromInt(3) >> 3).toEqual(Uint32.fromInt(0));
      expect(Uint32.fromInt(3) >> 0).toEqual(Uint32.fromInt(3));
      expect(Uint32.fromInt(250) >> 7).toEqual(Uint32.fromInt(1));
      expect(Uint32.fromInt(250) >> 10).toEqual(Uint32.fromInt(0));
    });

    test('unsigned bitshift right', () {
      expect(Uint32.fromInt(3) >>> 3).toEqual(Uint32.fromInt(0));
      expect(Uint32.fromInt(3) >>> 0).toEqual(Uint32.fromInt(3));
      expect(Uint32.fromInt(250) >>> 7).toEqual(Uint32.fromInt(1));
      expect(Uint32.fromInt(250) >>> 10).toEqual(Uint32.fromInt(0));
    });
  });

  group('Uint64', () {
    test('constructor', () {
      expect(Uint64.fromInt(0).values).toEqual((0, 0));
      expect(Uint64(0xFFFFFFFF, 0xFFFFFFFF)).toEqual(Uint64.max);
      expect(Uint64.parse('0xFFFFFFFF')).toEqual(Uint64(0, Uint32.max));
      expect(Uint64.parse('0xFFFFFFFFFFFFFFFF')).toEqual(Uint64.max);
      expect(() => Uint64.fromInt(pow(2, 51) as int)).throws.isArgumentError();
      expect(() => Uint64.fromInt(-3)).throws.isArgumentError();
      expect(() => Uint64(Uint32.max + 1, 0)).throws.isArgumentError();
      expect(() => Uint64(-100, Uint32.max)).throws.isArgumentError();
      expect(() => Uint64(2, -3)).throws.isArgumentError();
      expect(() => Uint64.parse('-27')).throws.isArgumentError();
    });

    test('toString', () {
      expect(Uint64.max.toString()).toEqual('18446744073709551615u64');
      expect(Uint64(1, 0).toString()).toEqual('${0x100000000}u64');
    });

    test('hashCode', () {
      expect(
        Uint64(3, 5).hashCode,
      ).toEqual(Object.hash(64, Object.hashAll(Uint32List.fromList([3, 5]))));
    });
  });
}
