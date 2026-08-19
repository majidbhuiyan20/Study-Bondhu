import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../models/topic.dart';

/// Spec #16 — per-subject weak-topic list. Rendered on Subject Details
/// to show which topics the student has flagged as weak.
class SubjectWeakTopics extends StatelessWidget {
  const SubjectWeakTopics({
    super.key,
    required this.topics,
  });

  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weak = topics
        .where((t) => t.status == TopicStatus.weak)
        .toList();
    if (weak.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'No weak topics — nice work!',
          style: AppTextStyles.bodySmall.copyWith(
            color: ThemeColors.textSecondary(context),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.isBangla ? 'দুর্বল বিষয়' : 'Weak topics',
            style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        for (final t in weak)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.priority_high_rounded,
                    size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(child: Text(t.name)),
              ],
            ),
          ),
      ],
    );
  }
}
