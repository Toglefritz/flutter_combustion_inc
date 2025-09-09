part of 'temperature_graph.dart';

/// Represents a single item in the temperature chart legend.
///
/// A [LegendItem] contains the visual information needed to display
/// a legend entry, including the color and label text that corresponds
/// to a specific temperature line in the chart.
class LegendItem {
  /// The color associated with this legend item's chart line.
  final Color color;

  /// The text label for this legend item.
  final String label;

  /// Creates a [LegendItem] with the specified [color] and [label].
  const LegendItem({
    required this.color,
    required this.label,
  });

  @override
  String toString() => 'LegendItem(color: $color, label: $label)';
}
