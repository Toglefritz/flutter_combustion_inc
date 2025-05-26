# flutter_combustion_inc

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

