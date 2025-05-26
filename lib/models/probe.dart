import '../flutter_combustion_inc_platform_interface.dart';
import 'virtual_temperatures.dart';

/// Represents a temperature probe discovered via the Combustion Inc. SDK.
///
/// This class provides access to metadata and interaction methods for a specific probe, such as connecting,
/// disconnecting, and retrieving live sensor data.
class Probe {
  /// The unique identifier assigned to the probe (UUID on iOS).
  final String identifier;

  /// The probe's serial number.
  final String serialNumber;

  /// The user-visible name of the probe, usually derived from the serial number.
  final String name;

  /// The MAC address of the probe, if available.
  final String macAddress;

  /// The numeric ID (1–8) assigned to the probe.
  final int id;

  /// The color of the probe’s silicone ring.
  final int color;

  /// The received signal strength indicator (RSSI).
  final int rssi;

  /// Constructs a new [Probe] instance.
  ///
  /// This constructor is typically used internally based on native data.
  Probe({
    required this.identifier,
    required this.serialNumber,
    required this.name,
    required this.macAddress,
    required this.id,
    required this.color,
    required this.rssi,
  });

  /// Creates a [Probe] instance from a map received via platform channels.
  ///
  /// The map should contain keys: 'identifier', 'serialNumber', 'name',
  /// 'macAddress', 'id', 'color', and 'rssi'.
  factory Probe.fromMap(Map<String, dynamic> map) {
    return Probe(
      identifier: map['identifier'] as String,
      serialNumber: map['serialNumber'] as String,
      name: map['name'] as String,
      macAddress: map['macAddress'] as String,
      id: map['id'] as int,
      color: map['color'] as int,
      rssi: map['rssi'] as int,
    );
  }

  /// Connects to the probe and begins maintaining a connection.
  ///
  /// The native SDK will attempt to stay connected until [disconnect] is called.
  ///
  /// Throws a `PlatformException` if the connection fails.
  Future<void> connect() async {
    await FlutterCombustionIncPlatform.instance.connectToProbe(identifier);
  }

  /// Disconnects from the probe and stops trying to maintain a connection.
  ///
  /// Throws a `PlatformException` if the disconnection fails.
  Future<void> disconnect() async {
    await FlutterCombustionIncPlatform.instance.disconnectFromProbe(identifier);
  }

  /// Gets the virtual temperature readings from the probe.
  ///
  /// Returns a [VirtualTemperatures] instance.
  /// Throws a `PlatformException` if retrieval fails.
  Future<VirtualTemperatures> get virtualTemperatures async {
    final result = await FlutterCombustionIncPlatform.instance.getVirtualTemperatures(identifier);
    return VirtualTemperatures.fromMap(result);
  }

  /// Provides a stream of virtual temperature readings from the probe.
  ///
  /// The stream emits a new [VirtualTemperatures] instance whenever a change occurs.
  /// Throws a `PlatformException` if the stream cannot be established.
  Stream<VirtualTemperatures> get virtualTemperatureStream {
    return FlutterCombustionIncPlatform.instance.virtualTemperatureStream(identifier).map(VirtualTemperatures.fromMap);
  }

  /// Gets the battery status of the probe ("OK" or "Low").
  ///
  /// Returns a [String] representing the battery status.
  /// Throws a `PlatformException` if retrieval fails.
  Future<String> get batteryStatus async {
    return FlutterCombustionIncPlatform.instance.getBatteryStatus(identifier);
  }

  /// Gets the most recent temperature readings from the probe.
  ///
  /// The result is a list of 8 temperatures (T1–T8) in Celsius.
  ///
  /// Returns a [List<double>] of temperatures.
  /// Throws a `PlatformException` if retrieval fails.
  Future<List<double>> get currentTemperatures async {
    return FlutterCombustionIncPlatform.instance.getCurrentTemperatures(identifier);
  }
}
