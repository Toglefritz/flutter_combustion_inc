import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'home_controller.dart';
import 'home_route.dart';

/// View for the [HomeRoute]. The view is dumb, and purely declarative. References values on the controller and widget.
class HomeView extends StatelessWidget {
  /// A reference to the controller for the [HomeRoute].
  final HomeController state;

  /// Creates an instance of [HomeView].
  const HomeView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
