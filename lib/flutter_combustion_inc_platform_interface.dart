import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_combustion_inc_method_channel.dart';

abstract class FlutterCombustionIncPlatform extends PlatformInterface {
  /// Constructs a FlutterCombustionIncPlatform.
  FlutterCombustionIncPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCombustionIncPlatform _instance = MethodChannelFlutterCombustionInc();

  /// The default instance of [FlutterCombustionIncPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCombustionInc].
  static FlutterCombustionIncPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterCombustionIncPlatform] when
  /// they register themselves.
  static set instance(FlutterCombustionIncPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
