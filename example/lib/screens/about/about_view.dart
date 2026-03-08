/// Settings view library.
///
/// This library provides the main view for the settings tab, allowing users to configure app preferences such as
/// temperature units.
library;

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/battery_status.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../services/temperature_unit_setting/models/temperature_unit.dart';
import '../../services/temperature_unit_setting/temperature_unit_setting.dart';
import '../../values/inset.dart';

part 'components/battery_level.dart';
part 'components/plugin_info_card.dart';
part 'components/probe_details_card.dart';
part 'components/signal_strength_row.dart';
part 'components/info_row.dart';
part 'components/temperature_unit_setting_card.dart';

/// View for the settings tab.
///
/// Displays app settings including temperature unit preferences and plugin information.
class SettingsView extends StatefulWidget {
  /// List of available probes.
  final List<Probe> probes;

  /// Currently selected probe.
  final Probe? selectedProbe;

  /// Creates an instance of [SettingsView].
  const SettingsView({
    required this.probes,
    required this.selectedProbe,
    super.key,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

/// State for [SettingsView].
class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Temperature unit setting
                TemperatureUnitSettingCard(
                  onUnitChanged: () {
                    setState(() {
                      // Trigger rebuild to update UI
                    });
                  },
                ),

                // Plugin information
                const PluginInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
