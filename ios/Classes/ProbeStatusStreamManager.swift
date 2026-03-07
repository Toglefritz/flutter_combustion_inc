import Foundation
import CombustionBLE
import Combine
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

/// Manages real-time status data streams from probes.
///
/// This manager handles streaming of probe status information including battery
/// status and data staleness indicators. It uses Combine publishers to observe
/// status changes and forwards updates through Flutter event sinks.
///
/// Responsibilities:
/// * Streaming battery status updates (ok, low)
/// * Streaming data staleness indicators
/// * Managing Combine subscriptions for status data
/// * Lifecycle management of status streams
///
/// Usage:
/// ```swift
/// let manager = ProbeStatusStreamManager()
/// manager.startBatteryStatusStream(
///     for: probe,
///     eventSink: flutterEventSink
/// )
/// // Later...
/// manager.stopBatteryStatusStream()
/// ```
public class ProbeStatusStreamManager {
    
    /// Event sink for streaming battery status updates to Flutter.
    ///
    /// Battery status values are emitted as strings: "ok" or "low".
    private var batteryStatusEventSink: FlutterEventSink?
    
    /// Combine subscription for battery status updates.
    ///
    /// Observes changes to the probe's batteryStatus property and
    /// forwards updates to the Flutter event sink.
    private var batteryStatusCancellable: AnyCancellable?
    
    /// Event sink for streaming data staleness updates to Flutter.
    ///
    /// Staleness values are emitted as booleans indicating whether
    /// the probe's temperature data has become stale.
    private var statusStaleEventSink: FlutterEventSink?
    
    /// Combine subscription for data staleness updates.
    ///
    /// Observes changes to the probe's statusNotificationsStale property
    /// and forwards updates to the Flutter event sink.
    private var statusStaleCancellable: AnyCancellable?
    
    /// Creates a new status stream manager.
    ///
    /// The manager is initialized in an inactive state. Call the appropriate
    /// start methods to begin streaming status data.
    public init() {}
    
    /// Starts streaming real-time battery status updates for a probe.
    ///
    /// This method establishes a Combine subscription to the probe's
    /// batteryStatus property. Whenever the battery status changes,
    /// an update is sent to Flutter with the new status value.
    ///
    /// Battery status values:
    /// * "ok" - Battery level is sufficient for normal operation
    /// * "low" - Battery level is low and should be replaced soon
    ///
    /// The stream continues until `stopBatteryStatusStream` is called
    /// or the manager is deallocated.
    ///
    /// - Parameters:
    ///   - probe: The probe to monitor for battery status updates
    ///   - eventSink: Flutter event sink for streaming status data
    public func startBatteryStatusStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.batteryStatusEventSink = eventSink
        
        self.batteryStatusCancellable = probe.$batteryStatus
            .sink { [weak self] status in
                self?.batteryStatusEventSink?(status.rawValue)
            }
    }
    
    /// Stops the battery status stream and cleans up resources.
    ///
    /// Cancels the Combine subscription and clears the event sink. After
    /// calling this method, no further battery status updates will be sent
    /// to Flutter until `startBatteryStatusStream` is called again.
    public func stopBatteryStatusStream() {
        self.batteryStatusEventSink = nil
        self.batteryStatusCancellable?.cancel()
        self.batteryStatusCancellable = nil
    }
    
    /// Starts streaming real-time data staleness updates for a probe.
    ///
    /// This method establishes a Combine subscription to the probe's
    /// statusNotificationsStale property. Whenever the staleness state
    /// changes, an update is sent to Flutter with a boolean value.
    ///
    /// Data staleness indicates whether the probe's temperature readings
    /// have not been updated recently, which may indicate connection issues
    /// or that the probe has stopped transmitting data.
    ///
    /// The stream continues until `stopStatusStaleStream` is called
    /// or the manager is deallocated.
    ///
    /// - Parameters:
    ///   - probe: The probe to monitor for staleness updates
    ///   - eventSink: Flutter event sink for streaming staleness data
    public func startStatusStaleStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.statusStaleEventSink = eventSink
        
        self.statusStaleCancellable = probe.$statusNotificationsStale
            .sink { [weak self] isStale in
                self?.statusStaleEventSink?(isStale)
            }
    }
    
    /// Stops the data staleness stream and cleans up resources.
    ///
    /// Cancels the Combine subscription and clears the event sink. After
    /// calling this method, no further staleness updates will be sent
    /// to Flutter until `startStatusStaleStream` is called again.
    public func stopStatusStaleStream() {
        self.statusStaleEventSink = nil
        self.statusStaleCancellable?.cancel()
        self.statusStaleCancellable = nil
    }
}
