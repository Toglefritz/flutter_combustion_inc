import 'connection_state.dart';
import 'dfu_state.dart';
import 'dfu_upload_progress.dart';

/// Base class for all Combustion BLE devices.
///
/// Contains the properties shared across device types: identity, connection state, signal strength, staleness tracking,
/// device info, and DFU state. Subclasses include `Probe` (identified by serial number) and `MeatNetNode` (identified
/// by BLE peripheral UUID).
abstract class Device {
  /// Stable identifier for this device.
  ///
  /// For probes this is the serial number string. For MeatNet nodes this is the BLE peripheral UUID string.
  final String uniqueIdentifier;

  /// BLE peripheral identifier (UUID string), present when the device's advertising packets are visible directly.
  String? bleIdentifier;

  /// Firmware version string, populated after connection.
  String? firmwareVersion;

  /// Hardware revision string, populated after connection.
  String? hardwareRevision;

  /// Device SKU, parsed from the model info characteristic.
  String? sku;

  /// Manufacturing lot number, parsed from the model info characteristic.
  String? manufacturingLot;

  /// Current BLE connection state.
  DeviceConnectionState connectionState;

  /// Whether the device is currently advertising as connectable.
  bool isConnectable;

  /// Most recent signal strength reading.
  int rssi;

  /// Whether the app should auto-reconnect on disconnect or failure.
  bool maintainingConnection;

  /// Whether the device data has gone stale (no update within [staleTimeout]).
  bool stale;

  /// Current DFU operation state, or `null` if no DFU is in progress.
  DfuState? dfuState;

  /// Current DFU upload progress, or `null` if not uploading.
  DfuUploadProgress? dfuUploadProgress;

  /// Timestamp of the most recent data update from this device.
  DateTime lastUpdateTime;

  /// Floor value for RSSI when no signal information is available.
  static const int minRssi = -128;

  /// Seconds of inactivity after which a device is considered stale.
  static const double staleTimeout = 15.0;

  /// Creates a new [Device].
  Device({
    required this.uniqueIdentifier,
    this.bleIdentifier,
    int? rssi,
  }) : connectionState = DeviceConnectionState.disconnected,
       isConnectable = false,
       maintainingConnection = false,
       stale = false,
       rssi = rssi ?? minRssi,
       lastUpdateTime = DateTime.now();

  /// Creates a [Device] from a platform channel map.
  ///
  /// Subclasses should use their own factory constructors that delegate here for the shared fields.
  Device.fromMap(Map<String, dynamic> map)
    : uniqueIdentifier =
          map['uniqueIdentifier'] as String? ?? map['identifier'] as String,
      bleIdentifier =
          map['bleIdentifier'] as String? ?? map['identifier'] as String?,
      firmwareVersion = map['firmwareVersion'] as String?,
      hardwareRevision = map['hardwareRevision'] as String?,
      sku = map['sku'] as String?,
      manufacturingLot = map['manufacturingLot'] as String?,
      connectionState = map['connectionState'] != null
          ? DeviceConnectionState.fromInt(map['connectionState'] as int)
          : DeviceConnectionState.disconnected,
      isConnectable = map['isConnectable'] as bool? ?? false,
      rssi = map['rssi'] as int? ?? minRssi,
      maintainingConnection = map['maintainingConnection'] as bool? ?? false,
      stale = map['stale'] as bool? ?? false,
      dfuState = map['dfuState'] != null
          ? DfuState.fromInt(map['dfuState'] as int)
          : null,
      dfuUploadProgress = map['dfuUploadProgress'] != null
          ? DfuUploadProgress.fromMap(
              Map<String, dynamic>.from(map['dfuUploadProgress'] as Map),
            )
          : null,
      lastUpdateTime = DateTime.now();

  /// Whether a DFU operation is currently in progress.
  bool get isDfuRunning {
    if (dfuState == null) return false;
    
    return dfuState != DfuState.completed;
  }

  /// Recalculates [stale] based on elapsed time since [lastUpdateTime].
  ///
  /// Also clears [isConnectable] when the device goes stale, since we can no longer confirm the advertising packet is
  /// still being received.
  void updateDeviceStale() {
    stale = DateTime.now().difference(lastUpdateTime).inSeconds > staleTimeout;
    if (stale) {
      isConnectable = false;
    }
  }
}
