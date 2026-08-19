import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_models/home_view_model.dart';

/// Spec 11 — multi-item plan card shown on the home dashboard. Lets the
/// user adjust the time budget and start the plan.
class StudyRecommendationCard extends ConsumerStatefulWidget {
  const StudyRecommendationCard({super.key});

  @override
  ConsumerState<StudyRecommendationCard> createState() =>
      _StudyRecommendationCardState();
}

class _StudyRecommendationCardState
    extends ConsumerState<StudyRecommendationCard> {
  int _minutes = 45;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final planAsync = ref.watch(studyPlanProvider(_minutes));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppColors.textOnPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(l10n.studyRecommendation.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color:
                        AppColors.textOnPrimary.withValues(alpha: 0.85),
                  )),
              const Spacer(),
              // Time budget chip.
              _MinutesChip(
                minutes: _minutes,
                onChanged: (v) => setState(() => _minutes = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.isBangla
                ? 'আপনার $_minutes মিনিটের প্ল্যান'
                : 'Your $_minutes-minute plan',
            style: AppTextStyles.headlineMedium
                .copyWith(color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 10),
          planAsync.when(
            data: (plan) {
              if (plan.isEmpty) {
                return Text(
                  'Add subjects, assignments, or revisions to get a personalised plan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        AppColors.textOnPrimary.withValues(alpha: 0.85),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in plan.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            _iconFor(item.icon),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${item.minutes} min',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textOnPrimary
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.textOnPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
            error: (e, _) => Text('Error: $e',
                style: TextStyle(color: AppColors.textOnPrimary)),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.study),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.isBangla
                ? 'প্ল্যান শুরু করো'
                : 'Start Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textOnPrimary,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }

  String _iconFor(String code) {
    switch (code) {
      case 'weak':
        return '🔴';
      case 'revision':
        return '🧠';
      case 'assignment':
        return '📝';
      case 'syllabus':
        return '📚';
      default:
        return '🎯';
    }
  }
}

class _MinutesChip extends StatelessWidget {
  const _MinutesChip({required this.minutes, required this.onChanged});
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: AppColors.primaryDeep,
      tooltip: 'Time budget',
      onSelected: onChanged,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 15, child: Text('15 min')),
        PopupMenuItem(value: 25, child: Text('25 min')),
        PopupMenuItem(value: 45, child: Text('45 min')),
        PopupMenuItem(value: 60, child: Text('60 min')),
        PopupMenuItem(value: 90, child: Text('90 min')),
      ],
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined,
                size: 14, color: AppColors.textOnPrimary),
            const SizedBox(width: 4),
            Text(
              '${minutes}m',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
