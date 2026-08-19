import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/utils/duration_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../view_models/study_view_model.dart';
import '../widgets/timer_panel.dart';

class StudyView extends ConsumerStatefulWidget {
  const StudyView({super.key});

  @override
  ConsumerState<StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends ConsumerState<StudyView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(studyViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(studyViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navStudy)),
      body: state.isLoading
          ? const AppLoading()
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(studyViewModelProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const TimerPanel(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(l10n.todaysStudySoFar,
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.push(AppRoutes.studyLog),
                        icon: const Icon(Icons.list_alt, size: 18),
                        label: Text(l10n.seeAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.sessions.isEmpty)
                    AppEmptyState(
                      title: l10n.noStudySessions,
                      message:
                          'Start your first session using the timer',
                      icon: Icons.timer_outlined,
                    )
                  else
                    ...state.sessions.take(5).map((s) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(
                                DurationUtils.formatHms(s.duration)),
                            subtitle: Text(
                              '${s.mode.name.toUpperCase()} • ${s.startTime}',
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
