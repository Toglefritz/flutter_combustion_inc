/// Represents the current state of the probe's prediction system.
///
/// This enum corresponds to the PredictionState enum in the Combustion Inc
/// iOS/macOS BLE SDK. The state indicates what phase of cooking the probe
/// is currently in and affects the reliability of predictions.
enum PredictionState {
  /// Probe is not inserted into food.
  ///
  /// Predictions are not available in this state as the probe cannot
  /// detect food temperature trends.
  probeNotInserted,

  /// Probe has been inserted into food but cooking has not started.
  ///
  /// The probe is detecting food temperature but predictions may not
  /// yet be reliable as temperature trends have not been established.
  probeInserted,

  /// Food is actively cooking and temperature is rising.
  ///
  /// The probe is tracking temperature trends and generating predictions
  /// based on the current rate of temperature change.
  cooking,

  /// Probe is actively generating time-to-target predictions.
  ///
  /// This state indicates that the probe has sufficient data to make
  /// reliable predictions about when the food will reach target temperature.
  predicting,

  /// Target temperature has been reached and removal prediction is complete.
  ///
  /// The food has reached the target temperature. If resting predictions
  /// are enabled, the probe may continue tracking temperature during rest.
  removalPredictionDone,

  /// Reserved state for future use (state 5).
  reservedState5,

  /// Reserved state for future use (state 6).
  reservedState6,

  /// Reserved state for future use (state 7).
  reservedState7,

  /// Reserved state for future use (state 8).
  reservedState8,

  /// Reserved state for future use (state 9).
  reservedState9,

  /// Reserved state for future use (state 10).
  reservedState10,

  /// Reserved state for future use (state 11).
  reservedState11,

  /// Reserved state for future use (state 12).
  reservedState12,

  /// Reserved state for future use (state 13).
  reservedState13,

  /// Reserved state for future use (state 14).
  reservedState14,

  /// Unknown or unrecognized prediction state.
  ///
  /// This state indicates that the probe reported a state value that
  /// is not recognized by this version of the SDK.
  unknown;

  /// Converts a raw integer value from the native SDK to [PredictionState].
  ///
  /// The raw value corresponds to the UInt8 rawValue from the iOS/macOS
  /// SDK's PredictionState enum.
  ///
  /// Throws [ArgumentError] if the raw value is not recognized.
  static PredictionState fromInt(int raw) {
    switch (raw) {
      case 0x00:
        return PredictionState.probeNotInserted;
      case 0x01:
        return PredictionState.probeInserted;
      case 0x02:
        return PredictionState.cooking;
      case 0x03:
        return PredictionState.predicting;
      case 0x04:
        return PredictionState.removalPredictionDone;
      case 0x05:
        return PredictionState.reservedState5;
      case 0x06:
        return PredictionState.reservedState6;
      case 0x07:
        return PredictionState.reservedState7;
      case 0x08:
        return PredictionState.reservedState8;
      case 0x09:
        return PredictionState.reservedState9;
      case 0x0A:
        return PredictionState.reservedState10;
      case 0x0B:
        return PredictionState.reservedState11;
      case 0x0C:
        return PredictionState.reservedState12;
      case 0x0D:
        return PredictionState.reservedState13;
      case 0x0E:
        return PredictionState.reservedState14;
      case 0x0F:
        return PredictionState.unknown;
      default:
        throw ArgumentError('Unknown PredictionState raw value: $raw');
    }
  }

  /// Converts a string representation from the native SDK to [PredictionState].
  ///
  /// This method handles the human-readable string values returned by
  /// the iOS/macOS SDK's toString() method.
  ///
  /// Throws [ArgumentError] if the string is not recognized.
  static PredictionState fromString(String value) {
    switch (value) {
      case 'Probe Not Inserted':
        return PredictionState.probeNotInserted;
      case 'Probe Inserted':
        return PredictionState.probeInserted;
      case 'Cooking':
        return PredictionState.cooking;
      case 'Predicting':
        return PredictionState.predicting;
      case 'Removal Prediction Done':
        return PredictionState.removalPredictionDone;
      case 'Reserved State 5':
        return PredictionState.reservedState5;
      case 'Reserved State 6':
        return PredictionState.reservedState6;
      case 'Reserved State 7':
        return PredictionState.reservedState7;
      case 'Reserved State 8':
        return PredictionState.reservedState8;
      case 'Reserved State 9':
        return PredictionState.reservedState9;
      case 'Reserved State 10':
        return PredictionState.reservedState10;
      case 'Reserved State 11':
        return PredictionState.reservedState11;
      case 'Reserved State 12':
        return PredictionState.reservedState12;
      case 'Reserved State 13':
        return PredictionState.reservedState13;
      case 'Reserved State 14':
        return PredictionState.reservedState14;
      case 'Unknown':
        return PredictionState.unknown;
      default:
        throw ArgumentError('Unknown PredictionState string: $value');
    }
  }
}
