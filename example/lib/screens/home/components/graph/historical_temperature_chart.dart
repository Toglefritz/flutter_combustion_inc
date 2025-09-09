part of 'temperature_graph.dart';

/// Widget for displaying historical temperature data in a line chart.
class HistoricalTemperatureChart extends StatelessWidget {
  /// The display mode determining which temperature data to show.
  final DisplayMode displayMode;

  /// Historical temperature log data.
  final List<ProbeLogDataPoint> historicalData;

  /// Temperature unit symbol for display.
  final String unitSymbol;

  /// Function to convert temperature values based on current unit setting.
  final double Function(double) convertTemperature;

  /// Creates a [HistoricalTemperatureChart].
  const HistoricalTemperatureChart({
    required this.displayMode,
    required this.historicalData,
    required this.unitSymbol,
    required this.convertTemperature,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (historicalData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Inset.medium),
              child: Text(AppLocalizations.of(context)!.loadingHistoricalData),
            ),
          ],
        ),
      );
    }

    final List<LineChartBarData> lineBarsData = [];

    if (displayMode == DisplayMode.virtualTemperatures) {
      // For historical data, we'll use the physical sensors to approximate virtual temps
      // This is a simplified approach - in a real app you might want to calculate virtual temps properly
      final List<FlSpot> coreSpots = [];
      final List<FlSpot> surfaceSpots = [];
      final List<FlSpot> ambientSpots = [];

      for (int i = 0; i < historicalData.length; i++) {
        final ProbeLogDataPoint point = historicalData[i];
        final double x = i.toDouble();

        // Approximate core as average of inner sensors
        final double core = (point.temperatures.t3 + point.temperatures.t4) / 2;
        // Approximate surface as average of middle sensors
        final double surface = (point.temperatures.t2 + point.temperatures.t5) / 2;
        // Approximate ambient as outermost sensor
        final double ambient = point.temperatures.t1;

        coreSpots.add(FlSpot(x, convertTemperature(core)));
        surfaceSpots.add(FlSpot(x, convertTemperature(surface)));
        ambientSpots.add(FlSpot(x, convertTemperature(ambient)));
      }

      lineBarsData
        ..add(_createLineChartBarData(coreSpots, Colors.red, 'Core'))
        ..add(_createLineChartBarData(surfaceSpots, Colors.orange, 'Surface'))
        ..add(_createLineChartBarData(ambientSpots, Colors.blue, 'Ambient'));
    } else {
      // Physical temperatures from historical data
      final List<List<FlSpot>> physicalSpots = List.generate(
        8,
        (_) => <FlSpot>[],
      );
      const List<Color> colors = [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.pink,
      ];

      for (int i = 0; i < historicalData.length; i++) {
        final ProbeLogDataPoint point = historicalData[i];
        final double x = i.toDouble();
        final List<double> temps = [
          point.temperatures.t1,
          point.temperatures.t2,
          point.temperatures.t3,
          point.temperatures.t4,
          point.temperatures.t5,
          point.temperatures.t6,
          point.temperatures.t7,
          point.temperatures.t8,
        ];

        for (int j = 0; j < 8; j++) {
          physicalSpots[j].add(FlSpot(x, convertTemperature(temps[j])));
        }
      }

      for (int i = 0; i < 8; i++) {
        lineBarsData.add(
          _createLineChartBarData(physicalSpots[i], colors[i], 'T${i + 1}'),
        );
      }
    }

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget:
                  (value, meta) => Text(
                    '${value.toInt()}$unitSymbol',
                    style: const TextStyle(fontSize: 10),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget:
                  (value, meta) => Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        gridData: const FlGridData(
          horizontalInterval: 10,
          verticalInterval: 10,
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: historicalData.length.toDouble(),
        minY: _getMinY(lineBarsData) - 5,
        maxY: _getMaxY(lineBarsData) + 5,
      ),
    );
  }

  /// Creates a LineChartBarData for the given data points.
  LineChartBarData _createLineChartBarData(
    List<FlSpot> spots,
    Color color,
    String label,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(),
    );
  }

  /// Gets the minimum Y value from all line data.
  double _getMinY(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 0;

    return lineBarsData.expand((line) => line.spots).map((spot) => spot.y).reduce(min);
  }

  /// Gets the maximum Y value from all line data.
  double _getMaxY(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 100;

    return lineBarsData.expand((line) => line.spots).map((spot) => spot.y).reduce(max);
  }
}
