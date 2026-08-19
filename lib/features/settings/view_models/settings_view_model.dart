import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/services/local_storage_service.dart';

class SettingsState {
  final Locale locale;
  final ThemeMode themeMode;
  final int dailyGoalMinutes;
  final bool notificationsEnabled;
  final bool notifAssignments;
  final bool notifRevisions;
  final bool notifExams;
  final bool notifDailyGoal;
  final bool notifAttendance;

  const SettingsState({
    this.locale = const Locale('en'),
    this.themeMode = ThemeMode.system,
    this.dailyGoalMinutes = 180,
    this.notificationsEnabled = true,
    this.notifAssignments = true,
    this.notifRevisions = true,
    this.notifExams = true,
    this.notifDailyGoal = true,
    this.notifAttendance = false,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
    bool? notifAssignments,
    bool? notifRevisions,
    bool? notifExams,
    bool? notifDailyGoal,
    bool? notifAttendance,
  }) =>
      SettingsState(
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
        dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        notifAssignments: notifAssignments ?? this.notifAssignments,
        notifRevisions: notifRevisions ?? this.notifRevisions,
        notifExams: notifExams ?? this.notifExams,
        notifDailyGoal: notifDailyGoal ?? this.notifDailyGoal,
        notifAttendance: notifAttendance ?? this.notifAttendance,
      );
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel(this._storage)
      : super(SettingsState(
          locale: Locale(_storage.locale),
          themeMode: _storage.themeModeEnum,
          dailyGoalMinutes: _storage.dailyGoalMinutes,
          notificationsEnabled: _storage.notificationsEnabled,
          notifAssignments: _storage.notifAssignments,
          notifRevisions: _storage.notifRevisions,
          notifExams: _storage.notifExams,
          notifDailyGoal: _storage.notifDailyGoal,
          notifAttendance: _storage.notifAttendance,
        ));

  final LocalStorageService _storage;

  Future<void> setLocale(Locale locale) async {
    await _storage.setLocale(locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final key = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.setThemeMode(key);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setDailyGoalMinutes(int v) async {
    await _storage.setDailyGoalMinutes(v);
    state = state.copyWith(dailyGoalMinutes: v);
  }

  Future<void> setNotificationsEnabled(bool v) async {
    await _storage.setNotificationsEnabled(v);
    state = state.copyWith(notificationsEnabled: v);
  }

  Future<void> setNotifAssignments(bool v) async {
    await _storage.setNotifAssignments(v);
    state = state.copyWith(notifAssignments: v);
  }

  Future<void> setNotifRevisions(bool v) async {
    await _storage.setNotifRevisions(v);
    state = state.copyWith(notifRevisions: v);
  }

  Future<void> setNotifExams(bool v) async {
    await _storage.setNotifExams(v);
    state = state.copyWith(notifExams: v);
  }

  Future<void> setNotifDailyGoal(bool v) async {
    await _storage.setNotifDailyGoal(v);
    state = state.copyWith(notifDailyGoal: v);
  }

  Future<void> setNotifAttendance(bool v) async {
    await _storage.setNotifAttendance(v);
    state = state.copyWith(notifAttendance: v);
  }
}

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>(
  (ref) => SettingsViewModel(ref.watch(localStorageProvider)),
);
