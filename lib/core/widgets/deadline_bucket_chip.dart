import 'package:flutter/material.dart';

import '../l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../theme/theme_colors.dart';
import '../utils/deadline_bucket.dart';

/// A small, colored bucket chip used across assignments, exams, and the
/// home dashboard (spec 07).
class DeadlineBucketChip extends StatelessWidget {
  const DeadlineBucketChip({super.key, required this.date});

  /// Date to bucket. If null, the chip renders as "No date".
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bucket = bucketFor(date);
    final label = l10n.isBangla ? bucket.bnLabel() : bucket.enLabel();
    final color = Color(bucket.hex);
    final bgAlpha = Theme.of(context).brightness == Brightness.dark
        ? 0.22
        : 0.13;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Off-the-shelf Bucket section header builder (returns a row widget).
class BucketSectionHeader extends StatelessWidget {
  const BucketSectionHeader({
    super.key,
    required this.bucket,
    this.count,
  });

  final DeadlineBucket bucket;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = l10n.isBangla ? bucket.bnLabel() : bucket.enLabel();
    final color = Color(bucket.hex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ThemeColors.textPrimary(context),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
