import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';

/// Cross-subject weakness radar (spec 16). The chart plots the proportion
/// of weak topics per subject; use [subjectSecondsById] only as a fallback
/// when the subject has no weak topics yet.
///
/// Per spec #16 we *also* support a fallback heuristic so the radar is
/// useful on day one: when all subjects have zero weak topics, the
/// subjects with the lowest study time in the last 7 days become the
/// "weakest" — the chart still surfaces something actionable.
class WeaknessRadarCard extends ConsumerWidget {
  const WeaknessRadarCard({
    super.key,
    required this.subjectSecondsById,
    this.weakerSubjects = const [],
  });

  final Map<int, int> subjectSecondsById;

  /// Optional: subjects that the user has identified as weak. When
  /// non-empty, these are used as the radar values (0..1) per subject;
  /// the highest weak count across subjects scales to 1.0.
  final List<({int subjectId, int weakCount})> weakerSubjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(_subjectsProvider);
    return subjectsAsync.when(
      loading: () => const AppCard(
        child: SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => AppCard(
        child: SizedBox(
          height: 160,
          child: Center(child: Text('Error: $e')),
        ),
      ),
      data: (subjects) {
        if (subjects.isEmpty) {
          return AppCard(
            child: SizedBox(
              height: 160,
              child: Center(
                child: Text('Add subjects to see weakness radar',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context))),
              ),
            ),
          );
        }
        if (subjects.length < 3) {
          return AppCard(
            child: SizedBox(
              height: 160,
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Add at least 3 subjects to see the weakness radar.\nYou currently have ${subjects.length}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ThemeColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        // Compute (subjectId -> 0..1 weak share).
        final Map<int, double> values = {};
        if (weakerSubjects.isEmpty) {
          // Fallback: invert study-time so the least-studied is biggest.
          final max = subjectSecondsById.values.fold<int>(
              1, (a, b) => a > b ? a : b);
          for (final s in subjects) {
            final sec = subjectSecondsById[s.id] ?? 0;
            values[s.id!] = 1.0 - (sec / max).clamp(0.0, 1.0);
          }
        } else {
          final maxCount = weakerSubjects
              .fold<int>(1, (a, b) => a > b.weakCount ? a : b.weakCount);
          for (final s in subjects) {
            final hits = weakerSubjects
                .where((w) => w.subjectId == s.id)
                .fold<int>(0, (a, b) => a + b.weakCount);
            values[s.id!] = (hits / maxCount).clamp(0.0, 1.0);
          }
        }
        return AppCard(
          child: SizedBox(
            height: 220,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle: const TextStyle(
                    color: Colors.transparent, fontSize: 10),
                gridBorderData:
                    BorderSide(color: ThemeColors.border(context)),
                tickBorderData:
                    BorderSide(color: ThemeColors.border(context)),
                getTitle: (i, _) => RadarChartTitle(
                  text: subjects[i].name,
                ),
                titleTextStyle: TextStyle(
                  fontSize: 11,
                  color: ThemeColors.textSecondary(context),
                ),
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withValues(alpha: 0.2),
                    borderColor: AppColors.primary,
                    entryRadius: 3,
                    dataEntries: subjects
                        .map((s) =>
                            RadarEntry(value: values[s.id] ?? 0.0))
                        .toList(),
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(
                    color: ThemeColors.border(context), width: 1),
              ),
            ),
          ),
        );
      },
    );
  }
}

final _subjectsProvider = FutureProvider((ref) async {
  return ref.watch(subjectsRepositoryProvider).getSubjects();
});
