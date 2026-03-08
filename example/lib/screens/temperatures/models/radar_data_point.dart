part of '../components/temperature_radar_chart.dart';

/// Data point for radar chart.
///
/// Represents a single temperature reading with its label, value, and color.
class RadarDataPoint {
  /// Label for this data point.
  final String label;

  /// Temperature value.
  final double value;

  /// Color for this data point.
  final Color color;

  /// Creates a radar data point.
  const RadarDataPoint({
    required this.label,
    required this.value,
    required this.color,
  });
}
