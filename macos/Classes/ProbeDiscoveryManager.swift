import Foundation
import CombustionBLE
import FlutterMacOS

/// Controls which device types are emitted to Flutter during scanning.
///
/// The native SDK always scans for all Combustion BLE advertisements. This
/// filter determines which discovered devices are forwarded through the event
/// sink to the Dart layer.
public enum DeviceScanFilter: Int {
    /// Only emit temperature probes.
    case probesOnly = 0
    /// Only emit MeatNet nodes (boosters, displays, chargers).
    case nodesOnly = 1
    /// Emit all Combustion devices.
    case all = 2
}

/// Manages device discovery and scanning operations.
///
/// Handles periodic polling of the DeviceManager for discovered devices and
/// streams updates to Flutter when the device list changes. Supports filtering
/// by device type so the Dart layer can control what it receives.
public class ProbeDiscoveryManager {

    /// Event sink for streaming discovered devices to Flutter.
    private var eventSink: FlutterEventSink?

    /// Timer for periodic device list polling (fires every 1 second).
    private var updateTimer: Timer?

    /// Cached set of device identifiers from the previous poll.
    private var lastDeviceIdentifiers: Set<String> = []

    /// Current scan filter controlling which device types are emitted.
    private var scanFilter: DeviceScanFilter = .probesOnly

    /// Creates a new discovery manager in an inactive state.
    public init() {}

    /// Updates the scan filter.
    ///
    /// Takes effect on the next poll cycle. Does not require restarting
    /// discovery.
    public func setScanFilter(_ filter: DeviceScanFilter) {
        self.scanFilter = filter
        // Reset cached identifiers so the next poll emits the full set
        // under the new filter.
        self.lastDeviceIdentifiers.removeAll()
    }

    /// Starts periodic polling for device discovery updates.
    ///
    /// Emits devices individually through the event sink whenever the set of
    /// discovered devices changes. Each device is emitted as a dictionary with
    /// a `deviceType` field ("probe" or "node") so the Dart layer can
    /// deserialize to the correct type.
    public func startDiscovery(eventSink: @escaping FlutterEventSink) {
        self.eventSink = eventSink

        self.updateTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.pollForDeviceUpdates()
        }
    }

    /// Stops discovery and cleans up resources.
    public func stopDiscovery() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
        self.eventSink = nil
        self.lastDeviceIdentifiers.removeAll()
    }

    /// Retrieves a snapshot of all currently discovered probes.
    public func getProbes() -> [[String: Any]] {
        return DeviceManager.shared.getProbes().map { probe in
            return probeToDict(probe)
        }
    }

    /// Retrieves the RSSI value for a specific probe.
    public func getRssi(for identifier: String) -> Int? {
        return DeviceManager.shared.getProbes()
            .first(where: { $0.uniqueIdentifier == identifier })?
            .rssi
    }

    /// Polls the DeviceManager for device list changes and emits updates.
    private func pollForDeviceUpdates() {
        guard let sink = self.eventSink else { return }

        var devices: [Device] = []

        switch scanFilter {
        case .probesOnly:
            devices = DeviceManager.shared.getProbes().map { $0 as Device }
        case .nodesOnly:
            devices = DeviceManager.shared.getMeatnetNodes().map { $0 as Device }
        case .all:
            devices = DeviceManager.shared.getDevices()
        }

        let newIdentifiers = Set(devices.map { $0.uniqueIdentifier })

        // Only emit when the device set has changed
        guard newIdentifiers != self.lastDeviceIdentifiers else { return }
        self.lastDeviceIdentifiers = newIdentifiers

        for device in devices {
            if let probe = device as? Probe {
                sink(probeToDict(probe))
            } else if let node = device as? MeatNetNode {
                sink(nodeToDict(node))
            }
        }
    }

    /// Converts a Probe to a dictionary for the Flutter event channel.
    private func probeToDict(_ probe: Probe) -> [String: Any] {
        return [
            "deviceType": "probe",
            "identifier": probe.uniqueIdentifier,
            "serialNumber": probe.serialNumberString,
            "name": probe.name,
            "macAddress": probe.macAddressString,
            "id": probe.id.rawValue,
            "color": probe.color.rawValue,
            "rssi": probe.rssi
        ]
    }

    /// Converts a MeatNetNode to a dictionary for the Flutter event channel.
    private func nodeToDict(_ node: MeatNetNode) -> [String: Any] {
        var dict: [String: Any] = [
            "deviceType": "node",
            "identifier": node.uniqueIdentifier,
            "rssi": node.rssi
        ]
        if let serial = node.serialNumberString {
            dict["serialNumber"] = serial
        }
        // Include the list of probe serial numbers this node can reach
        let networkedProbeSerials = node.probes.values.map { $0.serialNumberString }
        dict["networkedProbes"] = Array(networkedProbeSerials)
        return dict
    }
}
