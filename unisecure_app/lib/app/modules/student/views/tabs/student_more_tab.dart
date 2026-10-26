import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/auth/auth_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../../features/notifications/notification_view.dart';
import '../../controllers/student_controller.dart';
import '../courses/student_courses_view.dart';
import '../profile/student_profile_view.dart';
import '../security/student_campus_history_view.dart';

class StudentMoreTab extends GetView<StudentController> {
  const StudentMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final p = controller.profile.value;

      return ListView(
        padding: AppSpacing.screen,
        children: [
          // Student Profile Summary Card
          InkWell(
            onTap: () => Get.to(() => const StudentProfileView()),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: AppCard(
              child: Row(
                children: [
                  AppAvatar(
                    name: p?.name,
                    size: AppDimensions.avatarLg,
                    role: 'student',
                    badgeIcon: AppIcons.check,
                    badgeColor: AppColors.success,
                  ),
                  AppSpacing.hGap16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p?.name ?? 'Student',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGap4,
                        Text(
                          'ID: ${p?.studentIdNumber ?? 'BSIT-MC-0001'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                            fontFamily: 'monospace',
                          ),
                        ),
                        AppSpacing.vGap4,
                        Text(
                          p?.program ?? 'BS Information Technology',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryText,
                    size: AppDimensions.iconSm,
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vGap24,

          // Academic Information Group
          AppSectionHeader(title: 'Academic Services'),
          AppSpacing.vGap8,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListTile(
                  leading: _IconContainer(
                    icon: AppIcons.courses,
                    color: AppColors.primary,
                  ),
                  title: const Text('My Enrolled Courses'),
                  subtitle: Text(
                    '${controller.courses.length} courses this semester',
                  ),
                  onTap: () => Get.to(() => const StudentCoursesView()),
                ),
                const AppDivider(),
                AppListTile(
                  leading: _IconContainer(
                    icon: AppIcons.timetable,
                    color: AppColors.primaryDark,
                  ),
                  title: const Text('Weekly Timetable'),
                  subtitle: const Text('View and export class schedule'),
                  onTap: () => controller.changeTab(1),
                ),
                const AppDivider(),
                AppListTile(
                  leading: _IconContainer(
                    icon: AppIcons.attendance,
                    color: AppColors.success,
                  ),
                  title: const Text('Attendance Records'),
                  subtitle: Text(
                    '${controller.overallAttendanceRate.toStringAsFixed(1)}% current semester record',
                  ),
                  onTap: () => controller.changeTab(2),
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // Campus Security & Transactions
          AppSectionHeader(title: 'Security & Campus'),
          AppSpacing.vGap8,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListTile(
                  leading: _IconContainer(
                    icon: AppIcons.gate,
                    color: AppColors.guardAccent,
                  ),
                  title: const Text('Campus Access Log'),
                  subtitle: const Text(
                    'Gate entries, exits & verification history',
                  ),
                  onTap: () => Get.to(() => const StudentCampusHistoryView()),
                ),
                const AppDivider(),
                AppListTile(
                  leading: _IconContainer(
                    icon: AppIcons.notification,
                    color: AppColors.info,
                  ),
                  title: const Text('Notifications & Alerts'),
                  subtitle: const Text('Security notices and academic updates'),
                  onTap: () => Get.to(() => const NotificationView()),
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // Account & Session
          AppSectionHeader(title: 'Account Session'),
          AppSpacing.vGap8,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListTile(
                  leading: _IconContainer(
                    icon: AppIcons.profile,
                    color: AppColors.secondaryText,
                  ),
                  title: const Text('Student Identity Card'),
                  subtitle: const Text('Digital student credential'),
                  onTap: () => Get.to(() => const StudentProfileView()),
                ),
                const AppDivider(),
                AppListTile(
                  leading: _IconContainer(
                    icon: AppIcons.logout,
                    color: AppColors.error,
                  ),
                  title: const Text('Sign Out'),
                  subtitle: const Text('End active mobile session'),
                  isDestructive: true,
                  onTap: () async {
                    final shouldLogout = await AppBottomSheet.showConfirmation(
                      context: context,
                      title: 'Sign Out',
                      message:
                          'Are you sure you want to sign out of the Uni Secure mobile portal?',
                      confirmText: 'Sign Out',
                      isDestructive: true,
                      icon: AppIcons.logout,
                    );
                    if (shouldLogout == true) {
                      await auth.logout();
                    }
                  },
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // Prototype disclaimer
          Center(
            child: Text(
              'Uni Secure • Student Mobile Workspace v1.0\nNUML Campus Attendance & Security System',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ),
          AppSpacing.vGap16,
        ],
      );
    });
  }
}

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconContainer({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: color, size: AppDimensions.iconSm),
    );
  }
}
