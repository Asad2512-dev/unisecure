import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../features/notifications/notification_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/guard_controller.dart';
import 'tabs/guard_gate_tab.dart';
import 'tabs/guard_history_tab.dart';
import 'tabs/guard_profile_tab.dart';
import 'tabs/guard_visitors_tab.dart';

/// Modern Light-Mode Workspace Shell for Guard / Campus Perimeter Security.
class GuardShellView extends StatelessWidget {
  const GuardShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuardController());
    final auth = Get.find<AuthController>();

    const navItems = [
      AppNavBarItem(
        label: 'Gate',
        icon: Icons.security_outlined,
        activeIcon: Icons.security_rounded,
      ),
      AppNavBarItem(
        label: 'Visitors',
        icon: Icons.group_outlined,
        activeIcon: Icons.group_rounded,
      ),
      AppNavBarItem(
        label: 'History',
        icon: Icons.history_outlined,
        activeIcon: Icons.history_rounded,
      ),
      AppNavBarItem(
        label: 'Profile',
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge_rounded,
      ),
    ];

    const tabTitles = [
      'Gate Security Desk',
      'Campus Visitors',
      'Access Audit History',
      'Officer Credential',
    ];

    return Obx(() {
      final tabIndex = controller.currentTabIndex.value;

      return AppScaffold(
        appBar: AppBar(
          title: tabIndex == 0
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 28,
                        height: 28,
                      ),
                      AppSpacing.hGap8,
                      Text(
                        'Uni Secure',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpacing.hGap10,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'SECURITY DESK',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  tabTitles[tabIndex],
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
          actions: [
            IconButton(
              icon: const Icon(
                AppIcons.notification,
                color: AppColors.mainText,
              ),
              tooltip: 'Notifications',
              onPressed: () => Get.to(() => const NotificationView()),
            ),
            IconButton(
              icon: const Icon(AppIcons.logout, color: AppColors.secondaryText),
              tooltip: 'Sign Out',
              onPressed: () async {
                final confirm = await AppBottomSheet.showConfirmation(
                  context: context,
                  title: 'Sign Out of Security Desk?',
                  message:
                      'Are you sure you want to end your shift and return to the login screen?',
                  confirmText: 'Sign Out',
                  cancelText: 'Cancel',
                  isDestructive: true,
                  icon: AppIcons.logout,
                );
                if (confirm == true) {
                  auth.logout();
                }
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: tabIndex,
          children: const [
            GuardGateTab(),
            GuardVisitorsTab(),
            GuardHistoryTab(),
            GuardProfileTab(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: tabIndex,
          onTap: controller.changeTab,
          items: navItems,
        ),
      );
    });
  }
}
