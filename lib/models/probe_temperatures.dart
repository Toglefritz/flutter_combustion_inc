/// Represents the readings from all eight temperature sensors of a Combustion Inc. probe.
///
/// The Combustion Inc. temperature probes are designed with eight sensors arranged in various positions along the
/// length of the probe. See [https://combustion.inc/cdn/shop/files/thermometer-features-sm.jpg?v=1712253666&width=2000](https://combustion.inc/cdn/shop/files/thermometer-features-sm.jpg?v=1712253666&width=2000)
/// for more information about the arrangement and capabilities of each temperature sensor. This class provides a way
/// to access each of these individual sensor readings by their position, such as the tip or handle of the probe.
///
/// The readings are provided as a list of doubles, where each index corresponds to a specific sensor's temperature
/// reading. By default, the temperature values are in Celsius, but they can be converted to Fahrenheit if needed.
class ProbeTemperatures {
  /// The temperature sensor located at the tip of the probe.
  final double t1;

  /// The second temperature sensor, counting from the tip towards the handle.
  final double t2;

  /// The third temperature sensor, counting from the tip towards the handle.
  final double t3;

  /// The fourth temperature sensor, counting from the tip towards the handle.
  final double t4;

  /// The fifth temperature sensor, counting from the tip towards the handle. This is the first sensor located in
  /// the "upper-half" range.
  final double t5;

  /// The sixth temperature sensor, counting from the tip towards the handle.
  final double t6;

  /// The seventh temperature sensor, counting from the tip towards the handle.
  final double t7;

  /// The eighth temperature sensor, located in the handle of the probe. This sensor is typically used to measure
  /// the ambient temperature of the probe's environment.
  final double t8;

  /// Creates a new [ProbeTemperatures] instance from a list of temperature values.
  ProbeTemperatures({
    required this.t1,
    required this.t2,
    required this.t3,
    required this.t4,
    required this.t5,
    required this.t6,
    required this.t7,
    required this.t8,
  });

  /// A convenience getter for accessing the temperature reading at the tip of the probe using a more human-readable name.
  double get tip => t1;
}
