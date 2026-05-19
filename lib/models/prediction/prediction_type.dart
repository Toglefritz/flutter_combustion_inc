/// Represents the type of prediction currently being generated.
///
/// This enum corresponds to the PredictionType enum in the Combustion Inc
/// iOS/macOS BLE SDK. The type indicates which phase of the cooking process
/// the current prediction applies to.
enum PredictionType {
  /// No prediction type is active.
  ///
  /// The probe is not generating predictions. This typically occurs
  /// when no target temperature has been set or the probe is in
  /// instant-read mode.
  none,

  /// Removal prediction type.
  ///
  /// The probe is predicting when the food should be removed from heat
  /// to reach the target temperature. This accounts for the current
  /// cooking rate and temperature trends.
  removal,

  /// Resting prediction type.
  ///
  /// The probe is tracking temperature during the resting period after
  /// removal from heat. This prediction accounts for carryover cooking
  /// that continues to raise the internal temperature.
  resting,

  /// Reserved type for future use.
  ///
  /// This type is reserved for future SDK features and should not
  /// be used in current implementations.
  reserved;

  /// Converts a raw integer value from the native SDK to [PredictionType].
  ///
  /// The raw value corresponds to the UInt8 rawValue from the iOS/macOS
  /// SDK's PredictionType enum.
  ///
  /// Throws [ArgumentError] if the raw value is not recognized.
  static PredictionType fromInt(int raw) {
    switch (raw) {
      case 0x00:
        return PredictionType.none;
      case 0x01:
        return PredictionType.removal;
      case 0x02:
        return PredictionType.resting;
      case 0x03:
        return PredictionType.reserved;
      default:
        throw ArgumentError('Unknown PredictionType raw value: $raw');
    }
  }

  /// Converts a string representation from the native SDK to [PredictionType].
  ///
  /// This method handles the human-readable string values returned by
  /// the iOS/macOS SDK's toString() method.
  ///
  /// Throws [ArgumentError] if the string is not recognized.
  static PredictionType fromString(String value) {
    switch (value) {
      case 'None':
        return PredictionType.none;
      case 'Removal':
        return PredictionType.removal;
      case 'Resting':
        return PredictionType.resting;
      case 'Reserved':
        return PredictionType.reserved;
      default:
        throw ArgumentError('Unknown PredictionType string: $value');
    }
  }
}
