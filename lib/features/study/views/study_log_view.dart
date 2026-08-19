import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/duration_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../subjects/models/topic.dart';
import '../models/study_session.dart';
import '../view_models/study_view_model.dart';
import '../widgets/session_tile.dart';

/// Spec 14 — study history grouped by day / week / month / subject / topic.
class StudyLogView extends ConsumerStatefulWidget {
  const StudyLogView({super.key});

  @override
  ConsumerState<StudyLogView> createState() => _StudyLogViewState();
}

class _StudyLogViewState extends ConsumerState<StudyLogView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(studyViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(studyViewModelProvider);
    final subjectsAsync = ref.watch(_subjectsProvider);
    final topicsAsync = ref.watch(_allTopicsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.studyLogTitle),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
            Tab(text: 'Subject'),
            Tab(text: 'Topic'),
          ],
        ),
      ),
      body: state.isLoading || subjectsAsync.isLoading
          ? const AppLoading()
          : state.sessions.isEmpty
              ? AppEmptyState(
                  title: l10n.noSessionsLabel,
                  message: l10n.noSessionsHint,
                  icon: Icons.timer_outlined,
                )
              : () {
                  final subjects = subjectsAsync.valueOrNull ?? const [];
                  final allTopics =
                      topicsAsync.valueOrNull ?? const <Topic>[];
                  final subjectNames = {
                    for (final s in subjects)
                      if (s.id != null) s.id!: s.name,
                  };
                  final topicNames = {
                    for (final t in allTopics)
                      if (t.id != null) t.id!: t.name,
                  };
                  return TabBarView(
                    controller: _tab,
                    children: [
                      _GroupedList(
                        sessions: state.sessions,
                        groupBy: (s) => _day(s.startTime),
                        headerLabel: (d) => _dayLabel(d as DateTime),
                        subjectNames: subjectNames,
                        topicNames: topicNames,
                      ),
                      _GroupedList(
                        sessions: state.sessions,
                        groupBy: (s) => _week(s.startTime),
                        headerLabel: (d) => 'Week of ${_dayLabel(d as DateTime)}',
                        subjectNames: subjectNames,
                        topicNames: topicNames,
                      ),
                      _GroupedList(
                        sessions: state.sessions,
                        groupBy: (s) => _month(s.startTime),
                        headerLabel: (d) => _monthLabel(d as DateTime),
                        subjectNames: subjectNames,
                        topicNames: topicNames,
                      ),
                      _GroupedList(
                        sessions: state.sessions,
                        groupBy: (s) => s.subjectId ?? -1,
                        headerLabel: (id) {
                          if (id == -1) return 'No subject';
                          return subjectNames[id] ?? 'Subject #$id';
                        },
                        subjectNames: subjectNames,
                        topicNames: topicNames,
                      ),
                      _GroupedList(
                        sessions: state.sessions,
                        groupBy: (s) => s.topicId ?? -1,
                        headerLabel: (id) {
                          if (id == -1) return 'No topic';
                          return topicNames[id] ?? 'Topic #$id';
                        },
                        subjectNames: subjectNames,
                        topicNames: topicNames,
                      ),
                    ],
                  );
                }(),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.sessions,
    required this.groupBy,
    required this.headerLabel,
    required this.subjectNames,
    required this.topicNames,
  });

  final List<StudySession> sessions;
  final Object Function(StudySession) groupBy;
  final String Function(Object) headerLabel;
  final Map<int, String> subjectNames;
  final Map<int, String> topicNames;

  @override
  Widget build(BuildContext context) {
    final groups = <Object, List<StudySession>>{};
    for (final s in sessions) {
      groups.putIfAbsent(groupBy(s), () => []).add(s);
    }
    final keys = groups.keys.toList();
    if (keys.isNotEmpty && keys.first is DateTime) {
      keys.sort((a, b) => (b as DateTime).compareTo(a as DateTime));
    }
    if (keys.isNotEmpty && keys.first is int) {
      keys.sort((a, b) => (a as int).compareTo(b as int));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final k in keys) ...[
          _GroupHeader(
            label: headerLabel(k),
            totalSeconds: groups[k]!
                .fold<int>(0, (acc, s) => acc + s.durationSeconds),
          ),
          const SizedBox(height: 8),
          ...groups[k]!.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SessionTile(
                  session: s,
                  subjectName: subjectNames[s.subjectId] ?? '—',
                  topicName: topicNames[s.topicId],
                ),
              )),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.totalSeconds});
  final String label;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(label,
              style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
          const Spacer(),
          Text(
            'Total ${DurationUtils.formatHuman(Duration(seconds: totalSeconds))}',
            style: AppTextStyles.label.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- grouping helpers ----------------

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);
DateTime _week(DateTime t) =>
    _day(t).subtract(Duration(days: _day(t).weekday - 1));
DateTime _month(DateTime t) => DateTime(t.year, t.month, 1);
String _dayLabel(DateTime d) =>
    '${d.day} ${_monthName(d.month)} ${d.year}';
String _monthLabel(DateTime d) => '${_monthName(d.month)} ${d.year}';
String _monthName(int m) {
  const names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return names[m - 1];
}

// ---------------- providers ----------------

final _subjectsProvider = FutureProvider((ref) async {
  return ref.watch(subjectsRepositoryProvider).getSubjects();
});

final _allTopicsProvider = FutureProvider.autoDispose<List<Topic>>((ref) async {
  return ref.watch(subjectsRepositoryProvider).getAllTopics();
});
