import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/battery_status.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
import 'components/battery_status_indicator.dart';
import 'components/temperature_unit_switch.dart';
import 'components/virtual_temperatures.dart';
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Device information
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Probe name
                          Text(
                            '${AppLocalizations.of(context)!.probe}: ${probe.name}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Low battery warning
                          StreamBuilder(
                            stream: probe.batteryStatusStream,
                            builder: (BuildContext context, AsyncSnapshot<BatteryStatus> snapshot) {
                              // If battery information is not available, return an empty widget
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              // Otherwise, extract the battery status from the snapshot
                              final BatteryStatus status = snapshot.data!;
                              return BatteryStatusIndicator(status: status);
                            },
                          ),
                        ],
                      ),

                      // Divider for visual separation
                      const Divider(
                        height: Inset.medium,
                      ),

                      // Temperature readings
                      VirtualTemperaturesDisplay(probe: probe),
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
