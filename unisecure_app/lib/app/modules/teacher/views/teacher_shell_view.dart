import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../../features/notifications/notification_view.dart';
import '../../profile/views/shared_profile_view.dart';
import '../controllers/teacher_controller.dart';
import 'tabs/teacher_courses_tab.dart';
import 'tabs/teacher_home_tab.dart';
import 'tabs/teacher_sessions_tab.dart';
import 'tabs/teacher_timetable_tab.dart';

class TeacherShellView extends StatelessWidget {
  const TeacherShellView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure TeacherController is initialized
    final controller = Get.put(TeacherController());
    final auth = Get.find<AuthController>();

    final tabs = const [
      TeacherHomeTab(),
      TeacherSessionsTab(),
      TeacherTimetableTab(),
      TeacherCoursesTab(),
    ];

    final navItems = const [
      AppNavBarItem(
        icon: AppIcons.home,
        activeIcon: AppIcons.homeActive,
        label: 'Home',
      ),
      AppNavBarItem(
        icon: AppIcons.sessions,
        activeIcon: AppIcons.sessionsActive,
        label: 'Sessions',
      ),
      AppNavBarItem(
        icon: AppIcons.timetable,
        activeIcon: AppIcons.timetableActive,
        label: 'Timetable',
      ),
      AppNavBarItem(
        icon: AppIcons.courses,
        activeIcon: AppIcons.coursesActive,
        label: 'Courses',
      ),
    ];

    return Obx(() {
      final currentIndex = controller.currentTabIndex.value;

      return AppScaffold(
        useSafeArea: true,
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 28, height: 28),
                AppSpacing.hGap8,
                Text(
                  'Uni Secure',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.mainText,
                  ),
                ),
                AppSpacing.hGap8,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teacherAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'FACULTY',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.teacherAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.mainText,
              ),
              tooltip: 'Faculty Profile',
              onPressed: () => Get.to(
                () => const SharedProfileView(overrideRole: 'teacher'),
              ),
            ),
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
              tooltip: 'Sign out',
              onPressed: () async {
                final confirm = await AppBottomSheet.showConfirmation(
                  context: context,
                  title: 'Sign Out',
                  message:
                      'Are you sure you want to sign out of the faculty workspace?',
                  confirmText: 'Sign Out',
                  isDestructive: true,
                  icon: AppIcons.logout,
                );
                if (confirm == true) {
                  await auth.logout();
                }
              },
            ),
          ],
        ),
        body: IndexedStack(index: currentIndex, children: tabs),
        bottomNavigationBar: AppBottomNav(
          currentIndex: currentIndex,
          onTap: controller.changeTab,
          items: navItems,
        ),
      );
    });
  }
}
