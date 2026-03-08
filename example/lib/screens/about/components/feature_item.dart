part of '../about_view.dart';

/// Widget that displays a single feature item.
///
/// Shows a checkmark icon followed by the feature description.
class FeatureItem extends StatelessWidget {
  /// The feature description text.
  final String feature;

  /// Creates an instance of [FeatureItem].
  const FeatureItem({
    required this.feature,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Inset.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
          ),
          const Padding(
            padding: EdgeInsets.only(left: Inset.small),
          ),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
