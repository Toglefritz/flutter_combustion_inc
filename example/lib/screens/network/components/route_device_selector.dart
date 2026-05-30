// Radio.groupValue and Radio.onChanged were deprecated in Flutter 3.32 in favor
// of RadioGroup. Suppressed until the RadioGroup API stabilizes.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/device.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/routing_config.dart';
import '../../../values/inset.dart';

/// Radio selector for choosing which device to route commands through.
class RouteDeviceSelector extends StatelessWidget {
  /// The probe that commands are being routed to.
  final Probe probe;

  /// Available MeatNet nodes that could relay commands.
  final List<MeatNetNode> nodes;

  /// Current routing configuration, used to highlight the active selection.
  final RoutingConfig routingConfig;

  /// Called when the user selects a device for explicit routing.
  final ValueChanged<Device> onSetExplicitRouting;

  /// Creates an instance of [RouteDeviceSelector].
  const RouteDeviceSelector({
    required this.probe,
    required this.nodes,
    required this.routingConfig,
    required this.onSetExplicitRouting,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? selectedId = routingConfig.isExplicit ? routingConfig.explicitDevice?.uniqueIdentifier : null;

    return Padding(
      padding: const EdgeInsets.only(top: Inset.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.routeThrough,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          ListTile(
            leading: Radio<String>(
              value: probe.uniqueIdentifier,
              groupValue: selectedId,
              onChanged: (_) => onSetExplicitRouting(probe),
            ),
            title: Text(l10n.directProbeBle),
            subtitle: Text(l10n.rssiValueDbm(probe.rssi)),
            dense: true,
            onTap: () => onSetExplicitRouting(probe),
          ),
          ...nodes.map(
            (node) => ListTile(
              leading: Radio<String>(
                value: node.uniqueIdentifier,
                groupValue: selectedId,
                onChanged: (_) => onSetExplicitRouting(node),
              ),
              title: Text(
                node.serialNumberString ?? node.uniqueIdentifier.substring(0, 8),
              ),
              subtitle: Text(
                '${l10n.rssiValueDbm(node.rssi)}  •  '
                '${l10n.nodeProbeCount(node.probes.length)}',
              ),
              dense: true,
              onTap: () => onSetExplicitRouting(node),
            ),
          ),
        ],
      ),
    );
  }
}
