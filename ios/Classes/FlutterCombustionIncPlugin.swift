import Flutter
import CombustionBLE
import UIKit
import Combine

/// `FlutterCombustionIncPlugin` is the iOS-side implementation of the
/// flutter_combustion_inc plugin. It uses Flutter method and event channels
/// to connect Flutter apps to Combustion Inc. temperature probes.
///
/// This class acts as a communication bridge, relaying probe information such as:
/// - Probe discovery and connection status
/// - Virtual temperature data (core, surface, ambient)
/// - Battery status updates
///
/// The plugin listens to probe events using Combine publishers and streams
/// real-time updates to the Dart layer through `FlutterEventSink`s.
public class FlutterCombustionIncPlugin: NSObject, FlutterPlugin {
    
    /// Stream for probe scan results triggered via EventChannel.
    /// Sends discovered probes to Dart during active scanning.
    private var scanEventSink: FlutterEventSink?
    
    /// Stream for the complete list of nearby discovered probes.
    /// Used for regularly emitting full probe snapshots.
    private var probeListEventSink: FlutterEventSink?
    
    /// Timer to periodically check for updates to the probe list.
    private var probeListUpdateTimer: Timer?
    
    /// Most recent snapshot of probe identifiers.
    private var lastProbeIdentifiers: Set<String> = []

    /// Used to emit real-time virtual temperature readings (core, surface, ambient)
    /// from a connected probe to Flutter.
    private var virtualTempEventSink: FlutterEventSink?

    /// Combine subscription to virtual temperature updates.
    private var virtualTempCancellable: AnyCancellable?
    
    /// Used to emit battery status changes from a probe ("ok" or "low") to Flutter.
    private var batteryStatusSink: FlutterEventSink?

    /// Combine subscription to battery status updates.
    private var batteryStatusCancellable: AnyCancellable?

    /// Used to emit updates for the raw sensor temperatures (8 probes) to Flutter.
    private var currentTempsSink: FlutterEventSink?

    /// Combine subscription to current temperature updates.
    private var currentTempsCancellable: AnyCancellable?

    /// Registers the plugin with the Flutter engine and sets up method and event channels.
    ///
    /// - Parameters:
    ///   - registrar: The FlutterPluginRegistrar provided by the Flutter engine.
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Create a shared plugin instance
        let instance = FlutterCombustionIncPlugin()
        
        // Method channel for one-off method calls (e.g., connect, disconnect, etc.)
        let methodChannel = FlutterMethodChannel(
            name: "flutter_combustion_inc",
            binaryMessenger: registrar.messenger()
        )
        
        // Event channel for continuous scan results.
        let probeListChannel = FlutterEventChannel(
          name: "flutter_combustion_inc_scan",
          binaryMessenger: registrar.messenger()
        )
        probeListChannel.setStreamHandler(instance)
        
        let virtualTempChannel = FlutterEventChannel(
          name: "flutter_combustion_inc_virtual_temps",
          binaryMessenger: registrar.messenger()
        )
        virtualTempChannel.setStreamHandler(instance)
        
        let currentTempsChannel = FlutterEventChannel(
          name: "flutter_combustion_inc_current_temperatures",
          binaryMessenger: registrar.messenger()
        )
        currentTempsChannel.setStreamHandler(instance)
        
        let batteryStatusChannel = FlutterEventChannel(
          name: "flutter_combustion_inc_battery_status",
          binaryMessenger: registrar.messenger()
        )
        batteryStatusChannel.setStreamHandler(instance)
        
        // Register the method and event channel handlers
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
    }
    
    /// Handles method channel calls from Flutter.
    ///
    /// - Parameters:
    ///   - call: The method call from Dart.
    ///   - result: Callback for sending a result or error back to Dart.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        // Initializes the Bluetooth stack in the Combustion SDK and begins scanning.
        case "initBluetooth":
            DeviceManager.shared.initBluetooth()
            result(nil)
       
        // Returns a snapshot list of all probes currently known to the DeviceManager.
        case "getProbes":
            let probes = DeviceManager.shared.getProbes().map { probe in
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
            result(probes)
            
        // Retrieves a one-time reading of virtual temperatures for a specific probe.
        // The result contains `core`, `surface`, and `ambient` temperature values.
        case "getVirtualTemperatures":
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let probe = DeviceManager.shared.getProbes().first(where: { $0.uniqueIdentifier == identifier })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid probe identifier", details: nil))
                return
            }

            let temps = probe.virtualTemperatures
            result([
                "core": temps?.coreTemperature,
                "surface": temps?.surfaceTemperature,
                "ambient": temps?.ambientTemperature,
            ])
            
        // Retrieves all eight raw sensor temperatures from the specified probe.
        // The values are returned in Celsius as a list of eight doubles.
        case "getCurrentTemperatures":
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let probe = DeviceManager.shared.getProbes().first(where: { $0.uniqueIdentifier == identifier }),
                let temps = probe.currentTemperatures?.values
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid probe identifier", details: nil))
                return
            }
            // Return as a list of doubles for Dart to convert to ProbeTemperatures.
            result(temps)
            
        // Starts streaming live virtual temperature updates for the specified probe.
        // Uses Combine to observe the `virtualTemperatures` property.
        case "startVirtualTemperatureStream":
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let probe = DeviceManager.shared.getProbes().first(where: { $0.uniqueIdentifier == identifier })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid probe identifier", details: nil))
                return
            }

            virtualTempCancellable = probe.$virtualTemperatures
                .sink { [weak self] temps in
                    guard let sink = self?.virtualTempEventSink, let temps = temps else { return }
                    sink([
                        "core": temps.coreTemperature,
                        "surface": temps.surfaceTemperature,
                        "ambient": temps.ambientTemperature,
                    ])
                }
            result(nil)
            
        // Starts streaming live battery status updates ("ok" or "low") for a probe.
        case "startBatteryStatusStream":
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let probe = DeviceManager.shared.getProbes().first(where: { $0.uniqueIdentifier == identifier })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid probe identifier", details: nil))
                return
            }

            batteryStatusCancellable = probe.$batteryStatus
                .sink { [weak self] status in
                    self?.batteryStatusSink?(status.rawValue)
                }

            result(nil)
            
        // Initiates a connection to the specified probe and enables automatic reconnection.
        case "connectToProbe":
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let probe = DeviceManager.shared.getProbes().first(where: { $0.uniqueIdentifier == identifier })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid probe identifier", details: nil))
                return
            }

            probe.connect()
            result(nil)
            
        // Starts streaming live current temperatures (8 sensors) for the specified probe.
        case "startCurrentTemperaturesStream":
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let probe = DeviceManager.shared.getProbes().first(where: { $0.uniqueIdentifier == identifier })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid probe identifier", details: nil))
                return
            }

            currentTempsCancellable = probe.$currentTemperatures
                .sink { [weak self] temperatures in
                    guard let sink = self?.currentTempsSink, let values = temperatures?.values else { return }
                    sink(values)
                }

            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension FlutterCombustionIncPlugin: FlutterStreamHandler {
    /// Called when Flutter begins listening to an EventChannel.
    /// Determines the channel type based on the `type` argument and sets the correct event sink.
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let args = arguments as? [String: Any] {
            switch args["type"] as? String {
            case "virtualTemps":
                self.virtualTempEventSink = events
                return nil
            case "batteryStatus":
                self.batteryStatusSink = events
                return nil
            case "currentTemperatures":
                self.currentTempsSink = events
                return nil
            default:
                break
            }
        }

        self.probeListEventSink = events
        startProbeListStream()
        return nil
    }

    /// Called when Flutter cancels a listener subscription on an EventChannel.
    /// Cleans up Combine subscriptions and disables any ongoing emissions.
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let args = arguments as? [String: Any] {
            switch args["type"] as? String {
            case "virtualTemps":
                self.virtualTempEventSink = nil
                self.virtualTempCancellable?.cancel()
                self.virtualTempCancellable = nil
                return nil
            case "batteryStatus":
                self.batteryStatusSink = nil
                self.batteryStatusCancellable?.cancel()
                self.batteryStatusCancellable = nil
                return nil
            case "currentTemperatures":
                self.currentTempsSink = nil
                self.currentTempsCancellable?.cancel()
                self.currentTempsCancellable = nil
                return nil
            default:
                break
            }
        }

        stopProbeListStream()
        self.probeListEventSink = nil
        return nil
    }

    
    /// Periodically polls the DeviceManager for updated probe lists and emits each
    /// discovered probe individually via `probeListEventSink`.
    /// Only emits updates when the set of discovered probe identifiers changes.
    private func startProbeListStream() {
        self.probeListUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let sink = self.probeListEventSink else { return }
            let probes = DeviceManager.shared.getProbes()
            let newIdentifiers = Set(probes.map { $0.uniqueIdentifier })

            if newIdentifiers != self.lastProbeIdentifiers {
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
    }

    /// Stops the periodic timer for emitting the probe list and clears state.
    private func stopProbeListStream() {
        self.probeListUpdateTimer?.invalidate()
        self.probeListUpdateTimer = nil
        self.lastProbeIdentifiers.removeAll()
    }
}
