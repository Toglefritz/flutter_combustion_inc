import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'package:flutter_combustion_inc/models/probe_temperatures.dart';

import '../../../l10n/app_localizations.dart';
import 'temperature_value.dart';

/// A widget displaying all temperature readings from a probe.
///
/// Combustion Inc. temperature probes include eight thermocouples arranged along the the probe's length. This widget
/// is used to display all physical temperature readings from the probe.
class PhysicalTemperaturesDisplay extends StatelessWidget {
  /// Creates an instance of [PhysicalTemperaturesDisplay].
  const PhysicalTemperaturesDisplay({
    required this.probe,
    super.key,
  });

  /// The probe instance from which to read the physical temperatures.
  final Probe probe;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProbeTemperatures>(
      stream: probe.currentTemperaturesStream,
      builder: (BuildContext context, AsyncSnapshot<ProbeTemperatures> snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        // Extract the virtual temperatures from the snapshot
        final ProbeTemperatures temps = snapshot.data!;

        // Arrange the temperatures in two rows of four temperatures each.
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Temperatures T1–T4
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (int index) {
                final double temperature = switch (index) {
                  0 => temps.t1,
                  1 => temps.t2,
                  2 => temps.t3,
                  3 => temps.t4,
                  _ => throw ArgumentError('Invalid index: $index'),
                };

                final String label = switch (index) {
                  0 => AppLocalizations.of(context)!.temperatureTn(1),
                  1 => AppLocalizations.of(context)!.temperatureTn(2),
                  2 => AppLocalizations.of(context)!.temperatureTn(3),
                  3 => AppLocalizations.of(context)!.temperatureTn(4),
                  _ => throw ArgumentError('Invalid index: $index'),
                };

                return TemperatureValue(
                  temperature: temperature,
                  label: label,
                );
              }),
            ),

            // Temperatures T5–T8
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (int index) {
                final double temperature = switch (index) {
                  0 => temps.t5,
                  1 => temps.t6,
                  2 => temps.t7,
                  3 => temps.t8,
                  _ => throw ArgumentError('Invalid index: $index'),
                };

                final String label = switch (index) {
                  0 => AppLocalizations.of(context)!.temperatureTn(5),
                  1 => AppLocalizations.of(context)!.temperatureTn(6),
                  2 => AppLocalizations.of(context)!.temperatureTn(7),
                  3 => AppLocalizations.of(context)!.temperatureTn(8),
                  _ => throw ArgumentError('Invalid index: $index'),
                };

                return TemperatureValue(
                  temperature: temperature,
                  label: label,
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
