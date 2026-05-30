import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/devices/device.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../../models/routing_config.dart';
import '../rssi/rssi_route.dart';
import 'main_navigation_route.dart';
import 'main_navigation_view.dart';

/// Controller for the [MainNavigationRoute].
///
/// Manages the device registry, probe selection, routing configuration, and
/// navigation state. All tabs receive their data from this controller.
class MainNavigationController extends State<MainNavigationRoute> {
  /// Currently selected tab index.
  int currentTabIndex = 0;

  /// All discovered devices (probes and MeatNet nodes).
  List<Device> devices = [];

  /// The currently selected probe for temperature/graph/prediction display.
  Probe? selectedProbe;

  /// Current routing configuration for command delivery.
  RoutingConfig routingConfig = const RoutingConfig.auto();

  /// Global key for accessing the RSSI route state.
  final GlobalKey<RssiRouteState> rssiKey = GlobalKey<RssiRouteState>();

  /// Filtered list of probes from the device registry.
  List<Probe> get probes => devices.whereType<Probe>().toList();

  /// Filtered list of MeatNet nodes from the device registry.
  List<MeatNetNode> get meatNetNodes => devices.whereType<MeatNetNode>().toList();

  @override
  void initState() {
    super.initState();

    DeviceManager.instance.scanResults.listen(_onDeviceDiscovered);
    unawaited(DeviceManager.instance.initBluetooth());
  }

  /// Handles discovery of a new device.
  ///
  /// Adds the device to the list and auto-connects probes. Nodes are connected
  /// separately when MeatNet is enabled via the Network tab.
  Future<void> _onDeviceDiscovered(Device device) async {
    if (!devices.any((d) => d.uniqueIdentifier == device.uniqueIdentifier)) {
      setState(() {
        devices.add(device);
        if (selectedProbe == null && device is Probe) {
          selectedProbe = device;
        }
      });

      rssiKey.currentState?.updateProbes(probes);

      if (device is Probe) {
        await device.connect();
      }
    }
  }

  /// Handles tab selection changes.
  void onTabChanged(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  /// Handles probe selection changes from any tab.
  void onProbeSelected(Probe? probe) {
    setState(() {
      selectedProbe = probe;
    });
  }

  /// Updates the routing configuration.
  ///
  /// Called from the Network tab when the user switches between auto and
  /// explicit routing modes.
  void onRoutingConfigChanged(RoutingConfig config) {
    setState(() {
      routingConfig = config;
    });
  }

  @override
  Widget build(BuildContext context) => MainNavigationView(this);
}
