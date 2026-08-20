import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static LocalStorageService? _instance;

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService(prefs);
    return _instance!;
  }

  static LocalStorageService get instance {
    assert(_instance != null, 'LocalStorageService not initialized');
    return _instance!;
  }

  Future<void> setLocale(String code) =>
      _prefs.setString(AppConstants.prefLocale, code);

  String get locale =>
      _prefs.getString(AppConstants.prefLocale) ?? AppConstants.localeEn;

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.prefThemeMode, mode);

  String get themeMode =>
      _prefs.getString(AppConstants.prefThemeMode) ?? 'system';

  Future<void> setOnboardingDone(bool v) =>
      _prefs.setBool(AppConstants.prefOnboardingDone, v);

  bool get onboardingDone =>
      _prefs.getBool(AppConstants.prefOnboardingDone) ?? false;

  Future<void> setDailyGoalMinutes(int v) =>
      _prefs.setInt(AppConstants.prefDailyGoalMinutes, v);

  int get dailyGoalMinutes =>
      _prefs.getInt(AppConstants.prefDailyGoalMinutes) ??
          AppConstants.defaultDailyGoalMinutes;

  Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(AppConstants.prefNotificationsEnabled, v);

  bool get notificationsEnabled =>
      _prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;

  // ----- Per-category notification toggles (spec #24) -----
  // All default to true so existing users keep getting reminders.
  bool get notifAssignments =>
      _prefs.getBool(AppConstants.prefNotifAssignments) ?? true;
  Future<void> setNotifAssignments(bool v) =>
      _prefs.setBool(AppConstants.prefNotifAssignments, v);

  bool get notifRevisions =>
      _prefs.getBool(AppConstants.prefNotifRevisions) ?? true;
  Future<void> setNotifRevisions(bool v) =>
      _prefs.setBool(AppConstants.prefNotifRevisions, v);

  bool get notifExams =>
      _prefs.getBool(AppConstants.prefNotifExams) ?? true;
  Future<void> setNotifExams(bool v) =>
      _prefs.setBool(AppConstants.prefNotifExams, v);

  bool get notifDailyGoal =>
      _prefs.getBool(AppConstants.prefNotifDailyGoal) ?? true;
  Future<void> setNotifDailyGoal(bool v) =>
      _prefs.setBool(AppConstants.prefNotifDailyGoal, v);

  bool get notifAttendance =>
      _prefs.getBool(AppConstants.prefNotifAttendance) ?? false;
  Future<void> setNotifAttendance(bool v) =>
      _prefs.setBool(AppConstants.prefNotifAttendance, v);

  Future<void> clearAll() => _prefs.clear();

  // ----- Active profile -----
  // Null when no preference has been recorded yet — callers should fall
  // back to the first profile in that case.
  String? get activeProfileId =>
      _prefs.getString(AppConstants.prefActiveProfileId);

  Future<void> setActiveProfileId(String? id) async {
    if (id == null) {
      await _prefs.remove(AppConstants.prefActiveProfileId);
    } else {
      await _prefs.setString(AppConstants.prefActiveProfileId, id);
    }
  }

  // Convenience
  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
