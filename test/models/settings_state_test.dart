import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_bondhu/features/settings/view_models/settings_view_model.dart';

void main() {
  group('SettingsState', () {
    test('default values match spec', () {
      const s = SettingsState();
      expect(s.locale.languageCode, 'en');
      expect(s.themeMode, ThemeMode.system);
      expect(s.dailyGoalMinutes, 180);
      expect(s.notificationsEnabled, isTrue);
      expect(s.notifAssignments, isTrue);
      expect(s.notifRevisions, isTrue);
      expect(s.notifExams, isTrue);
      expect(s.notifDailyGoal, isTrue);
      expect(s.notifAttendance, isFalse, reason: 'attendance alerts default off');
    });

    test('copyWith updates only the supplied field', () {
      const s = SettingsState();
      final updated = s.copyWith(locale: Locale('bn'), dailyGoalMinutes: 360);
      expect(updated.locale.languageCode, 'bn');
      expect(updated.dailyGoalMinutes, 360);
      // Untouched fields preserve defaults.
      expect(updated.themeMode, ThemeMode.system);
      expect(updated.notificationsEnabled, isTrue);
      expect(updated.notifAttendance, isFalse);
    });

    test('copyWith can flip individual notification toggles', () {
      const s = SettingsState();
      final updated = s.copyWith(notifAssignments: false, notifAttendance: true);
      expect(updated.notifAssignments, isFalse);
      expect(updated.notifAttendance, isTrue);
      expect(updated.notifRevisions, isTrue); // unchanged
      expect(updated.notifExams, isTrue); // unchanged
    });
  });
}