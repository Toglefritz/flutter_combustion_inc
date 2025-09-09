import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/probe.dart';

import '../../../l10n/app_localizations.dart';

/// A toggle switch for changing enabling or disabling the display of temperature log graphs.
class GraphDisplaySwitch extends StatelessWidget {
  /// Creates an instance of [GraphDisplaySwitch].
  const GraphDisplaySwitch({
    required this.probe,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  /// A [Probe] instance used to monitor the progress of syncing the temperature log. This is used to determine
  /// whether to display a switch for displaying the graphs versus a progress indicator for syncing the log.
  final Probe probe;

  /// Determines if the switch is enabled or disabled. The switch being enable corresponds to the graphs being
  /// displayed.
  final bool enabled;

  /// Callback function to handle the switch state change.
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: probe.logSyncPercentageStream,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.hideGraphs,
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
                trackOutlineColor: WidgetStateProperty.resolveWith<Color>((_) {
                  return Theme.of(context).primaryColorDark;
                }),
                trackOutlineWidth: WidgetStateProperty.all(1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: snapshot.hasData && snapshot.data! == 100.0
                    ? Switch(
                        key: ValueKey<bool>(enabled),
                        value: enabled,
                        onChanged: onChanged,
                      )
                    : SizedBox(
                        key: const ValueKey<String>('syncing'),
                        width: 48,
                        height: 48,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: snapshot.data,
                            strokeWidth: 2.0,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.showGraphs,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        );
      },
    );
  }
}
