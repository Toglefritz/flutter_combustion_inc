import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../l10n/app_localizations.dart';
import '../../values/inset.dart';

/// A reusable probe selector widget.
///
/// Displays a dropdown to select from available probes.
class ProbeSelector extends StatelessWidget {
  /// List of available probes.
  final List<Probe> probes;

  /// Currently selected probe.
  final Probe? selectedProbe;

  /// Callback when probe selection changes.
  final ValueChanged<Probe?> onProbeSelected;

  /// Creates an instance of [ProbeSelector].
  const ProbeSelector({
    required this.probes,
    required this.selectedProbe,
    required this.onProbeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (probes.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(Inset.medium),
      elevation: isDark ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      colorScheme.surfaceContainerHigh,
                      colorScheme.surfaceContainer,
                    ]
                    : [
                      colorScheme.surface,
                      colorScheme.surfaceContainerLow,
                    ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Inset.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.selectProbe,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Inset.small),
                child: DropdownButton<Probe>(
                  value: selectedProbe,
                  isExpanded: true,
                  items:
                      probes.map((Probe probe) {
                        return DropdownMenuItem<Probe>(
                          value: probe,
                          child: Text(probe.name),
                        );
                      }).toList(),
                  onChanged: onProbeSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
