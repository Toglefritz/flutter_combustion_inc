import 'probe_log_data_point.dart';

/// A stream-based abstraction representing the temperature log of a probe session.
///
/// This wraps a raw stream of batches of temperature data and emits individual [ProbeLogDataPoint] objects to
/// subscribers.
class ProbeTemperatureLog {
  /// The stream of temperature data points for this log session.
  final Stream<ProbeLogDataPoint> dataStream;

  /// The start time of the log session.
  final DateTime? startTime;

  /// Creates a [ProbeTemperatureLog] from a [startTime] and a stream of raw data batches.
  ///
  /// The [rawStream] should emit lists of maps, where each map represents a temperature data point.
  /// The [startTime] is provided separately from the stream.
  ProbeTemperatureLog({
    required Stream<List<Map<String, dynamic>>> rawStream,
    required this.startTime,
  }) : dataStream = rawStream.expand((batch) => batch).map(ProbeLogDataPoint.fromMap);
}
