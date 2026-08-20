import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsBangla, AppLocalizationsCamelCase, AppLocalizationsX;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../assignments/view_models/assignments_view_model.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/widgets/quick_stats_row.dart';
import '../models/profile.dart' show Profile, ProfileLevelX;
import '../view_models/profile_view_model.dart';
import '../widgets/edit_profile_sheet.dart';

/// Dedicated single-profile screen for the active profile.
///
/// Reachable from:
///   - Home AppBar profile icon (this screen is the canonical entry).
///   - Drawer profile tile.
///   - Drawer header tap (pushes here so users land on the same detail
///     surface they just saw the summary of).
class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(profileViewModelProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(profileViewModelProvider).active;
    final assignments = ref.watch(upcomingAssignmentsProvider).length;
    final home = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileChip),
        actions: [
          IconButton(
            tooltip: l10n.isBangla ? 'প্রোফাইল পরিবর্তন' : 'Switch profile',
            onPressed: () => context.push(AppRoutes.profiles),
            icon: const Icon(Icons.switch_account_rounded),
          ),
        ],
      ),
      body: profile == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.setUpProfile,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _ProfileHeaderCard(profile: profile),
                const SizedBox(height: 14),
                _ProfileDetailsCard(profile: profile),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showEditProfileSheet(
                          context,
                          existing: profile,
                        ),
                        icon: const Icon(Icons.edit_rounded),
                        label: Text(
                          l10n.isBangla ? 'প্রোফাইল সম্পাদনা' : 'Edit profile',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.profiles),
                        icon: const Icon(Icons.people_alt_outlined),
                        label: Text(
                          l10n.isBangla ? 'প্রোফাইল বদলান' : 'Switch',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.isBangla ? 'দ্রুত পরিসংখ্যান' : 'Quick stats',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                QuickStatsRow(
                  minutesToday: home.todaySeconds ~/ 60,
                  assignmentsDue: assignments,
                  weakTopicCount: home.weakTopicCount,
                  streakDays: home.streakDays,
                ),
                const SizedBox(height: 22),
                AppCard(
                  onTap: () => context.push(AppRoutes.profiles),
                  child: ListTile(
                    leading: const Icon(
                      Icons.people_alt_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      l10n.isBangla
                          ? 'সব প্রোফাইল দেখুন'
                          : 'Manage all profiles',
                    ),
                    subtitle: Text(
                      l10n.isBangla
                          ? 'প্রোফাইল যোগ, সম্পাদনা বা মুছে ফেলুন'
                          : 'Add, edit, or remove profiles',
                      style: TextStyle(
                          color: ThemeColors.textSecondary(context)),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile});
  final Profile profile;

  String get _initials {
    final n = profile.name.trim();
    if (n.isEmpty) return '?';
    return n.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primaryDeep.withValues(alpha: 0.55),
                  AppColors.primary.withValues(alpha: 0.30),
                ]
              : [
                  AppColors.primary,
                  AppColors.primaryDeep,
                ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    profile.level.en,
                    if (profile.classLabel != null) profile.classLabel!,
                  ].join(' · '),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final institution = profile.institution;
    final department = profile.department;
    final studentId = profile.studentId;
    if ((institution == null || institution.isEmpty) &&
        (department == null || department.isEmpty) &&
        (studentId == null || studentId.isEmpty)) {
      return const SizedBox.shrink();
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (institution != null && institution.isNotEmpty)
            _DetailRow(
              icon: Icons.school_rounded,
              label: l10n.isBangla ? 'প্রতিষ্ঠান' : 'Institution',
              value: institution,
            ),
          if (department != null && department.isNotEmpty)
            _DetailRow(
              icon: Icons.book_rounded,
              label: l10n.isBangla ? 'বিভাগ' : 'Department',
              value: department,
            ),
          if (studentId != null && studentId.isNotEmpty)
            _DetailRow(
              icon: Icons.badge_rounded,
              label: l10n.isBangla ? 'আইডি' : 'Student ID',
              value: studentId,
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}