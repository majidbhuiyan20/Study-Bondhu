import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_router.dart';
import 'core/l10n.dart' show AppLocalizations;
import 'core/services/notification_scheduler.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/view_models/settings_view_model.dart';

class StudyBondhuApp extends ConsumerStatefulWidget {
  const StudyBondhuApp({super.key});

  @override
  ConsumerState<StudyBondhuApp> createState() => _StudyBondhuAppState();
}

class _StudyBondhuAppState extends ConsumerState<StudyBondhuApp> {
  late final _router = buildRouter();

  @override
  void initState() {
    super.initState();
    NotificationService.instance.init();
    // Re-schedule all upcoming notifications after first frame so the
    // database is fully open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // We can't read providers from initState without a ref, so schedule
      // here via a microtask once the widget tree is up.
      Future.microtask(() {
        if (!mounted) return;
        try {
          // ref is not directly available here; reach in via the router
          // builder when needed (ProviderContainer lives in ProviderScope).
          final container = ProviderScope.containerOf(context, listen: false);
          container.read(notificationSchedulerProvider).scheduleAll();
        } catch (_) {
          // Swallow — scheduling is best-effort at boot.
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsViewModelProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'StudyBondhu',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
      builder: (context, child) {
        return _AppShell(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force re-build when locale changes (since `MaterialApp` already handles
    // locale, this is mostly a safety net).
    ref.watch(settingsViewModelProvider);
    return child;
  }
}