part of '../temperature_radar_chart.dart';

/// Widget that displays virtual temperature sensors on a radar chart.
///
/// Shows core, surface, and ambient temperatures from the probe's virtual temperature stream.
class VirtualTemperatureRadar extends StatelessWidget {
  /// The probe to display temperatures for.
  final Probe probe;

  /// Creates an instance of [VirtualTemperatureRadar].
  const VirtualTemperatureRadar({
    required this.probe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VirtualTemperatures>(
      stream: probe.virtualTemperatureStream,
      builder: (BuildContext context, AsyncSnapshot<VirtualTemperatures> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final VirtualTemperatures temps = snapshot.data!;
        final List<RadarDataPoint> dataPoints = [
          RadarDataPoint(
            label: AppLocalizations.of(context)!.coreTemperature,
            value: _convertTemperature(temps.core),
            color: Colors.red,
          ),
          RadarDataPoint(
            label: AppLocalizations.of(context)!.surfaceTemperature,
            value: _convertTemperature(temps.surface),
            color: Colors.orange,
          ),
          RadarDataPoint(
            label: AppLocalizations.of(context)!.ambientTemperature,
            value: _convertTemperature(temps.ambient),
            color: Colors.blue,
          ),
        ];

        return RadarChartPainterWidget(
          dataPoints: dataPoints,
          unit: _getUnitSymbol(),
        );
      },
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
