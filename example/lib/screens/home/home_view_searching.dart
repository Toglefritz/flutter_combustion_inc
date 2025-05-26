import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
import '../components/loaders/ripple_loader.dart';
import 'home_route.dart';

/// View for the [HomeRoute]. The view is dumb, and purely declarative. References values on the controller and widget.
///
/// This view is displayed while the app is searching for probes, but before any have been discovered.
class HomeViewSearching extends StatelessWidget {
  /// Creates an instance of [HomeViewSearching].
  const HomeViewSearching({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(Inset.xSmall),
              child: RippleLoader(
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.searchingForProbes,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
