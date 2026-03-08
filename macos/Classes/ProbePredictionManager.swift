import Foundation
import CombustionBLE
import Combine
import FlutterMacOS

/// Manages temperature prediction operations for probes.
///
/// This manager handles setting target temperatures and streaming prediction
/// information including estimated time to reach target temperature. It uses
/// the DeviceManager to configure predictions and Combine publishers to
/// observe prediction updates.
///
/// Responsibilities:
/// * Setting target temperatures for prediction calculations
/// * Streaming real-time prediction updates (ETA, reliability)
/// * Managing Combine subscriptions for prediction data
/// * Lifecycle management of prediction streams
///
/// Usage:
/// ```swift
/// let manager = ProbePredictionManager()
/// manager.setTargetTemperature(
///     for: probe,
///     temperatureCelsius: 65.0
/// ) { success in
///     if success {
///         manager.startPredictionStream(for: probe, eventSink: sink)
///     }
/// }
/// ```
public class ProbePredictionManager {
    
    /// Event sink for streaming prediction updates to Flutter.
    ///
    /// Prediction data includes estimated time remaining, target temperature,
    /// current core temperature, reliability status, and timestamp.
    private var predictionEventSink: FlutterEventSink?
    
    /// Combine subscription for prediction information updates.
    ///
    /// Observes changes to the probe's predictionInfo property and
    /// forwards updates to the Flutter event sink.
    private var predictionCancellable: AnyCancellable?
    
    /// Creates a new prediction manager.
    ///
    /// The manager is initialized in an inactive state. Call
    /// `setTargetTemperature` to configure predictions and
    /// `startPredictionStream` to begin receiving updates.
    public init() {}
    
    /// Sets the target temperature for prediction calculations.
    ///
    /// This method configures the probe to calculate predictions for when
    /// the food will reach the specified target temperature. Once set, the
    /// probe begins generating prediction information including estimated
    /// time to completion.
    ///
    /// The target temperature must be within the probe's valid range
    /// (typically 0°C to 100°C for food safety). The probe must be
    /// connected for this operation to succeed.
    ///
    /// - Parameters:
    ///   - probe: The probe to configure for predictions
    ///   - temperatureCelsius: Target temperature in Celsius
    ///   - completion: Callback invoked with success status when operation completes
    public func setTargetTemperature(
        for probe: Probe,
        temperatureCelsius: Double,
        completion: @escaping (Bool) -> Void
    ) {
        DeviceManager.shared.setRemovalPrediction(
            probe,
            removalTemperatureC: temperatureCelsius
        ) { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    /// Starts streaming real-time prediction updates for a probe.
    ///
    /// This method establishes a Combine subscription to the probe's
    /// predictionInfo property. Whenever prediction information changes,
    /// an update is sent to Flutter with the latest prediction data.
    ///
    /// Prediction data includes:
    /// * estimatedTimeSeconds - Seconds remaining until target temperature (nullable)
    /// * targetTemperatureCelsius - The configured target temperature
    /// * currentCoreTempCelsius - Current core temperature reading from virtual sensors
    /// * estimatedCoreTemperature - SDK's estimated core temperature for prediction
    /// * percentThroughCook - Integer percentage of cooking progress (0-100)
    /// * predictionState - Current state (probeNotInserted, probeInserted, cooking, predicting, etc.)
    /// * predictionMode - Prediction mode (none, timeToRemoval, removalAndResting, reserved)
    /// * predictionType - Type of prediction (none, removal, resting, reserved)
    /// * isReliable - Whether the prediction is considered reliable
    /// * timestampMillis - Timestamp of the prediction in milliseconds
    ///
    /// Note: A target temperature must be set using `setTargetTemperature`
    /// before the probe will generate prediction information.
    ///
    /// The stream continues until `stopPredictionStream` is called
    /// or the manager is deallocated.
    ///
    /// - Parameters:
    ///   - probe: The probe to monitor for prediction updates
    ///   - eventSink: Flutter event sink for streaming prediction data
    public func startPredictionStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.predictionEventSink = eventSink
        
        self.predictionCancellable = probe.$predictionInfo
            .sink { [weak self] predictionInfo in
                guard let sink = self?.predictionEventSink,
                      let info = predictionInfo else {
                    return
                }
                
                // Determine reliability based on prediction state
                // If probe is not inserted, predictions are unreliable
                let isReliable: Bool = info.predictionState != .probeNotInserted
                
                let predictionData: [String: Any] = [
                    "estimatedTimeSeconds": info.secondsRemaining ?? NSNull(),
                    "targetTemperatureCelsius": info.predictionSetPointTemperature,
                    "currentCoreTempCelsius": probe.virtualTemperatures?.coreTemperature ?? NSNull(),
                    "estimatedCoreTemperature": info.estimatedCoreTemperature,
                    "percentThroughCook": info.percentThroughCook,
                    "predictionState": info.predictionState.toString(),
                    "predictionStateRaw": info.predictionState.rawValue,
                    "predictionMode": info.predictionMode.toString(),
                    "predictionModeRaw": info.predictionMode.rawValue,
                    "predictionType": info.predictionType.toString(),
                    "predictionTypeRaw": info.predictionType.rawValue,
                    "isReliable": isReliable,
                    "timestampMillis": Int64(Date().timeIntervalSince1970 * 1000)
                ]
                
                sink(predictionData)
            }
    }
    
    /// Stops the prediction stream and cleans up resources.
    ///
    /// Cancels the Combine subscription and clears the event sink. After
    /// calling this method, no further prediction updates will be sent
    /// to Flutter until `startPredictionStream` is called again.
    public func stopPredictionStream() {
        self.predictionEventSink = nil
        self.predictionCancellable?.cancel()
        self.predictionCancellable = nil
    }
}
