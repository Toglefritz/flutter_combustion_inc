part of 'temperature_graph.dart';

/// A widget that displays a single legend item with a colored indicator and label.
///
/// This widget renders a [LegendItem] as a horizontal row containing
/// a small colored circle followed by the item's label text.
class LegendItemWidget extends StatelessWidget {
  /// The legend item to display.
  final LegendItem item;

  /// Creates a [LegendItemWidget] for the given [item].
  const LegendItemWidget({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
