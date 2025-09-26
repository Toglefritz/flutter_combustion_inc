import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/prediction_info.dart';
import 'package:flutter_combustion_inc/models/probe.dart';
import '../../services/temperature_unit_setting/temperature_unit_setting.dart';
import 'home_route.dart';
import 'home_view.dart';
import 'home_view_searching.dart';
import 'models/display_mode.dart';

/// A controller for the [HomeRoute] that manages the state and owns all business logic.
class HomeController extends State<HomeRoute> {
  /// A list of Combustion Inc. temperature probes discovered during scanning.
  List<Probe> probes = [];

  /// The display mode for this view. This is used to determine what information to show and how it should be presented.
  DisplayMode displayMode = DisplayMode.virtualTemperatures;

  /// Determines if temperature graphs should be displayed in the view.
  bool _showGraphs = false;

  /// The current prediction information for the selected probe.
  PredictionInfo? _currentPrediction;

  /// Stream subscription for prediction updates.
  StreamSubscription<PredictionInfo>? _predictionSubscription;

  /// A getter for the current state of the temperature graphs display.
  bool get showGraphs => _showGraphs;

  /// Sets the state of the temperature graphs display.
  set showGraphs(bool value) {
    if (_showGraphs != value) {
      _showGraphs = value;
      setState(() {});
    }
  }

  /// Gets the current prediction information.
  PredictionInfo? get currentPrediction => _currentPrediction;

  @override
  void initState() {
    // Set up a listener for probe discovery events.
    DeviceManager.instance.scanResults.listen(_onProbeDiscovered);

    // Initialize Bluetooth and start scanning for probes.
    DeviceManager.instance.initBluetooth();

    super.initState();
  }

  /// Handles the discovery of a new probe by adding it to the list of discovered probes.
  void _onProbeDiscovered(Probe probe) {
    debugPrint('Discovered probe: ${probe.name} (${probe.identifier})');

    // Check if the probe is already in the list to avoid duplicates.
    if (!probes.any((p) => p.identifier == probe.identifier)) {
      setState(() {
        probes.add(probe);
      });

      // Connect to the probe and attempt to maintain a connection.
      probe.connect();
    }
  }

  /// Callback for when a probe is selected from the list.
  void onProbeSelected() {
    // TODO(Toglefritz): Implement probe selection logic.
  }

  /// Handles changes in the temperature unit setting.
  void onTemperatureUnitChanged() => setState(TemperatureUnitSetting.toggle);

  /// Handles changes in the display mode.
  void onDisplayModeChanged(DisplayMode mode) => setState(() {
    displayMode = mode;
  });

  /// Sets the target temperature for the first available probe.
  ///
  /// This method sends the target temperature to the probe using the Method Channel.
  /// The temperature is provided in Celsius and will be used by the probe to
  /// generate cooking predictions and estimated completion times.
  ///
  /// @param temperatureCelsius The target temperature in Celsius
  Future<void> onTargetTemperatureSet(double temperatureCelsius) async {
    if (probes.isEmpty) {
      debugPrint('No probes available to set target temperature');
      return;
    }

    // Use the first probe for now - TODO: Allow user to select which probe
    final Probe targetProbe = probes.first;

    try {
      await DeviceManager.instance.setTargetTemperature(
        targetProbe.identifier,
        temperatureCelsius,
      );

      debugPrint('Target temperature set to $temperatureCelsius°C for probe ${targetProbe.name}');

      // Start listening to prediction updates for this probe
      _startPredictionStream(targetProbe);
    } on Exception catch (e) {
      debugPrint('Failed to set target temperature: $e');

      // Show error to user if context is available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set target temperature: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Starts listening to prediction updates for the specified probe.
  ///
  /// This method subscribes to the prediction stream and updates the UI whenever new prediction information becomes
  /// available.
  void _startPredictionStream(Probe probe) {
    // Cancel any existing subscription
    _predictionSubscription?.cancel();

    // Start listening to prediction updates
    _predictionSubscription = probe.predictionStream.listen(
      (PredictionInfo prediction) {
        debugPrint('Received prediction update: $prediction');
        setState(() {
          _currentPrediction = prediction;
        });
      },
      onError: (Object error) {
        debugPrint('Error in prediction stream: $error');
        // Clear prediction on error
        setState(() {
          _currentPrediction = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(microseconds: 250),
    child: probes.isEmpty ? const HomeViewSearching() : HomeView(this),
  );

  @override
  void dispose() {
    // Clean up the prediction stream subscription
    _predictionSubscription?.cancel();

    super.dispose();
  }
}
