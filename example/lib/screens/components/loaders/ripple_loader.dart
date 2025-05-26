import 'package:flutter/widgets.dart';

/// A Flutter widget that displays a ripple loader animation.
class RippleLoader extends StatefulWidget {
  /// Creates a [RippleLoader] widget.
  const RippleLoader({
    super.key,
    this.color,
    this.size = 50.0,
    this.borderWidth = 6.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1800),
    this.controller,
  }) : assert(
         !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
         'You should specify either a itemBuilder or a color',
       );

  /// The color of the ripple loader.
  final Color? color;

  /// The size of the ripple loader. The default is 50.0.
  final double size;

  /// The width of the border of the ripple loader. The default is 6.0.
  final double borderWidth;

  /// The item builder for the ripple loader. If this is provided, the color will be ignored.
  final IndexedWidgetBuilder? itemBuilder;

  /// The duration of the ripple animation. The default is 1800 milliseconds. This determines the speed of the ripple
  /// effect.
  final Duration duration;

  /// The animation controller for the ripple loader. If this is provided, the loader will use the provided controller
  /// instead of creating a new one. This allows for more control over the animation, such as starting, stopping, or
  /// repeating the animation as needed.
  final AnimationController? controller;

  @override
  State<RippleLoader> createState() => RippleLoaderState();
}

/// The state for the [RippleLoader] widget.
class RippleLoaderState extends State<RippleLoader> with SingleTickerProviderStateMixin {
  /// The animation controller for the ripple loader.
  late AnimationController _controller;

  /// The first animation for the ripple loader.
  late Animation<double> _animation1;

  /// The second animation for the ripple loader.
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    _controller =
        (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
          ..addListener(() {
            if (mounted) {
              setState(() {});
            }
          })
          ..repeat();
    _animation1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75),
      ),
    );
    _animation2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 1.0),
      ),
    );
  }

  /// Builds the item widget for the ripple loader.
  Widget _itemBuilder(int index) {
    return SizedBox.fromSize(
      size: Size.square(widget.size),
      child:
          widget.itemBuilder != null
              ? widget.itemBuilder!(context, index)
              : DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color!,
                    width: widget.borderWidth,
                  ),
                ),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: 1.0 - _animation1.value,
            child: Transform.scale(
              scale: _animation1.value,
              child: _itemBuilder(0),
            ),
          ),
          Opacity(
            opacity: 1.0 - _animation2.value,
            child: Transform.scale(
              scale: _animation2.value,
              child: _itemBuilder(1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
