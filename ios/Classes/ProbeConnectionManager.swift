import Foundation
import CombustionBLE

/// Manages probe connection operations and lifecycle.
///
/// This manager handles establishing and maintaining connections to Combustion
/// temperature probes. It provides a simple interface for connecting to probes
/// and retrieving probe references from the DeviceManager.
///
/// Responsibilities:
/// * Initiating connections to specific probes
/// * Retrieving probe references by identifier
/// * Managing connection lifecycle through the CombustionBLE SDK
///
/// Usage:
/// ```swift
/// let manager = ProbeConnectionManager()
/// if let probe = manager.getProbe(identifier: "ABC123") {
///     manager.connect(to: probe)
/// }
/// ```
public class ProbeConnectionManager {
    
    /// Creates a new probe connection manager.
    ///
    /// The manager uses the shared DeviceManager instance from the
    /// CombustionBLE SDK for all probe operations.
    public init() {}
    
    /// Retrieves a probe reference by its unique identifier.
    ///
    /// This method searches the DeviceManager's list of discovered probes
    /// for a probe matching the specified identifier.
    ///
    /// - Parameter identifier: Unique identifier of the probe to retrieve
    /// - Returns: Probe instance if found, nil otherwise
    public func getProbe(identifier: String) -> Probe? {
        return DeviceManager.shared.getProbes()
            .first(where: { $0.uniqueIdentifier == identifier })
    }
    
    /// Initiates a connection to the specified probe.
    ///
    /// This method establishes a Bluetooth connection to the probe and
    /// enables automatic reconnection if the connection is lost. The
    /// connection process is asynchronous and connection status updates
    /// are available through the probe's connection state property.
    ///
    /// The probe must be discovered and within Bluetooth range for the
    /// connection to succeed. Connection failures are handled internally
    /// by the CombustionBLE SDK with automatic retry logic.
    ///
    /// - Parameter probe: The probe to connect to
    public func connect(to probe: Probe) {
        probe.connect()
    }
}
