import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../study/models/study_session.dart';
import '../../../study/view_models/study_view_model.dart'
    show pendingStudySubjectIdProvider;
import '../../view_models/subjects_view_model.dart';
import 'subject_detail_widgets.dart' show StatTile;

/// Spec 03 §"Study Time tab" — aggregate stats + 7-day bars + Start Study CTA.
class SubjectStudyTimeView extends ConsumerWidget {
  const SubjectStudyTimeView({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync =
        ref.watch(_sessionsForSubjectProvider(subjectId));
    return sessionsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sessions) => _Content(sessions: sessions, subjectId: subjectId),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.sessions, required this.subjectId});
  final List<StudySession> sessions;
  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final totalSec =
        sessions.fold<int>(0, (a, b) => a + b.durationSeconds);
    final avgSec =
        sessions.isEmpty ? 0 : (totalSec / sessions.length).round();

    // Per-topic aggregation
    final topicBuckets = <int, int>{};
    final topicsAsync = ref.watch(topicsForSubjectProvider(subjectId));
    final topicsById = <int, String>{};
    topicsAsync.whenData((tts) {
      for (final t in tts) {
        if (t.id != null) topicsById[t.id!] = t.name;
      }
    });

    for (final s in sessions) {
      if (s.topicId == null) continue;
      topicBuckets[s.topicId!] =
          (topicBuckets[s.topicId!] ?? 0) + s.durationSeconds;
    }
    String? mostStudied;
    if (topicBuckets.isNotEmpty) {
      final sorted = topicBuckets.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostStudied = topicsById[sorted.first.key];
    }

    // Last 7 days bars
    final today = DateTime.now();
    final byDay = <DateTime, int>{};
    for (final s in sessions) {
      final d = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      byDay[d] = (byDay[d] ?? 0) + s.durationSeconds;
    }
    final last7 = <DateTime>[];
    for (int i = 6; i >= 0; i--) {
      last7.add(DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i)));
    }
    final maxSec = last7
        .map((d) => byDay[d] ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.totalHours,
                value: DurationUtils.formatHuman(Duration(seconds: totalSec)),
                color: AppColors.primary,
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: l10n.totalSessions,
                value: '${sessions.length}',
                color: AppColors.info,
                icon: Icons.format_list_numbered_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.avgSession,
                value: DurationUtils.formatHuman(Duration(seconds: avgSec)),
                color: AppColors.accent,
                icon: Icons.av_timer_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: l10n.mostStudiedTopic,
                value: mostStudied ?? '—',
                color: AppColors.success,
                icon: Icons.star_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.last7Days, style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: last7.map((d) {
                    final sec = byDay[d] ?? 0;
                    final h = maxSec == 0
                        ? 0.04
                        : (sec / maxSec).clamp(0.04, 1.0);
                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 100 * h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDeep,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${d.day}',
                              style: AppTextStyles.label.copyWith(
                                color: ThemeColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Spec 03 §"Start Study" CTA — pre-selects this subject for the timer.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(pendingStudySubjectIdProvider.notifier)
                  .state = subjectId;
              context.go(AppRoutes.study);
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.startStudyCta),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

final _sessionsForSubjectProvider =
    FutureProvider.family.autoDispose<List<StudySession>, int>(
  (ref, subjectId) async {
    final repo = ref.watch(studyRepositoryProvider);
    return repo.getSessions(subjectId: subjectId);
  },
);
