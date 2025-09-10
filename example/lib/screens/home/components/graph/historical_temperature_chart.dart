part of 'temperature_graph.dart';

/// Widget for displaying historical temperature data in a line chart with zoom and pan support.
class HistoricalTemperatureChart extends StatefulWidget {
  /// The display mode determining which temperature data to show.
  final DisplayMode displayMode;

  /// Historical temperature log data.
  final List<ProbeLogDataPoint> historicalData;

  /// Temperature unit symbol for display.
  final String unitSymbol;

  /// Function to convert temperature values based on current unit setting.
  final double Function(double) convertTemperature;

  /// Creates a [HistoricalTemperatureChart].
  const HistoricalTemperatureChart({
    required this.displayMode,
    required this.historicalData,
    required this.unitSymbol,
    required this.convertTemperature,
    super.key,
  });

  @override
  State<HistoricalTemperatureChart> createState() => _HistoricalTemperatureChartState();
}

/// The state for the [HistoricalTemperatureChart] widget.
class _HistoricalTemperatureChartState extends State<HistoricalTemperatureChart> {
  /// Current zoom level for the chart (1.0 = no zoom, >1.0 = zoomed in).
  double _zoomLevel = 1.0;

  /// Current pan offset for the X-axis.
  double _panOffset = 0.0;

  /// Maximum zoom level allowed.
  static const double _maxZoom = 20.0;

  /// Minimum zoom level allowed.
  static const double _minZoom = 0.1;

  /// Default timespan to show in data points (e.g., last 100 points).
  static const int _defaultTimespanPoints = 100;

  /// Whether to use default timespan or show all data.
  final bool _useDefaultTimespan = true;

  /// Stored scale for gesture handling.
  double _lastScale = 1.0;

  /// Stored focal point for gesture handling.
  Offset _lastFocalPoint = Offset.zero;

  /// Creates a LineChartBarData for the given data points.
  LineChartBarData _createLineChartBarData(
    List<FlSpot> spots,
    Color color,
    String label,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(),
    );
  }

  /// Zooms in by increasing the zoom level.
  ///
  /// When zooming in via button (not gesture), maintain focus on recent data
  /// by adjusting pan offset to keep the most recent data visible.
  void _zoomIn() {
    setState(() {
      final double oldZoom = _zoomLevel;
      _zoomLevel = (_zoomLevel * 1.5).clamp(_minZoom, _maxZoom);

      // If we're using default timespan and haven't manually panned,
      // adjust pan to keep recent data in view when zooming in
      if (_useDefaultTimespan && widget.historicalData.length > 100 && _panOffset == 0.0) {
        // Calculate how much the visible range has shrunk
        final double zoomRatio = _zoomLevel / oldZoom;

        if (zoomRatio > 1.0) {
          // Zooming in - shift pan to keep right side (recent data) more visible
          final double fullMaxX = _getMaxX(_buildLineBarsData());
          final double displayMaxX = fullMaxX;
          final double displayMinX = max(0, fullMaxX - _calculateDefaultTimespan());
          final double displayRangeX = displayMaxX - displayMinX;

          // Shift pan offset to bias towards recent data
          _panOffset = displayRangeX * 0.1; // Small shift towards recent data
        }
      }
    });
  }

  /// Zooms out by decreasing the zoom level.
  void _zoomOut() {
    setState(() {
      final double newZoomLevel = (_zoomLevel / 1.5).clamp(_minZoom, _maxZoom);

      // Prevent zooming out beyond what makes sense for the data
      const double minUsefulZoom = 0.5; // Allow some over-zoom for better UX
      final double effectiveMinZoom = max(_minZoom, minUsefulZoom);

      _zoomLevel = newZoomLevel.clamp(effectiveMinZoom, _maxZoom);

      // When zooming out, gradually reset pan offset to center view
      if (_zoomLevel <= 1.2) {
        _panOffset = 0.0;
      }
    });
  }

  /// Resets zoom and pan to show the appropriate data range.
  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = 0.0;
    });
  }

  /// Calculates appropriate X-axis interval based on visible range.
  double _calculateXAxisInterval(double visibleRange) {
    if (visibleRange <= 20) return 2;
    if (visibleRange <= 50) return 5;
    if (visibleRange <= 100) return 10;
    if (visibleRange <= 200) return 20;
    if (visibleRange <= 500) return 50;
    if (visibleRange <= 1000) return 100;

    return 200;
  }

  /// Calculates appropriate Y-axis interval based on temperature range.
  double _calculateYAxisInterval(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 10;

    final double minY = _getMinY(lineBarsData);
    final double maxY = _getMaxY(lineBarsData);
    final double range = maxY - minY;

    if (range <= 20) return 2;
    if (range <= 50) return 5;
    if (range <= 100) return 10;

    return 20;
  }

  /// Gets the minimum X value from all line data.
  double _getMinX(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 0;

    return lineBarsData.expand((line) => line.spots).map((spot) => spot.x).reduce(min);
  }

  /// Gets the maximum X value from all line data.
  double _getMaxX(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 100;

    return lineBarsData.expand((line) => line.spots).map((spot) => spot.x).reduce(max);
  }

  /// Gets the minimum Y value from all line data.
  double _getMinY(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 0;

    return lineBarsData.expand((line) => line.spots).map((spot) => spot.y).reduce(min);
  }

  /// Gets the maximum Y value from all line data.
  double _getMaxY(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) return 100;

    return lineBarsData.expand((line) => line.spots).map((spot) => spot.y).reduce(max);
  }

  /// Calculates a reasonable default timespan based on data size.
  ///
  /// For very large datasets, shows a smaller recent window for better readability.
  /// For smaller datasets, shows more or all data.
  int _calculateDefaultTimespan() {
    final int dataSize = widget.historicalData.length;

    if (dataSize <= 50) return dataSize; // Show all for very small datasets
    if (dataSize <= 100) return dataSize; // Show all for small datasets
    if (dataSize <= 200) return 100; // Show last 100 points for medium datasets

    return _defaultTimespanPoints; // Show default 100 points for large datasets
  }

  /// Builds the line chart data for the current display mode.
  ///
  /// This is a helper method to avoid duplicating the line building logic
  /// when we need to access the data boundaries in zoom calculations.
  List<LineChartBarData> _buildLineBarsData() {
    final List<LineChartBarData> lineBarsData = [];

    if (widget.displayMode == DisplayMode.virtualTemperatures) {
      // For historical data, we'll use the physical sensors to approximate virtual temps
      final List<FlSpot> coreSpots = [];
      final List<FlSpot> surfaceSpots = [];
      final List<FlSpot> ambientSpots = [];

      for (int i = 0; i < widget.historicalData.length; i++) {
        final ProbeLogDataPoint point = widget.historicalData[i];
        final double x = point.sequence.toDouble();

        // Approximate core as average of inner sensors
        final double core = (point.temperatures.t3 + point.temperatures.t4) / 2;
        // Approximate surface as average of middle sensors
        final double surface = (point.temperatures.t2 + point.temperatures.t5) / 2;
        // Approximate ambient as outermost sensor
        final double ambient = point.temperatures.t8;

        coreSpots.add(FlSpot(x, widget.convertTemperature(core)));
        surfaceSpots.add(FlSpot(x, widget.convertTemperature(surface)));
        ambientSpots.add(FlSpot(x, widget.convertTemperature(ambient)));
      }

      // Only add lines if they have data points
      if (coreSpots.isNotEmpty) {
        lineBarsData.add(_createLineChartBarData(coreSpots, Colors.red, 'Core'));
      }
      if (surfaceSpots.isNotEmpty) {
        lineBarsData.add(_createLineChartBarData(surfaceSpots, Colors.orange, 'Surface'));
      }
      if (ambientSpots.isNotEmpty) {
        lineBarsData.add(_createLineChartBarData(ambientSpots, Colors.blue, 'Ambient'));
      }
    } else {
      // Physical temperatures from historical data
      final List<List<FlSpot>> physicalSpots = List.generate(8, (_) => <FlSpot>[]);
      const List<Color> colors = [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.pink,
      ];

      for (int i = 0; i < widget.historicalData.length; i++) {
        final ProbeLogDataPoint point = widget.historicalData[i];
        final double x = point.sequence.toDouble();
        final List<double> temps = [
          point.temperatures.t1,
          point.temperatures.t2,
          point.temperatures.t3,
          point.temperatures.t4,
          point.temperatures.t5,
          point.temperatures.t6,
          point.temperatures.t7,
          point.temperatures.t8,
        ];

        for (int j = 0; j < 8; j++) {
          physicalSpots[j].add(FlSpot(x, widget.convertTemperature(temps[j])));
        }
      }

      for (int i = 0; i < 8; i++) {
        if (physicalSpots[i].isNotEmpty) {
          lineBarsData.add(_createLineChartBarData(physicalSpots[i], colors[i], 'T${i + 1}'));
        }
      }
    }

    return lineBarsData;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.historicalData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Inset.medium),
              child: Text(AppLocalizations.of(context)!.loadingHistoricalData),
            ),
          ],
        ),
      );
    }

    final List<LineChartBarData> lineBarsData = _buildLineBarsData();

    // Calculate data boundaries
    final double fullMinX = _getMinX(lineBarsData);
    final double fullMaxX = _getMaxX(lineBarsData);
    final double fullRangeX = fullMaxX - fullMinX;

    // Apply default timespan if enabled and data is large
    double displayMinX = fullMinX;
    double displayMaxX = fullMaxX;
    double displayRangeX = fullRangeX;

    if (_useDefaultTimespan && widget.historicalData.length > 100) {
      // Show the most recent data points by default using calculated timespan
      final int timespanPoints = _calculateDefaultTimespan();
      displayMaxX = fullMaxX;
      displayMinX = max(fullMinX, fullMaxX - timespanPoints);
      displayRangeX = displayMaxX - displayMinX;
    }

    // Calculate visible range based on zoom and pan
    final double visibleRangeX = displayRangeX / _zoomLevel;

    // When zooming, bias towards the most recent data (right side) unless user has panned
    double centerX;
    if (_panOffset == 0.0) {
      // No user panning - bias towards most recent data
      // For default timespan, center closer to the right (most recent)
      // For full data, center in the middle
      if (_useDefaultTimespan && widget.historicalData.length > 100) {
        // Bias 75% towards the right (most recent data)
        centerX = displayMinX + (displayRangeX * 0.75);
      } else {
        // Center normally for full data view
        centerX = displayMinX + (displayRangeX / 2);
      }
    } else {
      // User has panned - respect their pan offset
      centerX = displayMinX + (displayRangeX / 2) + _panOffset;
    }

    // Calculate view bounds with proper validation to prevent invalid clamp ranges
    double viewMinX = centerX - visibleRangeX / 2;
    double viewMaxX = centerX + visibleRangeX / 2;

    // Ensure we don't zoom out beyond the available data range
    if (visibleRangeX >= fullRangeX) {
      // When fully zoomed out or beyond, show the full range
      viewMinX = fullMinX;
      viewMaxX = fullMaxX;
    } else {
      // Apply proper bounds checking for clamp operations
      final double minBound = fullMinX;
      final double maxBoundForMinX = fullMaxX - visibleRangeX;
      final double minBoundForMaxX = fullMinX + visibleRangeX;
      final double maxBound = fullMaxX;

      // Only clamp if the bounds are valid (min <= max)
      if (minBound <= maxBoundForMinX) {
        viewMinX = viewMinX.clamp(minBound, maxBoundForMinX);
      } else {
        viewMinX = fullMinX;
      }

      if (minBoundForMaxX <= maxBound) {
        viewMaxX = viewMaxX.clamp(minBoundForMaxX, maxBound);
      } else {
        viewMaxX = fullMaxX;
      }
    }

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onDoubleTap: _resetZoom,
            // Handle both zoom and pan gestures using scale recognizer
            onScaleStart: (ScaleStartDetails details) {
              _lastScale = 1.0;
              _lastFocalPoint = details.focalPoint;
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                final bool isZooming = (details.scale - _lastScale).abs() > 0.01;
                final bool isPanning = (details.focalPoint - _lastFocalPoint).distance > 2.0;

                // Handle zoom with improved sensitivity
                if (isZooming) {
                  final double zoomDelta = details.scale / _lastScale;
                  final double newZoomLevel = (_zoomLevel * zoomDelta).clamp(_minZoom, _maxZoom);

                  // Additional validation to prevent problematic zoom levels
                  if (newZoomLevel > 0 && newZoomLevel.isFinite) {
                    _zoomLevel = newZoomLevel;
                  }
                  _lastScale = details.scale;
                }

                // Handle pan (works for both single finger drag and two-finger pan)
                if (isPanning) {
                  final double panDelta = (details.focalPoint.dx - _lastFocalPoint.dx) * (visibleRangeX / 400);
                  final double maxPanOffset = max(0, (fullRangeX - visibleRangeX) / 2);
                  _panOffset = (_panOffset - panDelta).clamp(-maxPanOffset, maxPanOffset);
                  _lastFocalPoint = details.focalPoint;
                }
              });
            },
            child: LineChart(
              LineChartData(
                lineBarsData: lineBarsData,
                clipData: const FlClipData.all(),
                // Disable built-in touch interactions to allow custom gestures
                lineTouchData: const LineTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget:
                          (double value, TitleMeta meta) => Text(
                            '${value.toInt()}${widget.unitSymbol}',
                            style: const TextStyle(fontSize: 10),
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _calculateXAxisInterval(visibleRangeX),
                      getTitlesWidget:
                          (double value, TitleMeta meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                gridData: FlGridData(
                  horizontalInterval: _calculateYAxisInterval(lineBarsData),
                  verticalInterval: _calculateXAxisInterval(visibleRangeX),
                ),
                borderData: FlBorderData(show: true),
                minX: viewMinX,
                maxX: viewMaxX,
                minY: _getMinY(lineBarsData) - 5,
                maxY: _getMaxY(lineBarsData) + 5,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Inset.small),
          child: Column(
            children: [
              // Timespan and zoom controls
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _zoomLevel > _minZoom ? _zoomOut : null,
                        icon: const Icon(Icons.zoom_out),
                        tooltip: AppLocalizations.of(context)!.zoomOutTooltip,
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          '${(_zoomLevel * 100).toInt()}%',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: _zoomLevel < _maxZoom ? _zoomIn : null,
                        icon: const Icon(Icons.zoom_in),
                        tooltip: AppLocalizations.of(context)!.zoomInTooltip,
                      ),
                      IconButton(
                        onPressed: _resetZoom,
                        icon: const Icon(Icons.fit_screen),
                        tooltip: AppLocalizations.of(context)!.resetViewTooltip,
                      ),
                    ],
                  ),
                ],
              ),
              TemperatureLegend(
                displayMode: widget.displayMode,
                showHistoricalData: true,
                hasRealTimeData: false,
                hasHistoricalData: widget.historicalData.isNotEmpty,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
