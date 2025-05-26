import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_combustion_inc_platform_interface.dart';

/// An implementation of [FlutterCombustionIncPlatform] that uses method channels.
class MethodChannelFlutterCombustionInc extends FlutterCombustionIncPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_combustion_inc');

  @override
  Future<void> initBluetooth() async {
    await methodChannel.invokeMethod('initBluetooth');
  }

  @override
  Future<List<Map<String, dynamic>>> getProbes() async {
    final List<dynamic> result = await methodChannel.invokeMethod('getProbes') as List<dynamic>;
    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<void> connectToProbe(String identifier) async {
    await methodChannel.invokeMethod('connectToProbe', {
      'identifier': identifier,
    });
  }

  @override
  Future<void> disconnectFromProbe(String identifier) async {
    await methodChannel.invokeMethod('disconnectFromProbe', {
      'identifier': identifier,
    });
  }

  @override
  Future<String> getBatteryStatus(String identifier) async {
    final result = await methodChannel.invokeMethod('getBatteryStatus', {
      'identifier': identifier,
    });
    return result as String;
  }

  @override
  Future<List<double>> getCurrentTemperatures(String identifier) async {
    final result = await methodChannel.invokeMethod('getCurrentTemperatures', {
      'identifier': identifier,
    });
    return List<double>.from(result as Iterable);
  }
}
