import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/student_controller.dart';
import '../courses/student_courses_view.dart';
import '../security/student_campus_history_view.dart';

class StudentHomeTab extends GetView<StudentController> {
  const StudentHomeTab({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: AppLoading(message: 'Loading academic dashboard...'),
        );
      }

      final p = controller.profile.value;
      final next = controller.nextClass;
      final todayClasses = controller.todayClasses;

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            // Greeting & Date Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formattedDate(),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        '${_greeting()}, ${p?.name.split(' ').first ?? 'Student'}',
                        style: AppTypography.headlineLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.mainText,
                          letterSpacing: -0.4,
                        ),
                      ),
                      AppSpacing.vGap6,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          '${p?.program ?? 'B.Sc. Computer Science'} • Sem ${p?.semester ?? 6} (${p?.section ?? 'A'})',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap12,
                AppAvatar(
                  name: p?.name,
                  size: AppDimensions.avatarMd,
                  role: 'student',
                  badgeIcon: AppIcons.check,
                  badgeColor: AppColors.success,
                ),
              ],
            ),
            AppSpacing.vGap24,

            // Next Class Highlight Card
            if (next != null) ...[
              AppCard(
                borderColor: AppColors.primary.withValues(alpha: 0.25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.xs,
                                  ),
                                ),
                                child: Text(
                                  'NEXT UP',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              AppSpacing.hGap8,
                              Expanded(
                                child: Text(
                                  next.timeRange,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mainText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hGap8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(
                              color: AppColors.border,
                              width: AppDimensions.strokeWidth,
                            ),
                          ),
                          child: Text(
                            next.room,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.mainText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap12,
                    Text(
                      next.courseTitle,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.vGap4,
                    Row(
                      children: [
                        Text(
                          next.courseCode,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.hGap8,
                        Expanded(
                          child: Text(
                            '•  ${next.instructor}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.vGap20,
            ],

            // Attendance Overview Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Attendance',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                            AppSpacing.vGap4,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${controller.overallAttendanceRate.toStringAsFixed(1)}%',
                                  style: AppTypography.displaySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        controller.overallAttendanceRate >= 75.0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                                AppSpacing.hGap8,
                                Flexible(
                                  child: Text(
                                    controller.overallAttendanceRate >= 75.0
                                        ? 'Above threshold (75%)'
                                        : 'Attention required',
                                    style: AppTypography.caption.copyWith(
                                      color:
                                          controller.overallAttendanceRate >=
                                              75.0
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.changeTab(2),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          size: AppDimensions.iconSm,
                          color: AppColors.primary,
                        ),
                        tooltip: 'View attendance history',
                      ),
                    ],
                  ),
                  AppSpacing.vGap12,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: (controller.overallAttendanceRate / 100.0).clamp(
                        0.0,
                        1.0,
                      ),
                      minHeight: 8,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        controller.overallAttendanceRate >= 75.0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                  AppSpacing.vGap16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Present',
                          value: '${controller.totalPresentCount}',
                          color: AppColors.success,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Late',
                          value: '${controller.totalLateCount}',
                          color: AppColors.warning,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Absent',
                          value: '${controller.totalAbsentCount}',
                          color: AppColors.error,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Total',
                          value: '${controller.totalLecturesCount}',
                          color: AppColors.mainText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.vGap20,

            // Quick Actions
            AppSectionHeader(title: 'Quick Actions'),
            AppSpacing.vGap12,
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: AppIcons.timetable,
                    label: 'Timetable',
                    onTap: () => controller.changeTab(1),
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: _QuickActionButton(
                    icon: AppIcons.attendance,
                    label: 'Attendance',
                    onTap: () => controller.changeTab(2),
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: _QuickActionButton(
                    icon: AppIcons.courses,
                    label: 'Courses',
                    onTap: () => Get.to(() => const StudentCoursesView()),
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: _QuickActionButton(
                    icon: AppIcons.gate,
                    label: 'Gate Pass',
                    onTap: () => Get.to(() => const StudentCampusHistoryView()),
                  ),
                ),
              ],
            ),
            AppSpacing.vGap24,

            // Today's Upcoming Classes
            AppSectionHeader(
              title: 'Today\'s Classes',
              actionLabel: 'Full Schedule',
              onAction: () => controller.changeTab(1),
            ),
            AppSpacing.vGap12,
            if (todayClasses.isEmpty)
              const AppCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No classes scheduled for today.',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                ),
              )
            else
              ...todayClasses.map(
                (slot) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: slot.isNext
                                ? AppColors.primarySoft
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Center(
                            child: Icon(
                              slot.type == 'Laboratory'
                                  ? Icons.science_outlined
                                  : Icons.school_outlined,
                              color: slot.isNext
                                  ? AppColors.primary
                                  : AppColors.secondaryText,
                              size: AppDimensions.iconSm,
                            ),
                          ),
                        ),
                        AppSpacing.hGap14,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.courseTitle,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpacing.vGap4,
                              Text(
                                '${slot.courseCode}  •  ${slot.room}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              slot.startTime,
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.mainText,
                              ),
                            ),
                            AppSpacing.vGap4,
                            Text(
                              slot.type,
                              style: AppTypography.caption.copyWith(
                                fontSize: 10,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            AppSpacing.vGap20,

            // Campus Alerts & Announcements
            if (controller.alerts.isNotEmpty) ...[
              AppSectionHeader(title: 'Campus Advisories'),
              AppSpacing.vGap12,
              ...controller.alerts
                  .take(2)
                  .map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppInfoCard(
                        icon: alert.priority == 'high'
                            ? AppIcons.warning
                            : AppIcons.info,
                        accentColor: alert.priority == 'high'
                            ? AppColors.warning
                            : AppColors.info,
                        title: alert.title,
                        description: alert.message,
                      ),
                    ),
                  ),
            ],
            AppSpacing.vGap16,
          ],
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        AppSpacing.vGap2,
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.border,
            width: AppDimensions.strokeWidth,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppDimensions.iconSm,
              ),
            ),
            AppSpacing.vGap8,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mainText,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
