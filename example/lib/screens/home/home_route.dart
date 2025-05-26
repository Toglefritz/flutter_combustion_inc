import 'package:flutter/material.dart';

import 'home_controller.dart';

/// Scans for Combustion Inc. temperature probes and displays them in a list.
///
/// This route is the main entry point for the application. It automatically starts scanning for temperature probes
/// when initialized and displays the discovered probes in a list. The user can select a probe to view its details.
class HomeRoute extends StatefulWidget {
  /// Creates an instance of [HomeRoute].
  const HomeRoute({super.key});

  @override
  HomeController createState() => HomeController();
}
