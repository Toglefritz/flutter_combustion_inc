import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_navigation/main_navigation_route.dart';

/// A [StatelessWidget] that builds the root [MaterialApp] for the Flutter BLE Example App.
///
/// This widget is responsible for creating the main application structure with an app bar and body content. The app bar
/// displays the title 'Flutter Splendid BLE Example App', and the body includes an animated image from a network URL.
///
/// The [FlutterCombustionIncExampleApp] is returned by the [runApp] method in main.dart and serves as the starting
/// point for the example application, setting the stage for any additional screens, widgets, or functionalities that
/// might be added.
class FlutterCombustionIncExampleApp extends StatelessWidget {
  /// Creates an instance of [FlutterCombustionIncExampleApp].
  const FlutterCombustionIncExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1B1F),
          surfaceContainerLowest: const Color(0xFF0F0E11),
          surfaceContainerLow: const Color(0xFF1C1B1F),
          surfaceContainer: const Color(0xFF201F23),
          surfaceContainerHigh: const Color(0xFF2B292D),
          surfaceContainerHighest: const Color(0xFF363438),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      supportedLocales: const [
        Locale('en'), // English
      ],
      home: const MainNavigationRoute(),
    );
  }
}
