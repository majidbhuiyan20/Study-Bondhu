import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../repositories/attendance_repository.dart';

/// Returns a map of subjectId -> AttendanceStats.
///
/// `autoDispose` so the provider is torn down when no longer watched (the
/// attendance screen is the only consumer today).
final attendanceStatsProvider =
    FutureProvider.autoDispose<Map<int, AttendanceStats>>((ref) async {
  return ref.watch(attendanceRepositoryProvider).getAllStats();
});