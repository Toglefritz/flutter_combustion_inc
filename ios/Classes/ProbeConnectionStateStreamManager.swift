import Foundation
import Combine
import CombustionBLE
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

/// Streams connection state changes for a specific probe to Flutter.
///
/// Subscribes to the probe's `$connectionState` Combine publisher and emits
/// integer-encoded state values through the Flutter event sink whenever the
/// connection state changes. This allows Flutter code to react to connection
/// loss, reconnection, and failure events in real time rather than relying on
/// indirect signals like `statusNotificationsStale`.
///
/// Emitted integer values correspond to [DeviceConnectionState] on the Dart
/// side:
/// - 0: disconnected
/// - 1: connecting
/// - 2: connected
/// - 3: failed
public class ProbeConnectionStateStreamManager {

    /// Active Combine subscription for connection state observation.
    ///
    /// Cancelled when `stopConnectionStateStream` is called or when
    /// the manager is deallocated.
    private var cancellable: AnyCancellable?

    /// Flutter event sink for streaming connection state updates.
    ///
    /// Cleared when the stream is stopped to prevent delivering events
    /// after the Flutter listener has unsubscribed.
    private var eventSink: FlutterEventSink?

    /// Creates a new connection state stream manager.
    ///
    /// The manager is inactive until `startConnectionStateStream` is called.
    public init() {}

    /// Begins observing connection state changes for the specified probe.
    ///
    /// Emits the current state immediately on subscription, then emits each
    /// subsequent state transition. Updates are delivered on the main thread
    /// to satisfy Flutter's threading requirements.
    ///
    /// Only one probe can be observed at a time. Calling this method while
    /// already observing a probe will replace the existing subscription.
    ///
    /// - Parameters:
    ///   - probe: The probe whose connection state to observe.
    ///   - eventSink: Flutter event sink for streaming state updates.
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
    ///
    /// Cancels the Combine subscription and clears the event sink. After
    /// calling this method, no further state updates will be sent to Flutter
    /// until `startConnectionStateStream` is called again.
    public func stopConnectionStateStream() {
        cancellable?.cancel()
        cancellable = nil
        eventSink = nil
    }
}

