/// Represents the various connection states of a Combustion device.
///
/// This enum mirrors the ConnectionState enum from the iOS SDK's Device class.
enum DeviceConnectionState {
  /// App is currently disconnected from the device.
  disconnected,

  /// App is attempting to connect via BLE to the device.
  connecting,

  /// App is currently connected via BLE to the device.
  connected,

  /// Attempt to connect to the device failed.
  failed;

  /// Converts a raw integer value from the native SDK to [DeviceConnectionState].
  static DeviceConnectionState fromInt(int raw) {
    switch (raw) {
      case 0:
        return DeviceConnectionState.disconnected;
      case 1:
        return DeviceConnectionState.connecting;
      case 2:
        return DeviceConnectionState.connected;
      case 3:
        return DeviceConnectionState.failed;
      default:
        return DeviceConnectionState.disconnected;
    }
  }

  /// Converts a string representation from the native SDK to [DeviceConnectionState].
  static DeviceConnectionState fromString(String value) {
    switch (value.toLowerCase()) {
      case 'disconnected':
        return DeviceConnectionState.disconnected;
      case 'connecting':
        return DeviceConnectionState.connecting;
      case 'connected':
        return DeviceConnectionState.connected;
      case 'failed':
        return DeviceConnectionState.failed;
      default:
        return DeviceConnectionState.disconnected;
    }
  }
}
