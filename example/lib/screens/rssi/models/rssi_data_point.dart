/// Represents a single RSSI data point with timestamp.
class RssiDataPoint {
  /// Time offset in seconds when this reading was taken.
  final double timestamp;

  /// RSSI value in dBm.
  final int rssi;

  /// Creates an RSSI data point.
  const RssiDataPoint({
    required this.timestamp,
    required this.rssi,
  });
}
