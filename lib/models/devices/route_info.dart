import '../ble_data/hop_count.dart';
import 'device.dart';
import 'meat_net_node.dart';
import 'probe.dart';

/// Describes the communication route between the app and a probe.
///
/// When the app communicates with a probe, data can travel either directly
/// over BLE or through one or more MeatNet repeater nodes. This class captures
/// the current best route, including which device to send commands through and
/// the hop count of the most recent data.
///
/// For engineering/QA use, this provides visibility into the mesh network
/// topology and allows informed decisions about explicit routing.
class RouteInfo {
  /// The probe to which this route information applies.
  final Probe probe;

  /// The device through which commands should be sent to reach the probe.
  ///
  /// If the probe is directly connected, this is the probe itself.
  /// If the probe is reachable through a MeatNet node, this is that node.
  /// If `null`, no route to the probe is currently available.
  final Device? routeDevice;

  /// Whether the route is a direct BLE connection to the probe.
  ///
  /// When `true`, [routeDevice] is the probe itself and [hopCount] is `null`.
  /// When `false`, data is being relayed through a MeatNet node.
  bool get isDirect => routeDevice is Probe;

  /// Whether the route goes through a MeatNet repeater node.
  bool get isRelayed => routeDevice is MeatNetNode;

  /// Whether any route to the probe is currently available.
  bool get isReachable => routeDevice != null;

  /// The MeatNet node relaying data, or `null` if the route is direct.
  MeatNetNode? get relayNode =>
      routeDevice is MeatNetNode ? routeDevice! as MeatNetNode : null;

  /// The hop count of the most recent data received for this probe.
  ///
  /// `null` when data arrives directly from the probe (no hops).
  /// Present when data is relayed through one or more MeatNet nodes.
  final HopCount? hopCount;

  /// RSSI to the route device (the device the app communicates with directly).
  ///
  /// For direct connections this is the RSSI to the probe. For relayed
  /// connections this is the RSSI to the intermediate node.
  final int? rssi;

  /// Creates a [RouteInfo] instance.
  const RouteInfo({
    required this.probe,
    required this.routeDevice,
    this.hopCount,
    this.rssi,
  });

  /// Creates a [RouteInfo] representing a direct connection to the probe.
  factory RouteInfo.direct(Probe probe) {
    return RouteInfo(
      probe: probe,
      routeDevice: probe,
      rssi: probe.rssi,
    );
  }

  /// Creates a [RouteInfo] representing a relayed connection through a node.
  factory RouteInfo.relayed({
    required Probe probe,
    required MeatNetNode node,
    HopCount? hopCount,
  }) {
    return RouteInfo(
      probe: probe,
      routeDevice: node,
      hopCount: hopCount,
      rssi: node.rssi,
    );
  }

  /// Creates a [RouteInfo] representing an unreachable probe.
  factory RouteInfo.unreachable(Probe probe) {
    return RouteInfo(
      probe: probe,
      routeDevice: null,
    );
  }

  @override
  String toString() {
    if (!isReachable) return 'RouteInfo(unreachable)';
    if (isDirect) return 'RouteInfo(direct, rssi: $rssi)';
    return 'RouteInfo(relayed via ${relayNode?.uniqueIdentifier}, '
        'hopCount: ${hopCount?.count}, rssi: $rssi)';
  }
}
