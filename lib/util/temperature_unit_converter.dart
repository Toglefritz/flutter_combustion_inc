/// Provides static methods for converting between Celsius and Fahrenheit.
class TemperatureUnitConverter {
  /// Converts a temperature in Fahrenheit to Celsius.
  static double toCelsius(double fahrenheit) => (fahrenheit - 32) * 5.0 / 9.0;

  /// Converts a temperature in Celsius to Fahrenheit.
  static double toFahrenheit(double celsius) => (celsius * 9.0 / 5.0) + 32.0;
}
