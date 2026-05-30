/// Controls how commands are routed to a probe.
///
/// In [auto] mode the native SDK picks the best available path (direct BLE or
/// through the highest-RSSI connected node). In [explicit] mode the app forces
/// commands through a specific device, which is useful for engineering/QA
/// validation of specific network paths.
enum RoutingMode {
  /// The SDK selects the best route automatically.
  auto,

  /// Commands are forced through a specific device.
  explicit,
}
