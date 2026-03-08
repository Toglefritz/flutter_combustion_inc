import '../temperatures_view.dart';

/// Represents ways the probe temperature information can be displayed in the [TemperaturesView].
enum TemperaturesDisplayMode {
  /// The virtual temperatures and physical temperatures are displayed in two different radar charts, one on top of the
  /// other in a column layout.
  column,

  /// The probe's virtual and physical temperatures are displayed together in the same radar chart. This allows analysis
  /// of how the physical temperatures and the virtual temperatures relate to each other.
  stacked,
}
