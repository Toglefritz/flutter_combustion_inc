import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import 'rssi_route.dart';
import 'rssi_view.dart';

/// Represents a single RSSI data point with timestamp.
class RssiDataPoint {
  /// Time offset in seconds when this reading was taken.
  final double timestamp;

  /// RSSI value in dBm.
  final int rssi;

  /// Creates an RSSI data point.
  const RssiDataPoint({
    required this.timestamp,
    required this.rssi,
  });
}

/// Controller for the [RssiRoute] that manages RSSI polling and data collection.
///
/// This controller handles:
/// * Periodic RSSI polling at 500ms intervals
/// * Historical RSSI data collection
/// * Probe selection management
class RssiController extends RssiRouteState {
  /// List of available probes.
  List<Probe> probes = [];

  /// Currently selected probe for RSSI monitoring.
  Probe? selectedProbe;

  /// Current RSSI value.
  int? currentRssi;

  /// Historical RSSI data points for graphing.
  final List<RssiDataPoint> rssiHistory = [];

  /// Timer for periodic RSSI polling.
  Timer? _pollTimer;

  /// Time offset for data points (in seconds).
  double _timeOffset = 0.0;

  /// Maximum time window to keep in history (in seconds).
  static const double maxTimeWindowSeconds = 60.0;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  /// Starts periodic RSSI polling at 500ms intervals.
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (selectedProbe != null) {
        try {
          final int rssi = await selectedProbe!.rssi;
          if (mounted) {
            setState(() {
              currentRssi = rssi;
              _addRssiDataPoint(rssi);
              _timeOffset += 0.5; // Increment by 0.5 seconds
            });
          }
        } on Exception catch (e) {
          debugPrint('Error reading RSSI: $e');
        }
      }
    });
  }

  /// Adds a new RSSI data point to the history.
  ///
  /// Maintains a rolling window of the most recent [maxTimeWindowSeconds] seconds of data for performance.
  void _addRssiDataPoint(int rssi) {
    rssiHistory.add(
      RssiDataPoint(
        timestamp: _timeOffset,
        rssi: rssi,
      ),
    );

    // Remove old data points outside the time window
    final double cutoffTime = _timeOffset - maxTimeWindowSeconds;
    rssiHistory.removeWhere((point) => point.timestamp < cutoffTime);
  }

  /// Handles probe selection changes.
  void onProbeSelected(Probe? probe) {
    setState(() {
      selectedProbe = probe;
      currentRssi = null;
      rssiHistory.clear();
      _timeOffset = 0.0;
    });
  }

  /// Updates the list of available probes.
  @override
  void updateProbes(List<Probe> newProbes) {
    setState(() {
      probes = newProbes;
      // Auto-select first probe if none selected
      if (selectedProbe == null && probes.isNotEmpty) {
        selectedProbe = probes.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) => RssiView(this);

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
