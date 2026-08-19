import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../attendance/models/attendance_record.dart';

/// Spec 03 §"Attendance tab" — compact stats + quick mark buttons + recent log.
class SubjectAttendanceView extends ConsumerWidget {
  const SubjectAttendanceView({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync =
        ref.watch(_attendanceForSubjectProvider(subjectId));
    return recordsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) {
        final total = records.length;
        final present = records
            .where((r) => r.status == AttendanceStatus.present)
            .length;
        final lateCount = records
            .where((r) => r.status == AttendanceStatus.late)
            .length;
        final absent = records
            .where((r) => r.status == AttendanceStatus.absent)
            .length;
        final counted = present + lateCount;
        final pct = total == 0 ? 0.0 : counted / total * 100;
        final l10n = context.l10n;
        final color = pct >= 75
            ? AppColors.success
            : pct >= 65
                ? AppColors.warning
                : AppColors.error;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.attendance} — ${l10n.attendedLabel}',
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                      Text(
                        '${pct.round()}%',
                        style: AppTextStyles.numericLarge.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.targetPercent} 75% • $counted/$total ${l10n.attendedLabel}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: ThemeColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AttendanceBar(
                      present: present, late: lateCount, absent: absent),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Legend(
                          color: AppColors.success, label: 'P $present'),
                      const SizedBox(width: 12),
                      _Legend(
                          color: AppColors.warning,
                          label: 'L $lateCount'),
                      const SizedBox(width: 12),
                      _Legend(color: AppColors.error, label: 'A $absent'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(l10n.quickMark, style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MarkButton(
                    label: l10n.present,
                    color: AppColors.success,
                    onTap: () => _mark(
                        context, ref, AttendanceStatus.present),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MarkButton(
                    label: l10n.late,
                    color: AppColors.warning,
                    onTap: () => _mark(
                        context, ref, AttendanceStatus.late),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MarkButton(
                    label: l10n.absent,
                    color: AppColors.error,
                    onTap: () => _mark(
                        context, ref, AttendanceStatus.absent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (records.isEmpty)
              AppEmptyState(
                title: l10n.noNotes,
                message: l10n.attendance,
                icon: Icons.event_available_outlined,
              )
            else ...[
              Text(l10n.attendance, style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              ...records.take(15).map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            _statusDot(r.status),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _fmtDate(r.date),
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color:
                                    ThemeColors.textTertiary(context),
                              ),
                              onPressed: () async {
                                await ref
                                    .read(attendanceRepositoryProvider)
                                    .deleteAttendance(r.id!);
                                ref.invalidate(
                                    _attendanceForSubjectProvider(
                                        subjectId));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _mark(BuildContext context, WidgetRef ref,
      AttendanceStatus status) async {
    await ref.read(attendanceRepositoryProvider).addAttendance(
          AttendanceRecord(
            subjectId: subjectId,
            date: DateTime.now(),
            status: status,
            createdAt: DateTime.now(),
          ),
        );
    ref.invalidate(_attendanceForSubjectProvider(subjectId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.save} • ${status.name}')),
      );
    }
  }

  Widget _statusDot(AttendanceStatus status) {
    Color c;
    switch (status) {
      case AttendanceStatus.present:
        c = AppColors.success;
        break;
      case AttendanceStatus.late:
        c = AppColors.warning;
        break;
      case AttendanceStatus.absent:
        c = AppColors.error;
        break;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _AttendanceBar extends StatelessWidget {
  const _AttendanceBar({
    required this.present,
    required this.late,
    required this.absent,
  });
  final int present;
  final int late;
  final int absent;

  @override
  Widget build(BuildContext context) {
    final t = present + late + absent;
    if (t == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: ThemeColors.border(context),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            if (present > 0)
              Expanded(flex: present, child: Container(color: AppColors.success)),
            if (late > 0)
              Expanded(flex: late, child: Container(color: AppColors.warning)),
            if (absent > 0)
              Expanded(flex: absent, child: Container(color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: ThemeColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

final _attendanceForSubjectProvider =
    FutureProvider.family.autoDispose<List<AttendanceRecord>, int>(
  (ref, subjectId) async {
    final repo = ref.watch(attendanceRepositoryProvider);
    return repo.getAttendanceForSubject(subjectId);
  },
);
