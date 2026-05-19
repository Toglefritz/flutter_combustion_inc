import 'device.dart';
import 'dfu_device_type.dart';
import 'probe.dart';

/// Represents a node on the MeatNet BLE repeater network.
///
/// Various Combustion products (Timer, Charger, etc.) act as MeatNet nodes,
/// relaying probe data over the mesh network. Unlike a [Probe] which is keyed
/// by serial number, a node is identified by its BLE peripheral UUID.
class MeatNetNode extends Device {
  /// Serial number string, read from the Device Info service after connection.
  ///
  /// Remains `null` until the characteristic has been read.
  String? serialNumberString;

  /// Probes connected to this node's network, keyed by serial number.
  final Map<int, Probe> probes;

  /// DFU device type, determines which firmware package applies to this node.
  ///
  /// Parsed from the model info characteristic after connection.
  DfuDeviceType dfuType;

  /// Creates a new [MeatNetNode].
  ///
  /// The [identifier] is the BLE peripheral UUID, used as both
  /// [uniqueIdentifier] and [bleIdentifier].
  MeatNetNode({
    required String identifier,
    super.rssi,
    this.serialNumberString,
    this.dfuType = DfuDeviceType.unknown,
  }) : probes = {},
       super(
         uniqueIdentifier: identifier,
         bleIdentifier: identifier,
       );

  /// Creates a [MeatNetNode] from a platform channel map.
  factory MeatNetNode.fromMap(Map<String, dynamic> map) {
    final MeatNetNode node = MeatNetNode(
      identifier: map['identifier'] as String,
      rssi: map['rssi'] as int?,
      serialNumberString: map['serialNumber'] as String?,
      dfuType: map['dfuType'] != null
          ? DfuDeviceType.fromInt(map['dfuType'] as int)
          : DfuDeviceType.unknown,
    );

    if (map['probes'] != null) {
      final List<dynamic> probesList = map['probes'] as List<dynamic>;
      for (final dynamic probeMap in probesList) {
        final Probe probe = Probe.fromMap(
          Map<String, dynamic>.from(probeMap as Map),
        );
        node.addNetworkedProbe(probe);
      }
    }

    return node;
  }

  /// Registers a probe as reachable through this node.
  void addNetworkedProbe(Probe probe) {
    final int? serialNum = int.tryParse(probe.serialNumber);
    if (serialNum != null) {
      probes[serialNum] = probe;
    }
  }

  /// Whether this node can relay data for the probe with [serialNumber].
  bool hasConnectionToProbe(int serialNumber) {
    return probes.containsKey(serialNumber);
  }

  /// Updates [dfuType] based on the model info string read after connection.
  ///
  /// The firmware reports internal product identifiers in this string. "Timer"
  /// is the internal name for the WiFi Display product, and "Charger" maps to
  /// the charging dock.
  void updateWithModelInfo(String modelInfo) {
    if (modelInfo.contains('Timer')) {
      dfuType = DfuDeviceType.display;
    } else if (modelInfo.contains('Charger')) {
      dfuType = DfuDeviceType.charger;
    }
  }
}
