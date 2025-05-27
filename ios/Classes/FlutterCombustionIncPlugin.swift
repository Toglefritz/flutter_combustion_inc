import Flutter
import CombustionBLE
import UIKit
import Combine

/// The FlutterCombustionIncPlugin serves as the entry point for native iOS
/// functionality in the flutter_combustion_inc plugin. It bridges method
/// and event channels between Flutter and the native Combustion Inc. SDK.
///
/// This class currently supports scanning for nearby Combustion Inc. probes
/// using the DeviceManager from the combustion-ios-ble SDK. Discovered probes
/// are streamed to Dart via an EventChannel.
public class FlutterCombustionIncPlugin: NSObject, FlutterPlugin {
    
    /// Event sink used to stream discovered probes back to Flutter.
    private var scanEventSink: FlutterEventSink?
    
    /// Event sink used to stream the full list of discovered probes back to Flutter.
    private var probeListEventSink: FlutterEventSink?
    
    /// Timer to periodically check for updates to the probe list.
    private var probeListUpdateTimer: Timer?
    
    /// Most recent snapshot of probe identifiers.
    private var lastProbeIdentifiers: Set<String> = []

    /// Event sink used to stream virtual temperatures.
    private var virtualTempEventSink: FlutterEventSink?

    /// Combine subscription to virtual temperature updates.
    private var virtualTempCancellable: AnyCancellable?
    
    /// Event sink used to stream battery status.
    private var batteryStatusSink: FlutterEventSink?

    /// Combine subscription to battery status updates.
    private var batteryStatusCancellable: AnyCancellable?

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
        // Initializes Bluetooth resources and begins scanning for nearby temperature probes.
        case "initBluetooth":
            DeviceManager.shared.initBluetooth()
            result(nil)
       
        // Returns a list of probes known to the DeviceManager.
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
            
        // Obtains "virtual temperatures" from a probe. Virtual temperatures represent the temperatures from different areas of the food.
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
            
        // Allows Flutter apps to listen to a stream of virtual temperatures.
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
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension FlutterCombustionIncPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let args = arguments as? [String: Any] {
            switch args["type"] as? String {
            case "virtualTemps":
                self.virtualTempEventSink = events
                return nil
            case "batteryStatus":
                self.batteryStatusSink = events
                return nil
            default:
                break
            }
        }

        self.probeListEventSink = events
        startProbeListStream()
        return nil
    }

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
            default:
                break
            }
        }

        stopProbeListStream()
        self.probeListEventSink = nil
        return nil
    }

    
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

    private func stopProbeListStream() {
        self.probeListUpdateTimer?.invalidate()
        self.probeListUpdateTimer = nil
        self.lastProbeIdentifiers.removeAll()
    }
}
