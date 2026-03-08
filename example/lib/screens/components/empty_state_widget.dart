import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';

/// Widget displayed when no probes are available.
///
/// Shows a centered message with an icon indicating that the app is searching for nearby Bluetooth probes. This widget
/// is reusable across different screens that need to display an empty state.
class EmptyStateWidget extends StatelessWidget {
  /// Creates an instance of [EmptyStateWidget].
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Inset.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Inset.large),
              child: Text(
                AppLocalizations.of(context)!.searchingForProbes,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Inset.small),
              child: Text(
                AppLocalizations.of(context)!.makeProbeVisible,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
