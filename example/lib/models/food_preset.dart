/// Represents a preset target temperature for common food types.
///
/// This class provides predefined temperature targets for various foods commonly cooked with temperature probes, making
/// it easy for users to select appropriate cooking temperatures without manual input.
class FoodPreset {
  /// The display name of the food type.
  final String name;

  /// The recommended target temperature in Celsius.
  final double temperatureCelsius;

  /// The icon data representing this food type.
  final String iconPath;

  /// Creates a new food preset with the specified parameters.
  ///
  /// @param name Display name for the food type
  /// @param temperatureCelsius Target temperature in Celsius
  /// @param iconPath Path to the icon asset for this food type
  const FoodPreset({
    required this.name,
    required this.temperatureCelsius,
    required this.iconPath,
  });

  /// Predefined food presets with common cooking temperatures.
  static const List<FoodPreset> presets = [
    FoodPreset(
      name: 'Chicken',
      temperatureCelsius: 74.0, // 165°F
      iconPath: '🐔',
    ),
    FoodPreset(
      name: 'Pork',
      temperatureCelsius: 63.0, // 145°F
      iconPath: '🐷',
    ),
    FoodPreset(
      name: 'Beef (Medium)',
      temperatureCelsius: 57.0, // 135°F
      iconPath: '🐄',
    ),
    FoodPreset(
      name: 'Fish',
      temperatureCelsius: 63.0, // 145°F
      iconPath: '🐟',
    ),
    FoodPreset(
      name: 'Turkey',
      temperatureCelsius: 74.0, // 165°F
      iconPath: '🦃',
    ),
    FoodPreset(
      name: 'Lamb',
      temperatureCelsius: 63.0, // 145°F
      iconPath: '🐑',
    ),
  ];

  /// Returns the temperature in Fahrenheit for display purposes.
  double get temperatureFahrenheit => (temperatureCelsius * 9 / 5) + 32;
}
