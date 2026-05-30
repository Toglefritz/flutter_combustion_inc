import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/device.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../../models/routing_config.dart';
import 'network_controller.dart';

/// Route for the network topology and device management screen.
///
/// Displays all discovered Combustion devices (probes and MeatNet nodes),
/// shows the mesh network topology, and provides controls for routing mode
/// selection and explicit device connections.
class NetworkRoute extends StatefulWidget {
  /// All discovered devices.
  final List<Device> devices;

  /// The currently selected probe.
  final Probe? selectedProbe;

  /// Current routing configuration.
  final RoutingConfig routingConfig;

  /// Callback when probe selection changes.
  final ValueChanged<Probe?> onProbeSelected;

  /// Callback when routing configuration changes.
  final ValueChanged<RoutingConfig> onRoutingConfigChanged;

  /// Creates an instance of [NetworkRoute].
  const NetworkRoute({
    required this.devices,
    required this.selectedProbe,
    required this.routingConfig,
    required this.onProbeSelected,
    required this.onRoutingConfigChanged,
    super.key,
  });

  @override
  State<NetworkRoute> createState() => NetworkController();
}
