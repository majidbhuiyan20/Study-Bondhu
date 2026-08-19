import 'package:flutter/material.dart';

/// All colors used across the application must come from this class.
/// Never use [Colors] directly inside widgets.
class AppColors {
  AppColors._();

  // Brand — single solid emerald-green. Students love this colour; it feels
  // calm, focused and "alive" without being childish.
  static const primary = Color(0xFF10B981);          // emerald 500
  static const primaryDeep = Color(0xFF059669);      // emerald 600
  static const primaryLight = Color(0xFFD1FAE5);     // emerald 100
  static const primarySoft = Color(0xFFECFDF5);      // emerald 50

  // Accent — same green family, used for streaks / urgency chips
  static const accent = Color(0xFFF59E0B);           // amber 500 (warm contrast)
  static const accentLight = Color(0xFFFFEDD5);      // amber 100

  // Background — neutral warm off-white (lets the green pop)
  static const background = Color(0xFFF8FAF9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F4);
  static const surfaceMuted = Color(0xFFE8EEEC);

  // Ink
  static const textPrimary = Color(0xFF111827);      // near-black with green tint
  static const textSecondary = Color(0xFF5F6B72);
  static const textTertiary = Color(0xFF98A2A8);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFEAB308);
  static const warningLight = Color(0xFFFEF9C3);
  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF0EA5E9);
  static const infoLight = Color(0xFFE0F2FE);

  // Borders / dividers
  static const border = Color(0xFFE4EAE8);
  static const divider = Color(0xFFEEF2F0);

  // Dark theme — deeper, layered surfaces for a professional, "OLED-ish"
  // feel. The scaffold sits one step lower than cards so cards feel lifted
  // rather than washed out.
  static const darkBackground = Color(0xFF0B0F12);     // deep ink (scaffold)
  static const darkSurface = Color(0xFF161B1F);        // slightly lifted card
  static const darkSurfaceAlt = Color(0xFF1C2328);     // elevated / inputs
  static const darkSurfaceVariant = Color(0xFF222A30); // chips / pills
  static const darkTextPrimary = Color(0xFFE6EAEE);
  static const darkTextSecondary = Color(0xFF98A2AB);
  static const darkTextTertiary = Color(0xFF6B7480);
  static const darkBorder = Color(0xFF26303A);
  static const darkDivider = Color(0xFF1F262C);
}