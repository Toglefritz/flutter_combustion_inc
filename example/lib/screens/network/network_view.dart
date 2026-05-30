import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../../l10n/app_localizations.dart';
import '../components/empty_state_widget.dart';
import 'components/device_list_section.dart';
import 'components/route_control_section.dart';
import 'components/topology_section.dart';
import 'network_controller.dart';

/// View for the Network tab.
///
/// Displays all discovered devices, the mesh network topology, and routing
/// controls. Organized into three sections:
/// 1. Device list (probes and nodes with connection controls)
/// 2. Topology (which nodes can reach which probes)
/// 3. Route control (auto vs. explicit routing for the selected probe)
class NetworkView extends StatelessWidget {
  /// Reference to the controller.
  final NetworkController state;

  /// Creates an instance of [NetworkView].
  const NetworkView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Probe> probes = state.widget.devices.whereType<Probe>().toList();
    final List<MeatNetNode> nodes = state.widget.devices.whereType<MeatNetNode>().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.network,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshRoute,
            onPressed: state.refreshRoute,
          ),
        ],
      ),
      body:
          state.widget.devices.isEmpty
              ? const EmptyStateWidget()
              : SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DeviceListSection(
                          probes: probes,
                          nodes: nodes,
                          selectedProbe: state.widget.selectedProbe,
                          onSelectProbe: state.selectProbe,
                          onConnect: state.connectToDevice,
                          onDisconnect: state.disconnectFromDevice,
                        ),
                        if (nodes.isNotEmpty) TopologySection(nodes: nodes),
                        if (state.widget.selectedProbe != null)
                          RouteControlSection(
                            probe: state.widget.selectedProbe!,
                            nodes: nodes,
                            routingConfig: state.widget.routingConfig,
                            currentRoute: state.currentRoute,
                            isQueryingRoute: state.isQueryingRoute,
                            onSetAutoRouting: state.setAutoRouting,
                            onSetExplicitRouting: state.setExplicitRouting,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
