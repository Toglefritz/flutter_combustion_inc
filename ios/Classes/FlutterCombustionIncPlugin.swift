import Flutter
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
        let eventChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_scan",
            binaryMessenger: registrar.messenger()
        )
        
        // Register the method and event channel handlers
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }
    
    /// Handles method channel calls from Flutter. Currently unimplemented.
    ///
    /// - Parameters:
    ///   - call: The method call from Dart.
    ///   - result: Callback for sending a result or error back to Dart.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initBluetooth":
            DeviceManager.shared.startScanning()
            result(nil)
            
        case "getProbes":
            let probes = DeviceManager.shared.getProbes().map { probe in
                return [
                    "identifier": probe.identifier.uuidString,
                    "serialNumber": probe.serialNumber,
                    "name": probe.deviceName,
                    "macAddress": probe.macAddressString,
                    "id": probe.id,
                    "color": probe.color,
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
    /// Called when Flutter starts listening to the scan EventChannel.
    ///
    /// - Parameters:
    ///   - arguments: Optional arguments passed from Flutter (unused).
    ///   - events: The sink to send discovered probes back to Flutter.
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.scanEventSink = events
        startScanning()
        return nil
    }
    
    /// Called when Flutter cancels listening to the scan EventChannel.
    ///
    /// - Parameters:
    ///   - arguments: Optional arguments passed from Flutter (unused).
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopScanning()
        self.scanEventSink = nil
        return nil
    }
    
    /// Starts scanning for nearby Combustion Inc. probes using DeviceManager.
    /// Discovered probes are serialized and emitted through the scanEventSink.
    private func startScanning() {
        DeviceManager.shared.onProbeDiscovered = { [weak self] probe in
            guard let self = self, let sink = self.scanEventSink else { return }
            let data: [String: Any] = [
                "id": probe.serialNumber,
                "name": probe.deviceName,
                "rssi": probe.rssi
            ]
            sink(data)
        }
        
        DeviceManager.shared.startScanning()
    }
    
    /// Stops scanning for probes and removes the onProbeDiscovered callback.
    private func stopScanning() {
        DeviceManager.shared.stopScanning()
        DeviceManager.shared.onProbeDiscovered = nil
    }
}
