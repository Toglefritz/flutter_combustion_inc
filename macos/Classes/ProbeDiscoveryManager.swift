import Foundation
import CombustionBLE
import FlutterMacOS

/// Manages probe discovery and scanning operations.
///
/// This manager handles the periodic polling of the DeviceManager for discovered
/// probes and streams updates to Flutter when the probe list changes. It maintains
/// a snapshot of previously discovered probes to avoid redundant updates.
///
/// Responsibilities:
/// * Periodic polling of DeviceManager for probe list updates
/// * Change detection to minimize unnecessary Flutter updates
/// * Streaming probe discovery events to Flutter via EventChannel
/// * Lifecycle management of the discovery timer
///
/// Usage:
/// ```swift
/// let manager = ProbeDiscoveryManager()
/// manager.startDiscovery(eventSink: flutterEventSink)
/// // Later...
/// manager.stopDiscovery()
/// ```
public class ProbeDiscoveryManager {
    
    /// Event sink for streaming discovered probes to Flutter.
    ///
    /// When set, probe discovery updates are sent through this sink.
    /// Each probe is emitted individually as a dictionary containing
    /// identifier, serial number, name, MAC address, ID, color, and RSSI.
    private var eventSink: FlutterEventSink?
    
    /// Timer for periodic probe list polling.
    ///
    /// Fires every 1 second to check for changes in the discovered probe list.
    /// Automatically invalidated when discovery is stopped.
    private var updateTimer: Timer?
    
    /// Cached set of probe identifiers from the previous poll.
    ///
    /// Used for change detection to avoid emitting duplicate probe lists
    /// when no new probes have been discovered or removed.
    private var lastProbeIdentifiers: Set<String> = []
    
    /// Creates a new probe discovery manager.
    ///
    /// The manager is initialized in an inactive state. Call `startDiscovery`
    /// to begin polling for probe updates.
    public init() {}
    
    /// Starts periodic polling for probe discovery updates.
    ///
    /// This method initiates a timer that polls the DeviceManager every second
    /// for changes to the discovered probe list. When changes are detected,
    /// all probes are emitted individually through the provided event sink.
    ///
    /// Only probes that have changed (added or removed) trigger updates to
    /// minimize unnecessary data transfer to Flutter.
    ///
    /// - Parameter eventSink: Flutter event sink for streaming probe updates
    public func startDiscovery(eventSink: @escaping FlutterEventSink) {
        self.eventSink = eventSink
        
        self.updateTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.pollForProbeUpdates()
        }
    }
    
    /// Stops probe discovery and cleans up resources.
    ///
    /// Invalidates the polling timer, clears the event sink, and resets
    /// the cached probe identifier set. After calling this method, no
    /// further probe updates will be emitted until `startDiscovery` is
    /// called again.
    public func stopDiscovery() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
        self.eventSink = nil
        self.lastProbeIdentifiers.removeAll()
    }
    
    /// Retrieves a snapshot of all currently discovered probes.
    ///
    /// This method queries the DeviceManager for the current list of probes
    /// and converts each probe into a dictionary suitable for Flutter consumption.
    ///
    /// - Returns: Array of probe dictionaries containing all probe metadata
    public func getProbes() -> [[String: Any]] {
        return DeviceManager.shared.getProbes().map { probe in
            return [
                "identifier": probe.uniqueIdentifier,
                "serialNumber": probe.serialNumberString,
                "name": probe.name,
                "macAddress": probe.macAddressString,
                "id": probe.id.rawValue,
                "color": probe.color.rawValue,
                "rssi": probe.rssi
            ]
        }
    }
    
    /// Retrieves the RSSI value for a specific probe.
    ///
    /// - Parameter identifier: Unique identifier of the probe
    /// - Returns: RSSI value if probe is found, nil otherwise
    public func getRssi(for identifier: String) -> Int? {
        return DeviceManager.shared.getProbes()
            .first(where: { $0.uniqueIdentifier == identifier })?
            .rssi
    }
    
    /// Polls the DeviceManager for probe list changes and emits updates.
    ///
    /// This method is called periodically by the update timer. It compares
    /// the current set of probe identifiers with the cached set from the
    /// previous poll. If changes are detected, all probes are emitted
    /// individually through the event sink.
    ///
    /// Performance: O(n) where n is the number of discovered probes.
    /// Change detection is O(1) using Set comparison.
    private func pollForProbeUpdates() {
        guard let sink = self.eventSink else { return }
        
        let probes = DeviceManager.shared.getProbes()
        let newIdentifiers = Set(probes.map { $0.uniqueIdentifier })
        
        // Only emit updates when the probe list has changed
        guard newIdentifiers != self.lastProbeIdentifiers else { return }
        
        self.lastProbeIdentifiers = newIdentifiers
        
        for probe in probes {
            let probeDict: [String: Any] = [
                "identifier": probe.uniqueIdentifier,
                "serialNumber": probe.serialNumberString,
                "name": probe.name,
                "macAddress": probe.macAddressString,
                "id": probe.id.rawValue,
                "color": probe.color.rawValue,
                "rssi": probe.rssi
            ]
            sink(probeDict)
        }
    }
}
