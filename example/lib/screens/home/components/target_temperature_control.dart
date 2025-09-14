import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import '../models/food_preset.dart';

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

  /// Creates a target temperature control widget.
  ///
  /// @param onTargetSet Callback for when a temperature is selected
  /// @param enabled Whether the control accepts user input
  const TargetTemperatureControl({
    required this.onTargetSet,
    this.enabled = true,
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

  /// Converts temperature from Celsius to display unit.
  ///
  /// @param celsiusTemperature Temperature in Celsius
  /// @returns Temperature in current display unit
  double _convertFromCelsius(double celsiusTemperature) {
    if (TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius) {
      return celsiusTemperature;
    } else {
      // Convert Celsius to Fahrenheit
      return (celsiusTemperature * 9 / 5) + 32;
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

  /// Builds a keypad button.
  ///
  /// @param value The value this button represents
  /// @param flex The flex value for layout
  Widget _buildKeypadButton(String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed: widget.enabled ? () => _onKeypadPress(value) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  /// Builds the keypad interface for temperature input.
  Widget _buildKeypad() {
    return Column(
      children: [
        // Display current input
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Inset.medium),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _temperatureInput.isEmpty ? '0' : _temperatureInput,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: Inset.small),
                  child: Text(
                    _validationError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: Inset.medium),
          child: Column(
            children: [
              // Row 1: 1, 2, 3
              Row(
                children: [
                  _buildKeypadButton('1'),
                  _buildKeypadButton('2'),
                  _buildKeypadButton('3'),
                ],
              ),
              // Row 2: 4, 5, 6
              Row(
                children: [
                  _buildKeypadButton('4'),
                  _buildKeypadButton('5'),
                  _buildKeypadButton('6'),
                ],
              ),
              // Row 3: 7, 8, 9
              Row(
                children: [
                  _buildKeypadButton('7'),
                  _buildKeypadButton('8'),
                  _buildKeypadButton('9'),
                ],
              ),
              // Row 4: ., 0, ⌫
              Row(
                children: [
                  _buildKeypadButton('.'),
                  _buildKeypadButton('0'),
                  _buildKeypadButton('⌫'),
                ],
              ),
            ],
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.only(top: Inset.medium),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.enabled ? _clearInput : null,
                  child: Text(AppLocalizations.of(context)!.clear),
                ),
              ),
              const SizedBox(width: Inset.small),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.enabled && _temperatureInput.isNotEmpty ? _onCustomSubmit : null,
                  child: Text(AppLocalizations.of(context)!.set),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the preset temperature chips.
  Widget _buildPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quickPresets,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Inset.small),
          child: Wrap(
            spacing: Inset.small,
            runSpacing: Inset.small,
            children:
                FoodPreset.presets.map((FoodPreset preset) {
                  final double displayTemp =
                      TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius
                          ? preset.temperatureCelsius
                          : preset.temperatureFahrenheit;
                  final String unit = TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';

                  return ActionChip(
                    label: Text('${preset.name} ${displayTemp.toInt()}$unit'),
                    onPressed: widget.enabled ? () => _onPresetSelected(preset) : null,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds the prediction display when a target temperature is set.
  Widget _buildPredictionDisplay() {
    if (_setTargetTemperature == null) return const SizedBox.shrink();

    final double displayTemp = _convertFromCelsius(_setTargetTemperature!);
    final String unit = TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Inset.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.targetTemperature,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: widget.enabled ? _onClearTarget : null,
                  icon: const Icon(Icons.edit),
                  tooltip: AppLocalizations.of(context)!.changeTarget,
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Inset.small),
              child: Text(
                '${displayTemp.toInt()}$unit',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const Divider(),

            // Placeholder for prediction information
            Text(
              AppLocalizations.of(context)!.predictionInfo,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: Inset.small),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Inset.xSmall),
                    child: Text(
                      AppLocalizations.of(context)!.estimatedTimeRemaining,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: Inset.xSmall),
              child: Text(
                AppLocalizations.of(context)!.predictionPlaceholder,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: Inset.medium),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Inset.xSmall),
                    child: Text(
                      AppLocalizations.of(context)!.currentProgress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: Inset.xSmall),
              child: Text(
                AppLocalizations.of(context)!.progressPlaceholder,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If target temperature is set, show prediction display
    if (_setTargetTemperature != null) {
      return _buildPredictionDisplay();
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
              child: _buildPresets(),
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
              child: _buildKeypad(),
            ),
          ],
        ),
      ),
    );
  }
}
