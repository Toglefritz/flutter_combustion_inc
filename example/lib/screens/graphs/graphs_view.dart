import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
import '../components/empty_state_widget.dart';
import '../components/probe_selector.dart';
import 'components/graph/temperature_graph.dart';
import 'models/display_mode.dart';

/// View for the graphs tab.
///
/// Displays historical temperature data in elegant line charts.
class GraphsView extends StatelessWidget {
  /// List of available probes.
  final List<Probe> probes;

  /// Currently selected probe.
  final Probe? selectedProbe;

  /// Callback when probe selection changes.
  final ValueChanged<Probe?> onProbeSelected;

  /// Creates an instance of [GraphsView].
  const GraphsView({
    required this.probes,
    required this.selectedProbe,
    required this.onProbeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.graphs,
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
                      // Virtual temperatures graph
                      Padding(
                        padding: const EdgeInsets.all(Inset.medium),
                        child: Card(
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
                                    AppLocalizations.of(context)!.virtualTemperatures,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: Inset.medium),
                                    child: TemperatureGraph(
                                      probe: selectedProbe!,
                                      displayMode: DisplayMode.virtualTemperatures,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Physical temperatures graph
                      Padding(
                        padding: const EdgeInsets.all(Inset.medium),
                        child: Card(
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
                                    AppLocalizations.of(context)!.physicalTemperatures,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: Inset.medium),
                                    child: TemperatureGraph(
                                      probe: selectedProbe!,
                                      displayMode: DisplayMode.physicalTemperatures,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
