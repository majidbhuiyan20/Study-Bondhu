import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Resolves the correct themed color regardless of light/dark mode.
///
/// Always prefer using these helpers over hardcoded [AppColors.textPrimary]
/// etc. inside widget bodies, otherwise text becomes invisible in dark mode.
class ThemeColors {
  ThemeColors._();

  static bool get _isDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark ||
      // Fallback: caller may have passed a context.
      false;

  /// Text that should always be readable — headline-like.
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkTextPrimary
          : AppColors.textPrimary;

  /// Slightly muted body text.
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkTextSecondary
          : AppColors.textSecondary;

  /// Most muted text (timestamps, hints).
  static Color textTertiary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkTextTertiary
          : AppColors.textTertiary;

  /// Background for cards & elevated surfaces.
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.surface;

  /// Slightly elevated surface (inputs, chips).
  static Color surfaceAlt(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceAlt
          : AppColors.surfaceVariant;

  /// Edge / divider color.
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBorder
          : AppColors.border;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkDivider
          : AppColors.divider;

  // Suppress unused-field lint; keeps the static available for callers that
  // need a quick system-brightness read without a context.
  // ignore: unused_element
  static bool get isSystemDark => _isDark;
}