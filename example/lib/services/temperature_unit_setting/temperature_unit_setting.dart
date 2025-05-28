import 'models/temperature_unit.dart';

/// Singleton-like class that manages the selected temperature unit in memory.
///
/// This class provides global access to the user's current temperature unit preference
/// across the app, without passing values explicitly between screens.
// Note: In a real-world application, consider saving the user's preference with something like SharedPreferences.
class TemperatureUnitSetting {
  // Prevent instantiation
  TemperatureUnitSetting._();

  /// The current temperature unit, defaulting to Fahrenheit.
  static TemperatureUnit currentUnit = TemperatureUnit.fahrenheit;

  /// Toggles between Celsius and Fahrenheit.
  static void toggle() {
    currentUnit = currentUnit == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
  }
}
