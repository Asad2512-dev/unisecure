import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Top-level page header with prominent typography, optional subtitle, and trailing action.
class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? tag;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null) ...[tag!, AppSpacing.vGap8],
                  Text(
                    title,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.mainText,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[AppSpacing.hGap12, trailing!],
          ],
        ),
        if (subtitle != null) ...[
          AppSpacing.vGap4,
          Text(
            subtitle!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

/// Section divider and title row with optional trailing action button.
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.mainText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                AppSpacing.vGap4,
                Text(
                  subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(48, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ?trailing,
      ],
    );
  }
}
