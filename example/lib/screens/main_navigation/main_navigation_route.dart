import 'package:flutter/material.dart';

import 'main_navigation_controller.dart';

/// Main navigation route that provides bottom navigation between app sections.
///
/// This route serves as the primary entry point for the example app, demonstrating all features of the
/// flutter_combustion_inc plugin through a clean, intuitive tabbed interface.
class MainNavigationRoute extends StatefulWidget {
  /// Creates an instance of [MainNavigationRoute].
  const MainNavigationRoute({super.key});

  @override
  State<MainNavigationRoute> createState() => MainNavigationController();
}
