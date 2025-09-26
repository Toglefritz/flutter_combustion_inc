import 'package:flutter/material.dart';

/// A button widget for the temperature input keypad.
///
/// This widget represents a single button in the keypad interface,
/// handling both numeric input and special characters like backspace.
class KeypadButtonWidget extends StatelessWidget {
  /// The value this button represents (digit, decimal point, or backspace).
  final String value;

  /// Whether the button should be enabled for user interaction.
  final bool enabled;

  /// Callback function called when the button is pressed.
  final void Function(String value) onPressed;

  /// The flex value for layout within a Row.
  final int flex;

  /// Creates a keypad button widget.
  ///
  /// The button displays the [value] and calls [onPressed] when tapped.
  /// The [flex] parameter controls the button's width relative to other buttons.
  const KeypadButtonWidget({
    required this.value,
    required this.enabled,
    required this.onPressed,
    this.flex = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed: enabled ? () => onPressed(value) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
