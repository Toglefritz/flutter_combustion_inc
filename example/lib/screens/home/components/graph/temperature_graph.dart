library;

import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/flutter_combustion_inc_platform_interface.dart';
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

  /// Whether historical data is currently being loaded.
  bool _isLoadingHistoricalData = false;

  /// Error message when historical data loading fails.
  String? _historicalDataError;

  /// Whether session information is available for the probe.
  bool _hasSessionInfo = false;

  /// Subscription for session information updates.
  StreamSubscription<Map<String, dynamic>>? _sessionInfoSubscription;

  /// Timer for periodic silent retry of historical data loading.
  Timer? _silentRetryTimer;

  @override
  void initState() {
    super.initState();
    _startRealTimeStreams();
    _startSessionInfoStream();
    // Don't load historical data immediately - wait for session info to be available

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
  ///
  /// Sets up subscriptions to both virtual temperature updates (core, surface, ambient)
  /// and physical temperature updates (T1-T8 sensors). Data points are only added
  /// when not showing historical data to avoid mixing real-time and historical data.
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

  /// Starts listening to session information updates.
  ///
  /// Monitors the probe's session information availability and automatically
  /// attempts to load historical data when a session becomes available.
  /// Clears any previous errors when session info becomes available.
  void _startSessionInfoStream() {
    _sessionInfoSubscription = widget.probe.sessionInfoStream.listen((Map<String, dynamic> sessionInfo) {
      if (mounted) {
        final bool hasSession = sessionInfo['hasSession'] as bool? ?? false;
        final bool previousHasSession = _hasSessionInfo;

        setState(() {
          _hasSessionInfo = hasSession;
          // Clear any previous error when session info becomes available
          if (hasSession && !previousHasSession) {
            _historicalDataError = null;
          }
        });

        // If session info just became available and we don't have historical data yet, try to load it
        // But don't show errors immediately - wait for user to explicitly request historical data
        if (hasSession && !previousHasSession && _historicalData.isEmpty && !_isLoadingHistoricalData) {
          _loadHistoricalDataSilently();
          _startSilentRetryTimer();
        }

        // If session info is lost, stop the retry timer
        if (!hasSession && previousHasSession) {
          _stopSilentRetryTimer();
        }
      }
    });
  }

  /// Loads historical temperature log data silently (without showing errors to user).
  ///
  /// Used for automatic loading when session info becomes available.
  /// Does not display errors to the user - they will only see errors when
  /// explicitly requesting historical data via the UI.
  Future<void> _loadHistoricalDataSilently() async {
    if (!mounted) return;

    try {
      final ProbeTemperatureLog log = await widget.probe.temperatureLog;

      if (!mounted) return;

      _logSubscription = log.dataStream.listen((ProbeLogDataPoint dataPoint) {
        if (mounted) {
          setState(() {
            _historicalData.add(dataPoint);
          });
        }
      });

      // Stop the retry timer since we succeeded
      _stopSilentRetryTimer();
    } on Exception {
      // Don't show error to user for silent loads - they'll see it when they explicitly request historical data
    }
  }

  /// Starts a timer to periodically retry loading historical data silently.
  ///
  /// Retries every 5 seconds for up to 12 attempts (1 minute total).
  /// Automatically stops when data is successfully loaded, session info is lost,
  /// or the maximum number of attempts is reached.
  void _startSilentRetryTimer() {
    _stopSilentRetryTimer(); // Stop any existing timer

    _silentRetryTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted || !_hasSessionInfo || _historicalData.isNotEmpty) {
        _stopSilentRetryTimer();
        return;
      }

      _loadHistoricalDataSilently();

      // Stop after 12 attempts (1 minute)
      if (timer.tick >= 12) {
        _stopSilentRetryTimer();
      }
    });
  }

  /// Stops the silent retry timer.
  ///
  /// Cancels the periodic timer and clears the reference to prevent memory leaks.
  void _stopSilentRetryTimer() {
    _silentRetryTimer?.cancel();
    _silentRetryTimer = null;
  }

  /// Loads historical temperature log data with user-visible error handling.
  ///
  /// This method is called when the user explicitly requests historical data
  /// (e.g., by pressing the retry button). It shows loading states and error
  /// messages to the user. If session info is not available, it attempts to
  /// refresh it before trying to load the temperature log.
  Future<void> _loadHistoricalData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingHistoricalData = true;
      _historicalDataError = null;
    });

    try {
      // Check session info before attempting to get temperature log
      final Map<String, dynamic> sessionInfo = await widget.probe.sessionInfo;

      // If no session info is available, try refreshing it
      if (!(sessionInfo['hasSession'] as bool? ?? false)) {
        await FlutterCombustionIncPlatform.instance.refreshSessionInfo(widget.probe.identifier);

        // Wait a bit for the refresh to take effect
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Check again after refresh
        await widget.probe.sessionInfo;
      }

      final ProbeTemperatureLog log = await widget.probe.temperatureLog;

      if (!mounted) return;

      setState(() {
        _isLoadingHistoricalData = false;
      });

      _logSubscription = log.dataStream.listen((ProbeLogDataPoint dataPoint) {
        if (mounted) {
          setState(() {
            _historicalData.add(dataPoint);
          });
        }
      });
    } on Exception catch (exception) {
      if (!mounted) return;

      setState(() {
        _isLoadingHistoricalData = false;
        _historicalDataError = _getErrorMessage(exception);
      });
    }
  }

  /// Converts platform exceptions to user-friendly error messages.
  String _getErrorMessage(Exception exception) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String exceptionString = exception.toString();

    if (exceptionString.contains('NO_SESSION_INFO')) {
      return localizations.errorNoActiveSession;
    } else if (exceptionString.contains('NO_LOGS_AVAILABLE')) {
      return localizations.errorNoLogsAvailable;
    } else if (exceptionString.contains('PROBE_NOT_FOUND')) {
      return localizations.errorProbeNotFound;
    } else if (exceptionString.contains('LOG_NOT_FOUND')) {
      return localizations.errorLogNotFound;
    } else {
      return localizations.errorLoadingLogs;
    }
  }

  /// Retries loading historical temperature data.
  ///
  /// Only attempts to load data if session information is available.
  /// This method is called when the user presses the retry button in the error state.
  void _retryLoadHistoricalData() {
    if (_hasSessionInfo) {
      _loadHistoricalData();
    }
  }

  /// Adds a new virtual temperature data point to the real-time data.
  ///
  /// Converts temperatures to the current unit setting and maintains a rolling
  /// window of the most recent [maxDataPoints] data points for performance.
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
  ///
  /// Processes all 8 physical temperature sensors (T1-T8) and converts them
  /// to the current unit setting. Maintains a rolling window of the most recent
  /// [maxDataPoints] data points for each sensor for performance.
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

    for (int sensorIndex = 0; sensorIndex < 8; sensorIndex++) {
      _physicalTemps[sensorIndex].add(FlSpot(time, _convertTemperature(values[sensorIndex])));

      // Keep only the last maxDataPoints
      if (_physicalTemps[sensorIndex].length > maxDataPoints) {
        _physicalTemps[sensorIndex].removeAt(0);
      }
    }
  }

  /// Converts temperature based on current unit setting.
  ///
  /// Takes a temperature value in Celsius and converts it to the user's
  /// preferred unit (Celsius or Fahrenheit) based on the current setting.
  double _convertTemperature(double celsius) {
    return TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? celsius : (celsius * 9 / 5) + 32;
  }

  /// Gets the temperature unit symbol.
  ///
  /// Returns the appropriate symbol ('°C' or '°F') based on the current
  /// temperature unit setting for display in the UI.
  String get _unitSymbol => TemperatureUnitSetting.currentUnit == TemperatureUnit.celsius ? '°C' : '°F';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Inset.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Inset.medium),
              child: TemperatureGraphHeader(
                showHistoricalData: _showHistoricalData,
                hasSessionInfo: _hasSessionInfo,
                onToggleDataMode: () {
                  setState(() {
                    _showHistoricalData = !_showHistoricalData;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Inset.medium),
              child: SizedBox(
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
                  isLoadingHistoricalData: _isLoadingHistoricalData,
                  historicalDataError: _historicalDataError,
                  onRetryLoadHistoricalData: _retryLoadHistoricalData,
                  hasSessionInfo: _hasSessionInfo,
                ),
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
    _sessionInfoSubscription?.cancel();
    _updateTimer?.cancel();
    _stopSilentRetryTimer();
    super.dispose();
  }
}
