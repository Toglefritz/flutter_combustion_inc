library;

import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import 'package:flutter_combustion_inc/models/probe_log_data_point.dart';
import 'package:flutter_combustion_inc/models/probe_temperature_log.dart';
import 'package:flutter_combustion_inc/models/probe_temperatures.dart';
import 'package:flutter_combustion_inc/models/virtual_temperatures.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../../../values/inset.dart';
import '../../models/display_mode.dart';

// Parts
part 'historical_temperature_chart.dart';
part 'legend_item.dart';
part 'real_time_temperature_chart.dart';
part 'temperature_chart.dart';
part 'temperature_graph_header.dart';
part 'temperature_legend.dart';
part 'legend_item_widget.dart';

/// A widget that displays temperature data from a Combustion Inc. probe in a line chart format.
///
/// This widget can display both real-time temperature streams and historical temperature logs,
/// with support for virtual temperatures (core, surface, ambient) and physical sensor readings (T1-T8).
class TemperatureGraph extends StatefulWidget {
  /// The probe to display temperature data for.
  final Probe probe;

  /// The display mode determining which temperature data to show.
  final DisplayMode displayMode;

  /// Creates a [TemperatureGraph] widget.
  const TemperatureGraph({
    required this.probe,
    required this.displayMode,
    super.key,
  });

  @override
  State<TemperatureGraph> createState() => _TemperatureGraphState();
}

/// The state for the [TemperatureGraph] widget.
class _TemperatureGraphState extends State<TemperatureGraph> {
  /// Maximum number of data points to keep in memory for real-time display.
  static const int maxDataPoints = 100;

  /// Real-time virtual core temperature data points.
  final List<FlSpot> _coreTemps = [];

  /// Real-time surface core temperature data points.
  final List<FlSpot> _surfaceTemps = [];

  /// Real-time ambient core temperature data points.
  final List<FlSpot> _ambientTemps = [];

  /// Real-time temperature data points for physical sensors (T1-T8).
  final List<List<FlSpot>> _physicalTemps = List.generate(8, (_) => <FlSpot>[]);

  /// Historical temperature log data.
  final List<ProbeLogDataPoint> _historicalData = [];

  /// Subscriptions for real-time virtual temperature data streams.
  StreamSubscription<VirtualTemperatures>? _virtualTempSubscription;

  /// Subscriptions for real-time physical temperature data streams.
  StreamSubscription<ProbeTemperatures>? _physicalTempSubscription;

  /// Subscriptions for real-time logs.
  StreamSubscription<ProbeLogDataPoint>? _logSubscription;

  /// Current time offset for real-time data points.
  double _currentTimeOffset = 0;

  /// Whether to show historical data or real-time data.
  bool _showHistoricalData = false;

  /// Timer for updating real-time data timestamps.
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startRealTimeStreams();
    _loadHistoricalData();

    // Update timestamps every second for real-time data
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_showHistoricalData) {
        setState(() {
          _currentTimeOffset += 1;
        });
      }
    });
  }

  /// Starts listening to real-time temperature streams.
  void _startRealTimeStreams() {
    // Listen to virtual temperature updates
    _virtualTempSubscription = widget.probe.virtualTemperatureStream.listen((
      temps,
    ) {
      if (!_showHistoricalData && mounted) {
        setState(() {
          _addVirtualTemperaturePoint(temps);
        });
      }
    });

    // Listen to physical temperature updates
    _physicalTempSubscription = widget.probe.currentTemperaturesStream.listen((
      temps,
    ) {
      if (!_showHistoricalData && mounted) {
        setState(() {
          _addPhysicalTemperaturePoint(temps);
        });
      }
    });
  }

  /// Loads historical temperature log data.
  Future<void> _loadHistoricalData() async {
    try {
      final ProbeTemperatureLog log = await widget.probe.temperatureLog;

      _logSubscription = log.dataStream.listen((ProbeLogDataPoint dataPoint) {
        if (mounted) {
          setState(() {
            _historicalData.add(dataPoint);
          });
        }
      });
    } on Exception catch (e) {
      debugPrint('Failed to load temperature log with exception, $e');
    }
  }

  /// Adds a new virtual temperature data point to the real-time data.
  void _addVirtualTemperaturePoint(VirtualTemperatures temps) {
    final double time = _currentTimeOffset;

    _coreTemps.add(FlSpot(time, _convertTemperature(temps.core)));
    _surfaceTemps.add(FlSpot(time, _convertTemperature(temps.surface)));
    _ambientTemps.add(FlSpot(time, _convertTemperature(temps.ambient)));

    // Keep only the last maxDataPoints
    if (_coreTemps.length > maxDataPoints) {
      _coreTemps.removeAt(0);
      _surfaceTemps.removeAt(0);
      _ambientTemps.removeAt(0);
    }
  }

  /// Adds a new physical temperature data point to the real-time data.
  void _addPhysicalTemperaturePoint(ProbeTemperatures temps) {
    final double time = _currentTimeOffset;
    final List<double> values = [
      temps.t1,
      temps.t2,
      temps.t3,
      temps.t4,
      temps.t5,
      temps.t6,
      temps.t7,
      temps.t8,
    ];

    for (int i = 0; i < 8; i++) {
      _physicalTemps[i].add(FlSpot(time, _convertTemperature(values[i])));

      // Keep only the last maxDataPoints
      if (_physicalTemps[i].length > maxDataPoints) {
        _physicalTemps[i].removeAt(0);
      }
    }
  }

  /// Converts temperature based on current unit setting.
  double _convertTemperature(double celsius) {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius
        ? celsius
        : (celsius * 9 / 5) + 32;
  }

  /// Gets the temperature unit symbol.
  String get _unitSymbol =>
      TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius
          ? '°C'
          : '°F';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TemperatureGraphHeader(
              showHistoricalData: _showHistoricalData,
              onToggleDataMode: () {
                setState(() {
                  _showHistoricalData = !_showHistoricalData;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TemperatureChart(
                showHistoricalData: _showHistoricalData,
                displayMode: widget.displayMode,
                coreTemps: _coreTemps,
                surfaceTemps: _surfaceTemps,
                ambientTemps: _ambientTemps,
                physicalTemps: _physicalTemps,
                historicalData: _historicalData,
                unitSymbol: _unitSymbol,
                convertTemperature: _convertTemperature,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _virtualTempSubscription?.cancel();
    _physicalTempSubscription?.cancel();
    _logSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }
}
