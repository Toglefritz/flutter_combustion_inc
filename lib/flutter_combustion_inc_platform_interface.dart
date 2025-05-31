import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_combustion_inc_method_channel.dart';
import 'models/battery_status.dart';
import 'models/probe_temperatures.dart';

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

  /// Initializes Bluetooth and begins scanning for probes.
  Future<void> initBluetooth();

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
}
