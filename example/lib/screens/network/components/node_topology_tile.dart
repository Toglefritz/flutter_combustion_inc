import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/connection_state.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';

import '../../../l10n/app_localizations.dart';
import '../../../values/inset.dart';

/// A single node's topology entry showing its networked probes.
class NodeTopologyTile extends StatelessWidget {
  /// The MeatNet node to display.
  final MeatNetNode node;

  /// Creates an instance of [NodeTopologyTile].
  const NodeTopologyTile({required this.node, super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String nodeName = node.serialNumberString ?? node.uniqueIdentifier.substring(0, 8);

    return Padding(
      padding: const EdgeInsets.only(top: Inset.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.router, size: 16),
              Padding(
                padding: const EdgeInsets.only(left: Inset.xSmall),
                child: Text(
                  nodeName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: Inset.small),
                child: Text(
                  '(${_connectionStateLabel(l10n, node.connectionState)})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (node.probes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: Inset.large),
              child: Text(
                l10n.noProbesDetected,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...node.probes.values.map(
              (probe) => Padding(
                padding: const EdgeInsets.only(left: Inset.large),
                child: Row(
                  children: [
                    const Icon(Icons.thermostat, size: 14),
                    Padding(
                      padding: const EdgeInsets.only(left: Inset.xSmall),
                      child: Text(probe.name),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _connectionStateLabel(AppLocalizations l10n, DeviceConnectionState state) {
    switch (state) {
      case DeviceConnectionState.disconnected:
        return l10n.connectionStateDisconnected;
      case DeviceConnectionState.connecting:
        return l10n.connectionStateConnecting;
      case DeviceConnectionState.connected:
        return l10n.connectionStateConnected;
      case DeviceConnectionState.failed:
        return l10n.connectionStateFailed;
    }
  }
}
