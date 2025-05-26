import 'package:flutter/material.dart';

import 'home_controller.dart';

/// Scans for Combustion Inc. temperature probes and displays them in a list.
///
/// This route is the main entry point for the application. It automatically starts scanning for temperature probes
/// when initialized. Once a probe is discovered, information about the probe and its temperature readings is displayed.
/// If more than one probe is discovered, the user can select which probe to view.
class HomeRoute extends StatefulWidget {
  /// Creates an instance of [HomeRoute].
  const HomeRoute({super.key});

  @override
  HomeController createState() => HomeController();
}
