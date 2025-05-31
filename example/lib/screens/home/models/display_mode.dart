import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// An enumeration of display modes used to determine what information to show in the UI and how to present it.
///
/// Combustion Inc. temperature probes deliver a variety of data, including temperature readings represented in
/// multiple different ways and historical temperature data. This enum is used to specify which data should be displayed
/// and how it should be formatted in the user interface.
enum DisplayMode {
  /// Display virtual temperatures (core, surface, ambient). This is the simplest way to report the probe's readings,
  /// and is the default mode.
  virtualTemperatures,

  /// Advanced mode that displays all eight physical temperature sensors (T1–T8) in a list format.
  physicalTemperatures,

  /// Displays full debug information, including all available data from the probe. This includes both temperature
  /// readings and additional metadata such as probe status, battery level, and other diagnostics. It also includes
  /// information related to the communication between the app and the probe, such as connection status and RSSI values.
  debugInfo;

  /// Returns a label for each mode to display in the UI.
  static String label({required BuildContext context, required DisplayMode displayMode}) {
    switch (displayMode) {
      case DisplayMode.virtualTemperatures:
        return AppLocalizations.of(context)!.virtualTemperatures;
      case DisplayMode.physicalTemperatures:
        return AppLocalizations.of(context)!.physicalTemperatures;
      case DisplayMode.debugInfo:
        return AppLocalizations.of(context)!.debugInfo;
    }
  }
}
