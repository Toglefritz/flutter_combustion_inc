part of '../about_view.dart';

/// Widget that displays temperature unit setting control.
///
/// Allows users to switch between Celsius and Fahrenheit temperature units using a segmented button control.
class TemperatureUnitSettingCard extends StatelessWidget {
  /// Callback invoked when the temperature unit is changed.
  final VoidCallback onUnitChanged;

  /// Creates an instance of [TemperatureUnitSettingCard].
  const TemperatureUnitSettingCard({
    required this.onUnitChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations localizations = AppLocalizations.of(context)!;

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
                localizations.temperatureUnit,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: SegmentedButton<TemperatureUnit>(
                  segments: [
                    ButtonSegment<TemperatureUnit>(
                      value: TemperatureUnit.celsius,
                      label: Text(localizations.celsius),
                      icon: const Icon(Icons.thermostat),
                    ),
                    ButtonSegment<TemperatureUnit>(
                      value: TemperatureUnit.fahrenheit,
                      label: Text(localizations.fahrenheit),
                      icon: const Icon(Icons.thermostat_outlined),
                    ),
                  ],
                  selected: {TemperatureUnitSetting.currentUnit},
                  onSelectionChanged: (Set<TemperatureUnit> newSelection) {
                    TemperatureUnitSetting.currentUnit = newSelection.first;
                    onUnitChanged();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
