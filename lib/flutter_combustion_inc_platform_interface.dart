import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_combustion_inc_method_channel.dart';

/// The interface that implementations of _flutter_combustion_inc_ must implement.
abstract class FlutterCombustionIncPlatform extends PlatformInterface {
  /// Constructs a [FlutterCombustionIncPlatform].
  FlutterCombustionIncPlatform() : super(token: _token);

  /// A token that can be used to verify that subclasses extend this class.
  static final Object _token = Object();

  /// The default instance of [FlutterCombustionIncPlatform] to use.
  static FlutterCombustionIncPlatform _instance = MethodChannelFlutterCombustionInc();

  /// The default instance of [FlutterCombustionIncPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCombustionInc].
  static FlutterCombustionIncPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own platform-specific class that extends
  /// [FlutterCombustionIncPlatform] when they register themselves.
  static set instance(FlutterCombustionIncPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
