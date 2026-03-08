import 'package:flutter/material.dart';

import '../../../values/inset.dart';

/// Widget that displays a single temperature statistic column.
///
/// Shows a label and a temperature value with unit in a vertical layout.
class TemperatureStatColumn extends StatelessWidget {
  /// The label text for this statistic.
  final String label;

  /// The temperature value to display.
  final double value;

  /// The temperature unit symbol (e.g., '°C' or '°F').
  final String unit;

  /// The color to use for the temperature value.
  final Color color;

  /// Creates an instance of [TemperatureStatColumn].
  const TemperatureStatColumn({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Inset.xSmall),
          child: Text(
            '${value.toStringAsFixed(1)}$unit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
