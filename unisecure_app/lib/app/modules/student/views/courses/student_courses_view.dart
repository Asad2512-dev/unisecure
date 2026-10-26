import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/student_models.dart';
import '../../controllers/student_controller.dart';
import 'course_detail_view.dart';

class StudentCoursesView extends GetView<StudentController> {
  const StudentCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: Column(
        children: [
          // Search Field Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppSearchField(
              hint: 'Search by course name, code, or teacher...',
              onChanged: controller.searchCourses,
            ),
          ),

          // Course List
          Expanded(
            child: Obx(() {
              final courses = controller.filteredCourses;

              if (courses.isEmpty) {
                return const AppEmptyState(
                  title: 'No courses found',
                  message:
                      'No enrolled courses match your current search criteria.',
                );
              }

              return ListView.builder(
                padding: AppSpacing.screen,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _CourseItemCard(
                    course: course,
                    onTap: () => Get.to(() => CourseDetailView(course: course)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CourseItemCard extends StatelessWidget {
  final StudentCourse course;
  final VoidCallback onTap;

  const _CourseItemCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = course.attendancePercentage;
    final isSafe = pct >= 75.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
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
                Text(
                  '${course.credits} Credits • ${course.section}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppSpacing.vGap10,
            Text(
              course.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vGap6,
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                AppSpacing.hGap4,
                Text(
                  course.instructorName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            AppSpacing.vGap4,
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                AppSpacing.hGap4,
                Expanded(
                  child: Text(
                    '${course.schedule}  •  ${course.room}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AppSpacing.vGap12,
            const AppDivider(),
            AppSpacing.vGap8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Attendance: ',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSafe ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Details',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.hGap2,
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: AppDimensions.iconSm,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
