/// Represents the state of a Device Firmware Update (DFU) operation.
///
/// These states track the DFU lifecycle from initial connection through
/// firmware transfer and validation to completion or abort.
enum DfuState {
  /// DFU process is connecting to the device.
  connecting,

  /// DFU process is starting.
  starting,

  /// DFU process is enabling DFU mode on the device.
  enablingDfuMode,

  /// Firmware is being uploaded to the device.
  uploading,

  /// Firmware is being validated on the device.
  validating,

  /// DFU process is disconnecting from the device.
  disconnecting,

  /// DFU process completed successfully.
  completed,

  /// DFU process was aborted.
  aborted;

  /// Converts a raw integer value from the native SDK to [DfuState].
  static DfuState fromInt(int raw) {
    switch (raw) {
      case 0:
        return DfuState.connecting;
      case 1:
        return DfuState.starting;
      case 2:
        return DfuState.enablingDfuMode;
      case 3:
        return DfuState.uploading;
      case 4:
        return DfuState.validating;
      case 5:
        return DfuState.disconnecting;
      case 6:
        return DfuState.completed;
      case 7:
        return DfuState.aborted;
      default:
        return DfuState.connecting;
    }
  }

  /// Converts a string representation from the native SDK to [DfuState].
  static DfuState fromString(String value) {
    switch (value.toLowerCase()) {
      case 'connecting':
        return DfuState.connecting;
      case 'starting':
        return DfuState.starting;
      case 'enablingdfumode':
        return DfuState.enablingDfuMode;
      case 'uploading':
        return DfuState.uploading;
      case 'validating':
        return DfuState.validating;
      case 'disconnecting':
        return DfuState.disconnecting;
      case 'completed':
        return DfuState.completed;
      case 'aborted':
        return DfuState.aborted;
      default:
        return DfuState.connecting;
    }
  }
}
