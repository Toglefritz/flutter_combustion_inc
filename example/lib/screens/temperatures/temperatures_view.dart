/// Temperatures view library.
///
/// This library provides the main view for the temperatures tab, displaying temperature readings using radar charts and
/// statistics.
library;

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
import '../components/empty_state_widget.dart';
import '../components/probe_selector.dart';
import 'components/temperature_radar_chart.dart';
import 'components/temperature_stats_card.dart';

/// View for the temperatures tab.
///
/// Displays temperature readings using visual radar charts for both virtual temperatures (core, surface, ambient) and
/// physical sensor readings (T1-T8).
class TemperaturesView extends StatelessWidget {
  /// List of available probes.
  final List<Probe> probes;

  /// Currently selected probe.
  final Probe? selectedProbe;

  /// Callback when probe selection changes.
  final ValueChanged<Probe?> onProbeSelected;

  /// Creates an instance of [TemperaturesView].
  const TemperaturesView({
    required this.probes,
    required this.selectedProbe,
    required this.onProbeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.temperatures,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body:
          probes.isEmpty
              ? const EmptyStateWidget()
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Probe selector
                    if (probes.length > 1)
                      ProbeSelector(
                        probes: probes,
                        selectedProbe: selectedProbe,
                        onProbeSelected: onProbeSelected,
                      ),

                    if (selectedProbe != null) ...[
                      // Virtual temperatures radar chart
                      Padding(
                        padding: const EdgeInsets.all(Inset.medium),
                        child: TemperatureRadarChart(
                          probe: selectedProbe!,
                          showVirtual: true,
                        ),
                      ),

                      // Physical temperatures radar chart
                      Padding(
                        padding: const EdgeInsets.all(Inset.medium),
                        child: TemperatureRadarChart(
                          probe: selectedProbe!,
                          showVirtual: false,
                        ),
                      ),

                      // Temperature statistics
                      Padding(
                        padding: const EdgeInsets.all(Inset.medium),
                        child: TemperatureStatsCard(probe: selectedProbe!),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
