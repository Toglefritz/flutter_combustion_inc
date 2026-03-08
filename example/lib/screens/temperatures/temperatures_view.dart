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
import 'components/stacked_radar_chart_card.dart';
import 'components/temperature_radar_chart.dart';
import 'components/temperature_stats_card.dart';
import 'models/temperatures_display_mode.dart';

/// View for the temperatures tab.
///
/// Displays temperature readings using visual radar charts for both virtual temperatures (core, surface, ambient) and
/// physical sensor readings (T1-T8). Supports two display modes: column (separate charts) and stacked (combined chart).
class TemperaturesView extends StatefulWidget {
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
  State<TemperaturesView> createState() => _TemperaturesViewState();
}

/// State for [TemperaturesView].
class _TemperaturesViewState extends State<TemperaturesView> {
  /// Current display mode for temperature visualization.
  TemperaturesDisplayMode _displayMode = TemperaturesDisplayMode.column;

  /// Toggles between column and stacked display modes.
  void _toggleDisplayMode() {
    setState(() {
      _displayMode =
          _displayMode == TemperaturesDisplayMode.column
              ? TemperaturesDisplayMode.stacked
              : TemperaturesDisplayMode.column;
    });
  }

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
        actions: [
          IconButton(
            icon: Icon(
              _displayMode == TemperaturesDisplayMode.column ? Icons.layers_outlined : Icons.view_column_outlined,
            ),
            tooltip:
                _displayMode == TemperaturesDisplayMode.column ? 'Switch to stacked view' : 'Switch to column view',
            onPressed: _toggleDisplayMode,
          ),
        ],
      ),
      body:
          widget.probes.isEmpty
              ? const EmptyStateWidget()
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Probe selector
                        if (widget.probes.length > 1)
                          ProbeSelector(
                            probes: widget.probes,
                            selectedProbe: widget.selectedProbe,
                            onProbeSelected: widget.onProbeSelected,
                          ),

                        if (widget.selectedProbe != null) ...[
                          if (_displayMode == TemperaturesDisplayMode.column) ...[
                            // Column mode: Virtual temperatures radar chart
                            Padding(
                              padding: const EdgeInsets.all(Inset.medium),
                              child: TemperatureRadarChart(
                                probe: widget.selectedProbe!,
                                showVirtual: true,
                              ),
                            ),

                            // Column mode: Physical temperatures radar chart
                            Padding(
                              padding: const EdgeInsets.all(Inset.medium),
                              child: TemperatureRadarChart(
                                probe: widget.selectedProbe!,
                                showVirtual: false,
                              ),
                            ),
                          ] else ...[
                            // Stacked mode: Combined radar chart
                            Padding(
                              padding: const EdgeInsets.all(Inset.medium),
                              child: StackedRadarChartCard(probe: widget.selectedProbe!),
                            ),
                          ],

                          // Temperature statistics
                          Padding(
                            padding: const EdgeInsets.all(Inset.medium),
                            child: TemperatureStatsCard(probe: widget.selectedProbe!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
