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
  String get errorNoActiveSession => 'No active cooking session found. Start a cooking session to view temperature logs.';

  @override
  String get errorNoLogsAvailable => 'No temperature logs available. Ensure the probe is connected and logging temperatures.';

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

  @override
  String get showRecentData => 'Recent';

  @override
  String get showAllData => 'All Data';

  @override
  String get timespanControlLabel => 'Show:';

  @override
  String get zoomOutTooltip => 'Zoom Out';

  @override
  String get zoomInTooltip => 'Zoom In';

  @override
  String get resetViewTooltip => 'Reset View (or double-tap chart)';

  @override
  String get setTargetTemperature => 'Set Target Temperature';

  @override
  String get selectFoodTypeOrEnterCustom => 'Select a food type for quick setup, or enter a custom temperature below.';

  @override
  String get or => 'OR';

  @override
  String get enterCustomTemperature => 'Enter Custom Temperature';

  @override
  String get temperature => 'Temperature';

  @override
  String get set => 'Set';

  @override
  String get temperatureRequired => 'Temperature is required';

  @override
  String get invalidTemperature => 'Please enter a valid number';

  @override
  String temperatureOutOfRange(int min, int max, String unit) {
    return 'Temperature must be between $min and $max $unit';
  }

  @override
  String targetTemperatureSet(String food, int temperature, String unit) {
    return 'Target set: $food at $temperature$unit';
  }

  @override
  String customTargetTemperatureSet(int temperature, String unit) {
    return 'Custom target set: $temperature$unit';
  }

  @override
  String get clear => 'Clear';

  @override
  String get quickPresets => 'Quick Presets';

  @override
  String get targetTemperature => 'Target Temperature';

  @override
  String get changeTarget => 'Change Target';

  @override
  String get predictionInfo => 'Prediction Information';

  @override
  String get estimatedTimeRemaining => 'Estimated time remaining:';

  @override
  String get predictionPlaceholder => 'Calculating... (Prediction system integration pending)';

  @override
  String get currentProgress => 'Current progress:';

  @override
  String get progressPlaceholder => 'Monitoring temperature... (Progress tracking pending)';
}
