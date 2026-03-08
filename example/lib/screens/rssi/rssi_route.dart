import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import 'rssi_controller.dart';

/// Route for the RSSI tracking screen.
///
/// This screen is used for testing and evaluating Bluetooth RSSI values in different scenarios (open-air, inside oven,
/// inside grill, etc.).
class RssiRoute extends StatefulWidget {
  /// Creates an instance of [RssiRoute].
  const RssiRoute({super.key});

  @override
  RssiRouteState createState() => RssiController();
}

/// Public state class for [RssiRoute] to allow external access.
abstract class RssiRouteState extends State<RssiRoute> {
  /// Updates the list of available probes.
  void updateProbes(List<Probe> probes);
}
