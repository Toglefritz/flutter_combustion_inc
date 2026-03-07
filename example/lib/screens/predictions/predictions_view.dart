import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';
import '../home/components/target_temperature_control.dart';
import 'predictions_controller.dart';

/// View for the predictions screen.
///
/// This view displays probe selection and target temperature controls
/// for viewing cooking predictions.
class PredictionsView extends StatelessWidget {
  /// Reference to the controller.
  final PredictionsController state;

  /// Creates an instance of [PredictionsView].
  const PredictionsView(this.state, {super.key});

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Probe selector
            if (state.availableProbes.isNotEmpty)
              Card(
                margin: const EdgeInsets.all(Inset.medium),
                child: Padding(
                  padding: const EdgeInsets.all(Inset.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.selectProbe,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Inset.small),
                        child: DropdownButton<Probe>(
                          value: state.selectedProbe,
                          isExpanded: true,
                          items:
                              state.availableProbes.map((probe) {
                                return DropdownMenuItem<Probe>(
                                  value: probe,
                                  child: Text(probe.name),
                                );
                              }).toList(),
                          onChanged: state.handleProbeSelectionChange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Target temperature control
            TargetTemperatureControl(
              onTargetSet: state.onTargetTemperatureSet,
              enabled: state.selectedProbe != null,
              predictionInfo: state.currentPrediction,
            ),

            // Empty state when no probes available
            if (state.availableProbes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Inset.large),
                child: Column(
                  children: [
                    Icon(
                      Icons.bluetooth_searching,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: Inset.medium),
                      child: Text(
                        AppLocalizations.of(context)!.noProbesAvailable,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: Inset.small),
                      child: Text(
                        AppLocalizations.of(context)!.connectProbeFirst,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
