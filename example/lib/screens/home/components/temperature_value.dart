import 'package:flutter/material.dart';

import '../../../extensions/double_extensions.dart';

/// Displays a temperature reading and its label.
///
/// This widget is used to display a single temperature value along with a label indicating what the temperature
/// represents (e.g., core, surface, T1, etc.). This widget automatically converts the temperature value to the user's
/// selected temperature unit (Celsius or Fahrenheit) using the `toUserSelectedTemperatureUnit` extension method. The
/// original temperature value should be provided in Celsius.
class TemperatureValue extends StatelessWidget {
  /// Creates an instance of [TemperatureValue].
  const TemperatureValue({
    required this.temperature,
    required this.label,
    super.key,
  });

  /// The temperature reading to display. This value should be provided in Celsius.
  final double temperature;

  /// A label for the temperature reading.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          temperature.toUserSelectedTemperatureUnit().toInt().toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
        ),
      ],
    );
  }
}
