part of 'temperature_graph.dart';

/// Header widget for the temperature graph with title and controls.
class TemperatureGraphHeader extends StatelessWidget {
  /// Whether historical data is currently being shown.
  final bool showHistoricalData;

  /// Callback for toggling between real-time and historical data modes.
  final VoidCallback onToggleDataMode;

  /// Whether session information is available for the probe.
  final bool hasSessionInfo;

  /// Creates a [TemperatureGraphHeader].
  const TemperatureGraphHeader({
    required this.showHistoricalData,
    required this.onToggleDataMode,
    required this.hasSessionInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.temperatureGraph,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hasSessionInfo)
          TextButton.icon(
            onPressed: onToggleDataMode,
            icon: Icon(showHistoricalData ? Icons.timeline : Icons.history),
            label: Text(showHistoricalData ? 'Live' : 'History'),
          )
        else
          Tooltip(
            message: AppLocalizations.of(context)!.historicalDataUnavailable,
            child: TextButton.icon(
              onPressed: null, // Disabled when no session info
              icon: const Icon(Icons.history),
              label: const Text('History'),
            ),
          ),
      ],
    );
  }
}
