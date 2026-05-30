import 'package:flutter_combustion_inc/models/devices/device.dart';

import 'routing_mode.dart';

/// Holds the current routing configuration for the app.
///
/// Consumed by the main navigation controller and passed to any tab that
/// needs to send commands to a probe.
class RoutingConfig {
  /// The active routing mode.
  final RoutingMode mode;

  /// The device to route through when [mode] is [RoutingMode.explicit].
  ///
  /// Ignored when [mode] is [RoutingMode.auto].
  final Device? explicitDevice;

  /// Creates a routing config in auto mode.
  const RoutingConfig.auto() : mode = RoutingMode.auto, explicitDevice = null;

  /// Creates a routing config that forces commands through [device].
  const RoutingConfig.explicit(Device device) : mode = RoutingMode.explicit, explicitDevice = device;

  /// Whether the current mode is auto-routing.
  bool get isAuto => mode == RoutingMode.auto;

  /// Whether the current mode is explicit routing.
  bool get isExplicit => mode == RoutingMode.explicit;
}
