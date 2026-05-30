import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/device.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/routing_config.dart';
import '../../../models/routing_mode.dart';
import '../../../values/inset.dart';
import 'route_device_selector.dart';

/// Controls for selecting routing mode and displaying current route info.
class RouteControlSection extends StatelessWidget {
  /// The probe for which routing is being configured.
  final Probe probe;

  /// Available MeatNet nodes that could serve as relay devices.
  final List<MeatNetNode> nodes;

  /// Current routing configuration.
  final RoutingConfig routingConfig;

  /// The current route information, displayed as a string.
  final Object? currentRoute;

  /// Whether a route query is in progress.
  final bool isQueryingRoute;

  /// Called when the user switches to auto routing mode.
  final VoidCallback onSetAutoRouting;

  /// Called when the user selects a specific device for explicit routing.
  final ValueChanged<Device> onSetExplicitRouting;

  /// Creates an instance of [RouteControlSection].
  const RouteControlSection({
    required this.probe,
    required this.nodes,
    required this.routingConfig,
    required this.currentRoute,
    required this.isQueryingRoute,
    required this.onSetAutoRouting,
    required this.onSetExplicitRouting,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(Inset.medium),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Inset.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.routeControl,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.xSmall),
                child: Text(
                  l10n.selectedProbeLabel(probe.name),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (isQueryingRoute)
                const Padding(
                  padding: EdgeInsets.only(top: Inset.small),
                  child: LinearProgressIndicator(),
                )
              else if (currentRoute != null)
                Padding(
                  padding: const EdgeInsets.only(top: Inset.small),
                  child: Text(
                    l10n.currentRouteLabel(currentRoute.toString()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: SegmentedButton<RoutingMode>(
                  segments: [
                    ButtonSegment<RoutingMode>(
                      value: RoutingMode.auto,
                      label: Text(l10n.routingModeAuto),
                      icon: const Icon(Icons.auto_fix_high),
                    ),
                    ButtonSegment<RoutingMode>(
                      value: RoutingMode.explicit,
                      label: Text(l10n.routingModeExplicit),
                      icon: const Icon(Icons.route),
                    ),
                  ],
                  selected: {routingConfig.mode},
                  onSelectionChanged: (Set<RoutingMode> selection) {
                    if (selection.first == RoutingMode.auto) {
                      onSetAutoRouting();
                    }
                  },
                ),
              ),
              if (nodes.isNotEmpty)
                RouteDeviceSelector(
                  probe: probe,
                  nodes: nodes,
                  routingConfig: routingConfig,
                  onSetExplicitRouting: onSetExplicitRouting,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
