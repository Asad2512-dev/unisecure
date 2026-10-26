import 'package:flutter/material.dart';

/// Centralized color palette for the UniSecure light-mode design system.
class AppColors {
  AppColors._();

  // Primary brand palette
  static const Color primary = Color(0xFF3157D5);
  static const Color primaryDark = Color(0xFF2445B5);
  static const Color primarySoft = Color(0xFFEDF2FD);
  static const Color primaryHover = Color(0xFF2A4EC4);

  // Backgrounds & surfaces
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);

  // Typography & Neutrals
  static const Color mainText = Color(0xFF172033);
  static const Color secondaryText = Color(0xFF68738A);
  static const Color subtleText = Color(0xFF94A3B8);
  static const Color disabledText = Color(0xFFCBD5E1);

  // Borders & Dividers
  static const Color border = Color(0xFFE5EAF2);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocused = Color(0xFF3157D5);
  static const Color divider = Color(0xFFEEF2F7);

  // Semantic Feedback & Status Colors
  static const Color success = Color(0xFF16845B);
  static const Color successSoft = Color(0xFFE8F6F0);

  static const Color warning = Color(0xFFB96A12);
  static const Color warningSoft = Color(0xFFFEF6ED);

  static const Color error = Color(0xFFC83D4D);
  static const Color errorSoft = Color(0xFFFDEDF0);
  static const Color danger = error; // Alias for backward compatibility
  static const Color dangerSoft = errorSoft;

  static const Color info = Color(0xFF3574C8);
  static const Color infoSoft = Color(0xFFEBF2FC);

  // Role Accents (Subtle, elegant differentiation)
  static const Color studentAccent = Color(0xFF3157D5);
  static const Color teacherAccent = Color(0xFF0F766E);
  static const Color guardAccent = Color(0xFF1E293B);

  // Legacy backwards-compatible aliases
  static const Color deepNavy = Color(0xFF172033);
  static const Color professionalTeal = Color(0xFF3157D5);
  static const Color paleBlueGray = Color(0xFFF6F8FC);
  static const Color navy = mainText;
  static const Color blue = primary;
  static const Color ink = mainText;
  static const Color muted = secondaryText;
}
