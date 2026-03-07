import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/prediction_info.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import 'predictions_route.dart';
import 'predictions_view.dart';

/// Controller for the [PredictionsRoute] that manages prediction state and business logic.
class PredictionsController extends State<PredictionsRoute> {
  /// List of available probes.
  final List<Probe> _availableProbes = [];

  /// The currently selected probe for predictions.
  Probe? _selectedProbe;

  /// The current prediction information for the selected probe.
  PredictionInfo? _currentPrediction;

  /// Stream subscription for prediction updates.
  StreamSubscription<PredictionInfo>? _predictionSubscription;

  /// Stream subscription for probe discovery.
  StreamSubscription<Probe>? _probeDiscoverySubscription;

  /// Gets the currently selected probe.
  Probe? get selectedProbe => _selectedProbe;

  /// Gets the current prediction information.
  PredictionInfo? get currentPrediction => _currentPrediction;

  /// Gets the list of available probes.
  List<Probe> get availableProbes => _availableProbes;

  @override
  void initState() {
    super.initState();

    // Listen for probe discoveries
    _probeDiscoverySubscription = DeviceManager.instance.scanResults.listen(
      (probe) {
        // Check if probe is already in the list
        if (!_availableProbes.any((p) => p.identifier == probe.identifier)) {
          setState(() {
            _availableProbes.add(probe);

            // Select first probe if none selected
            _selectedProbe ??= probe;
          });
        }
      },
    );

    // Load existing probes
    unawaited(_loadExistingProbes());
  }

  /// Loads probes that were already discovered.
  Future<void> _loadExistingProbes() async {
    try {
      final List<Probe> probes = await DeviceManager.instance.getProbes();

      if (probes.isNotEmpty && mounted) {
        setState(() {
          _availableProbes.addAll(probes);
          _selectedProbe ??= probes.first;
        });
      }
    } on Exception catch (e) {
      debugPrint('Failed to load existing probes: $e');
    }
  }

  /// Handles probe selection changes from the UI.
  ///
  /// This method wraps the async [onProbeSelected] method to handle
  /// the callback from the dropdown widget properly.
  ///
  /// - Parameter probe: The newly selected probe, or null if deselected
  void handleProbeSelectionChange(Probe? probe) {
    if (probe != null) {
      unawaited(onProbeSelected(probe));
    }
  }

  /// Handles probe selection changes.
  ///
  /// - Parameter probe: The newly selected probe
  Future<void> onProbeSelected(Probe probe) async {
    setState(() {
      _selectedProbe = probe;
      _currentPrediction = null;
    });

    // Cancel existing prediction subscription
    await _predictionSubscription?.cancel();
    _predictionSubscription = null;
  }

  /// Sets the target temperature for the selected probe.
  ///
  /// This method sends the target temperature to the probe and starts
  /// listening for prediction updates.
  ///
  /// - Parameter temperatureCelsius: The target temperature in Celsius
  Future<void> onTargetTemperatureSet(double temperatureCelsius) async {
    if (_selectedProbe == null) {
      debugPrint('No probe selected for target temperature');
      return;
    }

    try {
      await DeviceManager.instance.setTargetTemperature(
        _selectedProbe!.identifier,
        temperatureCelsius,
      );

      debugPrint(
        'Target temperature set to $temperatureCelsius°C for probe ${_selectedProbe!.name}',
      );

      // Start listening to prediction updates
      await _startPredictionStream(_selectedProbe!);
    } on Exception catch (e) {
      debugPrint('Failed to set target temperature: $e');

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
  /// - Parameter probe: The probe to monitor for predictions
  Future<void> _startPredictionStream(Probe probe) async {
    // Cancel any existing subscription
    await _predictionSubscription?.cancel();

    // Start listening to prediction updates
    _predictionSubscription = probe.predictionStream.listen(
      (prediction) {
        debugPrint('Received prediction update: $prediction');
        setState(() {
          _currentPrediction = prediction;
        });
      },
      onError: (Object error) {
        debugPrint('Error in prediction stream: $error');
        setState(() {
          _currentPrediction = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => PredictionsView(this);

  @override
  void dispose() {
    unawaited(_predictionSubscription?.cancel());
    unawaited(_probeDiscoverySubscription?.cancel());

    super.dispose();
  }
}
