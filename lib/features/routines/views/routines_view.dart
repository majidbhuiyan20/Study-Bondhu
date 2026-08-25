import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/routine.dart';
import '../view_models/routines_view_model.dart';

class RoutinesView extends ConsumerStatefulWidget {
  const RoutinesView({super.key});

  @override
  ConsumerState<RoutinesView> createState() => _RoutinesViewState();
}

class _RoutinesViewState extends ConsumerState<RoutinesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(routinesViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routinesViewModelProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Routines'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Today'), Tab(text: 'All')],
          ),
          actions: [
            IconButton(
              tooltip: 'Add routine',
              icon: const Icon(Icons.add),
              onPressed: () => _editRoutine(context, null),
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _todayList(context, state),
                  _allList(context, state),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-routines',
          onPressed: () => _editRoutine(context, null),
          icon: const Icon(Icons.add),
          label: const Text('Add routine'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
      ),
    );
  }

  Widget _todayList(BuildContext context, RoutinesState state) {
    final today = du.AppDateUtils.formatWeekday(DateTime.now());
    final routines = state.todaysRoutines;
    if (routines.isEmpty) {
      return AppEmptyState(
        title: 'No routines today',
        message: 'Add a daily or weekly routine to get started',
        icon: Icons.repeat_rounded,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = routines[i];
        return _routineCard(context, r, today: today);
      },
    );
  }

  Widget _allList(BuildContext context, RoutinesState state) {
    if (state.routines.isEmpty) {
      return const AppEmptyState(
        title: 'No routines yet',
        message: 'Add a routine like "Read Bangla 30 min" to track it daily',
        icon: Icons.repeat_rounded,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.routines.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = state.routines[i];
        return _routineCard(context, r);
      },
    );
  }

  Widget _routineCard(BuildContext context, Routine r, {String? today}) {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    final isDoneToday = r.lastDone != null &&
        du.AppDateUtils.isSameDay(r.lastDone!, DateTime.now());
    return AppCard(
      onTap: () => _editRoutine(context, r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: r.isActive
                      ? AppColors.primaryLight
                      : ThemeColors.surfaceAlt(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.repeat_rounded,
                  color: r.isActive
                      ? AppColors.primary
                      : ThemeColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          decoration:
                              isDoneToday ? TextDecoration.lineThrough : null,
                          color: isDoneToday
                              ? ThemeColors.textSecondary(context)
                              : null,
                        )),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: r.daysOfWeek
                          .map((d) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: today != null
                                      ? AppColors.primary
                                      : ThemeColors.surfaceAlt(context),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (isBn ? weekdayShortBn : weekdayShortEn)[d] ??
                                      '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: today != null
                                        ? AppColors.textOnPrimary
                                        : ThemeColors.textSecondary(context),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    if (r.timeOfDay != null) ...[
                      const SizedBox(height: 4),
                      Text('⏰ ${r.timeOfDay!}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: ThemeColors.textSecondary(context),
                          )),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: isDoneToday ? 'Done today' : 'Mark done',
                onPressed: isDoneToday
                    ? null
                    : () => ref
                        .read(routinesViewModelProvider.notifier)
                        .markDone(r.id!),
                icon: Icon(
                  isDoneToday
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isDoneToday
                      ? AppColors.success
                      : ThemeColors.textTertiary(context),
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete routine?'),
                      content:
                          const Text('It will stop appearing on the schedule.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && r.id != null) {
                    await ref
                        .read(routinesViewModelProvider.notifier)
                        .deleteRoutine(r.id!);
                  }
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          if (r.notes != null && r.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(r.notes!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: ThemeColors.textSecondary(context),
                )),
          ],
        ],
      ),
    );
  }

  Future<void> _editRoutine(BuildContext context, Routine? existing) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final timeCtl = TextEditingController(text: existing?.timeOfDay ?? '');
    final notesCtl = TextEditingController(text: existing?.notes ?? '');
    Set<int> selectedDays =
        (existing?.daysOfWeek ?? const [1, 2, 3, 4, 5]).toSet();
    bool active = existing?.isActive ?? true;
    int? subjectId = existing?.subjectId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSt) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existing == null ? 'New routine' : 'Edit routine',
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. Read Bangla 30 min',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future:
                        ref.read(subjectsRepositoryProvider).getSubjects(),
                    builder: (_, snap) {
                      final subjects = snap.data ?? const [];
                      return DropdownButtonFormField<int?>(
                        initialValue: subjectId,
                        decoration: const InputDecoration(
                            labelText: 'Subject (optional)'),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('No subject')),
                          ...subjects.map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name))),
                        ],
                        onChanged: (v) => setSt(() => subjectId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Days', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: List.generate(7, (i) {
                      final d = i + 1;
                      final picked = selectedDays.contains(d);
                      return ChoiceChip(
                        label: Text(weekdayShortEn[d] ?? ''),
                        selected: picked,
                        onSelected: (v) => setSt(() {
                          if (v) {
                            selectedDays.add(d);
                          } else {
                            selectedDays.remove(d);
                          }
                        }),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: picked
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeCtl,
                    decoration: const InputDecoration(
                      labelText: 'Time of day (optional)',
                      hintText: 'e.g. After school / সন্ধ্যায়',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: active,
                    onChanged: (v) => setSt(() => active = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (title.text.trim().isEmpty) return;
                            final r = Routine(
                              id: existing?.id,
                              subjectId: subjectId,
                              title: title.text.trim(),
                              daysOfWeek: selectedDays.toList()..sort(),
                              timeOfDay: timeCtl.text.trim().isEmpty
                                  ? null
                                  : timeCtl.text.trim(),
                              notes: notesCtl.text.trim().isEmpty
                                  ? null
                                  : notesCtl.text.trim(),
                              isActive: active,
                              createdAt:
                                  existing?.createdAt ?? DateTime.now(),
                            );
                            if (existing == null) {
                              await ref
                                  .read(routinesViewModelProvider.notifier)
                                  .addRoutine(r);
                            } else {
                              await ref
                                  .read(routinesViewModelProvider.notifier)
                                  .updateRoutine(r);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: Text(
                              existing == null ? 'Create' : 'Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
