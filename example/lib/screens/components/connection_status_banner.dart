import 'package:flutter/material.dart';
import 'package:flutter_combustion_inc/models/devices/connection_state.dart';

import '../../l10n/app_localizations.dart';

/// Animated banner shown at the top of the main content area when the selected probe is not connected.
///
/// The banner slides into view when [connectionState] is anything other than [DeviceConnectionState.connected], and
/// slides back out when the connection is restored. It distinguishes between an active reconnection attempt and a fully
/// lost connection so the user knows whether recovery is in progress.
///
/// Pass [visible] as false to suppress the banner regardless of state, which is useful while waiting for the first
/// successful connection (i.e., before there is anything meaningful to report as "lost").
class ConnectionStatusBanner extends StatelessWidget {
  /// The current connection state of the selected probe.
  final DeviceConnectionState connectionState;

  /// Whether the banner should be shown at all.
  ///
  /// Set to false until the probe has connected at least once, so the normal initial `connecting` state does not
  /// trigger a warning.
  final bool visible;

  /// Creates a [ConnectionStatusBanner].
  const ConnectionStatusBanner({
    required this.connectionState,
    required this.visible,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool show = visible && connectionState != DeviceConnectionState.connected;
    final bool isReconnecting = connectionState == DeviceConnectionState.connecting;

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colors = Theme.of(context).colorScheme;

    // AnimatedSize collapses the banner to zero height when hidden, giving a smooth slide-up/slide-down transition
    // without needing a custom animation controller.
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child:
          show
              ? _BannerContent(
                message: isReconnecting ? l10n.probeReconnecting : l10n.probeDisconnected,
                isReconnecting: isReconnecting,
                backgroundColor: isReconnecting ? colors.secondaryContainer : colors.errorContainer,
                foregroundColor: isReconnecting ? colors.onSecondaryContainer : colors.onErrorContainer,
              )
              : const SizedBox.shrink(),
    );
  }
}

/// Internal widget that renders the banner content row.
///
/// Separated from [ConnectionStatusBanner] so the outer widget can collapse cleanly to zero height via [AnimatedSize]
/// without layout artifacts.
class _BannerContent extends StatelessWidget {
  /// The message to display in the banner.
  final String message;

  /// Whether to show a progress indicator instead of a static warning icon.
  final bool isReconnecting;

  /// Background color for the banner strip.
  final Color backgroundColor;

  /// Foreground color for the icon and text.
  final Color foregroundColor;

  /// Creates a [_BannerContent].
  const _BannerContent({
    required this.message,
    required this.isReconnecting,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              if (isReconnecting)
                SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: foregroundColor,
                  ),
                )
              else
                Icon(Icons.bluetooth_disabled, size: 16.0, color: foregroundColor),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
