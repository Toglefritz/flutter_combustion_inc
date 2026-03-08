import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/device_manager.dart';
import 'package:flutter_combustion_inc/models/prediction_info.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../components/empty_state_widget.dart';
import '../components/probe_selector.dart';
import 'components/target_temperature_control.dart';

/// View for the predictions tab.
///
/// Displays cooking predictions with visual progress indicators and target temperature controls. Allows users to set
/// target temperatures and view estimated cooking times.
class PredictionsView extends StatefulWidget {
  /// List of available probes.
  final List<Probe> probes;

  /// Currently selected probe.
  final Probe? selectedProbe;

  /// Callback when probe selection changes.
  final ValueChanged<Probe?> onProbeSelected;

  /// Creates an instance of [PredictionsView].
  const PredictionsView({
    required this.probes,
    required this.selectedProbe,
    required this.onProbeSelected,
    super.key,
  });

  @override
  State<PredictionsView> createState() => _PredictionsViewState();
}

/// State for [PredictionsView].
class _PredictionsViewState extends State<PredictionsView> {
  /// The current prediction information for the selected probe.
  PredictionInfo? _currentPrediction;

  /// Stream subscription for prediction updates.
  StreamSubscription<PredictionInfo>? _predictionSubscription;

  @override
  void didUpdateWidget(PredictionsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the selected probe changed, cancel the old subscription
    if (oldWidget.selectedProbe?.identifier != widget.selectedProbe?.identifier) {
      unawaited(_predictionSubscription?.cancel());
      _predictionSubscription = null;
      setState(() {
        _currentPrediction = null;
      });
    }
  }

  /// Sets the target temperature for the selected probe.
  ///
  /// This method sends the target temperature to the probe and starts listening for prediction updates.
  Future<void> _onTargetTemperatureSet(double temperatureCelsius) async {
    if (widget.selectedProbe == null) {
      debugPrint('No probe selected for target temperature');
      return;
    }

    try {
      await DeviceManager.instance.setTargetTemperature(
        widget.selectedProbe!.identifier,
        temperatureCelsius,
      );

      debugPrint(
        'Target temperature set to $temperatureCelsius°C for probe ${widget.selectedProbe!.name}',
      );

      // Start listening to prediction updates
      await _startPredictionStream(widget.selectedProbe!);
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
  Future<void> _startPredictionStream(Probe probe) async {
    // Cancel any existing subscription
    await _predictionSubscription?.cancel();

    // Start listening to prediction updates
    _predictionSubscription = probe.predictionStream.listen(
      (PredictionInfo prediction) {
        debugPrint('Received prediction update: $prediction');
        if (mounted) {
          setState(() {
            _currentPrediction = prediction;
          });
        }
      },
      onError: (Object error) {
        debugPrint('Error in prediction stream: $error');
        if (mounted) {
          setState(() {
            _currentPrediction = null;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.predictions,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          widget.probes.isEmpty
              ? const EmptyStateWidget()
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Probe selector
                        ProbeSelector(
                          probes: widget.probes,
                          selectedProbe: widget.selectedProbe,
                          onProbeSelected: widget.onProbeSelected,
                        ),

                        // Target temperature control
                        TargetTemperatureControl(
                          onTargetSet: _onTargetTemperatureSet,
                          enabled: widget.selectedProbe != null,
                          predictionInfo: _currentPrediction,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    unawaited(_predictionSubscription?.cancel());
    super.dispose();
  }
}
