import '../../flutter_combustion_inc_platform_interface.dart';
import '../ble_data/battery_status.dart';
import '../ble_data/probe_temperature_log.dart';
import '../ble_data/probe_temperatures.dart';
import '../ble_data/virtual_temperatures.dart';
import '../prediction/prediction_info.dart';
import 'device.dart';

/// Represents a Combustion Inc. temperature probe.
///
/// Extends [Device] with probe-specific functionality: temperature readings,
/// predictions, session management, and log syncing. The probe is uniquely
/// identified by its serial number (used as [uniqueIdentifier]), matching the
/// iOS SDK's `Probe` class behavior.
class Probe extends Device {
  /// The probe's serial number.
  final String serialNumber;

  /// User-visible name, typically derived from the serial number.
  final String name;

  /// The MAC address of the probe, if available.
  final String macAddress;

  /// Numeric ID (1-8) assigned to the probe.
  final int id;

  /// Color index of the probe's silicone ring.
  final int color;

  /// Creates a new [Probe].
  ///
  /// The [identifier] is the BLE peripheral UUID, while [serialNumber] is the
  /// probe's unique serial used as [uniqueIdentifier] on the base [Device].
  Probe({
    required String identifier,
    required this.serialNumber,
    required this.name,
    required this.macAddress,
    required this.id,
    required this.color,
    super.rssi,
  }) : super(
         uniqueIdentifier: serialNumber,
         bleIdentifier: identifier,
       );

  /// Creates a [Probe] from a platform channel map.
  ///
  /// Expected keys: 'identifier', 'serialNumber', 'name', 'macAddress', 'id',
  /// 'color', and optionally 'rssi'.
  factory Probe.fromMap(Map<String, dynamic> map) {
    return Probe(
      identifier: map['identifier'] as String,
      serialNumber: map['serialNumber'] as String,
      name: map['name'] as String,
      macAddress: map['macAddress'] as String,
      id: map['id'] as int,
      color: map['color'] as int,
      rssi: map['rssi'] as int?,
    );
  }

  /// The BLE peripheral identifier (UUID string) for this probe.
  String get identifier => bleIdentifier!;

  /// Connects to the probe and begins maintaining a connection.
  ///
  /// The native SDK will attempt to stay connected until [disconnect] is called.
  Future<void> connect() async {
    maintainingConnection = true;
    await FlutterCombustionIncPlatform.instance.connectToProbe(identifier);
  }

  /// Disconnects from the probe and stops maintaining a connection.
  Future<void> disconnect() async {
    maintainingConnection = false;
    await FlutterCombustionIncPlatform.instance.disconnectFromProbe(identifier);
  }

  /// Fetches the current RSSI value from the native layer and updates [rssi].
  Future<int> getRssi() async {
    final int result = await FlutterCombustionIncPlatform.instance.getRssi(
      identifier,
    );
    rssi = result;

    return result;
  }

  /// Emits `true` when status data from the probe has not been updated recently.
  Stream<bool> get statusStaleStream {
    return FlutterCombustionIncPlatform.instance.statusStaleStream(identifier);
  }

  /// Fetches the current virtual temperature readings (core, surface, ambient).
  Future<VirtualTemperatures> get virtualTemperatures async {
    final Map<String, double> result = await FlutterCombustionIncPlatform
        .instance
        .getVirtualTemperatures(identifier);

    return VirtualTemperatures.fromMap(result);
  }

  /// Emits updated [VirtualTemperatures] whenever the probe reports new values.
  Stream<VirtualTemperatures> get virtualTemperatureStream {
    return FlutterCombustionIncPlatform.instance
        .virtualTemperatureStream(identifier)
        .map(VirtualTemperatures.fromMap);
  }

  /// Fetches the most recent raw temperature readings from all 8 sensors.
  Future<ProbeTemperatures> get currentTemperatures async {
    return FlutterCombustionIncPlatform.instance.getCurrentTemperatures(
      identifier,
    );
  }

  /// Emits updated [ProbeTemperatures] whenever the probe reports new values.
  Stream<ProbeTemperatures> get currentTemperaturesStream {
    return FlutterCombustionIncPlatform.instance.currentTemperaturesStream(
      identifier,
    );
  }

  /// Fetches the current battery status of the probe.
  Future<BatteryStatus> get batteryStatus async {
    final String status = await FlutterCombustionIncPlatform.instance
        .getBatteryStatus(identifier);
        
    return BatteryStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
    );
  }

  /// Emits updated [BatteryStatus] whenever the probe reports a change.
  Stream<BatteryStatus> get batteryStatusStream {
    return FlutterCombustionIncPlatform.instance.batteryStatusStream(
      identifier,
    );
  }

  /// Emits the percentage (0-100) of temperature logs synced from the probe.
  Stream<double> get logSyncPercentageStream {
    return FlutterCombustionIncPlatform.instance.logSyncPercentStream(
      identifier,
    );
  }

  /// Retrieves the temperature log for the probe's current session.
  Future<ProbeTemperatureLog> get temperatureLog async {
    return FlutterCombustionIncPlatform.instance.getTemperatureLog(identifier);
  }

  /// Emits session information availability for this probe.
  ///
  /// The map contains:
  /// - `hasSession`: whether session information is available
  /// - `samplePeriod`: the sample period in milliseconds (if available)
  Stream<Map<String, dynamic>> get sessionInfoStream {
    return FlutterCombustionIncPlatform.instance.sessionInfoStream(identifier);
  }

  /// Fetches the current session information for this probe.
  Future<Map<String, dynamic>> get sessionInfo async {
    return FlutterCombustionIncPlatform.instance.getSessionInfo(identifier);
  }

  /// Emits [PredictionInfo] updates for this probe.
  ///
  /// Predictions are only available after a target temperature has been set
  /// via `DeviceManager.setTargetTemperature`.
  Stream<PredictionInfo> get predictionStream {
    return FlutterCombustionIncPlatform.instance.predictionStream(identifier);
  }
}
