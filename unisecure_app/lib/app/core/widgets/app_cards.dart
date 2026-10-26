import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Primary surface card component with subtle borders, zero elevation, and optional tap action.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.cardRadius;
    final cardWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: AppDimensions.strokeWidth,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: AppColors.primarySoft,
          highlightColor: Colors.transparent,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

/// Backward compatibility alias for existing code
typedef AppSurface = AppCard;

/// Informational feature card with icon container, title, description, and optional arrow.
class AppInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AppInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.accentColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconMd),
          ),
          AppSpacing.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap4,
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.hGap8,
            trailing!,
          ] else if (onTap != null) ...[
            AppSpacing.hGap8,
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: AppDimensions.iconSm,
            ),
          ],
        ],
      ),
    );
  }
}

/// Metric / statistic card for dashboards and overview cards.
class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final String? change;
  final bool isPositive;
  final Color? color;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.change,
    this.isPositive = true,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveColor,
                    size: AppDimensions.iconSm,
                  ),
                ),
            ],
          ),
          AppSpacing.vGap12,
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.mainText,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (change != null) ...[
            AppSpacing.vGap4,
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                AppSpacing.hGap4,
                Flexible(
                  child: Text(
                    change!,
                    style: AppTypography.caption.copyWith(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
