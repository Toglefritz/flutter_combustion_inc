part of '../temperature_radar_chart.dart';

/// Widget that displays physical temperature sensors on a radar chart.
///
/// Shows all 8 physical temperature sensors (T1-T8) from the probe's current temperatures stream.
class PhysicalTemperatureRadar extends StatelessWidget {
  /// The probe to display temperatures for.
  final Probe probe;

  /// Optional color for the radar chart structure (axes, circles, connecting lines).
  /// If not provided, uses default gray colors.
  final Color? radarColor;

  /// Creates an instance of [PhysicalTemperatureRadar].
  const PhysicalTemperatureRadar({
    required this.probe,
    this.radarColor,
    super.key,
  });

  /// Converts temperature from Celsius to the user's preferred unit.
  double _convertTemperature(double celsius) {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? celsius : (celsius * 9 / 5) + 32;
  }

  /// Gets the temperature unit symbol.
  String _getUnitSymbol() {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';
  }

  /// Gets a color for a physical sensor based on its index.
  Color _getColorForSensor(int index) {
    final List<Color> colors = [
      Colors.red,
      Colors.deepOrange,
      Colors.orange,
      Colors.amber,
      Colors.yellow,
      Colors.lime,
      Colors.lightGreen,
      Colors.green,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProbeTemperatures>(
      stream: probe.currentTemperaturesStream,
      builder: (BuildContext context, AsyncSnapshot<ProbeTemperatures> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final ProbeTemperatures temps = snapshot.data!;
        final List<double> temperatures = [
          temps.t1,
          temps.t2,
          temps.t3,
          temps.t4,
          temps.t5,
          temps.t6,
          temps.t7,
          temps.t8,
        ];

        final List<RadarDataPoint> dataPoints = List.generate(8, (int index) {
          return RadarDataPoint(
            label: AppLocalizations.of(context)!.temperatureTn(index + 1),
            value: _convertTemperature(temperatures[index]),
            color: _getColorForSensor(index),
          );
        });

        return RadarChartPainterWidget(
          dataPoints: dataPoints,
          unit: _getUnitSymbol(),
          radarColor: radarColor,
        );
      },
    );
  }
}
