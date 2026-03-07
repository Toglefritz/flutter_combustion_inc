import Foundation
import CombustionBLE
import Combine
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

/// Manages real-time temperature data streams from probes.
///
/// This manager handles streaming of both virtual temperatures (core, surface,
/// ambient) and raw sensor temperatures (8 sensors) from connected probes to
/// Flutter. It uses Combine publishers to observe temperature changes and
/// forwards updates through Flutter event sinks.
///
/// Responsibilities:
/// * Streaming virtual temperature updates (core, surface, ambient)
/// * Streaming raw sensor temperature updates (8 sensors)
/// * Managing Combine subscriptions for temperature data
/// * Lifecycle management of temperature streams
///
/// Usage:
/// ```swift
/// let manager = ProbeTemperatureStreamManager()
/// manager.startVirtualTemperatureStream(
///     for: probe,
///     eventSink: flutterEventSink
/// )
/// // Later...
/// manager.stopVirtualTemperatureStream()
/// ```
public class ProbeTemperatureStreamManager {
    
    /// Event sink for streaming virtual temperature updates to Flutter.
    ///
    /// Virtual temperatures include core, surface, and ambient readings
    /// calculated by the probe's internal algorithms.
    private var virtualTempEventSink: FlutterEventSink?
    
    /// Combine subscription for virtual temperature updates.
    ///
    /// Observes changes to the probe's virtualTemperatures property and
    /// forwards updates to the Flutter event sink.
    private var virtualTempCancellable: AnyCancellable?
    
    /// Event sink for streaming raw sensor temperature updates to Flutter.
    ///
    /// Raw temperatures are the eight individual sensor readings from
    /// the probe's temperature sensors.
    private var currentTempsEventSink: FlutterEventSink?
    
    /// Combine subscription for raw sensor temperature updates.
    ///
    /// Observes changes to the probe's currentTemperatures property and
    /// forwards the eight sensor values to the Flutter event sink.
    private var currentTempsCancellable: AnyCancellable?
    
    /// Creates a new temperature stream manager.
    ///
    /// The manager is initialized in an inactive state. Call the appropriate
    /// start methods to begin streaming temperature data.
    public init() {}
    
    /// Retrieves a one-time snapshot of virtual temperatures for a probe.
    ///
    /// This method returns the current virtual temperature readings without
    /// establishing a continuous stream. Use `startVirtualTemperatureStream`
    /// for real-time updates.
    ///
    /// - Parameter probe: The probe to query for temperatures
    /// - Returns: Dictionary containing core, surface, and ambient temperatures,
    ///            or nil values if temperatures are not available
    public func getVirtualTemperatures(for probe: Probe) -> [String: Any] {
        let temps = probe.virtualTemperatures
        return [
            "core": temps?.coreTemperature ?? NSNull(),
            "surface": temps?.surfaceTemperature ?? NSNull(),
            "ambient": temps?.ambientTemperature ?? NSNull(),
        ]
    }
    
    /// Retrieves a one-time snapshot of raw sensor temperatures for a probe.
    ///
    /// This method returns the current readings from all eight temperature
    /// sensors without establishing a continuous stream. Use
    /// `startCurrentTemperaturesStream` for real-time updates.
    ///
    /// - Parameter probe: The probe to query for temperatures
    /// - Returns: Array of eight temperature values in Celsius, or nil if
    ///            temperatures are not available
    public func getCurrentTemperatures(for probe: Probe) -> [Double]? {
        return probe.currentTemperatures?.values
    }
    
    /// Starts streaming real-time virtual temperature updates for a probe.
    ///
    /// This method establishes a Combine subscription to the probe's
    /// virtualTemperatures property. Whenever the temperatures change,
    /// an update is sent to Flutter containing the core, surface, and
    /// ambient temperature values.
    ///
    /// The stream continues until `stopVirtualTemperatureStream` is called
    /// or the manager is deallocated.
    ///
    /// - Parameters:
    ///   - probe: The probe to monitor for temperature updates
    ///   - eventSink: Flutter event sink for streaming temperature data
    public func startVirtualTemperatureStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.virtualTempEventSink = eventSink
        
        self.virtualTempCancellable = probe.$virtualTemperatures
            .sink { [weak self] temps in
                guard let sink = self?.virtualTempEventSink, let temps = temps else {
                    return
                }
                
                sink([
                    "core": temps.coreTemperature,
                    "surface": temps.surfaceTemperature,
                    "ambient": temps.ambientTemperature,
                ])
            }
    }
    
    /// Stops the virtual temperature stream and cleans up resources.
    ///
    /// Cancels the Combine subscription and clears the event sink. After
    /// calling this method, no further temperature updates will be sent
    /// to Flutter until `startVirtualTemperatureStream` is called again.
    public func stopVirtualTemperatureStream() {
        self.virtualTempEventSink = nil
        self.virtualTempCancellable?.cancel()
        self.virtualTempCancellable = nil
    }
    
    /// Starts streaming real-time raw sensor temperature updates for a probe.
    ///
    /// This method establishes a Combine subscription to the probe's
    /// currentTemperatures property. Whenever the sensor readings change,
    /// an update is sent to Flutter containing all eight temperature values.
    ///
    /// The stream continues until `stopCurrentTemperaturesStream` is called
    /// or the manager is deallocated.
    ///
    /// - Parameters:
    ///   - probe: The probe to monitor for temperature updates
    ///   - eventSink: Flutter event sink for streaming temperature data
    public func startCurrentTemperaturesStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.currentTempsEventSink = eventSink
        
        self.currentTempsCancellable = probe.$currentTemperatures
            .sink { [weak self] temperatures in
                guard let sink = self?.currentTempsEventSink,
                      let values = temperatures?.values else {
                    return
                }
                
                sink(values)
            }
    }
    
    /// Stops the raw sensor temperature stream and cleans up resources.
    ///
    /// Cancels the Combine subscription and clears the event sink. After
    /// calling this method, no further temperature updates will be sent
    /// to Flutter until `startCurrentTemperaturesStream` is called again.
    public func stopCurrentTemperaturesStream() {
        self.currentTempsEventSink = nil
        self.currentTempsCancellable?.cancel()
        self.currentTempsCancellable = nil
    }
}
