/// Flutter plugin for integrating with Combustion Inc. temperature probes.
///
/// This plugin provides a comprehensive interface for discovering, connecting to, and monitoring Combustion Inc.
/// temperature probes. It supports real-time temperature readings, battery status monitoring, temperature logging,
/// and cooking predictions.
///
/// Key features:
/// * Probe discovery and connection management
/// * Real-time virtual and raw temperature streaming
/// * Battery status monitoring
/// * Temperature logging and synchronization
/// * Cooking predictions with target temperature support
/// * Session information management
library;

// Core platform interface
export 'flutter_combustion_inc_platform_interface.dart';

// Models
export 'models/battery_status.dart';
export 'models/device_manager.dart';
export 'models/prediction_info.dart';
export 'models/probe.dart';
export 'models/probe_log_data_point.dart';
export 'models/probe_temperature_log.dart';
export 'models/probe_temperatures.dart';
export 'models/virtual_temperatures.dart';

// Utilities
export 'util/temperature_unit_converter.dart';
