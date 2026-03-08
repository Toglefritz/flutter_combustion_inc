part of '../about_view.dart';

/// Widget that displays detailed probe information.
///
/// Shows probe name, serial number, MAC address, ID, battery status, and signal strength in a card with gradient
/// background.
class ProbeDetailsCard extends StatelessWidget {
  /// The probe to display details for.
  final Probe probe;

  /// Creates an instance of [ProbeDetailsCard].
  const ProbeDetailsCard({
    required this.probe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(Inset.medium),
      elevation: isDark ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      colorScheme.surfaceContainerHigh,
                      colorScheme.surfaceContainer,
                    ]
                    : [
                      colorScheme.surface,
                      colorScheme.surfaceContainerLow,
                    ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Inset.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.probeDetails,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: InfoRow(
                  label: AppLocalizations.of(context)!.name,
                  value: probe.name,
                ),
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.serialNumber,
                value: probe.serialNumber,
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.macAddress,
                value: probe.macAddress,
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.probeId,
                value: probe.id.toString(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.small),
                child: BatteryLevel(probe: probe),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.small),
                child: SignalStrength(probe: probe),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
