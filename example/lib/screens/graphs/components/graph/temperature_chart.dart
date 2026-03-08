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

  /// Whether historical data is currently being loaded.
  final bool isLoadingHistoricalData;

  /// Error message when historical data loading fails.
  final String? historicalDataError;

  /// Callback to retry loading historical data.
  final VoidCallback? onRetryLoadHistoricalData;

  /// Whether session information is available for the probe.
  final bool hasSessionInfo;

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
    required this.isLoadingHistoricalData,
    required this.historicalDataError,
    required this.onRetryLoadHistoricalData,
    required this.hasSessionInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (showHistoricalData) {
      // Show loading, error, or historical data based on state
      if (isLoadingHistoricalData) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: Text(
                  AppLocalizations.of(context)!.loadingTemperatureLogs,
                ),
              ),
            ],
          ),
        );
      } else if (historicalDataError != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.medium),
                child: Text(
                  historicalDataError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              if (onRetryLoadHistoricalData != null)
                Padding(
                  padding: const EdgeInsets.only(top: Inset.medium),
                  child: ElevatedButton(
                    onPressed: onRetryLoadHistoricalData,
                    child: Text(AppLocalizations.of(context)!.retryButton),
                  ),
                ),
            ],
          ),
        );
      } else {
        return HistoricalTemperatureChart(
          displayMode: displayMode,
          historicalData: historicalData,
          unitSymbol: unitSymbol,
          convertTemperature: convertTemperature,
        );
      }
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
