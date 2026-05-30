import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/devices/device.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';
import 'package:flutter_combustion_inc/models/devices/route_info.dart';

import '../../models/routing_config.dart';
import 'network_route.dart';
import 'network_view.dart';

/// Controller for the [NetworkRoute].
///
/// Manages device connections, route queries, and routing mode changes.
/// Provides the Network tab with the data and actions it needs to display
/// the mesh topology and control routing behavior.
class NetworkController extends State<NetworkRoute> {
  /// The current route info for the selected probe, if available.
  RouteInfo? currentRoute;

  /// Whether a route query is in progress.
  bool isQueryingRoute = false;

  @override
  void didUpdateWidget(NetworkRoute oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedProbe?.uniqueIdentifier != widget.selectedProbe?.uniqueIdentifier) {
      unawaited(_refreshRoute());
    }
  }

  /// Connects to a specific device (probe or node).
  Future<void> connectToDevice(Device device) async {
    if (device is Probe) {
      await device.connect();
    } else if (device is MeatNetNode) {
      // Nodes are connected via the probe's connect mechanism in the SDK.
      // For now, we trigger connection through the DeviceManager.
      // The SDK's ConnectionManager handles node auto-connect when MeatNet
      // is enabled.
      debugPrint('Connecting to node: ${device.uniqueIdentifier}');
    }
  }

  /// Disconnects from a specific device.
  Future<void> disconnectFromDevice(Device device) async {
    if (device is Probe) {
      await device.disconnect();
    }
  }

  /// Switches to auto routing mode.
  void setAutoRouting() {
    widget.onRoutingConfigChanged(const RoutingConfig.auto());
    unawaited(_refreshRoute());
  }

  /// Switches to explicit routing through the specified device.
  void setExplicitRouting(Device device) {
    widget.onRoutingConfigChanged(RoutingConfig.explicit(device));
  }

  /// Selects a probe for temperature display across all tabs.
  void selectProbe(Probe probe) {
    widget.onProbeSelected(probe);
    unawaited(_refreshRoute());
  }

  /// Queries the native SDK for the current best route to the selected probe.
  Future<void> _refreshRoute() async {
    final Probe? probe = widget.selectedProbe;
    if (probe == null) {
      setState(() {
        currentRoute = null;
      });
      return;
    }

    setState(() {
      isQueryingRoute = true;
    });

    try {
      final RouteInfo route = await DeviceManager.instance.getRouteToProbe(probe);
      if (mounted) {
        setState(() {
          currentRoute = route;
          isQueryingRoute = false;
        });
      }
    } on Exception catch (e) {
      debugPrint('Failed to query route: $e');
      if (mounted) {
        setState(() {
          currentRoute = RouteInfo.unreachable(probe);
          isQueryingRoute = false;
        });
      }
    }
  }

  /// Refreshes route information (exposed for pull-to-refresh or manual refresh).
  Future<void> refreshRoute() => _refreshRoute();

  @override
  Widget build(BuildContext context) => NetworkView(this);
}
