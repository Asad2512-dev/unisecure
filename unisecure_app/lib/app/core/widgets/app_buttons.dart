import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger }

/// Reusable button component supporting primary, secondary, outlined, text, and danger variants
/// with responsive constraints, loading spinners, and accessible touch targets.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height = AppDimensions.buttonHeight,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height = AppDimensions.buttonHeight,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height = AppDimensions.buttonHeight,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height = AppDimensions.buttonHeight,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.textVariant({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.width,
    this.height = 40.0,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height = AppDimensions.buttonHeight,
  }) : variant = AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(_spinnerColor),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: _textColor),
          AppSpacing.hGap8,
          Flexible(
            child: Text(
              text,
              style: _textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      childContent = Text(
        text,
        style: _textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
            minimumSize: Size(
              width ?? (isFullWidth ? double.infinity : 64),
              height,
            ),
          ),
          child: childContent,
        );
      case AppButtonVariant.secondary:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.borderLight,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
            minimumSize: Size(
              width ?? (isFullWidth ? double.infinity : 64),
              height,
            ),
          ),
          child: childContent,
        );
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.mainText,
            side: const BorderSide(
              color: AppColors.border,
              width: AppDimensions.strokeWidth,
            ),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
            minimumSize: Size(
              width ?? (isFullWidth ? double.infinity : 64),
              height,
            ),
          ),
          child: childContent,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
            minimumSize: Size(
              width ?? (isFullWidth ? double.infinity : 48),
              height,
            ),
          ),
          child: childContent,
        );
      case AppButtonVariant.danger:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
            minimumSize: Size(
              width ?? (isFullWidth ? double.infinity : 64),
              height,
            ),
          ),
          child: childContent,
        );
    }

    if (width != null || isFullWidth) {
      return SizedBox(
        width: width ?? (isFullWidth ? double.infinity : null),
        child: button,
      );
    }
    return button;
  }

  Color get _spinnerColor {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
      case AppButtonVariant.text:
      case AppButtonVariant.outlined:
        return AppColors.primary;
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
      case AppButtonVariant.text:
        return AppColors.primary;
      case AppButtonVariant.outlined:
        return AppColors.mainText;
    }
  }

  TextStyle get _textStyle => AppTypography.labelLarge.copyWith(
    color: _textColor,
    fontWeight: FontWeight.w600,
  );
}
