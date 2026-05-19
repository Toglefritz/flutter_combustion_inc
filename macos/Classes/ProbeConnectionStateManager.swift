import Foundation
import Combine
import CombustionBLE
import FlutterMacOS

/// Streams connection state changes for a specific probe to Flutter.
///
/// Subscribes to the probe's `$connectionState` Combine publisher and emits
/// integer-encoded state values through the Flutter event sink whenever the
/// connection state changes.
public class ProbeConnectionStateManager {

    /// Active Combine subscription for connection state observation.
    private var cancellable: AnyCancellable?

    /// Flutter event sink for streaming connection state updates.
    private var eventSink: FlutterEventSink?

    /// Creates a new connection state manager.
    public init() {}

    /// Begins observing connection state changes for the specified probe.
    ///
    /// Emits an integer value through the event sink each time the probe's
    /// connection state changes. Values correspond to:
    /// - 0: disconnected
    /// - 1: connecting
    /// - 2: connected
    /// - 3: failed
    ///
    /// - Parameters:
    ///   - probe: The probe whose connection state to observe
    ///   - eventSink: Flutter event sink for streaming updates
    public func startConnectionStateStream(
        for probe: Probe,
        eventSink: @escaping FlutterEventSink
    ) {
        self.eventSink = eventSink

        cancellable = probe.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let sink = self?.eventSink else { return }
                let rawValue: Int
                switch state {
                case .disconnected:
                    rawValue = 0
                case .connecting:
                    rawValue = 1
                case .connected:
                    rawValue = 2
                case .failed:
                    rawValue = 3
                }
                sink(rawValue)
            }
    }

    /// Stops observing connection state and cleans up resources.
    public func stopConnectionStateStream() {
        cancellable?.cancel()
        cancellable = nil
        eventSink = nil
    }
}
