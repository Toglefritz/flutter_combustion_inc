import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/prediction_info.dart';
import 'package:flutter_combustion_inc/models/prediction_mode.dart';
import 'package:flutter_combustion_inc/models/prediction_state.dart';
import 'package:flutter_combustion_inc/models/prediction_type.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import 'prediction_time_display_widget.dart';

/// A widget that displays the prediction information when a target temperature is set.
///
/// This widget shows the target temperature, estimated time remaining, cooking progress, prediction state, mode, type,
/// and temperature information in a comprehensive card layout.
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
  /// Shows the [targetTemperatureCelsius] converted to the current unit, displays [predictionInfo] if available, and
  /// provides an edit button that calls [onClearTarget] when pressed.
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

  /// Gets the icon for the current prediction state.
  IconData _getStateIcon(PredictionState state) {
    switch (state) {
      case PredictionState.probeNotInserted:
        return Icons.sensors_off;
      case PredictionState.probeInserted:
        return Icons.sensors;
      case PredictionState.cooking:
        return Icons.local_fire_department;
      case PredictionState.predicting:
        return Icons.analytics;
      case PredictionState.removalPredictionDone:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  /// Gets the color for the current prediction state.
  Color _getStateColor(BuildContext context, PredictionState state) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    switch (state) {
      case PredictionState.probeNotInserted:
        return colorScheme.error;
      case PredictionState.probeInserted:
        return colorScheme.tertiary;
      case PredictionState.cooking:
        return Colors.orange;
      case PredictionState.predicting:
        return colorScheme.primary;
      case PredictionState.removalPredictionDone:
        return Colors.green;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// Gets a human-readable label for the prediction state.
  String _getStateLabel(PredictionState state) {
    switch (state) {
      case PredictionState.probeNotInserted:
        return 'Probe Not Inserted';
      case PredictionState.probeInserted:
        return 'Probe Inserted';
      case PredictionState.cooking:
        return 'Cooking';
      case PredictionState.predicting:
        return 'Predicting';
      case PredictionState.removalPredictionDone:
        return 'Done';
      default:
        return 'Unknown';
    }
  }

  /// Gets a human-readable label for the prediction mode.
  String _getModeLabel(PredictionMode mode) {
    switch (mode) {
      case PredictionMode.none:
        return 'None';
      case PredictionMode.timeToRemoval:
        return 'Time to Removal';
      case PredictionMode.removalAndResting:
        return 'Removal & Resting';
      case PredictionMode.reserved:
        return 'Reserved';
    }
  }

  /// Gets a human-readable label for the prediction type.
  String _getTypeLabel(PredictionType type) {
    switch (type) {
      case PredictionType.none:
        return 'None';
      case PredictionType.removal:
        return 'Removal';
      case PredictionType.resting:
        return 'Resting';
      case PredictionType.reserved:
        return 'Reserved';
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

            if (predictionInfo != null) ...[
              const Divider(),

              // Prediction State Badge
              Padding(
                padding: const EdgeInsets.only(top: Inset.small, bottom: Inset.medium),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Inset.small,
                    vertical: Inset.xSmall,
                  ),
                  decoration: BoxDecoration(
                    color: _getStateColor(context, predictionInfo!.predictionState).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStateColor(context, predictionInfo!.predictionState),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStateIcon(predictionInfo!.predictionState),
                        size: 18,
                        color: _getStateColor(context, predictionInfo!.predictionState),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: Inset.xSmall),
                        child: Text(
                          _getStateLabel(predictionInfo!.predictionState),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _getStateColor(context, predictionInfo!.predictionState),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!predictionInfo!.isReliable)
                        Padding(
                          padding: const EdgeInsets.only(left: Inset.xSmall),
                          child: Icon(
                            Icons.warning_amber,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Time Remaining Section
              _buildInfoSection(
                context,
                icon: Icons.schedule,
                title: AppLocalizations.of(context)!.estimatedTimeRemaining,
                child: PredictionTimeDisplayWidget(
                  predictionInfo: predictionInfo,
                ),
              ),

              // Cooking Progress Section
              _buildInfoSection(
                context,
                icon: Icons.trending_up,
                title: AppLocalizations.of(context)!.currentProgress,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${predictionInfo!.percentThroughCook}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: Inset.xSmall),
                      child: LinearProgressIndicator(
                        value: predictionInfo!.percentThroughCook / 100,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              // Temperature Information Section
              _buildInfoSection(
                context,
                icon: Icons.thermostat,
                title: 'Temperature Information',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (predictionInfo!.currentCoreTempCelsius != null)
                      _buildTemperatureRow(
                        context,
                        label: 'Current Core',
                        temperature: predictionInfo!.currentCoreTempCelsius!,
                      ),
                    _buildTemperatureRow(
                      context,
                      label: 'Estimated Core',
                      temperature: predictionInfo!.estimatedCoreTemperature,
                    ),
                    _buildTemperatureRow(
                      context,
                      label: 'Target',
                      temperature: predictionInfo!.targetTemperatureCelsius,
                      isTarget: true,
                    ),
                  ],
                ),
              ),

              // Prediction Details Section
              _buildInfoSection(
                context,
                icon: Icons.info_outline,
                title: 'Prediction Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      context,
                      label: 'Mode',
                      value: _getModeLabel(predictionInfo!.predictionMode),
                    ),
                    _buildDetailRow(
                      context,
                      label: 'Type',
                      value: _getTypeLabel(predictionInfo!.predictionType),
                    ),
                    _buildDetailRow(
                      context,
                      label: 'Reliable',
                      value: predictionInfo!.isReliable ? 'Yes' : 'No',
                      valueColor: predictionInfo!.isReliable ? Colors.green : Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Inset.small),
                        child: Text(
                          'Waiting for prediction data...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a section with an icon, title, and child content.
  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: Inset.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              Padding(
                padding: const EdgeInsets.only(left: Inset.xSmall),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: Inset.small, left: Inset.medium),
            child: child,
          ),
        ],
      ),
    );
  }

  /// Builds a temperature display row.
  Widget _buildTemperatureRow(
    BuildContext context, {
    required String label,
    required double temperature,
    bool isTarget = false,
  }) {
    final double displayTemp = _convertFromCelsius(temperature);
    final String unit = TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';

    return Padding(
      padding: const EdgeInsets.only(bottom: Inset.xSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${displayTemp.toStringAsFixed(1)}$unit',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isTarget ? FontWeight.bold : FontWeight.w600,
              color: isTarget ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a detail information row.
  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Inset.xSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
