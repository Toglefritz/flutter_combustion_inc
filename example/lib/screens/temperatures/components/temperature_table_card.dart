/// Temperature table card component.
///
/// This library provides a card widget that displays temperature readings in a tabular format, with the ability to
/// switch between virtual and physical temperature displays.
library;

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../values/inset.dart';
import '../models/temperatures_table_mode.dart';

/// A card widget that displays temperature readings in a table format.
///
/// This widget shows either virtual temperatures (core, surface, ambient) or physical sensor temperatures (T1-T8)
/// based on the selected mode. Users can toggle between modes using segmented buttons at the top of the card.
class TemperatureTableCard extends StatefulWidget {
  /// The probe whose temperature data should be displayed.
  final Probe probe;

  /// Creates a [TemperatureTableCard] instance.
  const TemperatureTableCard({
    required this.probe,
    super.key,
  });

  @override
  State<TemperatureTableCard> createState() => _TemperatureTableCardState();
}

/// State for [TemperatureTableCard].
class _TemperatureTableCardState extends State<TemperatureTableCard> {
  /// Current display mode for the temperature table.
  TemperaturesTableMode _tableMode = TemperaturesTableMode.virtual;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isDark ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      colorScheme.surfaceContainerHigh,
                      colorScheme.surfaceContainer,
                    ]
                    : [
                      colorScheme.surface,
                      colorScheme.surfaceContainerLow,
                    ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Inset.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode selector
              SegmentedButton<TemperaturesTableMode>(
                segments: [
                  ButtonSegment<TemperaturesTableMode>(
                    value: TemperaturesTableMode.virtual,
                    label: Text(localizations.virtualTemperatures),
                    icon: const Icon(Icons.thermostat),
                  ),
                  ButtonSegment<TemperaturesTableMode>(
                    value: TemperaturesTableMode.physical,
                    label: Text(localizations.physicalTemperatures),
                    icon: const Icon(Icons.sensors),
                  ),
                ],
                selected: {_tableMode},
                onSelectionChanged: (Set<TemperaturesTableMode> newSelection) {
                  setState(() {
                    _tableMode = newSelection.first;
                  });
                },
              ),

              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child:
                    _tableMode == TemperaturesTableMode.virtual
                        ? _VirtualTemperaturesTable(probe: widget.probe)
                        : _PhysicalTemperaturesTable(probe: widget.probe),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that displays virtual temperature readings in a table.
class _VirtualTemperaturesTable extends StatelessWidget {
  /// The probe whose virtual temperature data should be displayed.
  final Probe probe;

  /// Creates a [_VirtualTemperaturesTable] instance.
  const _VirtualTemperaturesTable({
    required this.probe,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return StreamBuilder(
      stream: probe.virtualTemperatureStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final double core = (snapshot.data.core as num).toDouble();
        final double surface = (snapshot.data.surface as num).toDouble();
        final double ambient = (snapshot.data.ambient as num).toDouble();

        return Table(
          border: TableBorder.all(
            color: theme.dividerColor,
            width: 1,
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: [
            _buildTableRow(
              context,
              'Core',
              core,
              isHeader: false,
            ),
            _buildTableRow(
              context,
              'Surface',
              surface,
              isHeader: false,
            ),
            _buildTableRow(
              context,
              'Ambient',
              ambient,
              isHeader: false,
            ),
          ],
        );
      },
    );
  }

  /// Builds a table row with a label and temperature value.
  TableRow _buildTableRow(
    BuildContext context,
    String label,
    double temperature, {
    required bool isHeader,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? textStyle =
        isHeader ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : theme.textTheme.bodyLarge;

    final double displayTemp = _convertTemperature(temperature);
    final String unit = _getUnitSymbol();

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(Inset.small),
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Inset.small),
          child: Text(
            '${displayTemp.toStringAsFixed(1)}$unit',
            style: textStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Converts temperature from Celsius to the user's preferred unit.
  double _convertTemperature(double celsius) {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? celsius : (celsius * 9 / 5) + 32;
  }

  /// Gets the temperature unit symbol.
  String _getUnitSymbol() {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';
  }
}

/// Widget that displays physical sensor temperature readings in a table.
class _PhysicalTemperaturesTable extends StatelessWidget {
  /// The probe whose physical temperature data should be displayed.
  final Probe probe;

  /// Creates a [_PhysicalTemperaturesTable] instance.
  const _PhysicalTemperaturesTable({
    required this.probe,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return StreamBuilder(
      stream: probe.currentTemperaturesStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<double> temperatures = <double>[
          (snapshot.data.t1 as num).toDouble(),
          (snapshot.data.t2 as num).toDouble(),
          (snapshot.data.t3 as num).toDouble(),
          (snapshot.data.t4 as num).toDouble(),
          (snapshot.data.t5 as num).toDouble(),
          (snapshot.data.t6 as num).toDouble(),
          (snapshot.data.t7 as num).toDouble(),
          (snapshot.data.t8 as num).toDouble(),
        ];

        return Table(
          border: TableBorder.all(
            color: theme.dividerColor,
            width: 1,
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: List<TableRow>.generate(
            8,
            (int index) => _buildTableRow(
              context,
              'T${index + 1}',
              temperatures[index],
              isHeader: false,
            ),
          ),
        );
      },
    );
  }

  /// Builds a table row with a sensor label and temperature value.
  TableRow _buildTableRow(
    BuildContext context,
    String label,
    double temperature, {
    required bool isHeader,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? textStyle =
        isHeader ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : theme.textTheme.bodyLarge;

    final double displayTemp = _convertTemperature(temperature);
    final String unit = _getUnitSymbol();

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(Inset.small),
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Inset.small),
          child: Text(
            '${displayTemp.toStringAsFixed(1)}$unit',
            style: textStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Converts temperature from Celsius to the user's preferred unit.
  double _convertTemperature(double celsius) {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? celsius : (celsius * 9 / 5) + 32;
  }

  /// Gets the temperature unit symbol.
  String _getUnitSymbol() {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';
  }
}
