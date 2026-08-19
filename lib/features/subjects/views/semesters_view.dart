import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../profile/models/profile.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../models/semester.dart';
import '../view_models/subjects_view_model.dart';

class SemestersView extends ConsumerStatefulWidget {
  const SemestersView({super.key});

  @override
  ConsumerState<SemestersView> createState() => _SemestersViewState();
}

class _SemestersViewState extends ConsumerState<SemestersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(subjectsViewModelProvider.notifier).bootstrap();
        ref.read(profileViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(subjectsViewModelProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final activeProfile = profileState.active;
    final semesters = activeProfile == null
        ? state.semesters
        : state.semesters
            .where((s) =>
                s.profileId == null ||
                s.profileId == activeProfile.id ||
                // legacy v1 data is also shown.
                true)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.semesterLabel),
        actions: [
          if (activeProfile != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    [
                      activeProfile.level.en,
                      if (activeProfile.classLabel != null)
                        activeProfile.classLabel!,
                    ].join(' · '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-semesters',
        onPressed: () => _addSemester(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSemester),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : semesters.isEmpty
              ? AppEmptyState(
                  title: l10n.noSubjects,
                  message: l10n.noSemestersHint,
                  icon: Icons.calendar_today_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: semesters.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final s = semesters[i];
                    final active = state.activeSemester?.id == s.id;
                    return AppCard(
                      onTap: () => ref
                          .read(subjectsViewModelProvider.notifier)
                          .setActiveSemester(s),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              active
                                  ? Icons.check_rounded
                                  : Icons.calendar_month_outlined,
                              color: active
                                  ? AppColors.textOnPrimary
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name,
                                    style: AppTextStyles.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  _rangeLabel(s, l10n.noDatesSet),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: ThemeColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (active)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(l10n.activeChip,
                                  style: const TextStyle(
                                    color: AppColors.textOnPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  )),
                            )
                          else
                            IconButton(
                              tooltip: l10n.makeActive,
                              onPressed: () => ref
                                  .read(subjectsViewModelProvider.notifier)
                                  .setActiveSemester(s),
                              icon: const Icon(Icons.check_circle_outline),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _rangeLabel(Semester s, String noDatesLabel) {
    if (s.startDate == null && s.endDate == null) return noDatesLabel;
    final start = s.startDate == null
        ? null
        : du.AppDateUtils.formatMonthDay(s.startDate!);
    final end = s.endDate == null
        ? null
        : du.AppDateUtils.formatMonthDay(s.endDate!);
    if (start != null && end != null) return '$start → $end';
    return start ?? end!;
  }

  Future<void> _addSemester(BuildContext context) async {
    final name = TextEditingController();
    DateTime? start;
    DateTime? end;
    final l10n = context.l10n;

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
                  Text(l10n.newSemester,
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: l10n.semesterName,
                      hintText: l10n.semesterNameHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate:
                                  start ?? DateTime.now(),
                            );
                            if (picked != null) {
                              setSt(() => start = picked);
                            }
                          },
                          icon: const Icon(Icons.event, size: 18),
                          label: Text(start == null
                              ? l10n.startDate
                              : du.AppDateUtils.formatMonthDay(start!)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate:
                                  end ?? DateTime.now(),
                            );
                            if (picked != null) {
                              setSt(() => end = picked);
                            }
                          },
                          icon: const Icon(Icons.event, size: 18),
                          label: Text(end == null
                              ? l10n.endDate
                              : du.AppDateUtils.formatMonthDay(end!)),
                        ),
                      ),
                    ],
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
                        child: ElevatedButton(
                          onPressed: () async {
                            if (name.text.trim().isEmpty) return;
                            await ref
                                .read(subjectsViewModelProvider.notifier)
                                .addSemester(Semester(
                                  name: name.text.trim(),
                                  startDate: start,
                                  endDate: end,
                                  isActive: false,
                                  profileId: ref
                                      .read(profileViewModelProvider)
                                      .active
                                      ?.id,
                                  createdAt: DateTime.now(),
                                ));
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: Text(l10n.save),
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
