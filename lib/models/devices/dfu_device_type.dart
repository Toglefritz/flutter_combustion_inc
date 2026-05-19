/// Represents the type of device for DFU (Device Firmware Update) purposes.
///
/// MeatNet nodes can be different physical products (display timers, chargers, etc.)
/// and the DFU firmware package differs by type.
enum DfuDeviceType {
  /// Device type is unknown or has not been determined yet.
  unknown,

  /// A display device (e.g., the Combustion Timer).
  display,

  /// A charger device (e.g., the Combustion Charger).
  charger;

  /// Converts a raw integer value from the native SDK to [DfuDeviceType].
  static DfuDeviceType fromInt(int raw) {
    switch (raw) {
      case 0:
        return DfuDeviceType.unknown;
      case 1:
        return DfuDeviceType.display;
      case 2:
        return DfuDeviceType.charger;
      default:
        return DfuDeviceType.unknown;
    }
  }

  /// Converts a string representation from the native SDK to [DfuDeviceType].
  static DfuDeviceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'display':
      case 'timer':
        return DfuDeviceType.display;
      case 'charger':
        return DfuDeviceType.charger;
      default:
        return DfuDeviceType.unknown;
    }
  }
}
