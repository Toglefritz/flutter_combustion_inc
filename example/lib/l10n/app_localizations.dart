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

  /// Label for the ambient temperature of a probe.
  ///
  /// In en, this message translates to:
  /// **'Ambient'**
  String get ambientTemperature;

  /// Message indicating that the battery status of a probe is okay.
  ///
  /// In en, this message translates to:
  /// **'Battery OK'**
  String get batteryStatusOk;

  /// Abbreviation for Celsius temperature.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get celsiusAbbreviation;

  /// Label for the core temperature of a probe.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get coreTemperature;

  /// Label for the debug information display mode.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// Abbreviation for Fahrenheit temperature.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fahrenheitAbbreviation;

  /// Warning message displayed when a probe's battery is low.
  ///
  /// In en, this message translates to:
  /// **'Battery low'**
  String get lowBatteryWarning;

  /// Label for the physical temperatures display mode.
  ///
  /// In en, this message translates to:
  /// **'Physical Temperatures'**
  String get physicalTemperatures;

  /// A generic label for a probe.
  ///
  /// In en, this message translates to:
  /// **'Probe'**
  String get probe;

  /// Label for the Received Signal Strength Indicator (RSSI) of a probe.
  ///
  /// In en, this message translates to:
  /// **'RSSI'**
  String get rssi;

  /// Message displayed when the app is searching for nearby probes.
  ///
  /// In en, this message translates to:
  /// **'Searching for probes...'**
  String get searchingForProbes;

  /// Label for the surface temperature of a probe.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surfaceTemperature;

  /// Label for a temperature reading, where {number} is the probe number (e.g. T1-T8).
  ///
  /// In en, this message translates to:
  /// **'T{number}'**
  String temperatureTn(int number);

  /// Label for the list of thermometers, where {number} is the count of available thermometers.
  ///
  /// In en, this message translates to:
  /// **'Thermometers ({number})'**
  String thermometers(int number);

  /// Label for the virtual temperatures display mode.
  ///
  /// In en, this message translates to:
  /// **'Virtual Temperatures'**
  String get virtualTemperatures;
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
