import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../../l10n/app_localizations.dart';
import '../../../values/inset.dart';
import 'temperature_radar_chart.dart';

/// Card widget that displays overlaid radar charts with both virtual and physical temperatures.
///
/// This card shows two radar charts stacked on top of each other - the virtual temperatures (core, surface, ambient)
/// overlaid on the physical temperatures (T1-T8). This allows for easy visual comparison and analysis of how the
/// virtual and physical sensors relate.
class StackedRadarChartCard extends StatelessWidget {
  /// The probe to display temperatures for.
  final Probe probe;

  /// Creates an instance of [StackedRadarChartCard].
  const StackedRadarChartCard({
    required this.probe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.allTemperatures,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: [
                      // Physical temperatures as the base layer with blue-tinted radar
                      PhysicalTemperatureRadar(
                        probe: probe,
                        radarColor: Colors.blue.withValues(alpha: 0.6),
                      ),
                      // Virtual temperatures overlaid on top with red-tinted radar
                      VirtualTemperatureRadar(
                        probe: probe,
                        radarColor: Colors.red.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
