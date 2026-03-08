part of '../about_view.dart';

/// Widget that displays plugin information.
///
/// Shows the plugin name, version, and platform in a card with gradient background.
class PluginInfoCard extends StatelessWidget {
  /// Creates an instance of [PluginInfoCard].
  const PluginInfoCard({super.key});

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
                AppLocalizations.of(context)!.pluginInformation,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: InfoRow(
                  label: AppLocalizations.of(context)!.name,
                  value: 'flutter_combustion_inc',
                ),
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.version,
                value: '0.1.0',
              ),
              InfoRow(
                label: AppLocalizations.of(context)!.platform,
                value: Theme.of(context).platform.name,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
