part of '../about_view.dart';

/// Widget that displays the signal strength (RSSI) for a probe.
///
/// Uses a FutureBuilder to show the RSSI value.
class SignalStrength extends StatelessWidget {
  /// The probe to display signal strength for.
  final Probe probe;

  /// Creates an instance of [SignalStrength].
  const SignalStrength({
    required this.probe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: probe.rssi,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final String rssi = snapshot.hasData ? '${snapshot.data} dBm' : AppLocalizations.of(context)!.loading;
        return InfoRow(
          label: AppLocalizations.of(context)!.signalStrength,
          value: rssi,
        );
      },
    );
  }
}
