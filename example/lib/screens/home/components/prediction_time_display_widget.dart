import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/prediction_info.dart';

import '../../../l10n/app_localizations.dart';

/// A widget that displays estimated cooking time based on prediction information.
///
/// This widget shows the estimated time remaining until the target temperature
/// is reached, with different states for loading, calculating, and completion.
class PredictionTimeDisplayWidget extends StatelessWidget {
  /// The current prediction information to display.
  final PredictionInfo? predictionInfo;

  /// Creates a prediction time display widget.
  ///
  /// If [predictionInfo] is null, shows a placeholder message.
  /// Otherwise displays the appropriate time estimate or status message.
  const PredictionTimeDisplayWidget({
    required this.predictionInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (predictionInfo == null) {
      return Text(
        AppLocalizations.of(context)!.predictionPlaceholder,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final PredictionInfo prediction = predictionInfo!;

    if (!prediction.isReliable) {
      return Text(
        'Calculating...',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (prediction.estimatedTimeSeconds == null) {
      return Text(
        'Target reached!',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final int totalSeconds = prediction.estimatedTimeSeconds!;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    String timeString;
    if (hours > 0) {
      timeString = '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      timeString = '${minutes}m ${seconds}s';
    } else {
      timeString = '${seconds}s';
    }

    return Text(
      timeString,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
