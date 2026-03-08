/// About view library.
///
/// This library provides the main view for the about tab, displaying plugin information, probe details, and feature
/// list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/battery_status.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';

part 'components/plugin_info_card.dart';
part 'components/probe_details_card.dart';
part 'components/battery_level.dart';
part 'components/signal_strength_row.dart';
part 'components/features_card.dart';
part 'components/feature_item.dart';
part 'components/info_row.dart';

/// View for the about tab.
///
/// Displays plugin information and detailed probe specifications.
class AboutView extends StatelessWidget {
  /// List of available probes.
  final List<Probe> probes;

  /// Currently selected probe.
  final Probe? selectedProbe;

  /// Creates an instance of [AboutView].
  const AboutView({
    required this.probes,
    required this.selectedProbe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.about,
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
                // Plugin information
                const PluginInfoCard(),

                // Probe details (if probe selected)
                if (selectedProbe != null) ProbeDetailsCard(probe: selectedProbe!),

                // Features list
                const FeaturesCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
