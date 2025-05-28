import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/battery_status.dart';
import '../../../l10n/app_localizations.dart';

/// A widget that displays the battery status of a probe, either "low" or "ok".
class BatteryStatusIndicator extends StatelessWidget {
  /// Creates an instance of [BatteryStatusIndicator].
  const BatteryStatusIndicator({
    required this.status,
    super.key,
  });

  /// The current battery status of the probe.
  final BatteryStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: 1.5708, // Rotate the icon by 90 degrees
          child: Icon(
            status == BatteryStatus.low ? Icons.battery_0_bar_outlined : Icons.battery_full,
            color: status == BatteryStatus.low ? Colors.red[900] : Theme.of(context).primaryColorDark,
          ),
        ),
        Text(
          status == BatteryStatus.low
              ? AppLocalizations.of(context)!.lowBatteryWarning
              : AppLocalizations.of(context)!.batteryStatusOk,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
