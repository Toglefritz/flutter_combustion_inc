import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/battery_status.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'package:flutter_combustion_inc/models/virtual_temperatures.dart';

import '../../extensions/double_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../services/temperature_unit_setting/temperature_unit_setting.dart';
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
        actions: [
          // Temperature unit selector switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Inset.small),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.celsiusAbbreviation,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SwitchTheme(
                  data: SwitchThemeData(
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    trackColor: WidgetStateProperty.all(Colors.transparent),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    thumbIcon: WidgetStateProperty.all(
                      Icon(
                        Icons.circle,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
                      return Colors.grey.shade600;
                    }),
                    trackOutlineWidth: WidgetStateProperty.all(1.5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Switch(
                    value: TemperatureUnitSetting.currentUnit == TemperatureUnit.fahrenheit,
                    onChanged: (_) => state.onTemperatureUnitChanged(),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.fahrenheitAbbreviation,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
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
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.rotate(
                                    angle: 1.5708, // Rotate the icon by 90 degrees
                                    child: Icon(
                                      status == BatteryStatus.low ? Icons.battery_0_bar_outlined : Icons.battery_full,
                                      color:
                                          status == BatteryStatus.low
                                              ? Colors.red[900]
                                              : Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  Text(
                                    status == BatteryStatus.low
                                        ? AppLocalizations.of(context)!.lowBatteryWarning
                                        : AppLocalizations.of(context)!.batteryStatusOk,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      const Divider(),

                      // Temperature readings
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
                                    temps.core.toUserSelectedTemperatureUnit().toInt().toString(),
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
                                    temps.surface.toUserSelectedTemperatureUnit().toInt().toString(),
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
                                    temps.ambient.toUserSelectedTemperatureUnit().toInt().toString(),
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
