import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../../features/notifications/notification_view.dart';
import '../controllers/student_controller.dart';
import 'tabs/student_attendance_tab.dart';
import 'tabs/student_home_tab.dart';
import 'tabs/student_more_tab.dart';
import 'tabs/student_timetable_tab.dart';

class StudentShellView extends StatelessWidget {
  const StudentShellView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure StudentController is registered
    final controller = Get.put(StudentController());

    final tabs = const [
      StudentHomeTab(),
      StudentTimetableTab(),
      StudentAttendanceTab(),
      StudentMoreTab(),
    ];

    final navItems = const [
      AppNavBarItem(
        icon: AppIcons.home,
        activeIcon: AppIcons.homeActive,
        label: 'Home',
      ),
      AppNavBarItem(
        icon: AppIcons.timetable,
        activeIcon: AppIcons.timetableActive,
        label: 'Timetable',
      ),
      AppNavBarItem(
        icon: AppIcons.attendance,
        activeIcon: AppIcons.attendanceActive,
        label: 'Attendance',
      ),
      AppNavBarItem(
        icon: AppIcons.more,
        activeIcon: AppIcons.moreActive,
        label: 'More',
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
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'STUDENT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryDark,
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
                AppIcons.notification,
                color: AppColors.mainText,
              ),
              tooltip: 'Notifications',
              onPressed: () => Get.to(() => const NotificationView()),
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
