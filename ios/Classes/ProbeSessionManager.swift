import Foundation
import CombustionBLE
import Combine
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

/// Error type for session manager operations.
///
/// This error type wraps FlutterError to make it throwable in Swift.
/// It conforms to the Error protocol and can be caught and converted
/// back to FlutterError for returning to Flutter.
enum SessionManagerError: Error {
    case flutterError(FlutterError)
    
    /// Creates a session manager error from a FlutterError.
    ///
    /// - Parameters:
    ///   - code: Error code for Flutter
    ///   - message: Human-readable error message
    ///   - details: Optional additional error details
    /// - Returns: SessionManagerError wrapping the FlutterError
    static func error(code: String, message: String, details: Any?) -> SessionManagerError {
        return .flutterError(FlutterError(code: code, message: message, details: details))
    }
    
    /// Extracts the wrapped FlutterError.
    ///
    /// - Returns: The FlutterError wrapped by this error
    var flutterError: FlutterError {
        switch self {
        case .flutterError(let error):
            return error
        }
    }
}

/// Manages probe cooking session information and temperature logs.
///
/// This manager handles session information retrieval, temperature log access,
/// and log synchronization progress monitoring. It provides both one-time
/// queries and real-time streaming of session-related data.
///
/// Responsibilities:
/// * Retrieving and streaming session information
/// * Accessing temperature log data
/// * Monitoring log synchronization progress
/// * Managing Combine subscriptions for session data
///
/// Usage:
/// ```swift
/// let manager = ProbeSessionManager()
/// if let sessionInfo = manager.getSessionInfo(for: probe) {
///     print("Sample period: \(sessionInfo["samplePeriod"])")
/// }
/// ```
public class ProbeSessionManager {
    
    /// Event sink for streaming session information updates to Flutter.
    ///
    /// Session information includes availability status and sample period.
    private var sessionInfoEventSink: FlutterEventSink?
    
    /// Combine subscription for session information updates.
    ///
    /// Observes changes to the probe's sessionInformation property and
    /// forwards updates to the Flutter event sink.
    private var sessionInfoCancellable: AnyCancellable?
    
    /// Reference to the probe being monitored for session information.
    ///
    /// Stored to ensure consistency when streaming session updates and
    /// to prevent the probe from being deallocated during monitoring.
    private var sessionInfoProbe: Probe?
    
    /// Event sink for streaming log synchronization progress to Flutter.
    ///
    /// Progress is emitted as a percentage (0.0 to 1.0) indicating how
    /// much of the temperature log has been synchronized from the probe.
    private var logSyncPercentEventSink: FlutterEventSink?
    
    /// Combine subscription for log synchronization progress updates.
    ///
    /// Observes changes to the probe's percentOfLogsSynced property and
    /// forwards updates to the Flutter event sink.
    private var logSyncPercentCancellable: AnyCancellable?
    
    /// Event sink for streaming temperature log data points to Flutter.
    ///
    /// Log data points include sequence number, timestamp, and eight
    /// temperature sensor readings.
    private var temperatureLogEventSink: FlutterEventSink?
    
    /// Timer for periodic polling of temperature log data points.
    ///
    /// Fires every second to check for new log data points and emit
    /// them to Flutter incrementally.
    private var temperatureLogTimer: AnyCancellable?
    
    /// Creates a new session manager.
    ///
    /// The manager is initialized in an inactive state. Call the appropriate
    /// methods to query or stream session data.
    public init() {}
    
    /// Retrieves the current session information for a probe.
    ///
    /// This method returns a snapshot of the probe's session information
    /// including whether a session is active and the sample period.
    ///
    /// - Parameter probe: The probe to query for session information
    /// - Returns: Dictionary containing session availability and sample period,
    ///            or nil values if no session is active
    public func getSessionInfo(for probe: Probe) -> [String: Any] {
        if let sessionInfo = probe.sessionInformation {
            return [
                "hasSession": true,
                "samplePeriod": sessionInfo.samplePeriod
            ]
        } else {
            return [
                "hasSession": false,
                "samplePeriod": NSNull()
            ]
        }
    }
    
    /// Starts streaming real-time session information updates for a probe.
    ///
    /// This method establishes a Combine subscription to the probe's
    /// sessionInformation property. Whenever the session information
    /// changes (becomes available or unavailable), an update is sent
    /// to Flutter.
    ///
    /// Session information includes:
    /// * hasSession - Boolean indicating if a cooking session is active
    /// * samplePeriod - Time interval between temperature log samples
    ///
    /// The stream continues until `stopSessionInfoStream` is called
    /// or the manager is deallocated.
    ///
    /// - Parameters:
    ///   - probe: The probe to monitor for session information updates
    ///   - eventSink: Flutter event sink for streaming session data
    public func startSessionInfoStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.sessionInfoEventSink = eventSink
        self.sessionInfoProbe = probe
        
        self.sessionInfoCancellable = probe.$sessionInformation
            .sink { [weak self] sessionInfo in
                guard let sink = self?.sessionInfoEventSink else { return }
                
                if let sessionInfo = sessionInfo {
                    sink([
                        "hasSession": true,
                        "samplePeriod": sessionInfo.samplePeriod
                    ])
                } else {
                    sink([
                        "hasSession": false,
                        "samplePeriod": NSNull()
                    ])
                }
            }
    }
    
    /// Stops the session information stream and cleans up resources.
    ///
    /// Cancels the Combine subscription, clears the event sink, and releases
    /// the probe reference. After calling this method, no further session
    /// updates will be sent to Flutter until `startSessionInfoStream` is
    /// called again.
    public func stopSessionInfoStream() {
        self.sessionInfoEventSink = nil
        self.sessionInfoCancellable?.cancel()
        self.sessionInfoCancellable = nil
        self.sessionInfoProbe = nil
    }
    
    /// Starts streaming log synchronization progress updates for a probe.
    ///
    /// This method establishes a Combine subscription to the probe's
    /// percentOfLogsSynced property. As temperature logs are downloaded
    /// from the probe, progress updates are sent to Flutter.
    ///
    /// Progress is reported as a decimal value from 0.0 (0%) to 1.0 (100%).
    ///
    /// The stream continues until `stopLogSyncPercentStream` is called
    /// or the manager is deallocated.
    ///
    /// - Parameters:
    ///   - probe: The probe to monitor for log sync progress
    ///   - eventSink: Flutter event sink for streaming progress data
    public func startLogSyncPercentStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.logSyncPercentEventSink = eventSink
        
        self.logSyncPercentCancellable = probe.$percentOfLogsSynced
            .sink { [weak self] percent in
                guard let percent = percent else { return }
                self?.logSyncPercentEventSink?(percent)
            }
    }
    
    /// Stops the log sync progress stream and cleans up resources.
    ///
    /// Cancels the Combine subscription and clears the event sink. After
    /// calling this method, no further progress updates will be sent
    /// to Flutter until `startLogSyncPercentStream` is called again.
    public func stopLogSyncPercentStream() {
        self.logSyncPercentEventSink = nil
        self.logSyncPercentCancellable?.cancel()
        self.logSyncPercentCancellable = nil
    }
    
    /// Retrieves temperature log metadata and starts streaming log data points.
    ///
    /// This method finds the temperature log matching the probe's current
    /// session and begins streaming individual data points to Flutter. Each
    /// data point includes sequence number, timestamp, and eight temperature
    /// sensor readings.
    ///
    /// The method returns immediately with log metadata (start time), while
    /// data points are streamed incrementally through the event sink as they
    /// become available.
    ///
    /// - Parameters:
    ///   - probe: The probe to retrieve temperature logs from
    ///   - eventSink: Flutter event sink for streaming log data points
    /// - Returns: Dictionary containing log metadata (start time)
    /// - Throws: SessionManagerError if session info is missing, no logs are available,
    ///           or no matching log is found for the current session
    public func getTemperatureLog(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) throws -> [String: Any] {
        guard let sessionInfo = probe.sessionInformation else {
            throw SessionManagerError.error(
                code: "NO_SESSION_INFO",
                message: "Probe has no active session information. Start a cooking session first.",
                details: nil
            )
        }
        
        guard !probe.temperatureLogs.isEmpty else {
            throw SessionManagerError.error(
                code: "NO_LOGS_AVAILABLE",
                message: "No temperature logs available on probe. Ensure the probe is connected and logging.",
                details: nil
            )
        }
        
        guard let log = probe.temperatureLogs.first(where: {
            $0.sessionInformation.samplePeriod == sessionInfo.samplePeriod
        }) else {
            throw SessionManagerError.error(
                code: "LOG_NOT_FOUND",
                message: "No matching temperature log found for current session",
                details: nil
            )
        }
        
        self.temperatureLogEventSink = eventSink
        startTemperatureLogStream(for: log)
        
        let startTimeMillis: Any = log.startTime.map {
            Int64($0.timeIntervalSince1970 * 1000)
        } ?? NSNull()
        
        return [
            "startTime": startTimeMillis
        ]
    }
    
    /// Stops the temperature log stream and cleans up resources.
    ///
    /// Cancels the polling timer and clears the event sink. After calling
    /// this method, no further log data points will be sent to Flutter
    /// until `getTemperatureLog` is called again.
    public func stopTemperatureLogStream() {
        self.temperatureLogEventSink = nil
        self.temperatureLogTimer?.cancel()
        self.temperatureLogTimer = nil
    }
    
    /// Starts periodic polling for new temperature log data points.
    ///
    /// This method establishes a timer that checks for new log data points
    /// every second. Only new data points (not previously emitted) are sent
    /// to Flutter to avoid duplicate data.
    ///
    /// Each data point includes:
    /// * sequence - Sequential number of the data point
    /// * startTime - Session start timestamp in milliseconds
    /// * t1-t8 - Eight temperature sensor readings in Celsius
    ///
    /// - Parameter log: The temperature log to monitor for new data points
    private func startTemperatureLogStream(for log: ProbeTemperatureLog) {
        var lastCount: Int = 0
        
        self.temperatureLogTimer = Timer.publish(
            every: 1.0,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            guard let sink = self?.temperatureLogEventSink else { return }
            
            let points = log.dataPoints
            guard points.count > lastCount else { return }
            
            // Only send new data points, not all data points
            let newPoints = Array(points[lastCount...])
            lastCount = points.count
            
            let startTimeMillis: Any = log.startTime.map {
                Int64($0.timeIntervalSince1970 * 1000)
            } ?? NSNull()
            
            let mapped = newPoints.map { point in
                return [
                    "sequence": point.sequenceNum,
                    "startTime": startTimeMillis,
                    "t1": point.temperatures.values[0],
                    "t2": point.temperatures.values[1],
                    "t3": point.temperatures.values[2],
                    "t4": point.temperatures.values[3],
                    "t5": point.temperatures.values[4],
                    "t6": point.temperatures.values[5],
                    "t7": point.temperatures.values[6],
                    "t8": point.temperatures.values[7],
                ]
            }
            
            sink(mapped)
        }
    }
}
