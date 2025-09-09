part of 'temperature_graph.dart';

/// Chart widget that displays temperature data based on the current mode and data availability.
class TemperatureChart extends StatelessWidget {
  /// Whether to show historical data or real-time data.
  final bool showHistoricalData;

  /// The display mode determining which temperature data to show.
  final DisplayMode displayMode;

  /// Real-time core temperature data.
  final List<FlSpot> coreTemps;

  /// Real-time surface temperature data.
  final List<FlSpot> surfaceTemps;

  /// Real-time ambient temperature data.
  final List<FlSpot> ambientTemps;

  /// Real-time physical temperature data for all 8 sensors.
  final List<List<FlSpot>> physicalTemps;

  /// Historical temperature log data.
  final List<ProbeLogDataPoint> historicalData;

  /// Temperature unit symbol for display.
  final String unitSymbol;

  /// Function to convert temperature values based on current unit setting.
  final double Function(double) convertTemperature;

  /// Creates a [TemperatureChart].
  const TemperatureChart({
    required this.showHistoricalData,
    required this.displayMode,
    required this.coreTemps,
    required this.surfaceTemps,
    required this.ambientTemps,
    required this.physicalTemps,
    required this.historicalData,
    required this.unitSymbol,
    required this.convertTemperature,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (showHistoricalData) {
      return HistoricalTemperatureChart(
        displayMode: displayMode,
        historicalData: historicalData,
        unitSymbol: unitSymbol,
        convertTemperature: convertTemperature,
      );
    } else {
      return RealTimeTemperatureChart(
        displayMode: displayMode,
        coreTemps: coreTemps,
        surfaceTemps: surfaceTemps,
        ambientTemps: ambientTemps,
        physicalTemps: physicalTemps,
        unitSymbol: unitSymbol,
      );
    }
  }
}
