import 'dart:io' as io show Platform;

import '../env_for_safe_int.dart';

class _NativeDiscoverEnvForSafeInt implements DiscoverEnvForSafeInt {
  @override
  EnvForSafeInt getEnvForSafeInt() {
    if (io.Platform.isAndroid) {
      return EnvForSafeInt.android;
    } else if (io.Platform.isIOS) {
      return EnvForSafeInt.ios;
    } else if (io.Platform.isMacOS) {
      return EnvForSafeInt.ios;
    } else if (io.Platform.isWindows) {
      return EnvForSafeInt.windows;
    } else if (io.Platform.isLinux) {
      return EnvForSafeInt.linux;
    } else if (io.Platform.isFuchsia) {
      return EnvForSafeInt.fuchsia;
    } else {
      throw StateError("Unrecognized native platform");
    }
  }
}

DiscoverEnvForSafeInt getDiscoverEnvForSafeInt() => _NativeDiscoverEnvForSafeInt();