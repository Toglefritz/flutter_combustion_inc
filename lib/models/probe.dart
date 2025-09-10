import '../flutter_combustion_inc_platform_interface.dart';
import 'battery_status.dart';
import 'probe_temperature_log.dart';
import 'probe_temperatures.dart';
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
  });

  /// Creates a [Probe] instance from a map received via platform channels.
  ///
  /// The map should contain keys: 'identifier', 'serialNumber', 'name', 'macAddress', 'id', 'color', and 'rssi'.
  factory Probe.fromMap(Map<String, dynamic> map) {
    return Probe(
      identifier: map['identifier'] as String,
      serialNumber: map['serialNumber'] as String,
      name: map['name'] as String,
      macAddress: map['macAddress'] as String,
      id: map['id'] as int,
      color: map['color'] as int,
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

  /// Returns the RSSI (Received Signal Strength Indicator) for the probe.
  Future<int> get rssi async {
    final int result = await FlutterCombustionIncPlatform.instance.getRssi(
      identifier,
    );

    return result;
  }

  /// Disconnects from the probe and stops trying to maintain a connection.
  ///
  /// Throws a `PlatformException` if the disconnection fails.
  Future<void> disconnect() async {
    await FlutterCombustionIncPlatform.instance.disconnectFromProbe(identifier);
  }

  /// Indicates whether the most recent data received from the probe is stale.
  ///
  /// Returns `true` if the status data has not been updated recently, or `false` if it is current.
  ///
  /// Throws a `PlatformException` if retrieval fails.
  Stream<bool> get statusStaleStream {
    return FlutterCombustionIncPlatform.instance.statusStaleStream(identifier);
  }

  /// Gets the virtual temperature readings from the probe.
  ///
  /// Returns a [VirtualTemperatures] instance.
  ///
  /// Throws a `PlatformException` if retrieval fails.
  Future<VirtualTemperatures> get virtualTemperatures async {
    final Map<String, double> result = await FlutterCombustionIncPlatform
        .instance
        .getVirtualTemperatures(identifier);

    return VirtualTemperatures.fromMap(result);
  }

  /// Provides a stream of virtual temperature readings from the probe.
  ///
  /// The stream emits a new [VirtualTemperatures] instance whenever a change occurs.
  ///
  /// Throws a `PlatformException` if the stream cannot be established.
  Stream<VirtualTemperatures> get virtualTemperatureStream {
    return FlutterCombustionIncPlatform.instance
        .virtualTemperatureStream(identifier)
        .map(VirtualTemperatures.fromMap);
  }

  /// Gets the battery status of the probe.
  ///
  /// Returns a [BatteryStatus] enum representing the battery status.
  ///
  /// Throws a `PlatformException` if retrieval fails.
  Future<BatteryStatus> get batteryStatus async {
    final String status = await FlutterCombustionIncPlatform.instance
        .getBatteryStatus(identifier);

    return BatteryStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
    );
  }

  /// Provides a stream of battery status updates from the probe.
  ///
  /// The stream emits a new [BatteryStatus] whenever a change occurs.
  ///
  /// Throws a `PlatformException` if the stream cannot be established.
  Stream<BatteryStatus> get batteryStatusStream {
    return FlutterCombustionIncPlatform.instance.batteryStatusStream(
      identifier,
    );
  }

  /// Gets the most recent temperature readings from the probe.
  ///
  /// The result is a list of 8 temperatures (T1–T8) in Celsius.
  ///
  /// Returns a [ProbeTemperatures] object representing the readings from all sensors.
  ///
  /// Throws a `PlatformException` if retrieval fails.
  Future<ProbeTemperatures> get currentTemperatures async {
    return FlutterCombustionIncPlatform.instance.getCurrentTemperatures(
      identifier,
    );
  }

  /// Provides a stream of current temperature readings from the probe.
  ///
  /// The stream emits a new [ProbeTemperatures] instance whenever a change occurs.
  ///
  /// Throws a `PlatformException` if the stream cannot be established.
  Stream<ProbeTemperatures> get currentTemperaturesStream {
    return FlutterCombustionIncPlatform.instance.currentTemperaturesStream(
      identifier,
    );
  }

  /// Provides a stream of the percentage of temperature logs that have been synced from the probe.
  ///
  /// The stream emits an [int] value between 0 and 100 indicating the percentage of log data that has been
  /// successfully synced from the probe to the app.
  ///
  /// Throws a `PlatformException` if the stream cannot be established.
  Stream<double> get logSyncPercentageStream {
    return FlutterCombustionIncPlatform.instance.logSyncPercentStream(
      identifier,
    );
  }

  /// Get a temperature log for the probe. The [ProbeTemperatureLog] will contain a stream of data points within the
  /// log session.
  Future<ProbeTemperatureLog> get temperatureLog async {
    return FlutterCombustionIncPlatform.instance.getTemperatureLog(identifier);
  }

  /// Stream that emits session information availability for this probe.
  ///
  /// The stream emits a map containing:
  /// - `hasSession`: boolean indicating if session information is available
  /// - `samplePeriod`: the sample period in milliseconds (if available)
  Stream<Map<String, dynamic>> get sessionInfoStream {
    return FlutterCombustionIncPlatform.instance.sessionInfoStream(identifier);
  }

  /// Gets the current session information for this probe synchronously.
  /// Used for debugging session availability issues.
  Future<Map<String, dynamic>> get sessionInfo async {
    return FlutterCombustionIncPlatform.instance.getSessionInfo(identifier);
  }
}
