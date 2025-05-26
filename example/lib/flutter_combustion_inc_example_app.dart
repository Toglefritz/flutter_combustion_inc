import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home/home_route.dart';

/// A [StatelessWidget] that builds the root [MaterialApp] for the Flutter BLE Example App.
///
/// This widget is responsible for creating the main application structure with an app bar and body content. The app
/// bar displays the title 'Flutter Splendid BLE Example App', and the body includes an animated image from a network
/// URL.
///
/// The [FlutterCombustionIncExampleApp] is returned by the [runApp] method in main.dart and serves as the starting point for
/// the example application, setting the stage for any additional screens, widgets, or functionalities that might be
/// added.
class FlutterCombustionIncExampleApp extends StatelessWidget {
  /// Creates an instance of [FlutterCombustionIncExampleApp].
  const FlutterCombustionIncExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
      ],
      home: HomeRoute(),
    );
  }
}
