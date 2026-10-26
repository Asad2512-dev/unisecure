import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Centralized Material 3 Light Theme for UniSecure.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.primaryDark,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.mainText,
          outline: AppColors.border,
          outlineVariant: AppColors.borderLight,
          error: AppColors.error,
          onError: Colors.white,
        ),
    textTheme: AppTypography.textTheme,
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: const BorderSide(
          color: AppColors.border,
          width: AppDimensions.strokeWidth,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.mainText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.titleLarge,
      iconTheme: const IconThemeData(
        color: AppColors.mainText,
        size: AppDimensions.iconMd,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: AppSpacing.input,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.subtleText),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.secondaryText,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.fieldRadius,
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppDimensions.strokeWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.fieldRadius,
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppDimensions.strokeWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.fieldRadius,
        borderSide: const BorderSide(
          color: AppColors.borderFocused,
          width: AppDimensions.strokeWidthThick,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.fieldRadius,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppDimensions.strokeWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.fieldRadius,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppDimensions.strokeWidthThick,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        foregroundColor: AppColors.mainText,
        side: const BorderSide(
          color: AppColors.border,
          width: AppDimensions.strokeWidth,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppDimensions.touchTargetMin, 40),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: AppDimensions.strokeWidth,
      space: AppDimensions.strokeWidth,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.mainText,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondaryText,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTypography.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelSmall,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
        side: const BorderSide(
          color: AppColors.border,
          width: AppDimensions.strokeWidth,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      showDragHandle: true,
      dragHandleColor: AppColors.border,
      dragHandleSize: const Size(36, 4),
    ),
  );
}
