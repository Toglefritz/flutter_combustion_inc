import 'package:flutter_combustion_inc/util/temperature_unit_converter.dart';

import '../services/temperature_unit_setting/models/temperature_unit.dart';
import '../services/temperature_unit_setting/temperature_unit_setting.dart';

/// Contains extension methods for the double type.
extension DoubleExtensions on double {
  /// Converts the provided temperature probe reading, which is in Celsius when obtained from the Combustion Inc. SDK,
  /// to the temperature unit selected by the user. If the user has selected Celsius, it returns the value as is.
  /// Otherwise, the value is converted to Fahrenheit.
  double toUserSelectedTemperatureUnit() {
    // Check if the current temperature unit is Celsius
    if (TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius) {
      return this; // Return the value as is
    } else {
      // Convert to Fahrenheit
      return TemperatureUnitConverter.toFahrenheit(this);
    }
  }
}
