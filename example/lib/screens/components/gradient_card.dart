import 'package:flutter/material.dart';

/// A card widget with subtle gradient background for a softer appearance.
///
/// This card uses elevation and gradients instead of borders to create depth and visual hierarchy while maintaining a
/// light, modern feel.
class GradientCard extends StatelessWidget {
  /// The widget to display inside the card.
  final Widget child;

  /// Optional margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Optional padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Optional elevation for the card shadow.
  final double? elevation;

  /// Creates a gradient card.
  const GradientCard({
    required this.child,
    this.margin,
    this.padding,
    this.elevation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: margin,
      elevation: elevation ?? (isDark ? 4 : 2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      colorScheme.surfaceContainerHigh,
                      colorScheme.surfaceContainer,
                    ]
                    : [
                      colorScheme.surface,
                      colorScheme.surfaceContainerLow,
                    ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
