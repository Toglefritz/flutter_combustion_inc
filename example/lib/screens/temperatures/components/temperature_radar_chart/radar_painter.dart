part of '../temperature_radar_chart.dart';

/// Custom painter implementation for radar chart.
///
/// Draws the radar chart with concentric circles, axes, data points, labels with pill-shaped backgrounds, and
/// connecting lines between points.
class RadarPainter extends CustomPainter {
  /// Data points to display.
  final List<RadarDataPoint> dataPoints;

  /// Temperature unit string.
  final String unit;

  /// Text style for labels.
  final TextStyle textStyle;

  /// Text style for values.
  final TextStyle valueStyle;

  /// Background color for label pills.
  final Color labelBackgroundColor;

  /// Optional color for the radar chart structure (axes, circles, connecting lines). If not provided, uses default gray
  /// colors.
  final Color? radarColor;

  /// Creates a radar painter.
  RadarPainter({
    required this.dataPoints,
    required this.unit,
    required this.textStyle,
    required this.valueStyle,
    required this.labelBackgroundColor,
    this.radarColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2 - 60;

    // Find max value for scaling
    final double maxValue = dataPoints.map((RadarDataPoint p) => p.value).reduce(math.max);
    final double scaledMax = (maxValue * 1.2).ceilToDouble();

    // Draw concentric circles
    _drawConcentricCircles(canvas, center, radius);

    // Draw axes and data points
    final int pointCount = dataPoints.length;
    for (int i = 0; i < pointCount; i++) {
      final double angle = (2 * math.pi * i / pointCount) - math.pi / 2;
      final Offset axisEnd = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      // Draw axis line
      _drawAxisLine(canvas, center, axisEnd);

      // Draw data point
      final double normalizedValue = dataPoints[i].value / scaledMax;
      final double pointRadius = radius * normalizedValue;
      final Offset pointPosition = Offset(
        center.dx + pointRadius * math.cos(angle),
        center.dy + pointRadius * math.sin(angle),
      );

      _drawDataPoint(canvas, pointPosition, dataPoints[i].color);

      // Draw label with pill background
      final double labelRadius = radius + 30;
      final Offset labelPosition = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      _drawTextWithPillBackground(
        canvas,
        dataPoints[i].label,
        labelPosition,
        textStyle,
        labelBackgroundColor,
      );

      // Draw value with pill background
      final Offset valuePosition = Offset(
        center.dx + (pointRadius + 20) * math.cos(angle),
        center.dy + (pointRadius + 20) * math.sin(angle),
      );

      _drawTextWithPillBackground(
        canvas,
        '${dataPoints[i].value.toStringAsFixed(1)}$unit',
        valuePosition,
        valueStyle.copyWith(color: dataPoints[i].color),
        labelBackgroundColor,
      );
    }

    // Draw connecting lines between points
    if (pointCount > 2) {
      _drawConnectingLines(canvas, center, radius, scaledMax);
    }
  }

  /// Draws concentric circles for the radar chart background.
  void _drawConcentricCircles(Canvas canvas, Offset center, double radius) {
    final Color circleColor = radarColor ?? Colors.grey;
    final Paint circlePaint =
        Paint()
          ..color = circleColor.withValues(alpha: 0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, circlePaint);
    }
  }

  /// Draws an axis line from center to edge.
  void _drawAxisLine(Canvas canvas, Offset start, Offset end) {
    final Color axisColor = radarColor ?? Colors.grey;
    final Paint axisPaint =
        Paint()
          ..color = axisColor.withValues(alpha: 0.3)
          ..strokeWidth = 1;
    canvas.drawLine(start, end, axisPaint);
  }

  /// Draws a data point circle.
  void _drawDataPoint(Canvas canvas, Offset position, Color color) {
    final Paint pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 8, pointPaint);
  }

  /// Draws connecting lines between data points.
  void _drawConnectingLines(
    Canvas canvas,
    Offset center,
    double radius,
    double scaledMax,
  ) {
    final int pointCount = dataPoints.length;
    final Path path = Path();

    for (int i = 0; i < pointCount; i++) {
      final double angle = (2 * math.pi * i / pointCount) - math.pi / 2;
      final double normalizedValue = dataPoints[i].value / scaledMax;
      final double pointRadius = radius * normalizedValue;
      final Offset point = Offset(
        center.dx + pointRadius * math.cos(angle),
        center.dy + pointRadius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Use radar color if provided, otherwise use first data point's color
    final Color baseColor = radarColor ?? dataPoints[0].color;

    // Draw filled area
    final Paint fillPaint =
        Paint()
          ..color = baseColor.withValues(alpha: 0.1)
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw stroke
    final Paint strokePaint =
        Paint()
          ..color = baseColor.withValues(alpha: 0.5)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  /// Draws text centered at a position with a pill-shaped background.
  void _drawTextWithPillBackground(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style,
    Color backgroundColor,
  ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final Offset textOffset = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    // Draw pill-shaped background
    final double horizontalPadding = 8.0;
    final double verticalPadding = 4.0;
    final RRect pillRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        textOffset.dx - horizontalPadding,
        textOffset.dy - verticalPadding,
        textOffset.dx + textPainter.width + horizontalPadding,
        textOffset.dy + textPainter.height + verticalPadding,
      ),
      const Radius.circular(12.0),
    );

    final Paint backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    canvas.drawRRect(pillRect, backgroundPaint);

    // Draw text on top
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => true;
}
