import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/prediction_info.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import 'prediction_time_display_widget.dart';

/// A widget that displays the prediction information when a target temperature is set.
///
/// This widget shows the target temperature, estimated time remaining,
/// and current cooking progress in a card layout.
class PredictionDisplayWidget extends StatelessWidget {
  /// The target temperature in Celsius.
  final double targetTemperatureCelsius;

  /// Current prediction information to display.
  final PredictionInfo? predictionInfo;

  /// Whether the widget should be enabled for user interaction.
  final bool enabled;

  /// Callback function called when the user wants to change the target.
  final VoidCallback onClearTarget;

  /// Creates a prediction display widget.
  ///
  /// Shows the [targetTemperatureCelsius] converted to the current unit,
  /// displays [predictionInfo] if available, and provides an edit button
  /// that calls [onClearTarget] when pressed.
  const PredictionDisplayWidget({
    required this.targetTemperatureCelsius,
    required this.enabled,
    required this.onClearTarget,
    this.predictionInfo,
    super.key,
  });

  /// Converts temperature from Celsius to the current display unit.
  double _convertFromCelsius(double celsiusTemperature) {
    if (TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius) {
      return celsiusTemperature;
    } else {
      // Convert Celsius to Fahrenheit
      return (celsiusTemperature * 9 / 5) + 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double displayTemp = _convertFromCelsius(targetTemperatureCelsius);
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
                  onPressed: enabled ? onClearTarget : null,
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

            // Prediction information section
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
              child: PredictionTimeDisplayWidget(
                predictionInfo: predictionInfo,
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
}
