part of '../temperature_radar_chart.dart';

/// Widget wrapper for the radar chart custom painter.
///
/// This widget provides the theme-aware text styles and background color to the custom painter and manages the
/// CustomPaint widget.
class RadarChartPainterWidget extends StatelessWidget {
  /// Data points to display.
  final List<RadarDataPoint> dataPoints;

  /// Temperature unit string.
  final String unit;

  /// Optional color for the radar chart structure (axes, circles, connecting lines).
  /// If not provided, uses default gray colors.
  final Color? radarColor;

  /// Creates a radar chart painter widget.
  const RadarChartPainterWidget({
    required this.dataPoints,
    required this.unit,
    this.radarColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Use a semi-transparent surface color for the pill backgrounds
    final Color pillBackgroundColor =
        isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.9)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.9);

    return CustomPaint(
      painter: RadarPainter(
        dataPoints: dataPoints,
        unit: unit,
        textStyle: Theme.of(context).textTheme.bodySmall!,
        valueStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        labelBackgroundColor: pillBackgroundColor,
        radarColor: radarColor,
      ),
      child: Container(),
    );
  }
}
