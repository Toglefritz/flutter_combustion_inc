/// Computed temperature readings derived from the probe's eight physical sensors.
///
/// The SDK calculates core, surface, and ambient temperatures by selecting the most appropriate physical sensors based
/// on the current virtual sensor configuration.
class VirtualTemperatures {
  /// Estimated core temperature of the food, in Celsius.
  final double core;

  /// Estimated surface temperature of the food, in Celsius.
  final double surface;

  /// Ambient temperature near the food, in Celsius.
  final double ambient;

  /// Creates a [VirtualTemperatures] instance.
  VirtualTemperatures({
    required this.core,
    required this.surface,
    required this.ambient,
  });

  /// Creates a [VirtualTemperatures] from a platform channel map.
  factory VirtualTemperatures.fromMap(Map<String, dynamic> map) {
    return VirtualTemperatures(
      core: (map['core'] as num).toDouble(),
      surface: (map['surface'] as num).toDouble(),
      ambient: (map['ambient'] as num).toDouble(),
    );
  }
}
