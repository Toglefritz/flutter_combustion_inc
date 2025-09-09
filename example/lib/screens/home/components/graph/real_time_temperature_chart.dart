part of 'temperature_graph.dart';

/// Widget for displaying real-time temperature data in a line chart.
class RealTimeTemperatureChart extends StatelessWidget {
  /// The display mode determining which temperature data to show.
  final DisplayMode displayMode;

  /// Real-time virtual core temperature data.
  final List<FlSpot> coreTemps;

  /// Real-time virtual surface temperature data.
  final List<FlSpot> surfaceTemps;

  /// Real-time virtual ambient temperature data.
  final List<FlSpot> ambientTemps;

  /// Real-time physical temperature data for all 8 sensors.
  final List<List<FlSpot>> physicalTemps;

  /// Temperature unit symbol for display.
  final String unitSymbol;

  /// Creates a [RealTimeTemperatureChart].
  const RealTimeTemperatureChart({
    required this.displayMode,
    required this.coreTemps,
    required this.surfaceTemps,
    required this.ambientTemps,
    required this.physicalTemps,
    required this.unitSymbol,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<LineChartBarData> lineBarsData = [];

    if (displayMode == DisplayMode.virtualTemperatures) {
      // Virtual temperatures chart
      if (coreTemps.isNotEmpty) {
        lineBarsData.add(
          _createLineChartBarData(coreTemps, Colors.red, 'Core'),
        );
      }
      if (surfaceTemps.isNotEmpty) {
        lineBarsData.add(
          _createLineChartBarData(surfaceTemps, Colors.orange, 'Surface'),
        );
      }
      if (ambientTemps.isNotEmpty) {
        lineBarsData.add(
          _createLineChartBarData(ambientTemps, Colors.blue, 'Ambient'),
        );
      }
    } else {
      // Physical temperatures chart (T1-T8)
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

      for (int i = 0; i < 8; i++) {
        if (physicalTemps[i].isNotEmpty) {
          lineBarsData.add(
            _createLineChartBarData(
              physicalTemps[i],
              colors[i],
              'T${i + 1}',
            ),
          );
        }
      }
    }

    if (lineBarsData.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noDataAvailable,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
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
                '${value.toInt()}s',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          rightTitles: const AxisTitles(

          ),
          topTitles: const AxisTitles(

          ),
        ),
        gridData: const FlGridData(
          horizontalInterval: 10,
          verticalInterval: 10,
        ),
        borderData: FlBorderData(show: true),
        minX: _getMinX(lineBarsData),
        maxX: _getMaxX(lineBarsData),
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

  /// Gets the minimum X value from all line data.
  double _getMinX(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 0;
    return lineBarsData
        .expand((line) => line.spots)
        .map((spot) => spot.x)
        .reduce(min);
  }

  /// Gets the maximum X value from all line data.
  double _getMaxX(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 100;
    return lineBarsData
        .expand((line) => line.spots)
        .map((spot) => spot.x)
        .reduce(max);
  }

  /// Gets the minimum Y value from all line data.
  double _getMinY(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 0;
    return lineBarsData
        .expand((line) => line.spots)
        .map((spot) => spot.y)
        .reduce(min);
  }

  /// Gets the maximum Y value from all line data.
  double _getMaxY(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 100;
    return lineBarsData
        .expand((line) => line.spots)
        .map((spot) => spot.y)
        .reduce(max);
  }
}
