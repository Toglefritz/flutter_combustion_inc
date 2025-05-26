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
  String get coreTemperature => 'Core';

  @override
  String get searchingForProbes => 'Searching for probes...';

  @override
  String get surfaceTemperature => 'Surface';

  @override
  String thermometers(int number) {
    return 'Thermometers ($number)';
  }
}
