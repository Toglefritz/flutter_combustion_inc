import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'home_route.dart';
import 'home_view.dart';

/// A controller for the [HomeRoute] that manages the state and owns all business logic.
class HomeController extends State<HomeRoute> {
  /// A list of Combustion Inc. temperature probes discovered during scanning.
  List<Probe> probes = [];

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
    }
  }

  /// Callback for when a probe is selected from the list.
  void onProbeSelected() {
    // TODO(Toglefritz): Implement probe selection logic.
  }

  @override
  Widget build(BuildContext context) => HomeView(this);
}
