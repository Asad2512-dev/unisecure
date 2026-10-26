import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Semantic status badge for attendance states, verification results, and gate transactions.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isSubtle;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isSubtle = true,
  });

  factory AppStatusBadge.fromString(String status, {IconData? icon}) {
    return AppStatusBadge(
      label: status.toUpperCase(),
      color: statusColor(status),
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.chip,
      decoration: BoxDecoration(
        color: isSubtle ? color.withValues(alpha: 0.12) : color,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: isSubtle
            ? Border.all(
                color: color.withValues(alpha: 0.25),
                width: AppDimensions.strokeWidth,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: isSubtle ? color : Colors.white),
            AppSpacing.hGap4,
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSubtle ? color : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility alias for existing code
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) =>
      AppStatusBadge(label: label, color: color);
}

/// Resolves standard semantic status colors based on backend strings.
Color statusColor(String value) {
  switch (value.trim().toLowerCase()) {
    case 'present':
    case 'active':
    case 'entry':
    case 'inside':
    case 'completed':
    case 'verified':
    case 'approved':
      return AppColors.success;
    case 'late':
    case 'pending':
    case 'in_progress':
    case 'partially_present':
      return AppColors.warning;
    case 'absent':
    case 'cancelled':
    case 'failed':
    case 'exited':
    case 'rejected':
    case 'inactive':
      return AppColors.error;
    case 'info':
    case 'scheduled':
      return AppColors.info;
    default:
      return AppColors.secondaryText;
  }
}
