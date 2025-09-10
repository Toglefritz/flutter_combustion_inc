// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ambientTemperature => 'Ambient';

  @override
  String get batteryStatusOk => 'Battery OK';

  @override
  String get celsiusAbbreviation => 'C';

  @override
  String get coreTemperature => 'Core';

  @override
  String get debugInfo => 'Debug Info';

  @override
  String get fahrenheitAbbreviation => 'F';

  @override
  String get hideGraphs => 'Hide Graphs';

  @override
  String get lowBatteryWarning => 'Battery low';

  @override
  String get physicalTemperatures => 'Physical Temperatures';

  @override
  String get probe => 'Probe';

  @override
  String get rssi => 'RSSI';

  @override
  String get searchingForProbes => 'Searching for probes...';

  @override
  String get showGraphs => 'Show Graphs';

  @override
  String get surfaceTemperature => 'Surface';

  @override
  String temperatureTn(int number) {
    return 'T$number';
  }

  @override
  String thermometers(int number) {
    return 'Thermometers ($number)';
  }

  @override
  String get virtualTemperatures => 'Virtual Temperatures';

  @override
  String get temperatureGraph => 'Temperature Graph';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get loadingHistoricalData => 'Loading historical data...';

  @override
  String get loadingTemperatureLogs => 'Loading temperature logs...';

  @override
  String get errorNoActiveSession =>
      'No active cooking session found. Start a cooking session to view temperature logs.';

  @override
  String get errorNoLogsAvailable =>
      'No temperature logs available. Ensure the probe is connected and logging temperatures.';

  @override
  String get errorProbeNotFound => 'Probe not found. Please check the connection and try again.';

  @override
  String get errorLogNotFound => 'No matching temperature log found for the current session.';

  @override
  String get errorLoadingLogs => 'Unable to load temperature logs. Please try again.';

  @override
  String get retryButton => 'Retry';

  @override
  String get historicalDataUnavailable => 'Historical data will be available once cooking session starts';
}
