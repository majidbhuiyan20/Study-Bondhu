import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // Single font family — TriooBangla (Tiro Bangla). Has solid Latin + Bangla
  // coverage, so we don't need a separate Latin family. This gives the whole
  // app a consistent, warm, book-like voice.
  static const String _family = 'TriooBangla';

  // Headings — no hardcoded color so the theme (light/dark) drives the
  // foreground via DefaultTextStyle / TextTheme.apply().
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _family,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Body small defaults to a neutral foreground; widgets can override with
  // ThemeColors.textSecondary(context) when needed.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Numeric — tabular for timers / stats. No hardcoded color so theme wins.
  static const TextStyle numericHuge = TextStyle(
    fontFamily: _family,
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -1.0,
  );

  static const TextStyle numericLarge = TextStyle(
    fontFamily: _family,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}