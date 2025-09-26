import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import '../models/food_preset.dart';

/// A widget that displays preset temperature options as action chips.
///
/// This widget shows a collection of common cooking temperatures
/// organized as selectable chips for quick temperature selection.
class TemperaturePresetsWidget extends StatelessWidget {
  /// Whether the presets should be enabled for user interaction.
  final bool enabled;

  /// Callback function called when a preset is selected.
  final void Function(FoodPreset preset) onPresetSelected;

  /// Creates a temperature presets widget.
  ///
  /// The presets are displayed as action chips that trigger [onPresetSelected]
  /// when tapped. The temperature values are automatically converted to the
  /// current temperature unit setting.
  const TemperaturePresetsWidget({
    required this.enabled,
    required this.onPresetSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                    onPressed: enabled ? () => onPresetSelected(preset) : null,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
