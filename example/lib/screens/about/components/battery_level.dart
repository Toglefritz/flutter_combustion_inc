part of '../about_view.dart';

/// Widget that displays the battery status for a probe.
///
/// Uses a StreamBuilder to show real-time battery status updates.
class BatteryLevel extends StatelessWidget {
  /// The probe to display battery status for.
  final Probe probe;

  /// Creates an instance of [BatteryLevel].
  const BatteryLevel({
    required this.probe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BatteryStatus>(
      stream: probe.batteryStatusStream,
      builder: (BuildContext context, AsyncSnapshot<BatteryStatus> snapshot) {
        final String status = snapshot.hasData ? snapshot.data!.name : AppLocalizations.of(context)!.unknown;
        return InfoRow(
          label: AppLocalizations.of(context)!.batteryStatus,
          value: status,
        );
      },
    );
  }
}
