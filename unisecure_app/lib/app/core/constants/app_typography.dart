import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typographic scale for UniSecure using Google Fonts Inter.
class AppTypography {
  AppTypography._();

  static bool get _isTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required double letterSpacing,
    required Color color,
  }) {
    if (_isTest) {
      return TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }

    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle get displayLarge => _font(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.8,
    color: AppColors.mainText,
  );

  static TextStyle get displayMedium => _font(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.28,
    letterSpacing: -0.6,
    color: AppColors.mainText,
  );

  static TextStyle get displaySmall => _font(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.4,
    color: AppColors.mainText,
  );

  static TextStyle get headlineLarge => _font(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.32,
    letterSpacing: -0.3,
    color: AppColors.mainText,
  );

  static TextStyle get headlineMedium => _font(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
    color: AppColors.mainText,
  );

  static TextStyle get headlineSmall => _font(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.38,
    letterSpacing: -0.1,
    color: AppColors.mainText,
  );

  static TextStyle get titleLarge => _font(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.0,
    color: AppColors.mainText,
  );

  static TextStyle get titleMedium => _font(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.0,
    color: AppColors.mainText,
  );

  static TextStyle get titleSmall => _font(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.42,
    letterSpacing: 0.1,
    color: AppColors.mainText,
  );

  static TextStyle get bodyLarge => _font(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.mainText,
  );

  static TextStyle get bodyMedium => _font(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.mainText,
  );

  static TextStyle get bodySmall => _font(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.46,
    letterSpacing: 0.15,
    color: AppColors.secondaryText,
  );

  static TextStyle get labelLarge => _font(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.1,
    color: AppColors.mainText,
  );

  static TextStyle get labelMedium => _font(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.2,
    color: AppColors.mainText,
  );

  static TextStyle get labelSmall => _font(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.3,
    color: AppColors.secondaryText,
  );

  static TextStyle get caption => _font(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.secondaryText,
  );

  /// Builds a complete Material 3 TextTheme tinted to UniSecure colors.
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
