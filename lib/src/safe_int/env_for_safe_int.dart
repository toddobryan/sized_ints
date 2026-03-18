import 'env_for_safe_int/get_env_for_safe_int.dart';

enum EnvForSafeInt {
  android(true),
  ios(true),
  windows(true),
  mac(true),
  linux(true),
  fuchsia(true),
  js(false),
  wasm(true);

  final bool isNative;
  static EnvForSafeInt? _current;

  const EnvForSafeInt(this.isNative);

  bool get isWeb => !isNative;

  static EnvForSafeInt get current {
    _current ??= getDiscoverEnvForSafeInt().getEnvForSafeInt();
    return _current!;
  }

  int get maxInteger {
    if (current.isNative) {
      return (1 << 63) - 1;
    } else {
      return (1 << 53) - 1;
    }
  }

  int get minInteger {
    if (current.isNative) {
      return -(1 << 63);
    } else {
      return -(1 << 53);
    }
  }

  int get maxBitLength {
    if (current.isNative) {
      return 64;
    } else {
      return 53;
    }
  }
}

extension BigIntToSafeInt on BigInt {
  int toSafeInt() {
    if (this < BigInt.from(EnvForSafeInt.current.minInteger) ||
        this > BigInt.from(EnvForSafeInt.current.maxInteger)) {
      throw RangeError("not safe to return $this as int on current platform");
    }
    return toInt();
  }
}

abstract class DiscoverEnvForSafeInt {
  EnvForSafeInt getEnvForSafeInt();
}
