# flutter_combustion_inc

![Plugin logo](assets/plugin_logo_200w.png)

A Flutter plugin that enables communication between Flutter mobile applications and Combustion Inc. wireless temperature probes via Bluetooth Low Energy (BLE). This plugin provides a strongly-typed, cross-platform API for discovering, connecting to, and retrieving real-time data from Combustion Inc. probes on both Android and iOS.

## Features

- Scan for nearby Combustion Inc. probes
- Connect and disconnect from a probe
- Stream real-time temperature and ambient sensor data
- Access battery status, probe orientation, and other probe characteristics
- Designed with clean, well-documented APIs and strong typing across Dart, Kotlin, Java, and Swift code

## Supported Platforms

- ✅ Android (uses [combustion-android-ble](https://github.com/combustion-inc/combustion-android-ble))
- ✅ iOS (uses [combustion-ios-ble](https://github.com/combustion-inc/combustion-ios-ble))
- ✅ macOS (uses [combustion-ios-ble](https://github.com/combustion-inc/combustion-ios-ble))

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_combustion_inc: ^0.1.0
```

Then run:

```bash
flutter pub get
```

### macOS Setup

For macOS support, ensure you have:

1. macOS 10.11 or later
2. Xcode with Swift 5.0+ support
3. The CombustionBLE framework available for macOS

The plugin uses the same CombustionBLE framework as iOS, so no additional setup is required beyond standard Flutter macOS configuration.

## Usage

Import the plugin:

```dart
import 'package:flutter_combustion_inc/flutter_combustion_inc.dart';
```

// TODO - Usage information coming soon

For a full example, see the [`example/`](example/) directory.

## Documentation

Comprehensive Dart and platform-specific documentation is provided inline with all classes and methods. You can also view generated API docs using `dart doc`.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Disclaimer

In the creation of this plugin, artificial intelligence (AI) tools have been utilized. These tools have assisted in various stages of the plugin's development, from initial code generation to the optimization of algorithms.

It is emphasized that the AI's contributions have been thoroughly overseen. Each segment of AI-assisted code has undergone meticulous scrutiny to ensure adherence to high standards of quality, reliability, and performance. This scrutiny was conducted by the sole developer responsible for the plugin's creation.

Rigorous testing has been applied to all AI-suggested outputs, encompassing a wide array of conditions and use cases. Modifications have been implemented where necessary, ensuring that the AI's contributions are well-suited to the specific requirements and limitations inherent in this project.

Commitment to the plugin's accuracy and functionality is paramount, and feedback or issue reports from users are invited to facilitate continuous improvement.

It is to be understood that this plugin, like all software, is subject to evolution over time. The developer is dedicated to its progressive refinement and is actively working to surpass the expectations of the Flutter community.

