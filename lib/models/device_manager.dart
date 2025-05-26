import 'dart:async';
import 'package:flutter/services.dart';

import '../flutter_combustion_inc_platform_interface.dart';
import 'probe.dart';

/// A singleton class that provides access to the Combustion Inc. SDK functionality
/// for scanning and managing discovered temperature probes.
///
/// This class acts as the Dart-side interface to the native DeviceManager on iOS
/// and Android, using platform channels to communicate with the underlying SDKs.
class DeviceManager {
  /// The singleton instance of DeviceManager.
  static final DeviceManager instance = DeviceManager._internal();

  DeviceManager._internal();

  /// Event channel used to stream probe discovery events from the native platform.
  static const EventChannel _scanChannel = EventChannel('flutter_combustion_inc_scan');

  Stream<Probe>? _scanResults;

  /// A stream of [Probe]s discovered while scanning.
  ///
  /// This stream is populated by listening to events from the native SDK
  /// via the scan event channel.
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
  /// The native platform is expected to return a list of probe maps,
  /// each of which will be converted into a [Probe] instance.
  Future<List<Probe>> getProbes() async {
    final result = await FlutterCombustionIncPlatform.instance.getProbes();
    return result.map(Probe.fromMap).toList();
  }
}
