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
  String get allTemperatures => 'All Temperatures';

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

  @override
  String get predictions => 'Predictions';

  @override
  String get selectProbe => 'Select Probe';

  @override
  String get noProbesAvailable => 'No Probes Available';

  @override
  String get connectProbeFirst => 'Please connect a probe from the home screen first.';

  @override
  String get temperatures => 'Temperatures';

  @override
  String get network => 'Network';

  @override
  String get graphs => 'Graphs';

  @override
  String get about => 'About';

  @override
  String get settings => 'Settings';

  @override
  String get temperatureUnit => 'Temperature Unit';

  @override
  String get celsius => 'Celsius (°C)';

  @override
  String get fahrenheit => 'Fahrenheit (°F)';

  @override
  String get makeProbeVisible => 'Make sure your probe is powered on and nearby.';

  @override
  String get virtualSensors => 'Virtual Sensors';

  @override
  String get physicalSensors => 'Physical Sensors';

  @override
  String get currentReading => 'Current Reading';

  @override
  String get minTemperature => 'Min';

  @override
  String get maxTemperature => 'Max';

  @override
  String get avgTemperature => 'Avg';

  @override
  String get probeDetails => 'Probe Details';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get macAddress => 'MAC Address';

  @override
  String get probeId => 'Probe ID';

  @override
  String get batteryStatus => 'Battery Status';

  @override
  String get signalStrength => 'Signal Strength';

  @override
  String get pluginInformation => 'Plugin Information';

  @override
  String get version => 'Version';

  @override
  String get features => 'Features';

  @override
  String get name => 'Name';

  @override
  String get platform => 'Platform';

  @override
  String get unknown => 'Unknown';

  @override
  String get loading => 'Loading...';

  @override
  String get featureRealtimeMonitoring => 'Real-time temperature monitoring';

  @override
  String get featureVirtualSensors => 'Virtual temperature sensors (core, surface, ambient)';

  @override
  String get featurePhysicalSensors => 'Physical sensor readings (T1-T8)';

  @override
  String get featureHistoricalGraphs => 'Historical temperature graphs';

  @override
  String get featurePredictions => 'Cooking time predictions';

  @override
  String get featureBatteryMonitoring => 'Battery status monitoring';

  @override
  String get featureBluetooth => 'Bluetooth Low Energy connectivity';

  @override
  String get featureCrossPlatform => 'Cross-platform support (iOS, Android, macOS)';

  @override
  String get rssiTracking => 'RSSI Tracking';

  @override
  String get currentRssi => 'Current RSSI';

  @override
  String get rssiHistory => 'RSSI History';

  @override
  String get rssiHistoryDescription => 'Last 60 seconds of signal strength readings';

  @override
  String get rssiDbm => 'RSSI (dBm)';

  @override
  String get timeSeconds => 'Time (seconds)';

  @override
  String get rssiExcellent => 'Excellent Signal';

  @override
  String get rssiGood => 'Good Signal';

  @override
  String get rssiFair => 'Fair Signal';

  @override
  String get rssiPoor => 'Poor Signal';

  @override
  String get scanningForDevices => 'Scanning for devices...';

  @override
  String get refreshRoute => 'Refresh route';

  @override
  String get devices => 'Devices';

  @override
  String get probes => 'Probes';

  @override
  String get meatNetNodes => 'MeatNet Nodes';

  @override
  String get selectProbeTooltip => 'Select probe';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connect => 'Connect';

  @override
  String get meshTopology => 'Mesh Topology';

  @override
  String get meshTopologyDescription => 'Shows which probes each node can reach.';

  @override
  String get noProbesDetected => 'No probes detected';

  @override
  String get routeControl => 'Route Control';

  @override
  String selectedProbeLabel(String name) {
    return 'Selected probe: $name';
  }

  @override
  String currentRouteLabel(String route) {
    return 'Current route: $route';
  }

  @override
  String get routingModeAuto => 'Auto';

  @override
  String get routingModeExplicit => 'Explicit';

  @override
  String get routeThrough => 'Route through:';

  @override
  String get directProbeBle => 'Direct (probe BLE)';

  @override
  String rssiValueDbm(int value) {
    return 'RSSI: $value dBm';
  }

  @override
  String nodeProbeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count probes',
      one: '1 probe',
    );
    return '$_temp0';
  }

  @override
  String get connectionStateDisconnected => 'Disconnected';

  @override
  String get connectionStateConnecting => 'Connecting...';

  @override
  String get connectionStateConnected => 'Connected';

  @override
  String get connectionStateFailed => 'Failed';

  @override
  String get switchToStackedView => 'Switch to stacked view';

  @override
  String get switchToColumnView => 'Switch to column view';

  @override
  String get liveData => 'Live';

  @override
  String get historyData => 'History';

  @override
  String get temperatureInformation => 'Temperature Information';

  @override
  String get currentCore => 'Current Core';

  @override
  String get estimatedCore => 'Estimated Core';

  @override
  String get target => 'Target';

  @override
  String get predictionDetails => 'Prediction Details';

  @override
  String get mode => 'Mode';

  @override
  String get type => 'Type';

  @override
  String get reliable => 'Reliable';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get waitingForPredictionData => 'Waiting for prediction data...';

  @override
  String get predictionStateProbeNotInserted => 'Probe Not Inserted';

  @override
  String get predictionStateProbeInserted => 'Probe Inserted';

  @override
  String get predictionStateCooking => 'Cooking';

  @override
  String get predictionStatePredicting => 'Predicting';

  @override
  String get predictionStateDone => 'Done';

  @override
  String get predictionStateUnknown => 'Unknown';

  @override
  String get predictionModeNone => 'None';

  @override
  String get predictionModeTimeToRemoval => 'Time to Removal';

  @override
  String get predictionModeRemovalAndResting => 'Removal & Resting';

  @override
  String get predictionModeReserved => 'Reserved';

  @override
  String get predictionTypeNone => 'None';

  @override
  String get predictionTypeRemoval => 'Removal';

  @override
  String get predictionTypeResting => 'Resting';

  @override
  String get predictionTypeReserved => 'Reserved';

  @override
  String failedToSetTargetTemperature(String error) {
    return 'Failed to set target temperature: $error';
  }
}
