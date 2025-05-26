# flutter_combustion_inc_example

This is the official example app for the [`flutter_combustion_inc`](https://pub.dev/packages/flutter_combustion_inc) plugin. It demonstrates how to use the plugin to discover, connect to, and read data from Combustion Inc. wireless temperature probes via Bluetooth Low Energy (BLE).

## Features Demonstrated

- Scanning for nearby probes
- Connecting to a probe
- Receiving real-time data including:
  - Tip and ambient temperatures
  - Battery status
  - Orientation and motion
- Handling connection lifecycle

## Getting Started

Make sure you have Flutter installed. Then, run the following commands from the root of the repository:

```bash
cd example
flutter pub get
flutter run
```

Ensure you have a Combustion Inc. probe powered on and nearby to see scan results.

## Platform Setup Notes

### iOS

- Ensure Bluetooth permissions are added to `Info.plist`:
  ```xml
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>This app uses Bluetooth to connect to cooking probes.</string>
  ```
- Run on a real device (Bluetooth is not available in the iOS simulator).

### Android

- Make sure the app has the necessary Bluetooth and location permissions.
- Bluetooth must be enabled on the device.
- For Android 12+, you must declare `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` in `AndroidManifest.xml`.

## Notes

- The example app is intended for testing and demonstration purposes.
- Probe scanning and connections depend on hardware availability and Bluetooth environment.

## License

See the [main plugin README](../README.md) for licensing details.
