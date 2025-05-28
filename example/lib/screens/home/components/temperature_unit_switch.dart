import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../../services/temperature_unit_setting/temperature_unit_setting.dart';

/// A toggle switch for changing the temperature unit between Celsius and Fahrenheit.
class TemperatureUnitSwitch extends StatelessWidget {
  /// Creates an instance of [TemperatureUnitSwitch].
  const TemperatureUnitSwitch({
    required this.onChanged,
    super.key,
  });

  /// Callback function to handle the switch state change.
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.celsiusAbbreviation,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SwitchTheme(
          data: SwitchThemeData(
            thumbColor: WidgetStateProperty.all(Colors.white),
            trackColor: WidgetStateProperty.all(Colors.transparent),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            thumbIcon: WidgetStateProperty.all(
              Icon(
                Icons.circle,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
              return Theme.of(context).primaryColorDark;
            }),
            trackOutlineWidth: WidgetStateProperty.all(1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Switch(
            value: TemperatureUnitSetting.currentUnit == TemperatureUnit.fahrenheit,
            onChanged: onChanged,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.fahrenheitAbbreviation,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
