import 'package:flutter/widgets.dart';

/// Widget that represents a single ripple item in the ripple loader animation.
///
/// This widget displays either a custom widget provided by the itemBuilder or a default circular border decoration with
/// the specified color.
class RippleLoaderItem extends StatelessWidget {
  /// The size of the ripple item.
  final double size;

  /// The color of the ripple border.
  final Color? color;

  /// The width of the border.
  final double borderWidth;

  /// Optional custom builder for the ripple item.
  final IndexedWidgetBuilder? itemBuilder;

  /// The index of this item in the ripple sequence.
  final int index;

  /// Creates a [RippleLoaderItem] widget.
  const RippleLoaderItem({
    required this.size,
    required this.index,
    this.color,
    this.borderWidth = 6.0,
    this.itemBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(size),
      child:
          itemBuilder != null
              ? itemBuilder!(context, index)
              : DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color!,
                    width: borderWidth,
                  ),
                ),
              ),
    );
  }
}
