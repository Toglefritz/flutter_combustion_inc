/// Controls which device types are emitted during BLE scanning.
///
/// The underlying iOS SDK always scans for all Combustion BLE advertisements,
/// but this filter determines which discovered devices are surfaced to the Dart
/// layer through the scan event channel.
enum DeviceScanFilter {
  /// Only emit temperature probes.
  probesOnly,

  /// Only emit MeatNet nodes (boosters, displays, chargers).
  nodesOnly,

  /// Emit all Combustion devices (probes and nodes).
  all;

  /// Converts to the integer value expected by the native bridge.
  int toInt() {
    switch (this) {
      case DeviceScanFilter.probesOnly:
        return 0;
      case DeviceScanFilter.nodesOnly:
        return 1;
      case DeviceScanFilter.all:
        return 2;
    }
  }
}
