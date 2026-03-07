#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

import CombustionBLE

/// Flutter plugin for Combustion Inc. temperature probes.
///
/// This plugin serves as the primary communication bridge between Flutter
/// applications and Combustion Inc. Bluetooth temperature probes. It delegates
/// specific responsibilities to specialized manager classes while coordinating
/// method channel calls and event channel streams.
///
/// Architecture:
/// The plugin follows a manager-based architecture where each manager handles
/// a specific domain of functionality:
/// * ProbeDiscoveryManager - Probe scanning and discovery
/// * ProbeConnectionManager - Connection lifecycle management
/// * ProbeTemperatureStreamManager - Temperature data streaming
/// * ProbeStatusStreamManager - Battery and staleness status
/// * ProbeSessionManager - Session info and temperature logs
/// * ProbePredictionManager - Temperature predictions and ETAs
///
/// Communication Channels:
/// * Method Channel - One-off commands and queries
/// * Event Channels - Real-time data streams to Flutter
///
/// Usage:
/// The plugin is automatically registered by Flutter when the app starts.
/// Flutter code communicates with the plugin through platform channels.
///
/// Thread Safety:
/// All Flutter communication occurs on the main thread. Manager operations
/// that involve Combine publishers automatically handle thread synchronization.
public class FlutterCombustionIncPlugin: NSObject, FlutterPlugin {
    
    /// Manager for probe discovery and scanning operations.
    ///
    /// Handles periodic polling of discovered probes and streams updates
    /// to Flutter when the probe list changes.
    private let discoveryManager = ProbeDiscoveryManager()
    
    /// Manager for probe connection operations.
    ///
    /// Handles establishing and maintaining connections to specific probes.
    private let connectionManager = ProbeConnectionManager()
    
    /// Manager for temperature data streaming.
    ///
    /// Handles both virtual temperatures (core, surface, ambient) and
    /// raw sensor temperatures (8 sensors) streaming to Flutter.
    private let temperatureStreamManager = ProbeTemperatureStreamManager()
    
    /// Manager for status data streaming.
    ///
    /// Handles battery status and data staleness indicator streaming
    /// to Flutter.
    private let statusStreamManager = ProbeStatusStreamManager()
    
    /// Manager for session information and temperature logs.
    ///
    /// Handles session info retrieval, temperature log access, and
    /// log synchronization progress monitoring.
    private let sessionManager = ProbeSessionManager()
    
    /// Manager for temperature prediction operations.
    ///
    /// Handles setting target temperatures and streaming prediction
    /// information including estimated time to target.
    private let predictionManager = ProbePredictionManager()
    
    /// Cached probe identifiers for stream operations.
    ///
    /// Maps stream types to probe identifiers to enable proper stream
    /// activation when Flutter begins listening to event channels.
    private var pendingStreamProbes: [String: String] = [:]
    
    /// Registers the plugin with the Flutter engine.
    ///
    /// This method is called automatically by Flutter during app initialization.
    /// It sets up all method and event channels for communication between
    /// Flutter and native iOS code.
    ///
    /// Method Channel:
    /// * flutter_combustion_inc - Commands and queries
    ///
    /// Event Channels:
    /// * flutter_combustion_inc_scan - Probe discovery updates
    /// * flutter_combustion_inc_virtual_temps - Virtual temperature stream
    /// * flutter_combustion_inc_current_temperatures - Raw sensor stream
    /// * flutter_combustion_inc_battery_status - Battery status stream
    /// * flutter_combustion_inc_status_stale - Data staleness stream
    /// * flutter_combustion_inc_log_sync_percent - Log sync progress stream
    /// * flutter_combustion_inc_temperature_log - Temperature log data stream
    /// * flutter_combustion_inc_session_info - Session information stream
    /// * flutter_combustion_inc_predictions - Temperature prediction stream
    ///
    /// - Parameter registrar: Flutter plugin registrar provided by the engine
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterCombustionIncPlugin()
        
        // Method channel for commands and queries
        let methodChannel = FlutterMethodChannel(
            name: "flutter_combustion_inc",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        // Event channel for probe discovery
        let probeListChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_scan",
            binaryMessenger: registrar.messenger()
        )
        probeListChannel.setStreamHandler(instance)
        
        // Event channel for virtual temperatures
        let virtualTempChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_virtual_temps",
            binaryMessenger: registrar.messenger()
        )
        virtualTempChannel.setStreamHandler(instance)
        
        // Event channel for raw sensor temperatures
        let currentTempsChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_current_temperatures",
            binaryMessenger: registrar.messenger()
        )
        currentTempsChannel.setStreamHandler(instance)
        
        // Event channel for battery status
        let batteryStatusChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_battery_status",
            binaryMessenger: registrar.messenger()
        )
        batteryStatusChannel.setStreamHandler(instance)
        
        // Event channel for data staleness
        let statusStaleChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_status_stale",
            binaryMessenger: registrar.messenger()
        )
        statusStaleChannel.setStreamHandler(instance)
        
        // Event channel for log sync progress
        let logSyncPercentChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_log_sync_percent",
            binaryMessenger: registrar.messenger()
        )
        logSyncPercentChannel.setStreamHandler(instance)
        
        // Event channel for temperature log data
        let temperatureLogChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_temperature_log",
            binaryMessenger: registrar.messenger()
        )
        temperatureLogChannel.setStreamHandler(instance)
        
        // Event channel for session information
        let sessionInfoChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_session_info",
            binaryMessenger: registrar.messenger()
        )
        sessionInfoChannel.setStreamHandler(instance)
        
        // Event channel for temperature predictions
        let predictionChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_predictions",
            binaryMessenger: registrar.messenger()
        )
        predictionChannel.setStreamHandler(instance)
    }
    
    /// Handles method channel calls from Flutter.
    ///
    /// This method routes incoming method calls to the appropriate manager
    /// and returns results or errors back to Flutter. All operations are
    /// performed on the main thread to ensure thread safety with Flutter.
    ///
    /// Supported Methods:
    /// * initBluetooth - Initialize Bluetooth stack
    /// * getProbes - Get snapshot of discovered probes
    /// * getRssi - Get RSSI for specific probe
    /// * getVirtualTemperatures - Get one-time virtual temperature reading
    /// * getCurrentTemperatures - Get one-time raw sensor reading
    /// * connectToProbe - Connect to specific probe
    /// * startVirtualTemperatureStream - Begin virtual temp streaming
    /// * startCurrentTemperaturesStream - Begin raw sensor streaming
    /// * startBatteryStatusStream - Begin battery status streaming
    /// * startStatusStaleStream - Begin staleness streaming
    /// * startLogSyncPercentStream - Begin log sync progress streaming
    /// * startSessionInfoStream - Begin session info streaming
    /// * refreshSessionInfo - Force session info refresh
    /// * getSessionInfo - Get one-time session info reading
    /// * getTemperatureLog - Get temperature log and start streaming
    /// * setTargetTemperature - Set target temp for predictions
    /// * startPredictionStream - Begin prediction streaming
    ///
    /// - Parameters:
    ///   - call: Method call from Flutter containing method name and arguments
    ///   - result: Callback for returning results or errors to Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initBluetooth":
            handleInitBluetooth(result: result)
            
        case "getProbes":
            handleGetProbes(result: result)
            
        case "getRssi":
            handleGetRssi(call: call, result: result)
            
        case "getVirtualTemperatures":
            handleGetVirtualTemperatures(call: call, result: result)
            
        case "getCurrentTemperatures":
            handleGetCurrentTemperatures(call: call, result: result)
            
        case "connectToProbe":
            handleConnectToProbe(call: call, result: result)
            
        case "startVirtualTemperatureStream":
            handleStartVirtualTemperatureStream(call: call, result: result)
            
        case "startCurrentTemperaturesStream":
            handleStartCurrentTemperaturesStream(call: call, result: result)
            
        case "startBatteryStatusStream":
            handleStartBatteryStatusStream(call: call, result: result)
            
        case "startStatusStaleStream":
            handleStartStatusStaleStream(call: call, result: result)
            
        case "startLogSyncPercentStream":
            handleStartLogSyncPercentStream(call: call, result: result)
            
        case "startSessionInfoStream":
            handleStartSessionInfoStream(call: call, result: result)
            
        case "refreshSessionInfo":
            handleRefreshSessionInfo(call: call, result: result)
            
        case "getSessionInfo":
            handleGetSessionInfo(call: call, result: result)
            
        case "getTemperatureLog":
            handleGetTemperatureLog(call: call, result: result)
            
        case "setTargetTemperature":
            handleSetTargetTemperature(call: call, result: result)
            
        case "startPredictionStream":
            handleStartPredictionStream(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - Method Handlers

extension FlutterCombustionIncPlugin {
    
    /// Initializes the Bluetooth stack and begins scanning for probes.
    ///
    /// This method must be called before any other probe operations.
    /// It initializes the CombustionBLE SDK and starts scanning for
    /// nearby temperature probes.
    ///
    /// - Parameter result: Flutter result callback (returns nil on success)
    private func handleInitBluetooth(result: @escaping FlutterResult) {
        DeviceManager.shared.initBluetooth()
        result(nil)
    }
    
    /// Returns a snapshot of all currently discovered probes.
    ///
    /// - Parameter result: Flutter result callback with array of probe dictionaries
    private func handleGetProbes(result: @escaping FlutterResult) {
        let probes = discoveryManager.getProbes()
        result(probes)
    }
    
    /// Returns the RSSI value for a specific probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback with RSSI value or error
    private func handleGetRssi(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        if let rssi = discoveryManager.getRssi(for: identifier) {
            result(rssi)
        } else {
            result(FlutterError(
                code: "PROBE_NOT_FOUND",
                message: "Probe not found",
                details: nil
            ))
        }
    }
    
    /// Returns a one-time reading of virtual temperatures for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback with temperature dictionary or error
    private func handleGetVirtualTemperatures(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let probe = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        let temps = temperatureStreamManager.getVirtualTemperatures(for: probe)
        result(temps)
    }
    
    /// Returns a one-time reading of raw sensor temperatures for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback with temperature array or error
    private func handleGetCurrentTemperatures(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let probe = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        if let temps = temperatureStreamManager.getCurrentTemperatures(for: probe) {
            result(temps)
        } else {
            result(FlutterError(
                code: "NO_TEMPERATURES",
                message: "Temperature data not available",
                details: nil
            ))
        }
    }
    
    /// Connects to a specific probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleConnectToProbe(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let probe = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        connectionManager.connect(to: probe)
        result(nil)
    }
    
    /// Starts streaming virtual temperature updates for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleStartVirtualTemperatureStream(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let _ = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        pendingStreamProbes["virtualTemps"] = identifier
        result(nil)
    }
    
    /// Starts streaming raw sensor temperature updates for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleStartCurrentTemperaturesStream(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let _ = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        pendingStreamProbes["currentTemperatures"] = identifier
        result(nil)
    }
    
    /// Starts streaming battery status updates for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleStartBatteryStatusStream(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let _ = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        pendingStreamProbes["batteryStatus"] = identifier
        result(nil)
    }
    
    /// Starts streaming data staleness updates for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleStartStatusStaleStream(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let _ = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        pendingStreamProbes["statusStale"] = identifier
        result(nil)
    }
    
    /// Starts streaming log synchronization progress for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleStartLogSyncPercentStream(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let _ = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        pendingStreamProbes["logSyncPercent"] = identifier
        result(nil)
    }
    
    /// Starts streaming session information updates for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleStartSessionInfoStream(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let _ = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        pendingStreamProbes["sessionInfo"] = identifier
        result(nil)
    }
    
    /// Forces a refresh of session information for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleRefreshSessionInfo(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let probe = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        // Trigger reconnection if not connected to force session info refresh
        if probe.connectionState != .connected {
            connectionManager.connect(to: probe)
        }
        
        result(nil)
    }
    
    /// Returns current session information for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback with session info or error
    private func handleGetSessionInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        guard let probe = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "PROBE_NOT_FOUND",
                message: "Probe with identifier '\(identifier)' not found",
                details: nil
            ))
            return
        }
        
        let sessionInfo = sessionManager.getSessionInfo(for: probe)
        result(sessionInfo)
    }
    
    /// Retrieves temperature log and starts streaming data points.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback with log metadata or error
    private func handleGetTemperatureLog(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        guard let probe = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "PROBE_NOT_FOUND",
                message: "Probe with identifier '\(identifier)' not found",
                details: nil
            ))
            return
        }
        
        // Event sink will be set when Flutter starts listening
        // For now, just validate that we can get the log
        do {
            // This will throw if there's no session or log
            _ = try sessionManager.getTemperatureLog(
                for: probe,
                eventSink: { _ in }
            )
            result(nil)
        } catch let error as SessionManagerError {
            result(error.flutterError)
        } catch {
            result(FlutterError(
                code: "UNKNOWN_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }
    
    /// Sets target temperature for prediction calculations.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier and target temperature
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleSetTargetTemperature(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let temperatureCelsius = args["temperatureCelsius"] as? Double else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid arguments. Expected 'identifier' (String) and 'temperatureCelsius' (Double)",
                details: nil
            ))
            return
        }
        
        guard let probe = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "PROBE_NOT_FOUND",
                message: "Probe with identifier '\(identifier)' not found",
                details: nil
            ))
            return
        }
        
        predictionManager.setTargetTemperature(
            for: probe,
            temperatureCelsius: temperatureCelsius
        ) { success in
            if success {
                result(nil)
            } else {
                result(FlutterError(
                    code: "SET_TEMPERATURE_FAILED",
                    message: "Failed to set target temperature. Temperature may be outside valid range or probe may not be connected.",
                    details: [
                        "identifier": identifier,
                        "temperatureCelsius": temperatureCelsius
                    ]
                ))
            }
        }
    }
    
    /// Starts streaming temperature prediction updates for a probe.
    ///
    /// - Parameters:
    ///   - call: Method call containing probe identifier
    ///   - result: Flutter result callback (returns nil on success or error)
    private func handleStartPredictionStream(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let _ = connectionManager.getProbe(identifier: identifier) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier",
                details: nil
            ))
            return
        }
        
        pendingStreamProbes["predictions"] = identifier
        result(nil)
    }
}

// MARK: - FlutterStreamHandler

extension FlutterCombustionIncPlugin: FlutterStreamHandler {
    
    /// Called when Flutter begins listening to an event channel.
    ///
    /// This method determines which stream type is being requested based on
    /// the arguments and activates the appropriate manager with the provided
    /// event sink.
    ///
    /// - Parameters:
    ///   - arguments: Dictionary containing stream type and probe identifier
    ///   - events: Flutter event sink for streaming data
    /// - Returns: FlutterError if setup fails, nil on success
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        guard let args = arguments as? [String: Any],
              let type = args["type"] as? String else {
            // Default to probe list stream if no type specified
            discoveryManager.startDiscovery(eventSink: events)
            return nil
        }
        
        // Get probe identifier from pending streams or arguments
        let identifier: String? = args["identifier"] as? String ?? pendingStreamProbes[type]
        
        guard let probeId = identifier,
              let probe = connectionManager.getProbe(identifier: probeId) else {
            return FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing or invalid probe identifier for stream type: \(type)",
                details: nil
            )
        }
        
        switch type {
        case "virtualTemps":
            temperatureStreamManager.startVirtualTemperatureStream(
                for: probe,
                eventSink: events
            )
            
        case "currentTemperatures":
            temperatureStreamManager.startCurrentTemperaturesStream(
                for: probe,
                eventSink: events
            )
            
        case "batteryStatus":
            statusStreamManager.startBatteryStatusStream(
                for: probe,
                eventSink: events
            )
            
        case "statusStale":
            statusStreamManager.startStatusStaleStream(
                for: probe,
                eventSink: events
            )
            
        case "logSyncPercent":
            sessionManager.startLogSyncPercentStream(
                for: probe,
                eventSink: events
            )
            
        case "sessionInfo":
            sessionManager.startSessionInfoStream(
                for: probe,
                eventSink: events
            )
            
        case "temperatureLog":
            do {
                _ = try sessionManager.getTemperatureLog(
                    for: probe,
                    eventSink: events
                )
            } catch let error as SessionManagerError {
                return error.flutterError
            } catch {
                return FlutterError(
                    code: "UNKNOWN_ERROR",
                    message: error.localizedDescription,
                    details: nil
                )
            }
            
        case "predictions":
            predictionManager.startPredictionStream(
                for: probe,
                eventSink: events
            )
            
        default:
            return FlutterError(
                code: "UNKNOWN_STREAM_TYPE",
                message: "Unknown stream type: \(type)",
                details: nil
            )
        }
        
        return nil
    }
    
    /// Called when Flutter cancels a listener subscription.
    ///
    /// This method determines which stream is being cancelled and deactivates
    /// the appropriate manager to clean up resources.
    ///
    /// - Parameter arguments: Dictionary containing stream type
    /// - Returns: FlutterError if cleanup fails, nil on success
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let args = arguments as? [String: Any],
              let type = args["type"] as? String else {
            // Default to probe list stream if no type specified
            discoveryManager.stopDiscovery()
            return nil
        }
        
        switch type {
        case "virtualTemps":
            temperatureStreamManager.stopVirtualTemperatureStream()
            
        case "currentTemperatures":
            temperatureStreamManager.stopCurrentTemperaturesStream()
            
        case "batteryStatus":
            statusStreamManager.stopBatteryStatusStream()
            
        case "statusStale":
            statusStreamManager.stopStatusStaleStream()
            
        case "logSyncPercent":
            sessionManager.stopLogSyncPercentStream()
            
        case "sessionInfo":
            sessionManager.stopSessionInfoStream()
            
        case "temperatureLog":
            sessionManager.stopTemperatureLogStream()
            
        case "predictions":
            predictionManager.stopPredictionStream()
            
        default:
            return FlutterError(
                code: "UNKNOWN_STREAM_TYPE",
                message: "Unknown stream type: \(type)",
                details: nil
            )
        }
        
        return nil
    }
}
