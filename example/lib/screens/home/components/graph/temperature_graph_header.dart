part of 'temperature_graph.dart';

/// Header widget for the temperature graph with title and controls.
class TemperatureGraphHeader extends StatelessWidget {
  /// Whether historical data is currently being shown.
  final bool showHistoricalData;

  /// Callback for toggling between real-time and historical data modes.
  final VoidCallback onToggleDataMode;

  /// Creates a [TemperatureGraphHeader].
  const TemperatureGraphHeader({
    required this.showHistoricalData,
    required this.onToggleDataMode,
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
        TextButton.icon(
          onPressed: onToggleDataMode,
          icon: Icon(showHistoricalData ? Icons.timeline : Icons.history),
          label: Text(showHistoricalData ? 'Live' : 'History'),
        ),
      ],
    );
  }
}
