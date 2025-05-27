import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_combustion_inc_platform_interface.dart';
import 'models/battery_status.dart';

/// An implementation of [FlutterCombustionIncPlatform] that uses method channels.
class MethodChannelFlutterCombustionInc extends FlutterCombustionIncPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_combustion_inc');

  /// The event channel used to stream the list of discovered probes.
  @visibleForTesting
  final EventChannel probeListEventChannel = const EventChannel('flutter_combustion_inc_probe_list');

  /// The event channel used to stream virtual temperature updates.
  @visibleForTesting
  final EventChannel virtualTempEventChannel = const EventChannel('flutter_combustion_inc_virtual_temps');

  /// The event channel used to stream battery status updates.
  @visibleForTesting
  final EventChannel batteryStatusEventChannel = const EventChannel('flutter_combustion_inc_battery_status');

  Stream<List<Map<String, dynamic>>>? _probeListStream;

  final Map<String, Stream<Map<String, double>>> _virtualTempStreams = {};

  @override
  Future<void> initBluetooth() async {
    await methodChannel.invokeMethod('initBluetooth');
  }

  @override
  Stream<List<Map<String, dynamic>>> probeListStream() {
    _probeListStream ??= probeListEventChannel.receiveBroadcastStream().map((event) {
      final List<dynamic> list = event as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    });
    return _probeListStream!;
  }

  @override
  Future<List<Map<String, dynamic>>> getProbes() async {
    final List<dynamic> result = await methodChannel.invokeMethod('getProbes') as List<dynamic>;
    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<void> connectToProbe(String identifier) async {
    await methodChannel.invokeMethod('connectToProbe', {'identifier': identifier});
  }

  @override
  Future<void> disconnectFromProbe(String identifier) async {
    await methodChannel.invokeMethod('disconnectFromProbe', {'identifier': identifier});
  }

  @override
  Future<Map<String, double>> getVirtualTemperatures(String identifier) async {
    final result = await methodChannel.invokeMethod('getVirtualTemperatures', {'identifier': identifier});

    return Map<String, double>.from(result as Map);
  }

  @override
  Future<String> getBatteryStatus(String identifier) async {
    final result = await methodChannel.invokeMethod('getBatteryStatus', {'identifier': identifier});
    return result as String;
  }

  @override
  Stream<BatteryStatus> batteryStatusStream(String identifier) {
    // Start the native stream
    methodChannel.invokeMethod('startBatteryStatusStream', {
      'identifier': identifier,
    });

    return batteryStatusEventChannel
        .receiveBroadcastStream({'type': 'batteryStatus'})
        .map((event) => BatteryStatus.fromInt(event as int));
  }

  @override
  Future<List<double>> getCurrentTemperatures(String identifier) async {
    final result = await methodChannel.invokeMethod('getCurrentTemperatures', {'identifier': identifier});
    return List<double>.from(result as Iterable);
  }

  @override
  Stream<Map<String, double>> virtualTemperatureStream(String identifier) {
    return _virtualTempStreams.putIfAbsent(identifier, () {
      // Start the native stream
      methodChannel.invokeMethod('startVirtualTemperatureStream', {
        'identifier': identifier,
      });

      return virtualTempEventChannel.receiveBroadcastStream({'type': 'virtualTemps'}).map((event) {
        final data = Map<String, dynamic>.from(event as Map);
        return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
      });
    });
  }
}
