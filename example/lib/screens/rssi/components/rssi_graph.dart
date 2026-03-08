import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../rssi_controller.dart';

/// A widget that displays RSSI data in a line chart format.
///
/// This widget shows the historical RSSI values over time, allowing users to visualize signal strength variations
/// during testing scenarios.
class RssiGraph extends StatelessWidget {
  /// Historical RSSI data points to display.
  final List<RssiDataPoint> rssiHistory;

  /// Creates an [RssiGraph] widget.
  const RssiGraph({
    required this.rssiHistory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (rssiHistory.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noDataAvailable,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Convert RSSI data points to FlSpot for charting
    final List<FlSpot> spots = rssiHistory.map((point) => FlSpot(point.timestamp, point.rssi.toDouble())).toList();

    // Calculate min/max for Y axis
    final List<int> rssiValues = rssiHistory.map((p) => p.rssi).toList();
    final int minRssi = rssiValues.reduce((a, b) => a < b ? a : b);
    final int maxRssi = rssiValues.reduce((a, b) => a > b ? a : b);

    // Add padding to Y axis range
    final double yMin = (minRssi - 10).toDouble();
    final double yMax = (maxRssi + 10).toDouble();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: true,
            horizontalInterval: 10,
            verticalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                AppLocalizations.of(context)!.timeSeconds,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                AppLocalizations.of(context)!.rssiDbm,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          minX: rssiHistory.first.timestamp,
          maxX: rssiHistory.last.timestamp,
          minY: yMin,
          maxY: yMax,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(),
              belowBarData: BarAreaData(
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toInt()} dBm\n${spot.x.toStringAsFixed(1)}s',
                    TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
