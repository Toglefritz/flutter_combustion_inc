import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/devices/connection_state.dart';
import 'package:flutter_combustion_inc/models/devices/probe.dart';

import '../rssi/rssi_route.dart';
import 'main_navigation_route.dart';
import 'main_navigation_view.dart';

/// Controller for the [MainNavigationRoute] that manages navigation state and probe discovery.
///
/// This controller handles:
/// * Bottom navigation tab selection
/// * Probe discovery and connection management
/// * Sharing probe data across all tabs
/// * Monitoring the selected probe's connection state and surfacing disconnection
/// events to the view via [probeConnectionState]
class MainNavigationController extends State<MainNavigationRoute> {
  /// Currently selected tab index.
  int currentTabIndex = 0;

  /// List of discovered and connected probes.
  List<Probe> probes = [];

  /// Currently selected probe for detailed viewing.
  Probe? selectedProbe;

  /// Global key for accessing the RSSI route state.
  final GlobalKey<RssiRouteState> rssiKey = GlobalKey<RssiRouteState>();

  /// The most recent connection state reported for [selectedProbe].
  ///
  /// Null until the first state event arrives after a probe is selected. The view uses this together with
  /// [hadSuccessfulConnection] to decide whether to display the disconnection banner.
  DeviceConnectionState? probeConnectionState;

  /// Whether the currently selected probe has been fully connected at least once.
  ///
  /// The banner is only shown after a successful connection has been established, so the normal `connecting` state
  /// during initial pairing does not trigger a warning.
  bool hadSuccessfulConnection = false;

  /// Active subscription to the selected probe's connection state stream.
  ///
  /// Cancelled and replaced whenever [selectedProbe] changes.
  StreamSubscription<DeviceConnectionState>? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    // Set up probe discovery listener
    DeviceManager.instance.scanResults.listen(_onProbeDiscovered);

    // Initialize Bluetooth and start scanning
    unawaited(DeviceManager.instance.initBluetooth());
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    super.dispose();
  }

  /// Handles discovery of a new probe.
  ///
  /// Adds the probe to the list and initiates connection.
  Future<void> _onProbeDiscovered(Probe probe) async {
    debugPrint('Discovered probe: ${probe.name} (${probe.identifier})');

    // Avoid duplicates
    if (!probes.any((p) => p.identifier == probe.identifier)) {
      setState(() {
        probes.add(probe);
        // Auto-select first probe
        selectedProbe ??= probe;
      });

      // Update RSSI route with new probes
      rssiKey.currentState?.updateProbes(probes);

      // Start monitoring the auto-selected probe's connection state
      if (selectedProbe?.identifier == probe.identifier) {
        _startConnectionStateMonitoring(probe);
      }

      // Connect to the probe
      await probe.connect();
    }
  }

  /// Begins monitoring connection state for [probe], replacing any existing subscription.
  ///
  /// Resets [hadSuccessfulConnection] so the banner is suppressed during the initial `connecting` → `connected`
  /// transition on the new probe.
  void _startConnectionStateMonitoring(Probe probe) {
    _connectionStateSubscription?.cancel();

    hadSuccessfulConnection = false;
    probeConnectionState = null;

    _connectionStateSubscription = probe.connectionStateStream.listen(
      (DeviceConnectionState state) {
        if (state == DeviceConnectionState.connected) {
          hadSuccessfulConnection = true;
        }
        setState(() {
          probeConnectionState = state;
        });
      },
    );
  }

  /// Handles tab selection changes.
  ///
  /// Triggers a rebuild to ensure all views reflect current settings (e.g., temperature unit).
  void onTabChanged(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  /// Handles probe selection changes.
  ///
  /// Restarts connection state monitoring for the newly selected probe.
  void onProbeSelected(Probe? probe) {
    setState(() {
      selectedProbe = probe;
    });

    if (probe != null) {
      _startConnectionStateMonitoring(probe);
    } else {
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = null;
      hadSuccessfulConnection = false;
      probeConnectionState = null;
    }
  }

  @override
  Widget build(BuildContext context) => MainNavigationView(this);
}
