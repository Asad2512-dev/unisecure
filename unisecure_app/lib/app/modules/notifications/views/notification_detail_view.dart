import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../data/models/notification_models.dart';

/// Detail view displaying complete notification contents, advisories, and action routing.
class NotificationDetailView extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailView({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Notification Details')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // Category and timestamp header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppStatusBadge(
                label: notification.type.label.toUpperCase(),
                color: notification.type.color,
                icon: notification.type.icon,
              ),
              Text(
                notification.timeAgo,
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.vGap16,

          // Main Title
          Text(
            notification.title,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.mainText,
              letterSpacing: -0.3,
            ),
          ),
          AppSpacing.vGap8,

          // Issuer / Sender Tag
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 16,
                color: notification.type.color,
              ),
              AppSpacing.hGap6,
              Expanded(
                child: Text(
                  notification.sender,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGap16,
          const AppDivider(),
          AppSpacing.vGap16,

          // Primary Body Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                AppSpacing.vGap6,
                Text(
                  notification.body,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mainText,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,

          // Extended Details Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 18,
                      color: notification.type.color,
                    ),
                    AppSpacing.hGap8,
                    Text(
                      'Official Advisory & Instructions',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap10,
                Text(
                  notification.details,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mainText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,

          // Metadata Info
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: AppColors.secondaryText,
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timestamp',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      AppSpacing.vGap2,
                      Text(
                        notification.formattedDate,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // Optional Action Button
          if (notification.actionLabel != null) ...[
            AppButton.primary(
              text: notification.actionLabel!,
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (notification.actionRoute != null) {
                  Get.back();
                  Get.toNamed(notification.actionRoute!);
                } else {
                  Get.back();
                }
              },
            ),
            AppSpacing.vGap12,
          ],

          AppButton.outlined(
            text: 'Back to Notifications',
            icon: Icons.close_rounded,
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
