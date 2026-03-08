import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
import '../components/empty_state_widget.dart';
import '../components/probe_selector.dart';
import 'components/rssi_graph.dart';
import 'rssi_controller.dart';

/// View for the RSSI tracking screen.
///
/// Displays current RSSI value and historical RSSI data in a line chart. Used for testing and evaluating Bluetooth
/// signal strength in different scenarios (open-air, inside oven, inside grill, etc.).
class RssiView extends StatelessWidget {
  /// Reference to the controller.
  final RssiController state;

  /// Creates an instance of [RssiView].
  const RssiView(this.state, {super.key});

  /// Gets the color for the RSSI value based on signal quality.
  Color _getRssiColor(int? rssi, ColorScheme colorScheme) {
    if (rssi == null) return colorScheme.onSurface;

    if (rssi >= -50) {
      return Colors.green;
    } else if (rssi >= -70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Gets a human-readable label for the RSSI signal quality.
  String _getRssiQualityLabel(BuildContext context, int? rssi) {
    if (rssi == null) return '';

    if (rssi >= -50) {
      return AppLocalizations.of(context)!.rssiExcellent;
    } else if (rssi >= -60) {
      return AppLocalizations.of(context)!.rssiGood;
    } else if (rssi >= -70) {
      return AppLocalizations.of(context)!.rssiFair;
    } else {
      return AppLocalizations.of(context)!.rssiPoor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.rssiTracking,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          state.probes.isEmpty
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
                        if (state.probes.length > 1)
                          ProbeSelector(
                            probes: state.probes,
                            selectedProbe: state.selectedProbe,
                            onProbeSelected: state.onProbeSelected,
                          ),

                        if (state.selectedProbe != null) ...[
                          // Current RSSI display
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
                                  padding: const EdgeInsets.all(Inset.large),
                                  child: Column(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.currentRssi,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: Inset.small),
                                        child: Text(
                                          state.currentRssi != null
                                              ? '${state.currentRssi} dBm'
                                              : AppLocalizations.of(context)!.loading,
                                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _getRssiColor(state.currentRssi, colorScheme),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: Inset.small),
                                        child: Text(
                                          _getRssiQualityLabel(context, state.currentRssi),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: _getRssiColor(state.currentRssi, colorScheme),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // RSSI graph
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
                                        AppLocalizations.of(context)!.rssiHistory,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: Inset.small),
                                        child: Text(
                                          AppLocalizations.of(context)!.rssiHistoryDescription,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: Inset.medium),
                                        child: RssiGraph(
                                          rssiHistory: state.rssiHistory,
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
                ),
              ),
    );
  }
}
