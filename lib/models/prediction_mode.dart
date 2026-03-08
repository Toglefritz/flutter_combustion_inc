/// Represents the prediction mode configured for the probe.
///
/// This enum corresponds to the PredictionMode enum in the Combustion Inc
/// iOS/macOS BLE SDK. The mode determines what type of predictions the
/// probe will generate during cooking.
enum PredictionMode {
  /// No prediction mode is active.
  ///
  /// The probe is not generating predictions. This typically occurs
  /// when no target temperature has been set.
  none,

  /// Time-to-removal prediction mode.
  ///
  /// The probe predicts when the food will reach the target temperature
  /// and should be removed from heat. This is the standard cooking mode.
  timeToRemoval,

  /// Removal and resting prediction mode.
  ///
  /// The probe predicts both when to remove the food from heat and
  /// tracks temperature during the resting period. This mode accounts
  /// for carryover cooking that occurs after removal from heat.
  removalAndResting,

  /// Reserved mode for future use.
  ///
  /// This mode is reserved for future SDK features and should not
  /// be used in current implementations.
  reserved;

  /// Converts a raw integer value from the native SDK to [PredictionMode].
  ///
  /// The raw value corresponds to the UInt8 rawValue from the iOS/macOS
  /// SDK's PredictionMode enum.
  ///
  /// Throws [ArgumentError] if the raw value is not recognized.
  static PredictionMode fromInt(int raw) {
    switch (raw) {
      case 0x00:
        return PredictionMode.none;
      case 0x01:
        return PredictionMode.timeToRemoval;
      case 0x02:
        return PredictionMode.removalAndResting;
      case 0x03:
        return PredictionMode.reserved;
      default:
        throw ArgumentError('Unknown PredictionMode raw value: $raw');
    }
  }

  /// Converts a string representation from the native SDK to [PredictionMode].
  ///
  /// This method handles the human-readable string values returned by
  /// the iOS/macOS SDK's toString() method.
  ///
  /// Throws [ArgumentError] if the string is not recognized.
  static PredictionMode fromString(String value) {
    switch (value) {
      case 'None':
        return PredictionMode.none;
      case 'Time to Removal':
        return PredictionMode.timeToRemoval;
      case 'Remove and Resting':
        return PredictionMode.removalAndResting;
      case 'Reserved':
        return PredictionMode.reserved;
      default:
        throw ArgumentError('Unknown PredictionMode string: $value');
    }
  }
}
