import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'package:flutter_combustion_inc/models/probe_temperatures.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import 'temperature_stat_column.dart';

/// Displays temperature statistics for a probe.
///
/// Shows minimum, maximum, and average temperatures across all sensors.
class TemperatureStatsCard extends StatelessWidget {
  /// The probe to display statistics for.
  final Probe probe;

  /// Creates an instance of [TemperatureStatsCard].
  const TemperatureStatsCard({
    required this.probe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<ProbeTemperatures>(
      stream: probe.currentTemperaturesStream,
      builder: (BuildContext context, AsyncSnapshot<ProbeTemperatures> snapshot) {
        if (!snapshot.hasData) {
          return Card(
            elevation: isDark ? 4 : 2,
            child: const Padding(
              padding: EdgeInsets.all(Inset.medium),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final ProbeTemperatures temps = snapshot.data!;
        final List<double> allTemps = [
          temps.t1,
          temps.t2,
          temps.t3,
          temps.t4,
          temps.t5,
          temps.t6,
          temps.t7,
          temps.t8,
        ];

        final double minTemp = allTemps.reduce((double a, double b) => a < b ? a : b);
        final double maxTemp = allTemps.reduce((double a, double b) => a > b ? a : b);
        final double avgTemp = allTemps.reduce((double a, double b) => a + b) / allTemps.length;

        final String unit = _getUnitSymbol();

        return Card(
          elevation: isDark ? 4 : 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [
                          colorScheme.surfaceContainerHigh,
                          colorScheme.surfaceContainer,
                        ]
                        : [
                          colorScheme.surface,
                          colorScheme.surfaceContainerLow,
                        ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Inset.medium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TemperatureStatColumn(
                    label: AppLocalizations.of(context)!.minTemperature,
                    value: _convertTemperature(minTemp),
                    unit: unit,
                    color: Colors.blue,
                  ),
                  TemperatureStatColumn(
                    label: AppLocalizations.of(context)!.avgTemperature,
                    value: _convertTemperature(avgTemp),
                    unit: unit,
                    color: Colors.orange,
                  ),
                  TemperatureStatColumn(
                    label: AppLocalizations.of(context)!.maxTemperature,
                    value: _convertTemperature(maxTemp),
                    unit: unit,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Converts temperature from Celsius to the user's preferred unit.
  double _convertTemperature(double celsius) {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? celsius : (celsius * 9 / 5) + 32;
  }

  /// Gets the temperature unit symbol.
  String _getUnitSymbol() {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';
  }
}
