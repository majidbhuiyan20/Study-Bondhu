import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/duration_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../models/study_session.dart';
import '../view_models/study_view_model.dart';

/// Spec 14 — a single row in the Study History. Shows subject + topic +
/// duration, with a tap-to-edit and swipe-to-delete affordance.
class SessionTile extends ConsumerWidget {
  const SessionTile({
    super.key,
    required this.session,
    required this.subjectName,
    required this.topicName,
    this.onTap,
  });

  final StudySession session;
  final String subjectName;
  final String? topicName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: _modeColor(session.mode),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  topicName ?? '—',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: ThemeColors.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DurationUtils.formatHms(session.duration),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _relativeTime(session.startTime),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: ThemeColors.textTertiary(context),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this session?'),
        content: const Text('This will remove it from your stats.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && session.id != null) {
      await ref
          .read(studyViewModelProvider.notifier)
          .deleteSession(session.id!);
    }
  }

  Color _modeColor(StudyMode mode) {
    switch (mode) {
      case StudyMode.focus:
        return AppColors.primary;
      case StudyMode.pomodoro:
        return AppColors.accent;
      case StudyMode.free:
        return AppColors.info;
    }
  }

  String _relativeTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}