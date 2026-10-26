import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/student_models.dart';

class CourseDetailView extends StatelessWidget {
  final StudentCourse course;

  const CourseDetailView({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final pct = course.attendancePercentage;
    final isSafe = pct >= 75.0;

    return AppScaffold(
      appBar: AppBar(title: Text(course.code)),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // Header Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        course.code,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppStatusBadge(
                      label: '${course.credits} CREDITS',
                      color: AppColors.primary,
                    ),
                  ],
                ),
                AppSpacing.vGap12,
                Text(
                  course.title,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap8,
                Text(
                  'Section: ${course.section}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,

          // Attendance Status in this course
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Course Attendance',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSafe ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap10,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: (pct / 100.0).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSafe ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                AppSpacing.vGap12,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(
                      label: 'Attended',
                      value: '${course.attendedClasses}',
                      color: AppColors.success,
                    ),
                    _StatBadge(
                      label: 'Late',
                      value: '${course.lateClasses}',
                      color: AppColors.warning,
                    ),
                    _StatBadge(
                      label: 'Absent',
                      value: '${course.absentClasses}',
                      color: AppColors.error,
                    ),
                    _StatBadge(
                      label: 'Total Sessions',
                      value: '${course.totalClasses}',
                      color: AppColors.mainText,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,

          // Instructor & Classroom Info
          AppSectionHeader(title: 'Instructor & Schedule'),
          AppSpacing.vGap8,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(course.instructorName),
                  subtitle: Text(course.instructorEmail),
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(course.room),
                  subtitle: const Text('Campus Academic Complex'),
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(course.schedule),
                  subtitle: const Text('Recurring weekly timetable slot'),
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,

          // Course Syllabus Overview
          AppSectionHeader(title: 'Syllabus Description'),
          AppSpacing.vGap8,
          AppCard(
            child: Text(
              course.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mainText,
                height: 1.6,
              ),
            ),
          ),
          AppSpacing.vGap24,
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
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
          style: AppTypography.titleMedium.copyWith(
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
