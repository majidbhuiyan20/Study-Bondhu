import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../subjects/models/subject.dart';
import '../models/attendance_record.dart';
import '../repositories/attendance_repository.dart';
import '../view_models/attendance_view_model.dart';
import '../widgets/attendance_row.dart';

class AttendanceView extends ConsumerWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final subjectsAsync = ref.watch(_subjectsProvider);
    final statsAsync = ref.watch(attendanceStatsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendanceTitle)),
      body: subjectsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (subjects) {
          if (subjects.isEmpty) {
            return AppEmptyState(
              title: 'Add subjects first',
              message: 'Track class attendance per subject',
              icon: Icons.event_available_outlined,
            );
          }
          return statsAsync.when(
            loading: () => const AppLoading(),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (statsMap) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                separatorBuilder: (_, i) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final subject = subjects[i];
                  final st = statsMap[subject.id] ?? _emptyStats;
                  return AttendanceRow(
                    subject: subject,
                    stats: st,
                    onMark: (status) => _markAttendance(ref, subject, status),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAttendance(
    WidgetRef ref,
    Subject subject,
    AttendanceStatus status,
  ) async {
    if (subject.id == null) return;
    final now = DateTime.now();
    await ref.read(attendanceRepositoryProvider).addAttendance(
          AttendanceRecord(
            subjectId: subject.id!,
            date: now,
            status: status,
            createdAt: now,
          ),
        );
    ref.invalidate(attendanceStatsProvider);
  }
}

final _subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return ref.watch(subjectsRepositoryProvider).getSubjects();
});

final AttendanceStats _emptyStats = AttendanceStats(
  present: 0,
  late: 0,
  absent: 0,
  total: 0,
  percent: 0,
);