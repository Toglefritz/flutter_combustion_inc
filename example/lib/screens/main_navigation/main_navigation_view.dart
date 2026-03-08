import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../about/about_view.dart';
import '../graphs/graphs_view.dart';
import '../predictions/predictions_view.dart';
import '../rssi/rssi_route.dart';
import '../temperatures/temperatures_view.dart';
import 'main_navigation_controller.dart';
import 'main_navigation_route.dart';

/// View for the [MainNavigationRoute].
///
/// Displays a bottom navigation bar with five tabs:
/// * Temperatures - Visual temperature display with radar charts
/// * Graphs - Historical temperature data visualization
/// * Predictions - Cooking time predictions and target temperature
/// * RSSI - Bluetooth signal strength tracking and testing
/// * About - Plugin information and probe details
class MainNavigationView extends StatelessWidget {
  /// Reference to the controller.
  final MainNavigationController state;

  /// Creates an instance of [MainNavigationView].
  const MainNavigationView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      TemperaturesView(
        probes: state.probes,
        selectedProbe: state.selectedProbe,
        onProbeSelected: state.onProbeSelected,
      ),
      GraphsView(
        probes: state.probes,
        selectedProbe: state.selectedProbe,
        onProbeSelected: state.onProbeSelected,
      ),
      PredictionsView(
        probes: state.probes,
        selectedProbe: state.selectedProbe,
        onProbeSelected: state.onProbeSelected,
      ),
      RssiRoute(key: state.rssiKey),
      AboutView(
        probes: state.probes,
        selectedProbe: state.selectedProbe,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.currentTabIndex,
        children: tabs,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: state.currentTabIndex,
        onDestinationSelected: state.onTabChanged,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.thermostat_outlined),
            selectedIcon: const Icon(Icons.thermostat),
            label: AppLocalizations.of(context)!.temperatures,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
            label: AppLocalizations.of(context)!.graphs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: AppLocalizations.of(context)!.predictions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.signal_cellular_alt_outlined),
            selectedIcon: const Icon(Icons.signal_cellular_alt),
            label: AppLocalizations.of(context)!.rssiTracking,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outlined),
            selectedIcon: const Icon(Icons.info),
            label: AppLocalizations.of(context)!.about,
          ),
        ],
      ),
    );
  }
}
