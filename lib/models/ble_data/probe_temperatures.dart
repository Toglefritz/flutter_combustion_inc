/// Raw temperature readings from all eight sensors on a Combustion probe.
///
/// Sensors are numbered T1 (tip) through T8 (handle). Values are in Celsius. The physical arrangement is documented at:
/// https://combustion.inc/cdn/shop/files/thermometer-features-sm.jpg
class ProbeTemperatures {
  /// Sensor at the tip of the probe (T1).
  final double t1;

  /// Second sensor from the tip (T2).
  final double t2;

  /// Third sensor from the tip (T3).
  final double t3;

  /// Fourth sensor from the tip (T4).
  final double t4;

  /// Fifth sensor from the tip (T5), first in the upper-half range.
  final double t5;

  /// Sixth sensor from the tip (T6).
  final double t6;

  /// Seventh sensor from the tip (T7).
  final double t7;

  /// Sensor in the handle (T8), typically measures ambient temperature.
  final double t8;

  /// Creates a [ProbeTemperatures] with explicit values for each sensor.
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

  /// Alias for [t1], the tip sensor.
  double get tip => t1;
}
