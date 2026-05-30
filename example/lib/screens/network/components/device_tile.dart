import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/connection_state.dart';
import 'package:flutter_combustion_inc/models/devices/device.dart';
import 'package:flutter_combustion_inc/models/devices/meat_net_node.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../../../l10n/app_localizations.dart';

/// A single device row with connection state, RSSI, and action buttons.
class DeviceTile extends StatelessWidget {
  /// The device to display.
  final Device device;

  /// Whether this device is the currently selected probe.
  final bool isSelected;

  /// Called when the user taps the select button. Only shown for probes.
  final VoidCallback? onSelect;

  /// Called when the user taps the connect button.
  final VoidCallback onConnect;

  /// Called when the user taps the disconnect button.
  final VoidCallback onDisconnect;

  /// Creates an instance of [DeviceTile].
  const DeviceTile({
    required this.device,
    required this.isSelected,
    required this.onConnect,
    required this.onDisconnect,
    this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final IconData icon = device is Probe ? Icons.thermostat : Icons.router;
    final String title =
        device is Probe
            ? (device as Probe).name
            : (device as MeatNetNode).serialNumberString ?? device.uniqueIdentifier;
    final String subtitle =
        '${_connectionStateLabel(l10n, device.connectionState)}  •  ${l10n.rssiValueDbm(device.rssi)}';

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onSelect != null)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: l10n.selectProbeTooltip,
              onPressed: onSelect,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          IconButton(
            icon: Icon(
              device.connectionState == DeviceConnectionState.connected ? Icons.link_off : Icons.link,
            ),
            tooltip: device.connectionState == DeviceConnectionState.connected ? l10n.disconnect : l10n.connect,
            onPressed: device.connectionState == DeviceConnectionState.connected ? onDisconnect : onConnect,
          ),
        ],
      ),
      selected: isSelected,
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
