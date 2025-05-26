/// Represents virtual temperature readings from a probe, including core, surface, and ambient measurements.
class VirtualTemperatures {
  /// The estimated core temperature of the food.
  final double core;

  /// The estimated surface temperature of the food.
  final double surface;

  /// The ambient temperature near the food.
  final double ambient;

  /// Creates a [VirtualTemperatures] instance with the given values.
  VirtualTemperatures({
    required this.core,
    required this.surface,
    required this.ambient,
  });

  /// Creates a [VirtualTemperatures] instance from a map received via platform channels.
  factory VirtualTemperatures.fromMap(Map<String, dynamic> map) {
    return VirtualTemperatures(
      core: (map['core'] as num).toDouble(),
      surface: (map['surface'] as num).toDouble(),
      ambient: (map['ambient'] as num).toDouble(),
    );
  }
}
