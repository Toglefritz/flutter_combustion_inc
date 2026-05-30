import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_combustion_inc_method_channel.dart';
import 'models/ble_data/battery_status.dart';
import 'models/ble_data/probe_temperature_log.dart';
import 'models/ble_data/probe_temperatures.dart';
import 'models/devices/connection_state.dart';
import 'models/prediction/prediction_info.dart';

/// The platform interface that defines the contract for all communication between Dart and the native platforms in the
/// _flutter_combustion_inc_ plugin.
///
/// This class is responsible for making all `MethodChannel` calls to the native iOS and Android SDKs. It provides a
/// clean, testable interface through which higher-level classes such as `DeviceManager` and `Probe` interact with
/// native code. These higher-level classes delegate their platform-specific method invocations to this interface,
/// rather than using `MethodChannels` directly.
///
/// Platform-specific implementations should extend this class and override its methods using their respective native
/// communication logic (e.g., [MethodChannelFlutterCombustionInc] for mobile platforms).
abstract class FlutterCombustionIncPlatform extends PlatformInterface {
  /// Constructs a [FlutterCombustionIncPlatform].
  FlutterCombustionIncPlatform() : super(token: _token);

  /// A token that can be used to verify that subclasses extend this class.
  static final Object _token = Object();

  /// The default instance of [FlutterCombustionIncPlatform] to use.
  static FlutterCombustionIncPlatform _instance =
      MethodChannelFlutterCombustionInc();

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

  /// Initializes Bluetooth and begins scanning for probes.
  Future<void> initBluetooth();

  /// Enables MeatNet repeater network support in the native SDK.
  ///
  /// Must be called before MeatNet nodes will be detected during scanning.
  /// Without this call, the SDK silently discards all node advertisements.
  Future<void> enableMeatNet();

  /// Sets the device scan filter to control which device types are emitted
  /// through the scan event channel.
  ///
  /// The native SDK always scans for all Combustion advertisements, but this
  /// filter determines which are forwarded to the Dart layer.
  Future<void> setScanFilter(int filter);

  /// Provides a stream of the list of discovered probes. This stream emits a list of maps, where each map contains
  /// information about a discovered probe, such as its identifier, name, and other relevant details.
  Stream<List<Map<String, dynamic>>> probeListStream();

  /// Retrieves a list of known probes from the native SDK.
  Future<List<Map<String, dynamic>>> getProbes();

  /// Retrieves the RSSI (Received Signal Strength Indicator) for the specified probe.
  Future<int> getRssi(String identifier);

  /// Checks if the status of the probe is stale. A stale status indicates that the probe has not sent an update in a
  /// while, which may suggest a connection issue or that the probe is powered off.
  Stream<bool> statusStaleStream(String identifier);

  /// Attempts to connect to a probe with the given identifier.
  Future<void> connectToProbe(String identifier);

  /// Disconnects from the probe with the given identifier.
  Future<void> disconnectFromProbe(String identifier);

  /// Retrieves a set of "virtual" temperatures for the specified probe. The virtual temperatures are calculated based
  /// on evaluations of all eight physical temperature sensors (T1–T8). The virtual temperatures are for the food's
  /// core, surface, and ambient conditions.
  Future<Map<String, double>> getVirtualTemperatures(String identifier);

  /// Provides a stream of virtual temperature readings (core, surface, ambient) for a specified probe. This stream
  /// emits updates whenever the probe's virtual temperatures change.
  Stream<Map<String, double>> virtualTemperatureStream(String identifier);

  /// Retrieves the battery status for the specified probe.
  Future<String> getBatteryStatus(String identifier);

  /// Provides a stream of the battery status for the specified probe. This stream emits updates whenever the probe's
  /// battery status changes (e.g., "OK" or "Low").
  Stream<BatteryStatus> batteryStatusStream(String identifier);

  /// Retrieves the current temperatures from the specified probe.
  Future<ProbeTemperatures> getCurrentTemperatures(String identifier);

  /// Provides a stream of the current temperatures from the specified probe. This stream emits updates whenever the
  /// probe's temperatures change.
  Stream<ProbeTemperatures> currentTemperaturesStream(String identifier);

  /// Provides a stream of the percentage of temperature log data points that have been synchronized for the specified
  /// probe. This stream emits a double value representing the percentage of log data that has been successfully
  /// synchronized with the probe to the mobile device.
  Stream<double> logSyncPercentStream(String identifier);

  /// Retrieves a temperature log for the specified probe The temperature log will include a stream of data points that
  /// constitute the stream. This data point stream emits a list of maps, where each map contains information about a
  /// temperature log entry, such as the timestamp and temperature readings. The log is updated via polling the probe
  /// once per second.
  Future<ProbeTemperatureLog> getTemperatureLog(String identifier);

  /// Provides a stream of session information availability for the specified probe. This stream emits updates whenever
  /// the probe's session information becomes available or unavailable, allowing the UI to show or hide historical data
  /// features accordingly.
  Stream<Map<String, dynamic>> sessionInfoStream(String identifier);

  /// Retrieves the current session information for the specified probe synchronously. Used for debugging session
  /// availability issues.
  Future<Map<String, dynamic>> getSessionInfo(String identifier);

  /// Forces the probe to refresh its session information from the device. This can help resolve timing issues where
  /// session info becomes stale.
  Future<void> refreshSessionInfo(String identifier);

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
  );

  /// Provides a stream of temperature prediction information for the specified probe.
  ///
  /// This stream emits [PredictionInfo] objects containing estimated time to reach target temperature and other cooking
  /// predictions. Predictions are only available after a target temperature has been set using [setTargetTemperature].
  ///
  /// The stream will emit updates whenever the probe's prediction calculations change based on current temperature
  /// trends and cooking conditions.
  ///
  /// @param identifier The unique identifier of the probe
  /// @returns Stream of prediction information updates
  Stream<PredictionInfo> predictionStream(String identifier);

  /// Provides a stream of connection state changes for the specified probe.
  ///
  /// Emits [DeviceConnectionState] values whenever the probe's BLE connection state transitions (disconnected,
  /// connecting, connected, failed).
  Stream<DeviceConnectionState> connectionStateStream(String identifier);

  /// Queries the native SDK for the best route to reach the specified probe.
  ///
  /// Returns a map describing the route:
  /// - `routeType`: "direct", "relayed", or "unreachable"
  /// - `nodeIdentifier`: BLE UUID of the relay node (if relayed)
  /// - `hopCount`: integer hop count (if relayed)
  /// - `rssi`: signal strength to the route device
  Future<Map<String, dynamic>> getRouteToProbe(String probeIdentifier);

  /// Sends a set-prediction command to the probe, optionally forcing the
  /// command through a specific device rather than using auto-routing.
  ///
  /// When [viaDeviceIdentifier] is `null`, the native SDK uses its internal
  /// `getBestRouteToProbe` logic. When specified, the command is sent through
  /// that specific device (useful for engineering/QA testing of specific paths).
  Future<void> setTargetTemperatureViaDevice(
    String probeIdentifier,
    double temperatureCelsius, {
    String? viaDeviceIdentifier,
  });
}
