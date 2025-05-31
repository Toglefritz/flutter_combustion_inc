import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import '../../services/temperature_unit_setting/temperature_unit_setting.dart';
import 'home_route.dart';
import 'home_view.dart';
import 'home_view_searching.dart';
import 'models/display_mode.dart';

/// A controller for the [HomeRoute] that manages the state and owns all business logic.
class HomeController extends State<HomeRoute> {
  /// A list of Combustion Inc. temperature probes discovered during scanning.
  List<Probe> probes = [];

  /// The display mode for this view. This is used to determine what information to show and how it should be presented.
  DisplayMode displayMode = DisplayMode.virtualTemperatures;

  @override
  void initState() {
    // Set up a listener for probe discovery events.
    DeviceManager.instance.scanResults.listen(_onProbeDiscovered);

    // Initialize Bluetooth and start scanning for probes.
    DeviceManager.instance.initBluetooth();

    super.initState();
  }

  /// Handles the discovery of a new probe by adding it to the list of discovered probes.
  void _onProbeDiscovered(Probe probe) {
    debugPrint('Discovered probe: ${probe.name} (${probe.identifier})');

    // Check if the probe is already in the list to avoid duplicates.
    if (!probes.any((p) => p.identifier == probe.identifier)) {
      setState(() {
        probes.add(probe);
      });

      // Connect to the probe and attempt to maintain a connection.
      probe.connect();
    }
  }

  /// Callback for when a probe is selected from the list.
  void onProbeSelected() {
    // TODO(Toglefritz): Implement probe selection logic.
  }

  /// Handles changes in the temperature unit setting.
  void onTemperatureUnitChanged() => setState(TemperatureUnitSetting.toggle);

  /// Handles changes in the display mode.
  void onDisplayModeChanged(DisplayMode mode) => setState(() {
    displayMode = mode;
  });

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(microseconds: 250),
    child: probes.isEmpty ? const HomeViewSearching() : HomeView(this),
  );
}
