/// Represents the battery status of a probe.
enum BatteryStatus {
  /// Indicates that the battery is functioning normally.
  ok,

  /// Indicates that the battery is low and may require charging or replacement.
  low;

  /// Converts a platform string to [BatteryStatus].
  static BatteryStatus fromInt(int raw) {
    switch (raw) {
      case 0:
        return BatteryStatus.ok;
      case 1:
        return BatteryStatus.low;
      default:
        throw ArgumentError('Unknown BatteryStatus raw value: $raw');
    }
  }
}
