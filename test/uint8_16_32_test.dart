import 'dart:math';
import 'package:sized_ints/uintx.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

void main() {
  group('Uint8', () {
    test('constructor', () {
      check(Uint8.fromInt(0).toInt()).equals(0);
      check(Uint8.fromInt(255).toInt()).equals(255);
      check(Uint8.fromInt(20).toInt()).equals(20);
      check(() => Uint8.fromInt(-5)).throws<ArgumentError>();
    });

    test('toString', () {
      check(Uint8.fromInt(0).toString()).equals("0u8");
      check('${Uint8.fromInt(255)}').equals('255u8');
    });

    test('add', () {
      check(Uint8.fromInt(32) + Uint8.fromInt(64)).equals(Uint8.fromInt(96));
      check(Uint8.fromInt(255) + Uint8.fromInt(1)).equals(Uint8.fromInt(0));
      check(Uint8.fromInt(128) + Uint8.fromInt(129)).equals(Uint8.fromInt(1));
    });

    test('subtract', () {
      check(Uint8.fromInt(0) - Uint8.fromInt(1)).equals(Uint8.fromInt(255));
      check(Uint8.fromInt(255) - Uint8.fromInt(128)).equals(Uint8.fromInt(127));
      check(Uint8.fromInt(20) - Uint8.fromInt(50)).equals(Uint8.fromInt(226));
    });

    test('multiply', () {
      check(Uint8.fromInt(0) * Uint8.fromInt(255)).equals(Uint8.fromInt(0));
      check(Uint8.fromInt(255) * Uint8.fromInt(255)).equals(Uint8.fromInt(1));
      check(Uint8.fromInt(32) * Uint8.fromInt(32)).equals(Uint8.fromInt(0));
    });

    test('divide', () {
      check(Uint8.fromInt(0) ~/ Uint8.fromInt(25)).equals(Uint8.fromInt(0));
      check(
        () => Uint8.fromInt(10) ~/ Uint8.fromInt(0),
      ).throws<UnsupportedError>();
      check(Uint8.fromInt(25) ~/ Uint8.fromInt(4)).equals(Uint8.fromInt(6));
    });

    test('mod', () {
      check(Uint8.fromInt(255) % Uint8.fromInt(16)).equals(Uint8.fromInt(15));
      check(Uint8.fromInt(254) % Uint8.fromInt(250)).equals(Uint8.fromInt(4));
      check(Uint8.fromInt(5) % Uint8.fromInt(32)).equals(Uint8.fromInt(5));
    });

    test('bit complement', () {
      check(~Uint8.fromInt(255)).equals(Uint8.fromInt(0));
      check(~Uint8.fromInt(3)).equals(Uint8.fromInt(252));
    });

    test('bitwise and', () {
      check(Uint8.fromInt(255) & Uint8.fromInt(17)).equals(Uint8.fromInt(17));
      check(Uint8.fromInt(21) & Uint8.fromInt(42)).equals(Uint8.fromInt(0));
    });

    test('bitwise or', () {
      check(Uint8.fromInt(255) | Uint8.fromInt(17)).equals(Uint8.fromInt(255));
      check(Uint8.fromInt(21) | Uint8.fromInt(42)).equals(Uint8.fromInt(63));
    });

    test('bitwise xor', () {
      check(Uint8.fromInt(255) ^ Uint8.fromInt(17)).equals(Uint8.fromInt(238));
      check(Uint8.fromInt(21) ^ Uint8.fromInt(42)).equals(Uint8.fromInt(63));
    });

    test('bitshift left', () {
      check(Uint8.fromInt(3) << 3).equals(Uint8.fromInt(24));
      check(Uint8.fromInt(3) << 0).equals(Uint8.fromInt(3));
      check(Uint8.fromInt(3) << 7).equals(Uint8.fromInt(128));
      check(Uint8.fromInt(3) << 8).equals(Uint8.fromInt(0));
    });

    test('bitshift right', () {
      check(Uint8.fromInt(3) >> 3).equals(Uint8.fromInt(0));
      check(Uint8.fromInt(3) >> 0).equals(Uint8.fromInt(3));
      check(Uint8.fromInt(250) >> 7).equals(Uint8.fromInt(1));
      check(Uint8.fromInt(250) >> 10).equals(Uint8.fromInt(0));
    });

    test('unsigned bitshift right', () {
      check(Uint8.fromInt(3) >>> 3).equals(Uint8.fromInt(0));
      check(Uint8.fromInt(3) >>> 0).equals(Uint8.fromInt(3));
      check(Uint8.fromInt(250) >>> 7).equals(Uint8.fromInt(1));
      check(Uint8.fromInt(250) >>> 10).equals(Uint8.fromInt(0));
    });
  });

  group('Uint16', () {
    test('constructor', () {
      check(Uint16.fromInt(0).toInt()).equals(0);
      check(Uint16.fromInt(255).toInt()).equals(255);
      check(Uint16.fromInt(20).toInt()).equals(20);
      check(() => Uint16.fromInt(-5)).throws<ArgumentError>();
    });

    test('toString', () {
      check(Uint16.fromInt(0).toString()).equals("0u16");
      check('${Uint16.fromInt(255)}').equals('255u16');
    });

    test('add', () {
      check(Uint16.fromInt(32) + Uint16.fromInt(64)).equals(Uint16.fromInt(96));
      check(
        Uint16.fromInt(65535) + Uint16.fromInt(1),
      ).equals(Uint16.fromInt(0));
      check(
        Uint16.fromInt(33000) + Uint16.fromInt(33000),
      ).equals(Uint16.fromInt(464));
    });

    test('subtract', () {
      check(
        Uint16.fromInt(0) - Uint16.fromInt(1),
      ).equals(Uint16.fromInt(65535));
      check(
        Uint16.fromInt(65535) - Uint16.fromInt(32768),
      ).equals(Uint16.fromInt(32767));
      check(
        Uint16.fromInt(20) - Uint16.fromInt(50),
      ).equals(Uint16.fromInt(65506));
    });

    test('multiply', () {
      check(Uint16.fromInt(0) * Uint16.fromInt(255)).equals(Uint16.fromInt(0));
      check(
        Uint16.fromInt(255) * Uint16.fromInt(255),
      ).equals(Uint16.fromInt(65025));
      check(
        Uint16.fromInt(32768) * Uint16.fromInt(32768),
      ).equals(Uint16.fromInt(0));
    });

    test('divide', () {
      check(Uint16.fromInt(0) ~/ Uint16.fromInt(25)).equals(Uint16.fromInt(0));
      check(
        () => Uint16.fromInt(10) ~/ Uint16.fromInt(0),
      ).throws<UnsupportedError>();
      check(
        Uint16.fromInt(302) ~/ Uint16.fromInt(75),
      ).equals(Uint16.fromInt(4));
    });

    test('mod', () {
      check(
        Uint16.fromInt(65535) % Uint16.fromInt(1024),
      ).equals(Uint16.fromInt(1023));
      check(
        Uint16.fromInt(254) % Uint16.fromInt(250),
      ).equals(Uint16.fromInt(4));
      check(Uint16.fromInt(5) % Uint16.fromInt(16)).equals(Uint16.fromInt(5));
    });

    test('bit complement', () {
      check(~Uint16.fromInt(255)).equals(Uint16.fromInt(65280));
      check(~Uint16.fromInt(3)).equals(Uint16.fromInt(65532));
    });

    test('bitwise and', () {
      check(
        Uint16.fromInt(255) & Uint16.fromInt(17),
      ).equals(Uint16.fromInt(17));
      check(Uint16.fromInt(21) & Uint16.fromInt(42)).equals(Uint16.fromInt(0));
    });

    test('bitwise or', () {
      check(
        Uint16.fromInt(255) | Uint16.fromInt(17),
      ).equals(Uint16.fromInt(255));
      check(Uint16.fromInt(21) | Uint16.fromInt(42)).equals(Uint16.fromInt(63));
    });

    test('bitwise xor', () {
      check(
        Uint16.fromInt(255) ^ Uint16.fromInt(17),
      ).equals(Uint16.fromInt(238));
      check(Uint16.fromInt(21) ^ Uint16.fromInt(42)).equals(Uint16.fromInt(63));
    });

    test('bitshift left', () {
      check(Uint16.fromInt(3) << 3).equals(Uint16.fromInt(24));
      check(Uint16.fromInt(3) << 0).equals(Uint16.fromInt(3));
      check(Uint16.fromInt(1) << 7).equals(Uint16.fromInt(128));
      check(Uint16.fromInt(3) << 15).equals(Uint16.fromInt(32768));
      check(Uint16.fromInt(3) << 16).equals(Uint16.fromInt(0));
    });

    test('bitshift right', () {
      check(Uint16.fromInt(3) >> 3).equals(Uint16.fromInt(0));
      check(Uint16.fromInt(3) >> 0).equals(Uint16.fromInt(3));
      check(Uint16.fromInt(250) >> 7).equals(Uint16.fromInt(1));
      check(Uint16.fromInt(250) >> 10).equals(Uint16.fromInt(0));
    });

    test('unsigned bitshift right', () {
      check(Uint16.fromInt(3) >>> 3).equals(Uint16.fromInt(0));
      check(Uint16.fromInt(3) >>> 0).equals(Uint16.fromInt(3));
      check(Uint16.fromInt(250) >>> 7).equals(Uint16.fromInt(1));
      check(Uint16.fromInt(250) >>> 10).equals(Uint16.fromInt(0));
    });
  });

  group('Uint32', () {
    test('constructor', () {
      check(Uint32.fromInt(0).toInt()).equals(0);
      check(Uint32.fromInt(255).toInt()).equals(255);
      check(Uint32.fromInt(20).toInt()).equals(20);
      check(() => Uint32.fromInt(-5)).throws<ArgumentError>();
    });

    test('toString', () {
      check(Uint32.fromInt(0).toString()).equals("0u32");
      check('${Uint32.fromInt(255)}').equals('255u32');
    });

    test('add', () {
      check(Uint32.fromInt(32) + Uint32.fromInt(64)).equals(Uint32.fromInt(96));
      check(Uint32.max + Uint32.fromInt(1)).equals(Uint32.fromInt(0));
      check(
        Uint32.fromInt(2_200_000_000) + Uint32.fromInt(2_200_000_000),
      ).equals(Uint32.fromInt(105_032_704));
    });

    test('subtract', () {
      check(Uint32.fromInt(0) - Uint32.fromInt(1)).equals(Uint32.max);
      check(
        Uint32.max - Uint32.fromInt(pow(2, 31) as int),
      ).equals(Uint32.fromInt((pow(2, 31) as int) - 1));
      check(
        Uint32.fromInt(20) - Uint32.fromInt(50),
      ).equals(Uint32.fromInt(Uint32.maxAsInt - 29));
    });

    test('multiply', () {
      check(Uint32.fromInt(0) * Uint32.fromInt(255)).equals(Uint32.fromInt(0));
      check(Uint32.max * Uint32.max).equals(Uint32.fromInt(1));
      check(
        Uint32.fromInt(pow(2, 31) as int) * Uint32.fromInt(pow(2, 31) as int),
      ).equals(Uint32.fromInt(0));
    });

    test('divide', () {
      check(Uint32.fromInt(0) ~/ Uint32.fromInt(25)).equals(Uint32.fromInt(0));
      check(
        () => Uint32.fromInt(10) ~/ Uint32.fromInt(0),
      ).throws<UnsupportedError>();
      check(
        Uint32.fromInt(302) ~/ Uint32.fromInt(75),
      ).equals(Uint32.fromInt(4));
    });

    test('mod', () {
      check(
        Uint32.fromInt(65535) % Uint32.fromInt(1024),
      ).equals(Uint32.fromInt(1023));
      check(
        Uint32.fromInt(254) % Uint32.fromInt(250),
      ).equals(Uint32.fromInt(4));
      check(Uint32.fromInt(5) % Uint32.fromInt(32)).equals(Uint32.fromInt(5));
    });

    test('bit complement', () {
      check(~Uint32.fromInt(255)).equals(Uint32.fromInt(Uint32.maxAsInt - 255));
      check(~Uint32.fromInt(3)).equals(Uint32.fromInt(Uint32.maxAsInt - 3));
    });

    test('bitwise and', () {
      check(
        Uint32.fromInt(255) & Uint32.fromInt(17),
      ).equals(Uint32.fromInt(17));
      check(Uint32.fromInt(21) & Uint32.fromInt(42)).equals(Uint32.fromInt(0));
    });

    test('bitwise or', () {
      check(
        Uint32.fromInt(255) | Uint32.fromInt(17),
      ).equals(Uint32.fromInt(255));
      check(Uint32.fromInt(21) | Uint32.fromInt(42)).equals(Uint32.fromInt(63));
      check(Uint32.max | Uint32.max).equals(Uint32.max);
    });

    test('bitwise xor', () {
      check(
        Uint32.fromInt(255) ^ Uint32.fromInt(17),
      ).equals(Uint32.fromInt(238));
      check(Uint32.fromInt(21) ^ Uint32.fromInt(42)).equals(Uint32.fromInt(63));
      check(Uint32.max ^ Uint32.max).equals(Uint32.fromInt(0));
    });

    test('bitshift left', () {
      check(Uint32.fromInt(3) << 3).equals(Uint32.fromInt(24));
      check(Uint32.fromInt(3) << 0).equals(Uint32.fromInt(3));
      check(Uint32.fromInt(1) << 7).equals(Uint32.fromInt(128));
      check(Uint32.fromInt(3) << 15).equals(Uint32.fromInt(98304));
      check(Uint32.fromInt(3) << 32).equals(Uint32.fromInt(0));
    });

    test('bitshift right', () {
      check(Uint32.fromInt(3) >> 3).equals(Uint32.fromInt(0));
      check(Uint32.fromInt(3) >> 0).equals(Uint32.fromInt(3));
      check(Uint32.fromInt(250) >> 7).equals(Uint32.fromInt(1));
      check(Uint32.fromInt(250) >> 10).equals(Uint32.fromInt(0));
    });

    test('unsigned bitshift right', () {
      check(Uint32.fromInt(3) >>> 3).equals(Uint32.fromInt(0));
      check(Uint32.fromInt(3) >>> 0).equals(Uint32.fromInt(3));
      check(Uint32.fromInt(250) >>> 7).equals(Uint32.fromInt(1));
      check(Uint32.fromInt(250) >>> 10).equals(Uint32.fromInt(0));
    });
  });

  group('Uint64', () {
    test('constructor', () {
      check(Uint64.fromInt(0).values).equals((0, 0));
      check(Uint64.parse('0xFFFFFFFF_FFFFFFFF')).equals(Uint64.max);
      check(Uint64.parse('0xFFFFFFFF')).equals(Uint64.fromInt(Uint32.maxAsInt));
      check(Uint64.parse('0xFFFFFFFFFFFFFFFF')).equals(Uint64.max);
      check(() => Uint64.fromInt(pow(2, 51) as int)).throws<ArgumentError>();
      check(() => Uint64.fromInt(-3)).throws<ArgumentError>();
      check(() => Uint64.fromInt(Uint32.maxAsInt + 1)).throws<ArgumentError>();
      check(() => Uint64.parse('-27')).throws<ArgumentError>();
    });

    test('toString', () {
      check(Uint64.max.toString()).equals('18446744073709551615u64');
      check(
        Uint64.parse('0x1_00000000').toString(),
      ).equals('${0x100000000}u64');
    });
  });
}
