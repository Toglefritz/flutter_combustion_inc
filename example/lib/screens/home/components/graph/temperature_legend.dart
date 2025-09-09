part of 'temperature_graph.dart';

/// Widget that displays a legend for the temperature chart lines.
class TemperatureLegend extends StatelessWidget {
  /// The display mode determining which temperature data is shown.
  final DisplayMode displayMode;

  /// Whether historical data is currently being shown.
  final bool showHistoricalData;

  /// Whether there is real-time data available for display.
  final bool hasRealTimeData;

  /// Whether there is historical data available for display.
  final bool hasHistoricalData;

  /// Creates a [TemperatureLegend].
  const TemperatureLegend({
    required this.displayMode,
    required this.showHistoricalData,
    required this.hasRealTimeData,
    required this.hasHistoricalData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show legend if no data is available
    final bool hasData =
        showHistoricalData ? hasHistoricalData : hasRealTimeData;
    if (!hasData) {
      return const SizedBox.shrink();
    }

    final List<LegendItem> legendItems = <LegendItem>[];

    if (displayMode == DisplayMode.virtualTemperatures) {
      // Virtual temperatures legend
      legendItems.addAll(<LegendItem>[
        const LegendItem(color: Colors.red, label: 'Core'),
        const LegendItem(color: Colors.orange, label: 'Surface'),
        const LegendItem(color: Colors.blue, label: 'Ambient'),
      ]);
    } else {
      // Physical temperatures legend (T1-T8)
      const List<Color> colors = <Color>[
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.pink,
      ];

      for (int i = 0; i < 8; i++) {
        legendItems.add(LegendItem(color: colors[i], label: 'T${i + 1}'));
      }
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          legendItems
              .map((LegendItem item) => LegendItemWidget(item: item))
              .toList(),
    );
  }
}
