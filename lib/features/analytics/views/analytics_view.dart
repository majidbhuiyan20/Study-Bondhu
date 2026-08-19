import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../models/goal.dart';
import '../view_models/analytics_view_model.dart';
import '../widgets/goals_section.dart';
import '../widgets/insights_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/weakness_radar_card.dart';
import '../widgets/weekly_chart.dart';

class AnalyticsView extends ConsumerStatefulWidget {
  const AnalyticsView({super.key});

  @override
  ConsumerState<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends ConsumerState<AnalyticsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(analyticsViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(analyticsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.analytics)),
      body: state.isLoading
          ? const AppLoading()
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(analyticsViewModelProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: l10n.totalStudyTime,
                          value: DurationUtils.formatHuman(
                              Duration(seconds: state.totalSeconds)),
                          icon: Icons.timer,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: l10n.isBangla ? 'সেশন' : 'Sessions',
                          value: '${state.totalSessions}',
                          icon: Icons.history,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: l10n.isBangla ? 'ধারা' : 'Streak',
                          value: l10n.isBangla
                              ? '${state.streakDays} দিন'
                              : '${state.streakDays} days',
                          icon: Icons.local_fire_department,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: l10n.isBangla ? 'গড় ফোকাস' : 'Avg focus',
                          value: state.avgFocus == 0
                              ? '—'
                              : state.avgFocus.toStringAsFixed(1),
                          icon: Icons.bolt,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.isBangla ? 'গত ৭ দিন' : 'Last 7 days',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  WeeklyChartCard(summary: state.weekly),
                  const SizedBox(height: 20),
                  Text(
                    l10n.isBangla ? 'ডেরাইভড ইনসাইটস' : 'Derived insights',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  InsightsSection(insights: state.insights),
                  const SizedBox(height: 20),
                  Text(
                    l10n.weaknessRadar,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  WeaknessRadarCard(
                    subjectSecondsById: state.subjectSecondsLast7Days,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.goals,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (state.goals.isEmpty)
                    AppEmptyState(
                      title: l10n.isBangla ? 'কোনো লক্ষ্য নেই' : 'No goals yet',
                      message: l10n.isBangla
                          ? 'দৈনিক, সাপ্তাহিক বা মোট লক্ষ্য সেট করুন'
                          : 'Set a daily, weekly or total goal',
                      icon: Icons.flag_outlined,
                    )
                  else
                    ...state.goals.map((g) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GoalTile(
                            goal: g,
                            onDelete: () => ref
                                .read(analyticsViewModelProvider.notifier)
                                .deleteGoal(g.id!),
                          ),
                        )),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showAddGoal(context),
                    icon: const Icon(Icons.add),
                    label: Text(
                      l10n.isBangla ? 'লক্ষ্য যোগ করুন' : 'Add goal',
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  void _showAddGoal(BuildContext context) {
    final l10n = context.l10n;
    final title = TextEditingController();
    int target = 60;
    GoalType type = GoalType.daily;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.isBangla ? 'নতুন লক্ষ্য' : 'New goal',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: title,
                decoration: InputDecoration(
                  hintText: l10n.isBangla ? 'শিরোনাম' : 'Title',
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<GoalType>(
                segments: [
                  ButtonSegment(
                    value: GoalType.daily,
                    label: Text(l10n.isBangla ? 'দৈনিক' : 'Daily'),
                  ),
                  ButtonSegment(
                    value: GoalType.weekly,
                    label: Text(l10n.isBangla ? 'সাপ্তাহিক' : 'Weekly'),
                  ),
                  ButtonSegment(
                    value: GoalType.total,
                    label: Text(l10n.isBangla ? 'মোট' : 'Total'),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (s) =>
                    setState(() => type = s.first),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(l10n.isBangla ? 'লক্ষ্য (মিনিট)' : 'Target (minutes)'),
                  Expanded(
                    child: Slider(
                      value: target.toDouble(),
                      min: 15,
                      max: 600,
                      divisions: 23,
                      label: '$target',
                      onChanged: (v) =>
                          setState(() => target = v.round()),
                    ),
                  ),
                  Text('$target'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.isBangla ? 'বাতিল' : 'Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (title.text.trim().isEmpty) return;
                      await ref
                          .read(analyticsViewModelProvider.notifier)
                          .addGoal(Goal(
                            title: title.text.trim(),
                            type: type,
                            target: target,
                            createdAt: DateTime.now(),
                          ));
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l10n.isBangla ? 'সংরক্ষণ' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
