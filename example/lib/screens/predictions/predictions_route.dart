import 'package:flutter/material.dart';

import 'predictions_controller.dart';

/// Route for the predictions screen.
///
/// This screen allows users to set target temperatures and view cooking
/// predictions including estimated time to completion.
class PredictionsRoute extends StatefulWidget {
  /// Creates an instance of [PredictionsRoute].
  const PredictionsRoute({super.key});

  @override
  State<PredictionsRoute> createState() => PredictionsController();
}
