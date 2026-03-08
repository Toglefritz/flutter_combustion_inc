part of '../about_view.dart';

/// Widget that displays the list of plugin features.
///
/// Shows a card with checkmark icons and feature descriptions.
class FeaturesCard extends StatelessWidget {
  /// Creates an instance of [FeaturesCard].
  const FeaturesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final List<String> features = [
      AppLocalizations.of(context)!.featureRealtimeMonitoring,
      AppLocalizations.of(context)!.featureVirtualSensors,
      AppLocalizations.of(context)!.featurePhysicalSensors,
      AppLocalizations.of(context)!.featureHistoricalGraphs,
      AppLocalizations.of(context)!.featurePredictions,
      AppLocalizations.of(context)!.featureBatteryMonitoring,
      AppLocalizations.of(context)!.featureBluetooth,
      AppLocalizations.of(context)!.featureCrossPlatform,
    ];

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
                AppLocalizations.of(context)!.features,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features.map((String feature) => FeatureItem(feature: feature)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
