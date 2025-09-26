import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_combustion_inc_platform_interface.dart';
import 'models/battery_status.dart';
import 'models/prediction_info.dart';
import 'models/probe_temperature_log.dart';
import 'models/probe_temperatures.dart';

/// An implementation of [FlutterCombustionIncPlatform] that uses method channels.
class MethodChannelFlutterCombustionInc extends FlutterCombustionIncPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_combustion_inc');

  /// The event channel used to stream the list of discovered probes.
  @visibleForTesting
  final EventChannel probeListEventChannel = const EventChannel(
    'flutter_combustion_inc_probe_list',
  );

  /// The event channel used to stream virtual temperature updates.
  @visibleForTesting
  final EventChannel virtualTempEventChannel = const EventChannel(
    'flutter_combustion_inc_virtual_temps',
  );

  /// The event channel used to stream battery status updates.
  @visibleForTesting
  final EventChannel batteryStatusEventChannel = const EventChannel(
    'flutter_combustion_inc_battery_status',
  );

  /// The event channel used to stream current temperature updates.
  @visibleForTesting
  final EventChannel currentTempsEventChannel = const EventChannel(
    'flutter_combustion_inc_current_temperatures',
  );

  /// The event channel used to stream status stale updates.
  @visibleForTesting
  final EventChannel statusStaleEventChannel = const EventChannel(
    'flutter_combustion_inc_status_stale',
  );

  /// The event channel used to stream log sync percent updates.
  @visibleForTesting
  final EventChannel logSyncPercentEventChannel = const EventChannel(
    'flutter_combustion_inc_log_sync_percent',
  );

  /// The event channel used to stream temperature log updates.
  @visibleForTesting
  final EventChannel temperatureLogEventChannel = const EventChannel(
    'flutter_combustion_inc_temperature_log',
  );

  /// The event channel used to stream session information updates.
  @visibleForTesting
  final EventChannel sessionInfoEventChannel = const EventChannel(
    'flutter_combustion_inc_session_info',
  );

  /// The event channel used to stream temperature prediction updates.
  @visibleForTesting
  final EventChannel predictionEventChannel = const EventChannel(
    'flutter_combustion_inc_predictions',
  );

  /// A stream that emits a list of discovered probes.
  Stream<List<Map<String, dynamic>>>? _probeListStream;

  /// A map of streams for virtual temperature updates, keyed by probe identifier.
  final Map<String, Stream<Map<String, double>>> _virtualTempStreams = {};

  /// A map of streams for current temperature updates, keyed by probe identifier.
  final Map<String, Stream<ProbeTemperatures>> _currentTempsStreams = {};

  /// A map of streams for log sync percent updates, keyed by probe identifier.
  final Map<String, Stream<double>> _logSyncPercentStreams = {};

  /// A map of streams for session information updates, keyed by probe identifier.
  final Map<String, Stream<Map<String, dynamic>>> _sessionInfoStreams = {};

  /// A map of streams for prediction updates, keyed by probe identifier.
  final Map<String, Stream<PredictionInfo>> _predictionStreams = {};

  @override
  Future<void> initBluetooth() async {
    await methodChannel.invokeMethod('initBluetooth');
  }

  @override
  Stream<List<Map<String, dynamic>>> probeListStream() {
    _probeListStream ??= probeListEventChannel.receiveBroadcastStream().map((
      event,
    ) {
      final List<dynamic> list = event as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    });
    return _probeListStream!;
  }

  @override
  Future<List<Map<String, dynamic>>> getProbes() async {
    final List<dynamic> result =
        await methodChannel.invokeMethod('getProbes') as List<dynamic>;

    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<int> getRssi(String identifier) async {
    final result = await methodChannel.invokeMethod('getRssi', {
      'identifier': identifier,
    });

    if (result == null) {
      throw Exception('Failed to retrieve RSSI');
    }

    return result as int;
  }

  @override
  Future<void> connectToProbe(String identifier) async {
    await methodChannel.invokeMethod('connectToProbe', {
      'identifier': identifier,
    });
  }

  @override
  Stream<bool> statusStaleStream(String identifier) {
    // Start the native stream
    methodChannel.invokeMethod('startStatusStaleStream', {
      'identifier': identifier,
    });

    return statusStaleEventChannel
        .receiveBroadcastStream({'type': 'statusStale'})
        .map((event) => event as bool);
  }

  @override
  Future<void> disconnectFromProbe(String identifier) async {
    await methodChannel.invokeMethod('disconnectFromProbe', {
      'identifier': identifier,
    });
  }

  @override
  Future<Map<String, double>> getVirtualTemperatures(String identifier) async {
    final result = await methodChannel.invokeMethod('getVirtualTemperatures', {
      'identifier': identifier,
    });

    return Map<String, double>.from(result as Map);
  }

  @override
  Future<String> getBatteryStatus(String identifier) async {
    final result = await methodChannel.invokeMethod('getBatteryStatus', {
      'identifier': identifier,
    });
    return result as String;
  }

  @override
  Stream<BatteryStatus> batteryStatusStream(String identifier) {
    // Start the native stream
    methodChannel.invokeMethod('startBatteryStatusStream', {
      'identifier': identifier,
    });

    return batteryStatusEventChannel
        .receiveBroadcastStream({'type': 'batteryStatus'})
        .map((event) => BatteryStatus.fromInt(event as int));
  }

  @override
  Future<ProbeTemperatures> getCurrentTemperatures(String identifier) async {
    final dynamic result = await methodChannel.invokeMethod(
      'getCurrentTemperatures',
      {'identifier': identifier},
    );

    // Convert the result to a list of doubles
    final List<double> values = List<double>.from(result as Iterable);

    // Convert the list to a ProbeTemperatures object. This assumes the list has exactly 8 elements and that they
    // are in the correct order as per the ProbeTemperatures class.
    return ProbeTemperatures(
      t1: values[0],
      t2: values[1],
      t3: values[2],
      t4: values[3],
      t5: values[4],
      t6: values[5],
      t7: values[6],
      t8: values[7],
    );
  }

  @override
  Stream<Map<String, double>> virtualTemperatureStream(String identifier) {
    return _virtualTempStreams.putIfAbsent(identifier, () {
      // Start the native stream
      methodChannel.invokeMethod('startVirtualTemperatureStream', {
        'identifier': identifier,
      });

      return virtualTempEventChannel
          .receiveBroadcastStream({'type': 'virtualTemps'})
          .map((event) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              event as Map,
            );

            return data.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            );
          });
    });
  }

  @override
  Stream<ProbeTemperatures> currentTemperaturesStream(String identifier) {
    return _currentTempsStreams.putIfAbsent(identifier, () {
      methodChannel.invokeMethod('startCurrentTemperaturesStream', {
        'identifier': identifier,
      });

      return currentTempsEventChannel
          .receiveBroadcastStream({'type': 'currentTemperatures'})
          .map((event) {
            final List<double> values = List<double>.from(event as List);
            return ProbeTemperatures(
              t1: values[0],
              t2: values[1],
              t3: values[2],
              t4: values[3],
              t5: values[4],
              t6: values[5],
              t7: values[6],
              t8: values[7],
            );
          });
    });
  }

  @override
  Stream<double> logSyncPercentStream(String identifier) {
    return _logSyncPercentStreams.putIfAbsent(identifier, () {
      methodChannel.invokeMethod('startLogSyncPercentStream', {
        'identifier': identifier,
      });

      return logSyncPercentEventChannel
          .receiveBroadcastStream({'type': 'logSyncPercent'})
          .map((event) => (event as num).toDouble());
    });
  }

  @override
  Future<ProbeTemperatureLog> getTemperatureLog(String identifier) async {
    // Request log metadata and initiate the stream from the native side
    final dynamic rawResult = await methodChannel.invokeMethod(
      'getTemperatureLog',
      {'identifier': identifier},
    );

    final Map<String, dynamic> result = Map<String, dynamic>.from(
      rawResult as Map,
    );

    final int? startTimeMillis = result['startTime'] is int
        ? result['startTime'] as int
        : null;
    final DateTime? startTime = startTimeMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(startTimeMillis)
        : null;

    // Subscribe to the EventChannel for streaming data points
    final Stream<List<Map<String, dynamic>>> rawStream =
        temperatureLogEventChannel
            .receiveBroadcastStream({'type': 'temperatureLog'})
            .map((event) {
              final List<dynamic> rawList = event as List<dynamic>;
              return rawList
                  .map((item) => Map<String, dynamic>.from(item as Map))
                  .toList();
            });

    return ProbeTemperatureLog(startTime: startTime, rawStream: rawStream);
  }

  @override
  Stream<Map<String, dynamic>> sessionInfoStream(String identifier) {
    return _sessionInfoStreams.putIfAbsent(identifier, () {
      // Start the native stream
      methodChannel.invokeMethod('startSessionInfoStream', {
        'identifier': identifier,
      });

      return sessionInfoEventChannel
          .receiveBroadcastStream({'type': 'sessionInfo'})
          .map((event) => Map<String, dynamic>.from(event as Map));
    });
  }

  @override
  Future<Map<String, dynamic>> getSessionInfo(String identifier) async {
    final dynamic rawResult = await methodChannel.invokeMethod(
      'getSessionInfo',
      {'identifier': identifier},
    );

    return Map<String, dynamic>.from(rawResult as Map);
  }

  @override
  Future<void> refreshSessionInfo(String identifier) async {
    await methodChannel.invokeMethod('refreshSessionInfo', {
      'identifier': identifier,
    });
  }

  @override
  Future<void> setTargetTemperature(
    String identifier,
    double temperatureCelsius,
  ) async {
    await methodChannel.invokeMethod('setTargetTemperature', {
      'identifier': identifier,
      'temperatureCelsius': temperatureCelsius,
    });
  }

  @override
  Stream<PredictionInfo> predictionStream(String identifier) {
    return _predictionStreams.putIfAbsent(identifier, () {
      // Start the native stream
      methodChannel.invokeMethod('startPredictionStream', {
        'identifier': identifier,
      });

      return predictionEventChannel
          .receiveBroadcastStream({'type': 'predictions'})
          .map((event) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              event as Map,
            );
            return PredictionInfo.fromMap(data);
          });
    });
  }
}
