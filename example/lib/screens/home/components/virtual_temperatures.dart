import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'package:flutter_combustion_inc/models/virtual_temperatures.dart';

import '../../../extensions/double_extensions.dart';
import '../../../l10n/app_localizations.dart';

/// A widget displaying the "virtual temperatures" of a probe.
///
/// Combustion Inc. temperature probes include eight thermocouples arranged along the the probe's length. The probe
/// firmware analyzes the readings from these thermocouples to calculate three virtual temperatures:
///
/// - Core temperature: The temperature at the center of the probe, representing the hottest point.
/// - Surface temperature: The temperature at the outer surface of the probe.
/// - Ambient temperature: The temperature of the surrounding environment, typically the air temperature.
///
/// These virtual temperatures are used to provide a representation of the food temperature in a way that is more easily
/// understood by the user. This widget reports these virtual temperatures in the user's selected temperature unit. It
/// listens to the `virtualTemperatureStream` of the provided [Probe] instance and updates the UI accordingly.
class VirtualTemperaturesDisplay extends StatelessWidget {
  /// Creates an instance of [VirtualTemperaturesDisplay].
  const VirtualTemperaturesDisplay({
    required this.probe, super.key,
  });

  /// The probe instance from which to read the virtual temperatures.
  final Probe probe;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VirtualTemperatures>(
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
    );
  }
}
