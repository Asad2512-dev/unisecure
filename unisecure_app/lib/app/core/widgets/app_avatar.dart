import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'app_cards.dart';

/// Clean user avatar showing initials fallback or remote image with optional status badge.
class AppAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final String? role;
  final IconData? badgeIcon;
  final Color? badgeColor;

  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = AppDimensions.avatarMd,
    this.role,
    this.badgeIcon,
    this.badgeColor,
  });

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color get _roleAccent {
    switch (role?.toLowerCase()) {
      case 'student':
        return AppColors.studentAccent;
      case 'teacher':
        return AppColors.teacherAccent;
      case 'guard':
        return AppColors.guardAccent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _roleAccent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: AppDimensions.strokeWidth,
            ),
          ),
          alignment: Alignment.center,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _initialsWidget,
                  ),
                )
              : _initialsWidget,
        ),
        if (badgeIcon != null)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(badgeIcon, size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget get _initialsWidget => Text(
    _initials,
    style: TextStyle(
      fontSize: size * 0.38,
      fontWeight: FontWeight.w700,
      color: _roleAccent,
    ),
  );
}

/// Profile summary banner card used across role dashboards and settings screens.
class AppProfileHeader extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? role;
  final String? idNumber;
  final String? avatarUrl;
  final List<Widget>? actions;
  final VoidCallback? onSignOut;

  const AppProfileHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.role,
    this.idNumber,
    this.avatarUrl,
    this.actions,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(
                name: name,
                imageUrl: avatarUrl,
                size: AppDimensions.avatarLg,
                role: role,
              ),
              AppSpacing.hGap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (idNumber != null) ...[
                      AppSpacing.vGap4,
                      Text(
                        'ID: $idNumber',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    if (role != null || subtitle != null) ...[
                      AppSpacing.vGap4,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          (role ?? subtitle!).toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onSignOut != null)
                IconButton(
                  onPressed: onSignOut,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.secondaryText,
                  ),
                  tooltip: 'Sign out',
                ),
            ],
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            AppSpacing.vGap16,
            const Divider(),
            AppSpacing.vGap8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
