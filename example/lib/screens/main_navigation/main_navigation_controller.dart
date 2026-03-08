import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import 'main_navigation_route.dart';
import 'main_navigation_view.dart';

/// Controller for the [MainNavigationRoute] that manages navigation state and probe discovery.
///
/// This controller handles:
/// * Bottom navigation tab selection
/// * Probe discovery and connection management
/// * Sharing probe data across all tabs
class MainNavigationController extends State<MainNavigationRoute> {
  /// Currently selected tab index.
  int currentTabIndex = 0;

  /// List of discovered and connected probes.
  List<Probe> probes = [];

  /// Currently selected probe for detailed viewing.
  Probe? selectedProbe;

  @override
  void initState() {
    super.initState();

    // Set up probe discovery listener
    DeviceManager.instance.scanResults.listen(_onProbeDiscovered);

    // Initialize Bluetooth and start scanning
    unawaited(DeviceManager.instance.initBluetooth());
  }

  /// Handles discovery of a new probe.
  ///
  /// Adds the probe to the list and initiates connection.
  Future<void> _onProbeDiscovered(Probe probe) async {
    debugPrint('Discovered probe: ${probe.name} (${probe.identifier})');

    // Avoid duplicates
    if (!probes.any((p) => p.identifier == probe.identifier)) {
      setState(() {
        probes.add(probe);
        // Auto-select first probe
        selectedProbe ??= probe;
      });

      // Connect to the probe
      await probe.connect();
    }
  }

  /// Handles tab selection changes.
  void onTabChanged(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  /// Handles probe selection changes.
  void onProbeSelected(Probe? probe) {
    setState(() {
      selectedProbe = probe;
    });
  }

  @override
  Widget build(BuildContext context) => MainNavigationView(this);
}
