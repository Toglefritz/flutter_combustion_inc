/// Represents the number of hops data has taken through the MeatNet mesh network.
///
/// Lower hop counts indicate a more direct (and typically more reliable) path
/// between the app and the probe. A `null` hop count in the context of route
/// information means the data arrived directly from the probe over BLE without
/// any intermediate nodes.
enum HopCount {
  /// Data traversed one intermediate node.
  hop1,

  /// Data traversed two intermediate nodes.
  hop2,

  /// Data traversed three intermediate nodes.
  hop3,

  /// Data traversed four intermediate nodes.
  hop4;

  /// Converts a raw integer value from the native SDK to [HopCount].
  static HopCount fromInt(int raw) {
    switch (raw) {
      case 0:
        return HopCount.hop1;
      case 1:
        return HopCount.hop2;
      case 2:
        return HopCount.hop3;
      case 3:
        return HopCount.hop4;
      default:
        return HopCount.hop1;
    }
  }

  /// The numeric hop count value (1-based for readability).
  int get count => index + 1;
}
