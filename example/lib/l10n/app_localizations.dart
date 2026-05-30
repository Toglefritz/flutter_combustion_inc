import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// Title for the about tab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Label for the stacked display mode showing both virtual and physical temperatures.
  ///
  /// In en, this message translates to:
  /// **'All Temperatures'**
  String get allTemperatures;

  /// Label for the ambient temperature of a probe.
  ///
  /// In en, this message translates to:
  /// **'Ambient'**
  String get ambientTemperature;

  /// Label for average temperature.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get avgTemperature;

  /// Label for battery status.
  ///
  /// In en, this message translates to:
  /// **'Battery Status'**
  String get batteryStatus;

  /// Message indicating that the battery status of a probe is okay.
  ///
  /// In en, this message translates to:
  /// **'Battery OK'**
  String get batteryStatusOk;

  /// Label for Celsius temperature unit option.
  ///
  /// In en, this message translates to:
  /// **'Celsius (°C)'**
  String get celsius;

  /// Abbreviation for Celsius temperature.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get celsiusAbbreviation;

  /// Tooltip for the button to change the target temperature.
  ///
  /// In en, this message translates to:
  /// **'Change Target'**
  String get changeTarget;

  /// Button label to clear input.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Tooltip for the connect button.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Instructions shown when no probes are available.
  ///
  /// In en, this message translates to:
  /// **'Please connect a probe from the home screen first.'**
  String get connectProbeFirst;

  /// Label for connected connection state.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectionStateConnected;

  /// Label for connecting connection state.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connectionStateConnecting;

  /// Label for disconnected connection state.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get connectionStateDisconnected;

  /// Label for failed connection state.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get connectionStateFailed;

  /// Label for the core temperature of a probe.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get coreTemperature;

  /// Label for current core temperature in predictions.
  ///
  /// In en, this message translates to:
  /// **'Current Core'**
  String get currentCore;

  /// Label for the current cooking progress information.
  ///
  /// In en, this message translates to:
  /// **'Current progress:'**
  String get currentProgress;

  /// Label for current temperature reading.
  ///
  /// In en, this message translates to:
  /// **'Current Reading'**
  String get currentReading;

  /// Displays the current route information.
  ///
  /// In en, this message translates to:
  /// **'Current route: {route}'**
  String currentRouteLabel(String route);

  /// Label for the current RSSI value.
  ///
  /// In en, this message translates to:
  /// **'Current RSSI'**
  String get currentRssi;

  /// Confirmation message when a custom target temperature is set.
  ///
  /// In en, this message translates to:
  /// **'Custom target set: {temperature}{unit}'**
  String customTargetTemperatureSet(int temperature, String unit);

  /// Label for the debug information display mode.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// Section header for the device list.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// Label for direct BLE connection route option.
  ///
  /// In en, this message translates to:
  /// **'Direct (probe BLE)'**
  String get directProbeBle;

  /// Tooltip for the disconnect button.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Button label to show the custom temperature input field.
  ///
  /// In en, this message translates to:
  /// **'Enter Custom Temperature'**
  String get enterCustomTemperature;

  /// Generic error message when temperature logs fail to load.
  ///
  /// In en, this message translates to:
  /// **'Unable to load temperature logs. Please try again.'**
  String get errorLoadingLogs;

  /// Error message when no matching temperature log is found for the current session.
  ///
  /// In en, this message translates to:
  /// **'No matching temperature log found for the current session.'**
  String get errorLogNotFound;

  /// Error message when no active cooking session is available for temperature logs.
  ///
  /// In en, this message translates to:
  /// **'No active cooking session found. Start a cooking session to view temperature logs.'**
  String get errorNoActiveSession;

  /// Error message when no temperature logs are available on the probe.
  ///
  /// In en, this message translates to:
  /// **'No temperature logs available. Ensure the probe is connected and logging temperatures.'**
  String get errorNoLogsAvailable;

  /// Error message when the specified probe cannot be found.
  ///
  /// In en, this message translates to:
  /// **'Probe not found. Please check the connection and try again.'**
  String get errorProbeNotFound;

  /// Label for estimated core temperature in predictions.
  ///
  /// In en, this message translates to:
  /// **'Estimated Core'**
  String get estimatedCore;

  /// Label for the estimated time until target temperature is reached.
  ///
  /// In en, this message translates to:
  /// **'Estimated time remaining:'**
  String get estimatedTimeRemaining;

  /// Label for Fahrenheit temperature unit option.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit (°F)'**
  String get fahrenheit;

  /// Abbreviation for Fahrenheit temperature.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fahrenheitAbbreviation;

  /// Error message when setting target temperature fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to set target temperature: {error}'**
  String failedToSetTargetTemperature(String error);

  /// Feature description for battery monitoring.
  ///
  /// In en, this message translates to:
  /// **'Battery status monitoring'**
  String get featureBatteryMonitoring;

  /// Feature description for Bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Low Energy connectivity'**
  String get featureBluetooth;

  /// Feature description for cross-platform support.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform support (iOS, Android, macOS)'**
  String get featureCrossPlatform;

  /// Feature description for historical graphs.
  ///
  /// In en, this message translates to:
  /// **'Historical temperature graphs'**
  String get featureHistoricalGraphs;

  /// Feature description for physical sensors.
  ///
  /// In en, this message translates to:
  /// **'Physical sensor readings (T1-T8)'**
  String get featurePhysicalSensors;

  /// Feature description for predictions.
  ///
  /// In en, this message translates to:
  /// **'Cooking time predictions'**
  String get featurePredictions;

  /// Feature description for real-time monitoring.
  ///
  /// In en, this message translates to:
  /// **'Real-time temperature monitoring'**
  String get featureRealtimeMonitoring;

  /// Feature description for virtual sensors.
  ///
  /// In en, this message translates to:
  /// **'Virtual temperature sensors (core, surface, ambient)'**
  String get featureVirtualSensors;

  /// Label for features list.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Title for the graphs tab.
  ///
  /// In en, this message translates to:
  /// **'Graphs'**
  String get graphs;

  /// Button label to hide the graphs in the temperature display.
  ///
  /// In en, this message translates to:
  /// **'Hide Graphs'**
  String get hideGraphs;

  /// Message shown when historical data is not available because no cooking session has started.
  ///
  /// In en, this message translates to:
  /// **'Historical data will be available once cooking session starts'**
  String get historicalDataUnavailable;

  /// Label for historical data display mode in graphs.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyData;

  /// Error message when temperature input is not a valid number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidTemperature;

  /// Label for live data display mode in graphs.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveData;

  /// Label shown while data is loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Message displayed while loading historical temperature data.
  ///
  /// In en, this message translates to:
  /// **'Loading historical data...'**
  String get loadingHistoricalData;

  /// Message displayed while loading temperature logs from the probe.
  ///
  /// In en, this message translates to:
  /// **'Loading temperature logs...'**
  String get loadingTemperatureLogs;

  /// Warning message displayed when a probe's battery is low.
  ///
  /// In en, this message translates to:
  /// **'Battery low'**
  String get lowBatteryWarning;

  /// Label for probe MAC address.
  ///
  /// In en, this message translates to:
  /// **'MAC Address'**
  String get macAddress;

  /// Instructions for making probe discoverable.
  ///
  /// In en, this message translates to:
  /// **'Make sure your probe is powered on and nearby.'**
  String get makeProbeVisible;

  /// Label for maximum temperature.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxTemperature;

  /// Label for the MeatNet nodes subsection in the device list.
  ///
  /// In en, this message translates to:
  /// **'MeatNet Nodes'**
  String get meatNetNodes;

  /// Section header for the mesh network topology view.
  ///
  /// In en, this message translates to:
  /// **'Mesh Topology'**
  String get meshTopology;

  /// Description for the mesh topology section.
  ///
  /// In en, this message translates to:
  /// **'Shows which probes each node can reach.'**
  String get meshTopologyDescription;

  /// Label for minimum temperature.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minTemperature;

  /// Label for prediction mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// Label for name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Title for the network topology tab.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// Negative label.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Message displayed when no temperature data is available for graphing.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Message shown when no probes are available for predictions.
  ///
  /// In en, this message translates to:
  /// **'No Probes Available'**
  String get noProbesAvailable;

  /// Message shown when a node has no probes in its network.
  ///
  /// In en, this message translates to:
  /// **'No probes detected'**
  String get noProbesDetected;

  /// Shows how many probes a node can reach.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 probe} other{{count} probes}}'**
  String nodeProbeCount(int count);

  /// Conjunction used to separate different options.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Title for physical temperature sensors section.
  ///
  /// In en, this message translates to:
  /// **'Physical Sensors'**
  String get physicalSensors;

  /// Label for the physical temperatures display mode.
  ///
  /// In en, this message translates to:
  /// **'Physical Temperatures'**
  String get physicalTemperatures;

  /// Label for platform field.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// Title for plugin information section.
  ///
  /// In en, this message translates to:
  /// **'Plugin Information'**
  String get pluginInformation;

  /// Section header for prediction detail information.
  ///
  /// In en, this message translates to:
  /// **'Prediction Details'**
  String get predictionDetails;

  /// Header for the prediction information section.
  ///
  /// In en, this message translates to:
  /// **'Prediction Information'**
  String get predictionInfo;

  /// Label for no prediction mode.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get predictionModeNone;

  /// Label for removal and resting prediction mode.
  ///
  /// In en, this message translates to:
  /// **'Removal & Resting'**
  String get predictionModeRemovalAndResting;

  /// Label for reserved prediction mode.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get predictionModeReserved;

  /// Label for time to removal prediction mode.
  ///
  /// In en, this message translates to:
  /// **'Time to Removal'**
  String get predictionModeTimeToRemoval;

  /// Placeholder text shown while prediction system is not yet integrated.
  ///
  /// In en, this message translates to:
  /// **'Calculating... (Prediction system integration pending)'**
  String get predictionPlaceholder;

  /// Label for cooking prediction state.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get predictionStateCooking;

  /// Label for done prediction state.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get predictionStateDone;

  /// Label for predicting prediction state.
  ///
  /// In en, this message translates to:
  /// **'Predicting'**
  String get predictionStatePredicting;

  /// Label for probe inserted prediction state.
  ///
  /// In en, this message translates to:
  /// **'Probe Inserted'**
  String get predictionStateProbeInserted;

  /// Label for probe not inserted prediction state.
  ///
  /// In en, this message translates to:
  /// **'Probe Not Inserted'**
  String get predictionStateProbeNotInserted;

  /// Label for unknown prediction state.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get predictionStateUnknown;

  /// Label for no prediction type.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get predictionTypeNone;

  /// Label for removal prediction type.
  ///
  /// In en, this message translates to:
  /// **'Removal'**
  String get predictionTypeRemoval;

  /// Label for reserved prediction type.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get predictionTypeReserved;

  /// Label for resting prediction type.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get predictionTypeResting;

  /// Title for the predictions screen.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get predictions;

  /// A generic label for a probe.
  ///
  /// In en, this message translates to:
  /// **'Probe'**
  String get probe;

  /// Title for probe details section.
  ///
  /// In en, this message translates to:
  /// **'Probe Details'**
  String get probeDetails;

  /// Label for probe ID.
  ///
  /// In en, this message translates to:
  /// **'Probe ID'**
  String get probeId;

  /// Label for the probes subsection in the device list.
  ///
  /// In en, this message translates to:
  /// **'Probes'**
  String get probes;

  /// Placeholder text shown while progress tracking is not yet integrated.
  ///
  /// In en, this message translates to:
  /// **'Monitoring temperature... (Progress tracking pending)'**
  String get progressPlaceholder;

  /// Header for the food preset selection section.
  ///
  /// In en, this message translates to:
  /// **'Quick Presets'**
  String get quickPresets;

  /// Tooltip for the refresh route button.
  ///
  /// In en, this message translates to:
  /// **'Refresh route'**
  String get refreshRoute;

  /// Label for prediction reliability indicator.
  ///
  /// In en, this message translates to:
  /// **'Reliable'**
  String get reliable;

  /// Tooltip for the reset view button in the temperature chart.
  ///
  /// In en, this message translates to:
  /// **'Reset View (or double-tap chart)'**
  String get resetViewTooltip;

  /// Button label to retry a failed operation.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Section header for the route control panel.
  ///
  /// In en, this message translates to:
  /// **'Route Control'**
  String get routeControl;

  /// Label for the route device selector.
  ///
  /// In en, this message translates to:
  /// **'Route through:'**
  String get routeThrough;

  /// Label for automatic routing mode.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get routingModeAuto;

  /// Label for explicit routing mode.
  ///
  /// In en, this message translates to:
  /// **'Explicit'**
  String get routingModeExplicit;

  /// Label for the Received Signal Strength Indicator (RSSI) of a probe.
  ///
  /// In en, this message translates to:
  /// **'RSSI'**
  String get rssi;

  /// Label for RSSI axis in graph.
  ///
  /// In en, this message translates to:
  /// **'RSSI (dBm)'**
  String get rssiDbm;

  /// Label for excellent RSSI signal quality.
  ///
  /// In en, this message translates to:
  /// **'Excellent Signal'**
  String get rssiExcellent;

  /// Label for fair RSSI signal quality.
  ///
  /// In en, this message translates to:
  /// **'Fair Signal'**
  String get rssiFair;

  /// Label for good RSSI signal quality.
  ///
  /// In en, this message translates to:
  /// **'Good Signal'**
  String get rssiGood;

  /// Title for the RSSI history graph.
  ///
  /// In en, this message translates to:
  /// **'RSSI History'**
  String get rssiHistory;

  /// Description for the RSSI history graph.
  ///
  /// In en, this message translates to:
  /// **'Last 60 seconds of signal strength readings'**
  String get rssiHistoryDescription;

  /// Label for poor RSSI signal quality.
  ///
  /// In en, this message translates to:
  /// **'Poor Signal'**
  String get rssiPoor;

  /// Title for the RSSI tracking screen.
  ///
  /// In en, this message translates to:
  /// **'RSSI Tracking'**
  String get rssiTracking;

  /// Displays an RSSI value with unit.
  ///
  /// In en, this message translates to:
  /// **'RSSI: {value} dBm'**
  String rssiValueDbm(int value);

  /// Message shown while scanning for nearby Combustion devices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for devices...'**
  String get scanningForDevices;

  /// Message displayed when the app is searching for nearby probes.
  ///
  /// In en, this message translates to:
  /// **'Searching for probes...'**
  String get searchingForProbes;

  /// Instructions for using the target temperature control.
  ///
  /// In en, this message translates to:
  /// **'Select a food type for quick setup, or enter a custom temperature below.'**
  String get selectFoodTypeOrEnterCustom;

  /// Label for the probe selection dropdown.
  ///
  /// In en, this message translates to:
  /// **'Select Probe'**
  String get selectProbe;

  /// Tooltip for the select probe button.
  ///
  /// In en, this message translates to:
  /// **'Select probe'**
  String get selectProbeTooltip;

  /// Shows which probe is currently selected for route control.
  ///
  /// In en, this message translates to:
  /// **'Selected probe: {name}'**
  String selectedProbeLabel(String name);

  /// Label for probe serial number.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// Button label to confirm setting a temperature.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// Header for the target temperature control section.
  ///
  /// In en, this message translates to:
  /// **'Set Target Temperature'**
  String get setTargetTemperature;

  /// Title for the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Button label to show all available temperature data in the historical chart.
  ///
  /// In en, this message translates to:
  /// **'All Data'**
  String get showAllData;

  /// Button label to show the graphs in the temperature display.
  ///
  /// In en, this message translates to:
  /// **'Show Graphs'**
  String get showGraphs;

  /// Button label to show only recent temperature data in the historical chart.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get showRecentData;

  /// Label for signal strength.
  ///
  /// In en, this message translates to:
  /// **'Signal Strength'**
  String get signalStrength;

  /// Label for the surface temperature of a probe.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surfaceTemperature;

  /// Tooltip for switching to column temperature display.
  ///
  /// In en, this message translates to:
  /// **'Switch to column view'**
  String get switchToColumnView;

  /// Tooltip for switching to stacked temperature display.
  ///
  /// In en, this message translates to:
  /// **'Switch to stacked view'**
  String get switchToStackedView;

  /// Label for target temperature in predictions.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// Label for the currently set target temperature.
  ///
  /// In en, this message translates to:
  /// **'Target Temperature'**
  String get targetTemperature;

  /// Confirmation message when a food preset target temperature is set.
  ///
  /// In en, this message translates to:
  /// **'Target set: {food} at {temperature}{unit}'**
  String targetTemperatureSet(String food, int temperature, String unit);

  /// Label for temperature input field.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Title for the temperature graph display.
  ///
  /// In en, this message translates to:
  /// **'Temperature Graph'**
  String get temperatureGraph;

  /// Section header for temperature details in predictions.
  ///
  /// In en, this message translates to:
  /// **'Temperature Information'**
  String get temperatureInformation;

  /// Error message when temperature is outside valid cooking range.
  ///
  /// In en, this message translates to:
  /// **'Temperature must be between {min} and {max} {unit}'**
  String temperatureOutOfRange(int min, int max, String unit);

  /// Error message when temperature field is empty.
  ///
  /// In en, this message translates to:
  /// **'Temperature is required'**
  String get temperatureRequired;

  /// Label for a temperature reading, where {number} is the probe number (e.g. T1-T8).
  ///
  /// In en, this message translates to:
  /// **'T{number}'**
  String temperatureTn(int number);

  /// Label for temperature unit setting.
  ///
  /// In en, this message translates to:
  /// **'Temperature Unit'**
  String get temperatureUnit;

  /// Title for the temperatures tab.
  ///
  /// In en, this message translates to:
  /// **'Temperatures'**
  String get temperatures;

  /// Label for the list of thermometers, where {number} is the count of available thermometers.
  ///
  /// In en, this message translates to:
  /// **'Thermometers ({number})'**
  String thermometers(int number);

  /// Label for time axis in graph.
  ///
  /// In en, this message translates to:
  /// **'Time (seconds)'**
  String get timeSeconds;

  /// Label for the timespan control that lets users choose between recent and all data.
  ///
  /// In en, this message translates to:
  /// **'Show:'**
  String get timespanControlLabel;

  /// Label for prediction type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Label for unknown or unavailable values.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Label for version number.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Title for virtual temperature sensors section.
  ///
  /// In en, this message translates to:
  /// **'Virtual Sensors'**
  String get virtualSensors;

  /// Label for the virtual temperatures display mode.
  ///
  /// In en, this message translates to:
  /// **'Virtual Temperatures'**
  String get virtualTemperatures;

  /// Message shown while waiting for prediction data to arrive.
  ///
  /// In en, this message translates to:
  /// **'Waiting for prediction data...'**
  String get waitingForPredictionData;

  /// Affirmative label.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Tooltip for the zoom in button in the temperature chart.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomInTooltip;

  /// Tooltip for the zoom out button in the temperature chart.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOutTooltip;

  /// Banner message shown while the app is attempting to reconnect to a probe.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting to probe...'**
  String get probeReconnecting;

  /// Banner message shown when the probe connection has been lost.
  ///
  /// In en, this message translates to:
  /// **'Probe disconnected'**
  String get probeDisconnected;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
