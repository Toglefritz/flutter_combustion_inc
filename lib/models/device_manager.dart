import 'dart:async';

import 'package:flutter/services.dart';

import '../flutter_combustion_inc_platform_interface.dart';
import 'devices/device.dart';
import 'devices/meat_net_node.dart';
import 'devices/probe.dart';
import 'prediction/prediction_info.dart';

/// Central registry and coordinator for all Combustion BLE devices.
///
/// Mirrors the iOS SDK's `DeviceManager` singleton. Maintains a local registry of discovered devices (probes and
/// MeatNet nodes), provides reactive streams for device discovery, and routes commands to the appropriate device.
class DeviceManager {
  /// The singleton instance.
  static final DeviceManager instance = DeviceManager._internal();

  DeviceManager._internal();

  /// Event channel for probe discovery events from the native platform.
  static const EventChannel _scanChannel = EventChannel(
    'flutter_combustion_inc_scan',
  );

  /// Local registry of all known devices, keyed by [Device.uniqueIdentifier].
  ///
  /// For probes the key is the serial number string. For MeatNet nodes the key is the BLE peripheral UUID string.
  final Map<String, Device> devices = <String, Device>{};

  /// Controller for broadcasting device list changes.
  final StreamController<List<Device>> _devicesController =
      StreamController<List<Device>>.broadcast();

  /// Emits the full device list whenever a device is added or removed.
  Stream<List<Device>> get devicesStream => _devicesController.stream;

  /// Returns all currently known probes.
  List<Probe> get probes {
    return devices.values.whereType<Probe>().toList();
  }

  /// Returns all currently known MeatNet nodes.
  List<MeatNetNode> get meatNetNodes {
    return devices.values.whereType<MeatNetNode>().toList();
  }

  /// A stream of [Probe]s discovered while scanning.
  ///
  /// Each emission represents a single probe that was discovered or updated. Probes are also added to the [devices]
  /// registry automatically.
  Stream<Probe>? _scanResults;

  /// Stream of individual probe discovery events.
  ///
  /// Subscribing to this stream also populates the [devices] registry.
  Stream<Probe> get scanResults {
    _scanResults ??= _scanChannel.receiveBroadcastStream().map(
      (dynamic event) {
        final Probe probe = Probe.fromMap(
          Map<String, dynamic>.from(event as Map),
        );
        _addDevice(probe);

        return probe;
      },
    );

    return _scanResults!;
  }

  /// Initializes Bluetooth and begins scanning for devices.
  Future<void> initBluetooth() async {
    await FlutterCombustionIncPlatform.instance.initBluetooth();
  }

  /// Retrieves a snapshot of all currently known probes from the native SDK and updates the local registry.
  Future<List<Probe>> getProbes() async {
    final List<Map<String, dynamic>> result = await FlutterCombustionIncPlatform
        .instance
        .getProbes();

    final List<Probe> probeList = result.map(Probe.fromMap).toList()
      ..forEach(_addDevice);

    return probeList;
  }

  /// Looks up a device by its unique identifier.
  Device? getDevice(String uniqueIdentifier) {
    return devices[uniqueIdentifier];
  }

  /// Looks up a probe by its unique identifier (serial number string).
  Probe? getProbe(String identifier) {
    final Device? device = devices[identifier];
    if (device is Probe) {
      return device;
    }

    // Fall back to searching by BLE identifier for backward compatibility
    for (final Device d in devices.values) {
      if (d is Probe && d.bleIdentifier == identifier) {
        return d;
      }
    }

    return null;
  }

  /// Sets a target temperature for the specified probe to enable predictions.
  Future<void> setTargetTemperature(
    String identifier,
    double temperatureCelsius,
  ) async {
    await FlutterCombustionIncPlatform.instance.setTargetTemperature(
      identifier,
      temperatureCelsius,
    );
  }

  /// Stream of prediction information for the specified probe.
  Stream<PredictionInfo> predictionStream(String identifier) {
    return FlutterCombustionIncPlatform.instance.predictionStream(identifier);
  }

  /// Adds or updates a device in the local registry and notifies listeners.
  void _addDevice(Device device) {
    final bool isNew = !devices.containsKey(device.uniqueIdentifier);
    devices[device.uniqueIdentifier] = device;
    if (isNew) {
      _devicesController.add(devices.values.toList());
    }
  }

  /// Removes a device from the registry and notifies listeners.
  void removeDevice(String uniqueIdentifier) {
    if (devices.remove(uniqueIdentifier) != null) {
      _devicesController.add(devices.values.toList());
    }
  }

  /// Clears all devices from the registry.
  void clearDevices() {
    devices.clear();
    _devicesController.add(<Device>[]);
  }
}
