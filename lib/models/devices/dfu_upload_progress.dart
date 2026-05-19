/// Tracks the progress of a DFU firmware upload.
///
/// For multi-part firmware packages, [part] and [totalParts] indicate which
/// segment is currently being transferred. [progress] is the percentage
/// complete (0-100) for the current part.
class DfuUploadProgress {
  /// The current part being uploaded (1-indexed).
  final int part;

  /// The total number of parts in the firmware package.
  final int totalParts;

  /// Upload progress percentage (0-100) for the current part.
  final int progress;

  /// Creates a [DfuUploadProgress] instance.
  const DfuUploadProgress({
    required this.part,
    required this.totalParts,
    required this.progress,
  });

  /// Creates a [DfuUploadProgress] from a platform channel map.
  factory DfuUploadProgress.fromMap(Map<String, dynamic> map) {
    return DfuUploadProgress(
      part: map['part'] as int,
      totalParts: map['totalParts'] as int,
      progress: map['progress'] as int,
    );
  }
}
