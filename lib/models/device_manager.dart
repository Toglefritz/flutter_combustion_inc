import 'dart:async';
import 'package:flutter/services.dart';

import '../flutter_combustion_inc_platform_interface.dart';
import 'prediction_info.dart';
import 'probe.dart';

/// A singleton class that provides access to the Combustion Inc. SDK functionality for scanning and managing
/// discovered temperature probes.
///
/// This class acts as the Dart-side interface to the native DeviceManager on iOS and Android, using platform channels
/// to communicate with the underlying SDKs.
class DeviceManager {
  /// The singleton instance of DeviceManager.
  static final DeviceManager instance = DeviceManager._internal();

  /// Internal constructor for this singleton class.
  DeviceManager._internal();

  /// Event channel used to stream probe discovery events from the native platform.
  static const EventChannel _scanChannel = EventChannel(
    'flutter_combustion_inc_scan',
  );

  /// A stream od [Probe] devies discovered during the Bluetooth scan.
  Stream<Probe>? _scanResults;

  /// A stream of [Probe]s discovered while scanning.
  ///
  /// This stream is populated by listening to events from the native SDK via the scan event channel.
  Stream<Probe> get scanResults {
    _scanResults ??= _scanChannel.receiveBroadcastStream().map(
      (dynamic event) => Probe.fromMap(Map<String, dynamic>.from(event as Map)),
    );
    return _scanResults!;
  }

  /// Initializes Bluetooth on the device and begins scanning for probes.
  ///
  /// This sends a platform method call to the native SDK to start BLE scanning.
  Future<void> initBluetooth() async {
    await FlutterCombustionIncPlatform.instance.initBluetooth();
  }

  /// Retrieves a list of currently known [Probe]s from the native SDK.
  ///
  /// The native platform is expected to return a list of probe maps, each of which will be converted into a [Probe]
  /// instance.
  Future<List<Probe>> getProbes() async {
    final List<Map<String, dynamic>> result = await FlutterCombustionIncPlatform
        .instance
        .getProbes();

    return result.map(Probe.fromMap).toList();
  }

  /// Sets a target temperature for the specified probe to enable temperature predictions.
  ///
  /// Once a target temperature is set, the probe will begin making predictions including an estimated time of arrival
  /// (ETA) for when the food will reach the target temperature.
  ///
  /// @param identifier The unique identifier of the probe
  /// @param temperatureCelsius The target temperature in Celsius
  /// @throws PlatformException if the temperature is outside valid range or probe is not connected
  Future<void> setTargetTemperature(
    String identifier,
    double temperatureCelsius,
  ) async {
    await FlutterCombustionIncPlatform.instance.setTargetTemperature(
      identifier,
      temperatureCelsius,
    );
  }

  /// Provides a stream of temperature prediction information for the specified probe.
  ///
  /// This stream emits [PredictionInfo] objects containing estimated time to reach target temperature and other
  /// cooking predictions. Predictions are only available after a target temperature has been set using
  /// [setTargetTemperature].
  ///
  /// The stream will emit updates whenever the probe's prediction calculations change based on current temperature
  /// trends and cooking conditions.
  ///
  /// @param identifier The unique identifier of the probe
  /// @returns Stream of prediction information updates
  Stream<PredictionInfo> predictionStream(String identifier) {
    return FlutterCombustionIncPlatform.instance.predictionStream(identifier);
  }
}
