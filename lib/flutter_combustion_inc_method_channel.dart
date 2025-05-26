import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_combustion_inc_platform_interface.dart';

/// An implementation of [FlutterCombustionIncPlatform] that uses method channels.
class MethodChannelFlutterCombustionInc extends FlutterCombustionIncPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_combustion_inc');
}
