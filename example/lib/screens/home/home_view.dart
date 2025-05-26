import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'package:flutter_combustion_inc/models/virtual_temperatures.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
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
                margin: const EdgeInsets.all(Inset.medium),
                child: Padding(
                  padding: const EdgeInsets.all(Inset.medium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        probe.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      StreamBuilder(
                        stream: probe.virtualTemperatureStream,
                        builder: (BuildContext context, AsyncSnapshot<VirtualTemperatures> snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Loading...');
                          }

                          // Extract the virtual temperatures from the snapshot
                          final VirtualTemperatures temps = snapshot.data!;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    temps.core.toInt().toString(),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.coreTemperature,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    temps.surface.toInt().toString(),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.surfaceTemperature,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    temps.ambient.toInt().toString(),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.ambientTemperature,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
