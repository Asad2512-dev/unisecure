import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_durations.dart';
import '../constants/app_icons.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import 'app_buttons.dart';

/// Centralized notification snackbars following UniSecure light-mode design guidelines.
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess({
    String title = 'Success',
    required String message,
    Duration duration = AppDurations.snackbar,
  }) {
    _show(
      title: title,
      message: message,
      icon: AppIcons.success,
      accentColor: AppColors.success,
      duration: duration,
    );
  }

  static void showError({
    String title = 'Error',
    required String message,
    Duration duration = AppDurations.snackbar,
  }) {
    _show(
      title: title,
      message: message,
      icon: AppIcons.error,
      accentColor: AppColors.error,
      duration: duration,
    );
  }

  static void showWarning({
    String title = 'Notice',
    required String message,
    Duration duration = AppDurations.snackbar,
  }) {
    _show(
      title: title,
      message: message,
      icon: AppIcons.warning,
      accentColor: AppColors.warning,
      duration: duration,
    );
  }

  static void showInfo({
    String title = 'Information',
    required String message,
    Duration duration = AppDurations.snackbar,
  }) {
    _show(
      title: title,
      message: message,
      icon: AppIcons.info,
      accentColor: AppColors.info,
      duration: duration,
    );
  }

  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color accentColor,
    required Duration duration,
  }) {
    if (Get.context == null || Get.overlayContext == null) {
      // In headless unit test environments, avoid triggering overlay snackbars
      return;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.surface,
      colorText: AppColors.mainText,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accentColor, size: AppDimensions.iconSm),
      ),
      shouldIconPulse: false,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: AppRadius.md,
      borderColor: AppColors.border,
      borderWidth: AppDimensions.strokeWidth,
      boxShadows: [
        BoxShadow(
          color: AppColors.mainText.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      duration: duration,
      titleText: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.mainText,
        ),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
      ),
    );
  }
}

/// Confirmation bottom sheet helper providing accessible, bottom-anchored decision flows.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = AppStrings.confirm,
    String cancelText = AppStrings.cancel,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.sheet,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (isDestructive ? AppColors.error : AppColors.primary)
                              .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.primary,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                ),
                AppSpacing.vGap16,
              ],
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainText,
                ),
              ),
              AppSpacing.vGap8,
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              AppSpacing.vGap24,
              Row(
                children: [
                  Expanded(
                    child: AppButton.outlined(
                      text: cancelText,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: isDestructive
                        ? AppButton.danger(
                            text: confirmText,
                            onPressed: () => Navigator.of(ctx).pop(true),
                          )
                        : AppButton.primary(
                            text: confirmText,
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
