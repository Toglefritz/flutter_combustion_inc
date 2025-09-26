import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/prediction_info.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import '../models/food_preset.dart';
import 'prediction_display_widget.dart';
import 'temperature_keypad_widget.dart';
import 'temperature_presets_widget.dart';

/// A control widget for setting and displaying target temperatures on temperature probes.
///
/// This widget provides a keypad interface for entering custom temperatures,
/// discrete preset buttons, and transforms into a prediction display once
/// a target temperature is set.
///
/// The control respects the user's temperature unit preference and validates
/// input to ensure reasonable cooking temperatures.
class TargetTemperatureControl extends StatefulWidget {
  /// Callback function called when a target temperature is set.
  /// The temperature is provided in Celsius regardless of display unit.
  final void Function(double temperatureCelsius) onTargetSet;

  /// Whether the control should be enabled for user interaction.
  final bool enabled;

  /// Current prediction information to display, if available.
  final PredictionInfo? predictionInfo;

  /// Creates a target temperature control widget.
  ///
  /// @param onTargetSet Callback for when a temperature is selected
  /// @param enabled Whether the control accepts user input
  /// @param predictionInfo Current prediction data to display
  const TargetTemperatureControl({
    required this.onTargetSet,
    this.enabled = true,
    this.predictionInfo,
    super.key,
  });

  @override
  State<TargetTemperatureControl> createState() => _TargetTemperatureControlState();
}

class _TargetTemperatureControlState extends State<TargetTemperatureControl> {
  /// The current temperature input as a string.
  String _temperatureInput = '';

  /// The currently set target temperature in Celsius, null if none set.
  double? _setTargetTemperature;

  /// Current validation error message for temperature input.
  String? _validationError;

  /// Validates the entered temperature value.
  ///
  /// Ensures the temperature is within reasonable cooking ranges:
  /// - Celsius: 40°C to 100°C
  /// - Fahrenheit: 104°F to 212°F
  ///
  /// @param value The input string to validate
  /// @returns Error message if invalid, null if valid
  String? _validateTemperature(String value) {
    if (value.isEmpty) {
      return AppLocalizations.of(context)!.temperatureRequired;
    }

    final double? temperature = double.tryParse(value);
    if (temperature == null) {
      return AppLocalizations.of(context)!.invalidTemperature;
    }

    final bool isCelsius = TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius;
    final double minTemp = isCelsius ? 40.0 : 104.0;
    final double maxTemp = isCelsius ? 100.0 : 212.0;

    if (temperature < minTemp || temperature > maxTemp) {
      final String unit = isCelsius ? '°C' : '°F';
      return AppLocalizations.of(context)!.temperatureOutOfRange(
        minTemp.toInt(),
        maxTemp.toInt(),
        unit,
      );
    }

    return null;
  }

  /// Converts temperature from display unit to Celsius.
  ///
  /// @param displayTemperature Temperature in current display unit
  /// @returns Temperature in Celsius
  double _convertToCelsius(double displayTemperature) {
    if (TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius) {
      return displayTemperature;
    } else {
      // Convert Fahrenheit to Celsius
      return (displayTemperature - 32) * 5 / 9;
    }
  }

  /// Handles keypad button presses.
  ///
  /// @param value The character to add to the input
  void _onKeypadPress(String value) {
    if (!widget.enabled) return;

    setState(() {
      if (value == '⌫') {
        // Backspace
        if (_temperatureInput.isNotEmpty) {
          _temperatureInput = _temperatureInput.substring(0, _temperatureInput.length - 1);
        }
      } else if (value == '.' && !_temperatureInput.contains('.')) {
        // Decimal point (only allow one)
        _temperatureInput += value;
      } else if (value != '.' && RegExp(r'^\d$').hasMatch(value)) {
        // Numeric digit
        _temperatureInput += value;
      }

      // Clear validation error when user types
      _validationError = null;
    });
  }

  /// Clears the current temperature input.
  void _clearInput() {
    setState(() {
      _temperatureInput = '';
      _validationError = null;
    });
  }

  /// Handles selection of a food preset.
  ///
  /// @param preset The selected food preset
  void _onPresetSelected(FoodPreset preset) {
    if (!widget.enabled) return;

    setState(() {
      _setTargetTemperature = preset.temperatureCelsius;
      _temperatureInput = '';
      _validationError = null;
    });

    widget.onTargetSet(preset.temperatureCelsius);
  }

  /// Handles custom temperature submission.
  void _onCustomSubmit() {
    if (!widget.enabled || _temperatureInput.isEmpty) return;

    final String? error = _validateTemperature(_temperatureInput);

    setState(() {
      _validationError = error;
    });

    if (error == null) {
      final double displayTemp = double.parse(_temperatureInput);
      final double celsiusTemp = _convertToCelsius(displayTemp);

      setState(() {
        _setTargetTemperature = celsiusTemp;
        _temperatureInput = '';
        _validationError = null;
      });

      widget.onTargetSet(celsiusTemp);
    }
  }

  /// Handles clearing the set target temperature to return to input mode.
  void _onClearTarget() {
    setState(() {
      _setTargetTemperature = null;
      _temperatureInput = '';
      _validationError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If target temperature is set, show prediction display
    if (_setTargetTemperature != null) {
      return PredictionDisplayWidget(
        targetTemperatureCelsius: _setTargetTemperature!,
        predictionInfo: widget.predictionInfo,
        enabled: widget.enabled,
        onClearTarget: _onClearTarget,
      );
    }

    // Otherwise show input interface
    return Card(
      margin: const EdgeInsets.all(Inset.medium),
      child: Padding(
        padding: const EdgeInsets.all(Inset.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              AppLocalizations.of(context)!.setTargetTemperature,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // Presets
            Padding(
              padding: const EdgeInsets.only(top: Inset.medium),
              child: TemperaturePresetsWidget(
                enabled: widget.enabled,
                onPresetSelected: _onPresetSelected,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Inset.medium),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Inset.small),
                    child: Text(
                      AppLocalizations.of(context)!.or,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),

            // Custom input section
            Text(
              AppLocalizations.of(context)!.enterCustomTemperature,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: Inset.small),
              child: TemperatureKeypadWidget(
                temperatureInput: _temperatureInput,
                validationError: _validationError,
                enabled: widget.enabled,
                onKeypadPress: _onKeypadPress,
                onClear: _clearInput,
                onSubmit: _onCustomSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
