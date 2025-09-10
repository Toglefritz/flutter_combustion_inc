import 'probe_temperatures.dart';

/// Represents a single logged temperature data point from a Combustion Inc. probe.
///
/// Each data point contains a unique sequence number and a [ProbeTemperatures] instance
/// representing the temperatures recorded by the eight probe sensors.
class ProbeLogDataPoint {
  /// The sequential index of this data point within the temperature log.
  final int sequence;

  /// The structured set of eight temperature readings from the probe.
  final ProbeTemperatures temperatures;

  /// Constructs a [ProbeLogDataPoint] from a [Map] typically received over platform channels.
  ///
  /// The map is expected to contain:
  /// - `sequence`: the sequence number
  /// - `t1` through `t8`: temperature values in Celsius
  ProbeLogDataPoint.fromMap(Map<String, dynamic> map)
    : sequence = map['sequence'] as int,
      temperatures = ProbeTemperatures(
        t1: (map['t1'] as num).toDouble(),
        t2: (map['t2'] as num).toDouble(),
        t3: (map['t3'] as num).toDouble(),
        t4: (map['t4'] as num).toDouble(),
        t5: (map['t5'] as num).toDouble(),
        t6: (map['t6'] as num).toDouble(),
        t7: (map['t7'] as num).toDouble(),
        t8: (map['t8'] as num).toDouble(),
      );
}
