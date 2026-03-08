part of '../about_view.dart';

/// Widget that displays a labeled information row.
///
/// Shows a label on the left and a value on the right, commonly used for displaying key-value pairs in information
/// cards.
class InfoRow extends StatelessWidget {
  /// The label text to display.
  final String label;

  /// The value text to display.
  final String value;

  /// Creates an instance of [InfoRow].
  const InfoRow({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Inset.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
