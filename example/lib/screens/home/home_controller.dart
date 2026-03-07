import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../predictions/predictions_route.dart';
import 'home_route.dart';
import 'home_view.dart';
import 'home_view_searching.dart';
import 'models/display_mode.dart';

/// Controller for the [HomeRoute] that manages temperature display state and business logic.
class HomeController extends State<HomeRoute> {
  /// List of Combustion Inc. temperature probes discovered during scanning.
  List<Probe> probes = [];

  /// The display mode for temperature readings.
  DisplayMode displayMode = DisplayMode.virtualTemperatures;

  /// Determines if temperature graphs should be displayed.
  bool _showGraphs = false;

  /// Gets the current state of the temperature graphs display.
  bool get showGraphs => _showGraphs;

  /// Sets the state of the temperature graphs display.
  set showGraphs(bool value) {
    if (_showGraphs != value) {
      _showGraphs = value;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    // Set up a listener for probe discovery events
    DeviceManager.instance.scanResults.listen(_onProbeDiscovered);

    // Initialize Bluetooth and start scanning for probes
    unawaited(DeviceManager.instance.initBluetooth());
  }

  /// Handles the discovery of a new probe.
  ///
  /// Adds the probe to the list and initiates a connection.
  ///
  /// - Parameter probe: The newly discovered probe
  Future<void> _onProbeDiscovered(Probe probe) async {
    debugPrint('Discovered probe: ${probe.name} (${probe.identifier})');

    // Check if the probe is already in the list to avoid duplicates
    if (!probes.any((p) => p.identifier == probe.identifier)) {
      setState(() {
        probes.add(probe);
      });

      // Connect to the probe and attempt to maintain a connection
      await probe.connect();
    }
  }

  /// Handles changes in the temperature unit setting.
  void onTemperatureUnitChanged() => setState(TemperatureUnitSetting.toggle);

  /// Handles changes in the display mode.
  ///
  /// - Parameter mode: The new display mode
  void onDisplayModeChanged(DisplayMode mode) => setState(() {
    displayMode = mode;
  });

  /// Handles taps on the button used to navigate to the screen used to view and manage predictions.
  Future<void> onPredictionsTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const PredictionsRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(microseconds: 250),
    child: probes.isEmpty ? const HomeViewSearching() : HomeView(this),
  );
}
