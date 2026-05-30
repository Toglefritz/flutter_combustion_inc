import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/device.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../../../l10n/app_localizations.dart';
import '../../../values/inset.dart';
import 'device_tile.dart';

/// Displays all discovered probes and MeatNet nodes with connection controls.
class DeviceListSection extends StatelessWidget {
  /// Discovered probes.
  final List<Probe> probes;

  /// Discovered MeatNet nodes.
  final List<MeatNetNode> nodes;

  /// The currently selected probe, used to highlight the active selection.
  final Probe? selectedProbe;

  /// Called when the user selects a probe for temperature display.
  final ValueChanged<Probe> onSelectProbe;

  /// Called when the user requests a connection to a device.
  final Future<void> Function(Device) onConnect;

  /// Called when the user requests a disconnection from a device.
  final Future<void> Function(Device) onDisconnect;

  /// Creates an instance of [DeviceListSection].
  const DeviceListSection({
    required this.probes,
    required this.nodes,
    required this.selectedProbe,
    required this.onSelectProbe,
    required this.onConnect,
    required this.onDisconnect,
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
                l10n.devices,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (probes.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: Inset.small),
                  child: Text(
                    l10n.probes,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ...probes.map(
                  (probe) => DeviceTile(
                    device: probe,
                    isSelected: probe.uniqueIdentifier == selectedProbe?.uniqueIdentifier,
                    onSelect: () => onSelectProbe(probe),
                    onConnect: () => unawaited(onConnect(probe)),
                    onDisconnect: () => unawaited(onDisconnect(probe)),
                  ),
                ),
              ],
              if (nodes.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: Inset.medium),
                  child: Text(
                    l10n.meatNetNodes,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                ...nodes.map(
                  (node) => DeviceTile(
                    device: node,
                    isSelected: false,
                    onConnect: () => unawaited(onConnect(node)),
                    onDisconnect: () => unawaited(onDisconnect(node)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
