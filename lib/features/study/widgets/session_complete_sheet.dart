import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/duration_utils.dart';
import '../models/study_session.dart';

/// Result returned from the session-complete sheet (spec 13).
/// `rating` is 1 (weak) / 3 (okay) / 5 (strong) — these map to
/// Topic.status and the spaced-repetition scheduler.
class SessionCompleteResult {
  final int rating;
  final String? notes;
  final int? topicId;
  const SessionCompleteResult({
    required this.rating,
    this.notes,
    this.topicId,
  });
}

/// Modal sheet shown when a Focus / Pomodoro / Free session ends.
/// Per spec 13: shows session duration, today's total study time,
/// a 3-state Weak/Okay/Strong rating, optional notes, and topic status
/// is updated by the caller (the rating drives the topic.status update).
class SessionCompleteSheet extends StatelessWidget {
  const SessionCompleteSheet({
    super.key,
    required this.session,
    required this.dailyTotalSec,
    this.topics = const [],
  });

  final StudySession session;
  final int dailyTotalSec;
  final List<({int id, String name})> topics;

  static Future<SessionCompleteResult?> show({
    required BuildContext context,
    required StudySession session,
    required int dailyTotalSec,
    List<({int id, String name})> topics = const [],
  }) {
    return showModalBottomSheet<SessionCompleteResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SessionCompleteSheet(
        session: session,
        dailyTotalSec: dailyTotalSec,
        topics: topics,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    int rating = 3;
    int? topicId = session.topicId;
    final notesCtl = TextEditingController();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: StatefulBuilder(
        builder: (ctx, setSt) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.sessionCompleteTitle,
                    style: AppTextStyles.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DurationUtils.formatHms(session.duration),
              style: AppTextStyles.numericLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.todaysStudySoFar}: ${DurationUtils.formatHuman(Duration(seconds: dailyTotalSec))}',
              style: AppTextStyles.bodySmall.copyWith(
                color: ThemeColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.howDidItGo, style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                _RatingChip(
                  label: l10n.revisionRateWeak,
                  rating: 1,
                  selected: rating == 1,
                  onTap: () => setSt(() => rating = 1),
                ),
                const SizedBox(width: 8),
                _RatingChip(
                  label: l10n.revisionRateOkay,
                  rating: 3,
                  selected: rating == 3,
                  onTap: () => setSt(() => rating = 3),
                ),
                const SizedBox(width: 8),
                _RatingChip(
                  label: l10n.revisionRateStrong,
                  rating: 5,
                  selected: rating == 5,
                  onTap: () => setSt(() => rating = 5),
                ),
              ],
            ),
            if (topics.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.topicPicker, style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: topicId,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.revisionGeneral),
                  ),
                  ...topics.map((t) => DropdownMenuItem<int?>(
                        value: t.id,
                        child: Text(t.name),
                      )),
                ],
                onChanged: (v) => setSt(() => topicId = v),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: notesCtl,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.sessionNotesOptional),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      ctx,
                      SessionCompleteResult(
                        rating: rating,
                        notes: notesCtl.text.trim().isEmpty
                            ? null
                            : notesCtl.text.trim(),
                        topicId: topicId,
                      ),
                    ),
                    child: Text(l10n.saveSession),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.label,
    required this.rating,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int rating;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = switch (rating) {
      1 => AppColors.error,
      3 => AppColors.primary,
      _ => AppColors.success,
    };
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? tint : ThemeColors.surfaceAlt(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? tint : ThemeColors.border(context),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected
                  ? AppColors.textOnPrimary
                  : ThemeColors.textPrimary(context),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}