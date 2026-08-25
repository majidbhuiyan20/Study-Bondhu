import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/services/notification_scheduler.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../view_models/settings_view_model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(settingsViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          IconButton(
            tooltip: l10n.search,
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.appName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          Text(
                              '${l10n.version} 1.0.0 • ${l10n.offline}',
                              style: TextStyle(
                                  color: ThemeColors.textSecondary(context),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(title: l10n.language),
          const SizedBox(height: 8),
          AppCard(
            child: RadioGroup<String>(
              groupValue: state.locale.languageCode,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setLocale(Locale(v));
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: AppConstants.localeEn,
                    title: const Text('English'),
                  ),
                  RadioListTile<String>(
                    value: AppConstants.localeBn,
                    title: const Text('বাংলা'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Section(title: l10n.theme),
          const SizedBox(height: 8),
          AppCard(
            child: RadioGroup<ThemeMode>(
              groupValue: state.themeMode,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setThemeMode(v);
                }
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: Text(l10n.systemMode),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text(l10n.lightMode),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text(l10n.darkMode),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Section(title: l10n.dailyGoal),
          const SizedBox(height: 8),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('${state.dailyGoalMinutes} min',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${(state.dailyGoalMinutes / 60).toStringAsFixed(1)} h',
                          style: TextStyle(
                              color: ThemeColors.textSecondary(context))),
                    ],
                  ),
                  Slider(
                    value: state.dailyGoalMinutes.toDouble(),
                    min: 30,
                    max: 600,
                    divisions: 19,
                    onChanged: (v) {
                      ref
                          .read(settingsViewModelProvider.notifier)
                          .setDailyGoalMinutes(v.round());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Section(title: l10n.notifications),
          const SizedBox(height: 8),
          AppCard(
            child: SwitchListTile(
              value: state.notificationsEnabled,
              onChanged: (v) async {
                if (v) {
                  // Confirm first — spec #36: explicit opt-in for permissions.
                  final ok = await _confirmNotifications(context);
                  if (!ok) return;
                  await NotificationService.instance.requestPermissions();
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setNotificationsEnabled(true);
                  await ref
                      .read(notificationSchedulerProvider)
                      .scheduleAll();
                } else {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setNotificationsEnabled(false);
                  await NotificationService.instance.cancelAll();
                }
              },
              title: Text(
                l10n.isBangla ? 'রিমাইন্ডার চালু করুন' : 'Enable reminders',
              ),
              subtitle: Text(
                l10n.isBangla
                    ? 'দৈনিক পড়া ও পরীক্ষার অ্যালার্ট'
                    : 'Daily study reminders and exam alerts',
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _NotifTile(
                  title: l10n.isBangla
                      ? 'অ্যাসাইনমেন্ট রিমাইন্ডার'
                      : 'Assignment reminders',
                  subtitle: l10n.isBangla
                      ? 'ডেডলাইনের আগের দিন রাত ৮টায়'
                      : 'Day before deadline, 8 PM',
                  value: state.notifAssignments,
                  enabled: state.notificationsEnabled,
                  onChanged: (v) async {
                    await ref
                        .read(settingsViewModelProvider.notifier)
                        .setNotifAssignments(v);
                    await ref
                        .read(notificationSchedulerProvider)
                        .scheduleAll();
                  },
                ),
                const Divider(height: 1),
                _NotifTile(
                  title: l10n.isBangla
                      ? 'রিভিশন রিমাইন্ডার'
                      : 'Revision reminders',
                  subtitle: l10n.isBangla
                      ? 'সকাল ৮টায়, রিভিশনের দিন'
                      : 'Morning of revision day, 8 AM',
                  value: state.notifRevisions,
                  enabled: state.notificationsEnabled,
                  onChanged: (v) async {
                    await ref
                        .read(settingsViewModelProvider.notifier)
                        .setNotifRevisions(v);
                    await ref
                        .read(notificationSchedulerProvider)
                        .scheduleAll();
                  },
                ),
                const Divider(height: 1),
                _NotifTile(
                  title: l10n.isBangla
                      ? 'পরীক্ষার রিমাইন্ডার'
                      : 'Exam reminders',
                  subtitle: l10n.isBangla
                      ? '৭/৩/১ দিন আগে, সকাল ৮টায়'
                      : '7/3/1 day(s) before, 8 AM',
                  value: state.notifExams,
                  enabled: state.notificationsEnabled,
                  onChanged: (v) async {
                    await ref
                        .read(settingsViewModelProvider.notifier)
                        .setNotifExams(v);
                    await ref
                        .read(notificationSchedulerProvider)
                        .scheduleAll();
                  },
                ),
                const Divider(height: 1),
                _NotifTile(
                  title: l10n.isBangla
                      ? 'দৈনিক লক্ষ্যের রিমাইন্ডার'
                      : 'Daily goal reminder',
                  subtitle: l10n.isBangla
                      ? 'প্রতিদিন রাত ৮টায়'
                      : 'Daily at 8 PM',
                  value: state.notifDailyGoal,
                  enabled: state.notificationsEnabled,
                  onChanged: (v) async {
                    await ref
                        .read(settingsViewModelProvider.notifier)
                        .setNotifDailyGoal(v);
                    await ref
                        .read(notificationSchedulerProvider)
                        .scheduleAll();
                  },
                ),
                const Divider(height: 1),
                _NotifTile(
                  title: l10n.isBangla
                      ? 'হাজিরা সতর্কতা'
                      : 'Attendance alerts',
                  subtitle: l10n.isBangla
                      ? 'কোনো বিষয়ে টার্গেটের নিচে গেলে'
                      : 'When a subject drops below target',
                  value: state.notifAttendance,
                  enabled: state.notificationsEnabled,
                  onChanged: (v) async {
                    await ref
                        .read(settingsViewModelProvider.notifier)
                        .setNotifAttendance(v);
                    await ref
                        .read(notificationSchedulerProvider)
                        .scheduleAll();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            onTap: () => context.push(AppRoutes.routines),
            child: ListTile(
              leading:
                  const Icon(Icons.repeat_rounded, color: AppColors.primary),
              title: const Text('Daily / weekly routines'),
              subtitle: Text(
                'Add recurring habits like "Read Bangla 30 min"',
                style: TextStyle(
                    color: ThemeColors.textSecondary(context)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => context.push(AppRoutes.streak),
            child: ListTile(
              leading: const Icon(Icons.local_fire_department,
                  color: AppColors.accent),
              title: Text(l10n.streakLabel),
              subtitle: Text(
                l10n.isBangla
                    ? 'মাসিক ক্যালেন্ডার হিটম্যাপ দেখুন'
                    : 'See your monthly heatmap',
                style: TextStyle(
                    color: ThemeColors.textSecondary(context)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => context.push(AppRoutes.backup),
            child: ListTile(
              leading: const Icon(Icons.cloud_off_rounded,
                  color: AppColors.primary),
              title: Text(l10n.isBangla ? 'ব্যাকআপ' : 'Backup'),
              subtitle: Text(
                l10n.isBangla
                    ? 'JSON ফাইলে এক্সপোর্ট বা রিস্টোর'
                    : 'Export or restore from a JSON file',
                style: TextStyle(
                    color: ThemeColors.textSecondary(context)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => context.push(AppRoutes.profiles),
            child: ListTile(
              leading: const Icon(Icons.school_outlined,
                  color: AppColors.primary),
              title: const Text('Class / profile'),
              subtitle: Text(
                'Set your class/grade and institution',
                style: TextStyle(
                    color: ThemeColors.textSecondary(context)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              leading:
                  const Icon(Icons.info_outline, color: AppColors.primary),
              title: Text(l10n.about),
              subtitle: const Text(
                  'StudyBondhu helps Bangladeshi students track academics offline.'),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.isBangla ? 'গোপনীয়তা' : 'Privacy',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.isBangla
                        ? '• অ্যাকাউন্ট লাগে না'
                        : '• No account required',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context),
                        fontSize: 12),
                  ),
                  Text(
                    l10n.isBangla
                        ? '• সব ডেটা এই ডিভাইসে থাকে'
                        : '• All data stays on this device',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context),
                        fontSize: 12),
                  ),
                  Text(
                    l10n.isBangla
                        ? '• কোনো অ্যানালিটিক্স বা ট্র্যাকিং নেই'
                        : '• No analytics or tracking',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context),
                        fontSize: 12),
                  ),
                  Text(
                    l10n.isBangla
                        ? '• নোটিফিকেশন শুধু সেটিংসে চালু করলে চাওয়া হয়'
                        : '• Notifications only requested when you toggle them on',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context),
                        fontSize: 12),
                  ),
                  Text(
                    l10n.isBangla
                        ? '• ফাইল রিসোর্স: শুধু পাথ সংরক্ষণ, কপি হয় না'
                        : '• File resources: only paths are stored, never copied',
                    style: TextStyle(
                        color: ThemeColors.textSecondary(context),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textSecondary(context),
              letterSpacing: 0.4)),
    );
  }
}

Future<bool> _confirmNotifications(BuildContext context) async {
  final l10n = context.l10n;
  final isBn = l10n.isBangla;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isBn ? 'রিমাইন্ডার চালু করবেন?' : 'Allow reminders?'),
      content: Text(
        isBn
            ? 'স্টাডিবন্ধু আপনাকে অ্যাসাইনমেন্ট, রিভিশন, পরীক্ষা ও দৈনিক লক্ষ্যের রিমাইন্ডার পাঠাতে চায়। আপনি যেকোনো সময় সেটিংস থেকে বন্ধ করতে পারবেন।'
            : 'StudyBondhu would like to send you reminders for assignments, revisions, exams, and your daily goal. You can turn this off anytime in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(isBn ? 'না' : 'Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(isBn ? 'অনুমতি দিন' : 'Allow'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value && enabled,
      onChanged: enabled ? onChanged : null,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: ThemeColors.textSecondary(context)),
      ),
    );
  }
}