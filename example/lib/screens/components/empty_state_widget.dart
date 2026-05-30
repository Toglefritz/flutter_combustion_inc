import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';

/// Widget displayed when no devices have been discovered yet.
///
/// Shows a centered Bluetooth scanning icon with a message indicating that the
/// app is actively searching for nearby Combustion devices. Used across all tabs
/// to provide a consistent empty state appearance.
class EmptyStateWidget extends StatelessWidget {
  /// Creates an instance of [EmptyStateWidget].
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Inset.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            Padding(
              padding: const EdgeInsets.only(top: Inset.large),
              child: Text(
                l10n.scanningForDevices,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Inset.small),
              child: Text(
                l10n.makeProbeVisible,
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
