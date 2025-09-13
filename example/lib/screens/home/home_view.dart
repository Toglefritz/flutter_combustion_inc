import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/battery_status.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
import 'components/battery_status_indicator.dart';
import 'components/graph/temperature_graph.dart';
import 'components/graph_display_switch.dart';
import 'components/physical_temperatures_display.dart';
import 'components/temperature_unit_switch.dart';
import 'components/virtual_temperatures_display.dart';
import 'home_controller.dart';
import 'home_route.dart';
import 'models/display_mode.dart';

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
        actions: [
          // Temperature unit selector switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Inset.small),
            child: TemperatureUnitSwitch(
              onChanged: (_) => state.onTemperatureUnitChanged(),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // A list of chips used to select a display mode
              Wrap(
                children: List.generate(DisplayMode.values.length, (int index) {
                  final DisplayMode mode = DisplayMode.values[index];

                  return Padding(
                    padding: const EdgeInsets.all(Inset.small),
                    child: ChoiceChip(
                      label: Text(
                        DisplayMode.label(context: context, displayMode: mode),
                      ),
                      selected: state.displayMode == mode,
                      onSelected: (bool selected) {
                        if (selected) {
                          state.onDisplayModeChanged(mode);
                        }
                      },
                    ),
                  );
                }),
              ),

              // Graph display selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Inset.small),
                child: GraphDisplaySwitch(
                  probe: state.probes.first, // TODO(Toglefritz): Select probe to display
                  onChanged: (bool active) => state.showGraphs = active,
                  enabled: state.showGraphs,
                ),
              ),

              // Display a card for each discovered probe
              ...List.generate(state.probes.length, (int index) {
                final Probe probe = state.probes[index];

                return StreamBuilder(
                  stream: probe.statusStaleStream,
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return AnimatedOpacity(
                      duration: const Duration(microseconds: 250),
                      opacity: snapshot.hasData && snapshot.data! ? 0.3 : 1.0,
                      child: Card(
                        margin: const EdgeInsets.all(Inset.medium),
                        child: Padding(
                          padding: const EdgeInsets.all(Inset.medium),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Device information
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Probe name
                                  Text(
                                    '${AppLocalizations.of(context)!.probe}: ${probe.name}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  if (state.displayMode == DisplayMode.debugInfo)
                                    Row(
                                      children: [
                                        // Battery indicator
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: Inset.xSmall,
                                          ),
                                          child: StreamBuilder(
                                            stream: probe.batteryStatusStream,
                                            builder: (
                                              BuildContext context,
                                              AsyncSnapshot<BatteryStatus> snapshot,
                                            ) {
                                              // If battery information is not available, return an empty widget
                                              if (!snapshot.hasData) {
                                                return const SizedBox.shrink();
                                              }

                                              // Otherwise, extract the battery status from the snapshot
                                              final BatteryStatus status = snapshot.data!;
                                              return BatteryStatusIndicator(
                                                status: status,
                                              );
                                            },
                                          ),
                                        ),

                                        // RSSI
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: Inset.xSmall,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FutureBuilder(
                                                future: probe.rssi,
                                                builder: (
                                                  BuildContext context,
                                                  AsyncSnapshot<int> snapshot,
                                                ) {
                                                  // If RSSI information is not available, return a loading indicator
                                                  if (!snapshot.hasData) {
                                                    return const CircularProgressIndicator();
                                                  }

                                                  // Otherwise, extract the RSSI value from the snapshot
                                                  final int rssi = snapshot.data!;
                                                  return Text(
                                                    rssi.toString(),
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  );
                                                },
                                              ),

                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.rssi,
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.labelSmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),

                              // Divider for visual separation
                              const Divider(
                                height: Inset.medium,
                              ),

                              // Animate the change in display mode
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 250),
                                // Virtual temperatures display
                                firstChild: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Inset.small,
                                  ),
                                  child: VirtualTemperaturesDisplay(probe: probe),
                                ),
                                // Physical temperatures display
                                secondChild: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Inset.small,
                                  ),
                                  child: PhysicalTemperaturesDisplay(
                                    probe: probe,
                                  ),
                                ),
                                crossFadeState:
                                    state.displayMode == DisplayMode.virtualTemperatures
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                              ),

                              // Animate the change in graph display
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 250),
                                firstChild: const SizedBox.shrink(),
                                secondChild: Padding(
                                  padding: const EdgeInsets.only(
                                    top: Inset.medium,
                                  ),
                                  child: TemperatureGraph(
                                    probe: probe,
                                    displayMode: state.displayMode,
                                  ),
                                ),
                                crossFadeState: state.showGraphs ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
