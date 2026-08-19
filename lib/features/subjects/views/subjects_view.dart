import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../profile/models/profile.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../view_models/subjects_view_model.dart';
import '../widgets/subject_card.dart';

class SubjectsView extends ConsumerStatefulWidget {
  const SubjectsView({super.key});

  @override
  ConsumerState<SubjectsView> createState() => _SubjectsViewState();
}

class _SubjectsViewState extends ConsumerState<SubjectsView> {
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
    final activeSem = state.activeSemester;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subjects),
        actions: [
          IconButton(
            tooltip: l10n.search,
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: l10n.profileChip,
            onPressed: () => context.push(AppRoutes.profiles),
            icon: const Icon(Icons.school_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-subjects',
        onPressed: () => context.push(AppRoutes.subjectAdd),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSubject),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Column(
        children: [
          _ContextStrip(
            profileName: activeProfile?.name,
            profileLabel: activeProfile == null
                ? null
                : [
                    activeProfile.level.en,
                    if (activeProfile.classLabel != null)
                      activeProfile.classLabel!,
                  ].join(' · '),
            semesterName: activeSem?.name,
            onTapSemester: () => context.push(AppRoutes.semesters),
            onTapProfile: () => context.push(AppRoutes.profiles),
          ),
          Expanded(child: _Body(state: state)),
        ],
      ),
    );
  }
}

class _ContextStrip extends StatelessWidget {
  const _ContextStrip({
    required this.profileName,
    required this.profileLabel,
    required this.semesterName,
    required this.onTapSemester,
    required this.onTapProfile,
  });

  final String? profileName;
  final String? profileLabel;
  final String? semesterName;
  final VoidCallback onTapSemester;
  final VoidCallback onTapProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profileName ?? l10n.setUpProfile,
                              style: AppTextStyles.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (profileLabel != null) ...[
                            const SizedBox(height: 2),
                            Text(profileLabel!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                )),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTapSemester,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ThemeColors.surfaceAlt(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.border(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 18,
                      color: ThemeColors.textSecondary(context)),
                  const SizedBox(width: 8),
                  Text(
                    semesterName ?? l10n.semesterLabel,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: semesterName == null
                          ? ThemeColors.textSecondary(context)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more,
                      size: 18,
                      color: ThemeColors.textSecondary(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});
  final SubjectsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (state.isLoading) return const AppLoading();
    if (state.subjects.isEmpty) {
      return AppEmptyState(
        title: l10n.noSubjects,
        message: l10n.emptySubjectsHint,
        icon: Icons.menu_book_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(subjectsViewModelProvider.notifier).load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.subjects.length,
        separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (_, i) => SubjectCard(
                subject: state.subjects[i],
                onTap: () => context.push(
                  AppRoutes.subjectDetail.replaceAll(
                    ':id',
                    state.subjects[i].id?.toString() ?? '0',
                  ),
                ),
              ),
      ),
    );
  }
}
