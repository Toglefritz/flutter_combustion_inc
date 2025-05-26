import Flutter
import CombustionBLE
import UIKit

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
        case "initBluetooth":
            DeviceManager.shared.initBluetooth()
            result(nil)
       
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension FlutterCombustionIncPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        // Assume probe list stream only (since only one EventChannel is registered)
        self.probeListEventSink = events
        startProbeListStream()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
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
