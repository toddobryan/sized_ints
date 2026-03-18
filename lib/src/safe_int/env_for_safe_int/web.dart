import '../env_for_safe_int.dart';

class _WebDiscoverEnvForSafeInt implements DiscoverEnvForSafeInt {
  @override
  EnvForSafeInt getEnvForSafeInt() {
    const bool isJsLoaded = bool.fromEnvironment("dart.library.js");
    if (isJsLoaded) {
      return EnvForSafeInt.js;
    } else {
      return EnvForSafeInt.wasm;
    }
  }
}

DiscoverEnvForSafeInt getDiscoverEnvForSafeInt() => _WebDiscoverEnvForSafeInt();