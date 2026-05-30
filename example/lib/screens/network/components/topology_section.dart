import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';

import '../../../l10n/app_localizations.dart';
import '../../../values/inset.dart';
import 'node_topology_tile.dart';

/// Shows the mesh network topology: which probes each node can reach.
class TopologySection extends StatelessWidget {
  /// The MeatNet nodes to display topology for.
  final List<MeatNetNode> nodes;

  /// Creates an instance of [TopologySection].
  const TopologySection({required this.nodes, super.key});

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
                l10n.meshTopology,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.small),
                child: Text(
                  l10n.meshTopologyDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ...nodes.map((node) => NodeTopologyTile(node: node)),
            ],
          ),
        ),
      ),
    );
  }
}
