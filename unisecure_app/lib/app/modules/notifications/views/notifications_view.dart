import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/app_states.dart';
import '../../../data/models/notification_models.dart';
import '../controllers/notification_controller.dart';
import 'notification_detail_view.dart';

/// Shared notifications view for Student, Teacher, and Guard roles.
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return AppScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            AppSpacing.hGap8,
            Obx(() {
              final unread = controller.unreadCount.value;
              if (unread == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$unread',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          Obx(() {
            final unread = controller.unreadCount.value;
            if (unread == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: Text(
                'Mark All Read',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Controls Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                AppSearchField(
                  hint: 'Search alerts, security, academic...',
                  onChanged: controller.search,
                ),
                AppSpacing.vGap10,
                Obx(() {
                  final active = controller.activeFilter.value;
                  final unread = controller.unreadCount.value;

                  return Row(
                    children: [
                      _FilterChip(
                        label: 'All Alerts',
                        isSelected: active == 'all',
                        onTap: () => controller.setFilter('all'),
                      ),
                      AppSpacing.hGap8,
                      _FilterChip(
                        label: unread > 0 ? 'Unread ($unread)' : 'Unread',
                        isSelected: active == 'unread',
                        badgeCount: unread > 0 ? unread : null,
                        onTap: () => controller.setFilter('unread'),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const AppDivider(),

          // Main Notifications Feed
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingSkeleton();
              }

              if (controller.errorMessage.value != null) {
                return AppErrorState(
                  message: controller.errorMessage.value!,
                  onRetry: () => controller.loadNotifications(),
                );
              }

              final items = controller.notifications;
              if (items.isEmpty) {
                final isSearching = controller.searchQuery.value
                    .trim()
                    .isNotEmpty;
                final isUnreadOnly = controller.activeFilter.value == 'unread';

                return AppEmptyState(
                  icon: isSearching
                      ? Icons.search_off_rounded
                      : Icons.notifications_none_rounded,
                  title: isSearching
                      ? 'No Matching Alerts'
                      : (isUnreadOnly
                            ? 'All Caught Up!'
                            : 'No Notifications Yet'),
                  message: isSearching
                      ? 'No alerts match "${controller.searchQuery.value}".'
                      : (isUnreadOnly
                            ? 'You have read all pending notifications in your queue.'
                            : 'Important campus announcements, timetable adjustments, and attendance updates will appear here.'),
                  actionText: (isSearching || isUnreadOnly)
                      ? 'View All Alerts'
                      : null,
                  onAction: (isSearching || isUnreadOnly)
                      ? () {
                          controller.search('');
                          controller.setFilter('all');
                        }
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    controller.loadNotifications(showSkeleton: false),
                color: AppColors.primary,
                child: ListView.separated(
                  padding: AppSpacing.screen,
                  itemCount: items.length,
                  separatorBuilder: (context, _) => AppSpacing.vGap10,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _NotificationTile(
                      notification: item,
                      onTap: () {
                        controller.markAsRead(item.id);
                        Get.to(
                          () => NotificationDetailView(notification: item),
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: AppSpacing.screen,
      itemCount: 4,
      separatorBuilder: (context, _) => AppSpacing.vGap10,
      itemBuilder: (context, _) => const AppCard(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeleton(width: 80, height: 16),
                AppSkeleton(width: 48, height: 14),
              ],
            ),
            SizedBox(height: 10),
            AppSkeleton(width: double.infinity, height: 16),
            SizedBox(height: 6),
            AppSkeleton(width: 220, height: 14),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Icon Container
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: notification.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              notification.type.icon,
              size: 20,
              color: notification.type.color,
            ),
          ),
          AppSpacing.hGap12,

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              notification.type.label,
                              style: AppTypography.caption.copyWith(
                                color: notification.type.color,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead) ...[
                            AppSpacing.hGap6,
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSpacing.hGap8,
                    Text(
                      notification.timeAgo,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap4,
                Text(
                  notification.title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.w600
                        : FontWeight.w700,
                    color: AppColors.mainText,
                  ),
                ),
                AppSpacing.vGap4,
                Text(
                  notification.body,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
