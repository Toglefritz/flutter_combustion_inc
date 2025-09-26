import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import 'keypad_button_widget.dart';

/// A keypad widget for entering custom temperature values.
///
/// This widget provides a numeric keypad interface with temperature display,
/// validation, and action buttons for clearing and submitting input.
class TemperatureKeypadWidget extends StatelessWidget {
  /// The current temperature input as a string.
  final String temperatureInput;

  /// Current validation error message, if any.
  final String? validationError;

  /// Whether the keypad should be enabled for user interaction.
  final bool enabled;

  /// Callback function called when a keypad button is pressed.
  final void Function(String value) onKeypadPress;

  /// Callback function called when the clear button is pressed.
  final VoidCallback onClear;

  /// Callback function called when the submit button is pressed.
  final VoidCallback onSubmit;

  /// Creates a temperature keypad widget.
  ///
  /// The keypad displays the current [temperatureInput] and any [validationError].
  /// User interactions trigger the appropriate callback functions.
  const TemperatureKeypadWidget({
    required this.temperatureInput,
    required this.enabled,
    required this.onKeypadPress,
    required this.onClear,
    required this.onSubmit,
    this.validationError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                temperatureInput.isEmpty ? '0' : temperatureInput,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (validationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: Inset.small),
                  child: Text(
                    validationError!,
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
                  KeypadButtonWidget(
                    value: '1',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '2',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '3',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                ],
              ),
              // Row 2: 4, 5, 6
              Row(
                children: [
                  KeypadButtonWidget(
                    value: '4',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '5',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '6',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                ],
              ),
              // Row 3: 7, 8, 9
              Row(
                children: [
                  KeypadButtonWidget(
                    value: '7',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '8',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '9',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                ],
              ),
              // Row 4: ., 0, ⌫
              Row(
                children: [
                  KeypadButtonWidget(
                    value: '.',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '0',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
                  KeypadButtonWidget(
                    value: '⌫',
                    enabled: enabled,
                    onPressed: onKeypadPress,
                  ),
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
                  onPressed: enabled ? onClear : null,
                  child: Text(AppLocalizations.of(context)!.clear),
                ),
              ),
              const SizedBox(width: Inset.small),
              Expanded(
                child: ElevatedButton(
                  onPressed: enabled && temperatureInput.isNotEmpty ? onSubmit : null,
                  child: Text(AppLocalizations.of(context)!.set),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
