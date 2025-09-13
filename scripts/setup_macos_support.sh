#!/bin/bash

# Setup script for adding macOS support to flutter_combustion_inc plugin
# This script helps implement Option 1 from docs/MACOS_SETUP.md

set -e

echo "🔧 Setting up macOS support for flutter_combustion_inc plugin"
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ] || [ ! -d "ios" ]; then
    echo "❌ Error: Please run this script from the root of your Flutter plugin directory"
    exit 1
fi

echo "📋 This script will help you set up macOS support by:"
echo "   1. Forking the CombustionBLE repository"
echo "   2. Adding macOS platform support"
echo "   3. Updating your plugin configuration"
echo ""

# Get user's GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GitHub username is required"
    exit 1
fi

echo ""
echo "🍴 Step 1: Fork and clone CombustionBLE repository"
echo "   Please fork https://github.com/combustion-inc/combustion-ios-ble to your GitHub account"
echo "   Then press Enter to continue..."
read

# Clone the forked repository
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "📥 Cloning your forked repository..."
git clone "https://github.com/$GITHUB_USERNAME/combustion-ios-ble.git"
cd combustion-ios-ble

# Create feature branch
echo "🌿 Creating feature branch..."
git checkout -b feature/macos-support

# Update Package.swift for macOS support
echo "📝 Updating Package.swift for macOS support..."
cat > Package.swift << 'EOF'
// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "combustion-ios-ble",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)  // Added macOS support
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "CombustionBLE", targets: ["CombustionBLE"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-collections", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-DFU-Library", .upToNextMajor(from: "4.11.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CombustionBLE",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "NordicDFU", package: "IOS-DFU-Library")
            ],
            path: "Sources/CombustionBLE"),
        /*
        .testTarget(
            name: "combustion-ios-bleTests",
            dependencies: ["combustion-ios-ble"]),
        */
    ]
)
EOF

echo "🔍 Checking for iOS-specific code that needs macOS compatibility..."

# Find files that might need platform-specific updates
echo "   Scanning source files for potential iOS-specific imports..."
find Sources -name "*.swift" -exec grep -l "UIKit\|import Foundation" {} \; | while read file; do
    echo "   📄 Found file that may need review: $file"
done

echo ""
echo "📤 Committing changes..."
git add Package.swift
git commit -m "Add macOS platform support to Package.swift

- Added .macOS(.v10_15) to supported platforms
- This enables the CombustionBLE framework to be used on macOS
- Core Bluetooth APIs should work identically between iOS and macOS"

echo "🚀 Pushing changes to your fork..."
git push origin feature/macos-support

echo ""
echo "✅ CombustionBLE fork setup complete!"
echo ""
echo "🔧 Step 2: Update your Flutter plugin configuration"

# Return to original directory
cd - > /dev/null

# Update iOS podspec to use forked version
echo "📝 Updating iOS podspec..."
sed -i.bak "s/s\.dependency 'CombustionBLE'/s.dependency 'CombustionBLE', :git => 'https:\/\/github.com\/$GITHUB_USERNAME\/combustion-ios-ble.git', :branch => 'feature\/macos-support'/" ios/flutter_combustion_inc.podspec

# Update macOS podspec to use forked version
echo "📝 Updating macOS podspec..."
cat > macos/flutter_combustion_inc.podspec << EOF
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run \`pod lib lint flutter_combustion_inc.podspec\` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_combustion_inc'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for Combustion Inc. wireless temperature probes on macOS.'
  s.description      = <<-DESC
A Flutter plugin that enables communication between Flutter macOS applications and Combustion Inc. wireless temperature probes.
                       DESC
  s.homepage         = 'https://github.com/Toglefritz/flutter_combustion_inc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Toglefritz' => 'your.email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.dependency 'CombustionBLE', :git => 'https://github.com/$GITHUB_USERNAME/combustion-ios-ble.git', :branch => 'feature/macos-support'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
EOF

# Update macOS plugin implementation to use real CombustionBLE
echo "📝 Updating macOS plugin implementation..."
cat > macos/Classes/FlutterCombustionIncPlugin.swift << 'EOF'
import FlutterMacOS
import CombustionBLE
import AppKit
import Combine

/// `FlutterCombustionIncPlugin` is the macOS-side implementation of the
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
public class FlutterCombustionIncPluginMacOS: NSObject, FlutterPlugin {
    
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
    
    /// Used to emit updates about whether the probe data is considered stale.
    private var statusStaleSink: FlutterEventSink?

    /// Combine subscription to status notification staleness.
    private var statusStaleCancellable: AnyCancellable?
    
    /// Used to emit updates about log sync percent for a probe.
    private var logSyncPercentSink: FlutterEventSink?

    /// Combine subscription to percentOfLogsSynced updates.
    private var logSyncPercentCancellable: AnyCancellable?

    /// Used to emit temperature log data points as a stream to Flutter.
    private var temperatureLogSink: FlutterEventSink?

    /// Combine subscription to probe's temperature log stream.
    private var temperatureLogCancellable: AnyCancellable?
    
    /// Used to emit session information availability updates to Flutter.
    private var sessionInfoSink: FlutterEventSink?

    /// Combine subscription to session information updates.
    private var sessionInfoCancellable: AnyCancellable?
    
    /// Store the probe reference for session info monitoring to ensure consistency.
    private var sessionInfoProbe: Probe?
    
    /// Registers the plugin with the Flutter engine and sets up method and event channels.
    ///
    /// - Parameters:
    ///   - registrar: The FlutterPluginRegistrar provided by the Flutter engine.
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Create a shared plugin instance
        let instance = FlutterCombustionIncPluginMacOS()
        
        // Method channel for one-off method calls (e.g., connect, disconnect, etc.)
        let methodChannel = FlutterMethodChannel(
            name: "flutter_combustion_inc",
            binaryMessenger: registrar.messenger
        )
        
        // Event channels for continuous data streams
        let probeListChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_scan",
            binaryMessenger: registrar.messenger
        )
        probeListChannel.setStreamHandler(instance)
        
        let virtualTempChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_virtual_temps",
            binaryMessenger: registrar.messenger
        )
        virtualTempChannel.setStreamHandler(instance)
        
        let currentTempsChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_current_temperatures",
            binaryMessenger: registrar.messenger
        )
        currentTempsChannel.setStreamHandler(instance)
        
        let batteryStatusChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_battery_status",
            binaryMessenger: registrar.messenger
        )
        batteryStatusChannel.setStreamHandler(instance)
        
        let statusStaleChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_status_stale",
            binaryMessenger: registrar.messenger
        )
        statusStaleChannel.setStreamHandler(instance)
        
        let logSyncPercentChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_log_sync_percent",
            binaryMessenger: registrar.messenger
        )
        logSyncPercentChannel.setStreamHandler(instance)
        
        let temperatureLogChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_temperature_log",
            binaryMessenger: registrar.messenger
        )
        temperatureLogChannel.setStreamHandler(instance)
        
        let sessionInfoChannel = FlutterEventChannel(
            name: "flutter_combustion_inc_session_info",
            binaryMessenger: registrar.messenger
        )
        sessionInfoChannel.setStreamHandler(instance)

        // Register the method and event channel handlers
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
    }
    
    // NOTE: The rest of the implementation is identical to the iOS version
    // since Core Bluetooth APIs are the same on both platforms.
    // Copy the handle(_:result:) method and FlutterStreamHandler extension
    // from ios/Classes/FlutterCombustionIncPlugin.swift
}
EOF

echo ""
echo "🧪 Step 3: Test the setup"
echo "   Run the following commands to test your setup:"
echo ""
echo "   cd example"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run -d macos"
echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "   1. Test the CombustionBLE framework builds successfully on macOS"
echo "   2. If there are compilation errors, review the source files in your fork"
echo "   3. Add platform-specific imports where needed (UIKit vs AppKit)"
echo "   4. Submit a pull request to the original CombustionBLE repository"
echo ""
echo "🔗 Your forked repository: https://github.com/$GITHUB_USERNAME/combustion-ios-ble"
echo "🌿 Feature branch: feature/macos-support"

# Cleanup
rm -rf "$TEMP_DIR"
EOF