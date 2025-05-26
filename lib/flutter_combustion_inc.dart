
import 'flutter_combustion_inc_platform_interface.dart';

class FlutterCombustionInc {
  Future<String?> getPlatformVersion() {
    return FlutterCombustionIncPlatform.instance.getPlatformVersion();
  }
}
