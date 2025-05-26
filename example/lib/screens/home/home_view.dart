import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import 'home_controller.dart';
import 'home_route.dart';

/// View for the [HomeRoute]. The view is dumb, and purely declarative. References values on the controller and widget.
///
/// This view is displayed when at least one probe has been discovered.
class HomeView extends StatelessWidget {
  /// A reference to the controller for the [HomeRoute].
  final HomeController state;

  /// Creates an instance of [HomeView].
  const HomeView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.thermometers(state.probes.length),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          children: [
            ...List.generate(state.probes.length, (int index) {
              final Probe probe = state.probes[index];

              return Card(
                child: ListTile(
                  title: Text(probe.name),
                  onTap: state.onProbeSelected,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
