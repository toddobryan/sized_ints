import 'env_for_safe_int/get_env_for_safe_int.dart';

/// An enum representing (roughly) the current platform. Used
/// to determine which int values may be safely returned.
///
/// For native and wasm, ints are on the range [-2^63, 2^63-1].
/// For web, ints are on the range [-2^53, 2^53-1].
enum EnvForSafeInt {
  android(true),
  ios(true),
  windows(true),
  mac(true),
  linux(true),
  fuchsia(true),
  js(false),
  wasm(true);

  /// Whether the current platform is a native VM.
  final bool isNative;

  static EnvForSafeInt? _current;

  const EnvForSafeInt(this.isNative);

  /// Whether the current platform is web (Javascript).
  bool get isWeb => !isNative;

  /// The current platform.
  static EnvForSafeInt get current {
    _current ??= getDiscoverEnvForSafeInt().getEnvForSafeInt();
    return _current!;
  }

  /// The maximum integer for the current platform.
  int get maxInteger {
    if (current.isNative) {
      return (1 << 63) - 1;
    } else {
      return (1 << 53) - 1;
    }
  }

  /// The minimum integer for the current platform.
  int get minInteger {
    if (current.isNative) {
      return -(1 << 63);
    } else {
      return -(1 << 53);
    }
  }

  /// The maximum bit length for the current platform.
  int get maxBitLength {
    if (current.isNative) {
      return 64;
    } else {
      return 53;
    }
  }
}


extension BigIntToSafeInt on BigInt {
  /// Converts this BigInt to an int on the current platform, or throws an
  /// error if such an int would be out of the range the platform can handle.
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
