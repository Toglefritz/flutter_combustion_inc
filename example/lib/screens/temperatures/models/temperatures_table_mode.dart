import '../temperatures_view.dart';

/// Represents the type of temperature data displayed in the temperature table within the [TemperaturesView].
///
/// This enum controls whether the table shows virtual temperature readings (core, surface, ambient) or physical sensor
/// readings (T1-T8) from the probe.
enum TemperaturesTableMode {
  /// Display virtual temperature readings including core, surface, and ambient temperatures.
  ///
  /// Virtual temperatures are calculated values that represent the estimated temperatures at key points of interest
  /// during cooking.
  virtual,

  /// Display physical sensor readings from all eight temperature sensors (T1-T8).
  ///
  /// Physical temperatures are the raw readings from each individual sensor along the length of the probe, from the tip
  /// (T1) to the handle (T8).
  physical,
}
