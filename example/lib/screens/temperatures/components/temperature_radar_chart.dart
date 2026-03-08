/// Temperature radar chart library.
///
/// This library provides widgets for displaying temperature readings in a radar chart format, supporting both virtual
/// and physical sensors.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'package:flutter_combustion_inc/models/probe_temperatures.dart';
import 'package:flutter_combustion_inc/models/virtual_temperatures.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';

part '../models/radar_data_point.dart';
part 'temperature_radar_chart/virtual_temperature_radar.dart';
part 'temperature_radar_chart/physical_temperature_radar.dart';
part 'temperature_radar_chart/radar_chart_painter_widget.dart';
part 'temperature_radar_chart/radar_painter.dart';

/// A radar chart widget for displaying temperature readings.
///
/// Can display either virtual temperatures (core, surface, ambient) or physical sensor temperatures (T1-T8).
class TemperatureRadarChart extends StatelessWidget {
  /// The probe to display temperatures for.
  final Probe probe;

  /// Whether to show virtual temperatures (true) or physical sensors (false).
  final bool showVirtual;

  /// Creates an instance of [TemperatureRadarChart].
  const TemperatureRadarChart({
    required this.probe,
    required this.showVirtual,
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
                showVirtual
                    ? AppLocalizations.of(context)!.virtualSensors
                    : AppLocalizations.of(context)!.physicalSensors,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: showVirtual ? VirtualTemperatureRadar(probe: probe) : PhysicalTemperatureRadar(probe: probe),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
