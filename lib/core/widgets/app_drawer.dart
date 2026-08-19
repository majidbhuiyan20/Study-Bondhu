import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/profile/models/profile.dart' show ProfileLevelX;
import '../../features/profile/view_models/profile_view_model.dart';
import '../../features/settings/view_models/settings_view_model.dart';
import '../constants/app_routes.dart';
import '../l10n.dart'
    show
        AppLocalizationsBangla,
        AppLocalizationsCamelCase,
        AppLocalizationsX;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_colors.dart';

/// A polished side drawer with:
///   - Profile header (name, level, class)
///   - Quick stats tile (subjects / streak / today's goal)
///   - Categorised navigation (Study, Track, Review, Library)
///   - Footer (theme toggle, language switch, app version)
///
/// Designed to slot into the MainShell's Scaffold.drawer.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileViewModelProvider).active;
    final settings = ref.watch(settingsViewModelProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(
              name: profile?.name ?? l10n.setUpProfile,
              subtitle: profile == null
                  ? null
                  : [
                      profile.level.en,
                      if (profile.classLabel != null) profile.classLabel!,
                    ].join(' · '),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.profiles);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                children: [
                  _SectionTitle(text: l10n.drawerDashboard),
                  _DrawerTile(
                    icon: Icons.home_rounded,
                    label: l10n.drawerDashboard,
                    route: AppRoutes.shell,
                  ),
                  _DrawerTile(
                    icon: Icons.menu_book_rounded,
                    label: l10n.drawerSubjects,
                    route: AppRoutes.subjects,
                  ),
                  _DrawerTile(
                    icon: Icons.timer_rounded,
                    label: l10n.drawerAssignments,
                    route: AppRoutes.assignments,
                  ),
                  _DrawerTile(
                    icon: Icons.event_note_rounded,
                    label: l10n.drawerExams,
                    route: AppRoutes.exams,
                  ),
                  const SizedBox(height: 8),
                  _SectionTitle(text: l10n.drawerAttendance),
                  _DrawerTile(
                    icon: Icons.event_available_rounded,
                    label: l10n.drawerAttendance,
                    route: AppRoutes.attendance,
                  ),
                  _DrawerTile(
                    icon: Icons.repeat_rounded,
                    label: l10n.drawerRevision,
                    route: AppRoutes.revision,
                  ),
                  _DrawerTile(
                    icon: Icons.bar_chart_rounded,
                    label: l10n.drawerAnalytics,
                    route: AppRoutes.analytics,
                  ),
                  _DrawerTile(
                    icon: Icons.flag_rounded,
                    label: l10n.drawerGoals,
                    route: AppRoutes.analytics,
                  ),
                  const SizedBox(height: 8),
                  _SectionTitle(text: l10n.notes),
                  _DrawerTile(
                    icon: Icons.note_alt_rounded,
                    label: l10n.drawerNotes,
                    route: AppRoutes.notes,
                  ),
                  _DrawerTile(
                    icon: Icons.style_rounded,
                    label: l10n.drawerFlashcards,
                    route: AppRoutes.flashcards,
                  ),
                  _DrawerTile(
                    icon: Icons.payments_rounded,
                    label: l10n.drawerExpenses,
                    route: AppRoutes.expenses,
                  ),
                  _DrawerTile(
                    icon: Icons.calendar_view_week_rounded,
                    label: l10n.drawerRoutines,
                    route: AppRoutes.routines,
                  ),
                  _DrawerTile(
                    icon: Icons.event_note_rounded,
                    label: l10n.isBangla ? 'ক্লাস রুটিন' : 'Class routine',
                    route: AppRoutes.timetable,
                  ),
                  _DrawerTile(
                    icon: Icons.folder_outlined,
                    label: l10n.isBangla ? 'ফাইল রিসোর্স' : 'File resources',
                    route: AppRoutes.resources,
                  ),
                  _DrawerTile(
                    icon: Icons.timeline_rounded,
                    label: l10n.drawerTimeline,
                    route: AppRoutes.semesterTimeline,
                  ),
                  const SizedBox(height: 8),
                  _SectionTitle(text: l10n.drawerSettings),
                  _DrawerTile(
                    icon: Icons.search_rounded,
                    label: l10n.drawerSearch,
                    route: AppRoutes.search,
                  ),
                  _DrawerTile(
                    icon: Icons.settings_rounded,
                    label: l10n.drawerSettings,
                    route: AppRoutes.settings,
                  ),
                ],
              ),
            ),
            _DrawerFooter(
              themeLabel: settings.themeMode == ThemeMode.dark
                  ? l10n.darkMode
                  : settings.themeMode == ThemeMode.light
                      ? l10n.lightMode
                      : l10n.systemMode,
              onThemeTap: () => _showThemeSheet(context, ref, settings),
              onLangTap: () => _showLangSheet(context, ref, settings),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(
    BuildContext context,
    WidgetRef ref,
    SettingsState s,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((m) {
              final label = switch (m) {
                ThemeMode.system => ctx.l10n.systemMode,
                ThemeMode.light => ctx.l10n.lightMode,
                ThemeMode.dark => ctx.l10n.darkMode,
              };
              return ListTile(
                leading: Icon(switch (m) {
                  ThemeMode.system => Icons.brightness_auto_rounded,
                  ThemeMode.light => Icons.light_mode_rounded,
                  ThemeMode.dark => Icons.dark_mode_rounded,
                }),
                title: Text(label),
                trailing: m == s.themeMode
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setThemeMode(m);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLangSheet(
    BuildContext context,
    WidgetRef ref,
    SettingsState s,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: Text(ctx.l10n.english),
                trailing: s.locale.languageCode == 'en'
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setLocale(const Locale('en'));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇧🇩', style: TextStyle(fontSize: 24)),
                title: Text(ctx.l10n.bangla),
                trailing: s.locale.languageCode == 'bn'
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setLocale(const Locale('bn'));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.subtitle,
    required this.onTap,
  });
  final String name;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.primaryDeep.withValues(alpha: 0.5),
                      AppColors.primary.withValues(alpha: 0.25),
                    ]
                  : [
                      AppColors.primary,
                      AppColors.primaryDeep,
                    ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
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
                      name.isEmpty
                          ? '?'
                          : name.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: ThemeColors.textTertiary(context),
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Tile
// ---------------------------------------------------------------------

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selected = location == route ||
        (route == AppRoutes.shell && location.startsWith('/shell'));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected
              ? AppColors.primary
              : ThemeColors.textSecondary(context),
          size: 22,
        ),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: selected
                ? AppColors.primary
                : ThemeColors.textPrimary(context),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: selected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          if (route == AppRoutes.shell) {
            context.go(route);
          } else {
            context.push(route);
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------

class _DrawerFooter extends ConsumerWidget {
  const _DrawerFooter({
    required this.themeLabel,
    required this.onThemeTap,
    required this.onLangTap,
  });

  final String themeLabel;
  final VoidCallback onThemeTap;
  final VoidCallback onLangTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(settingsViewModelProvider);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ThemeColors.divider(context)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: _PillButton(
              icon: Icons.brightness_6_rounded,
              label: themeLabel,
              onTap: onThemeTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PillButton(
              icon: Icons.translate_rounded,
              label: s.locale.languageCode == 'bn'
                  ? l10n.bangla
                  : l10n.english,
              onTap: onLangTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeColors.surfaceAlt(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: ThemeColors.textSecondary(context)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}