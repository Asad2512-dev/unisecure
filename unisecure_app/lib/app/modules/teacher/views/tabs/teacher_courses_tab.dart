import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/teacher_models.dart';
import '../../controllers/teacher_controller.dart';
import '../courses/teacher_course_detail_view.dart';

class TeacherCoursesTab extends GetView<TeacherController> {
  const TeacherCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: AppSearchField(
            hint: 'Search assigned courses or sections...',
            onChanged: controller.searchCourses,
          ),
        ),

        // Courses list
        Expanded(
          child: Obx(() {
            final courses = controller.filteredCourses;

            if (courses.isEmpty) {
              return const AppEmptyState(
                icon: AppIcons.courses,
                title: 'No courses found',
                message: 'No assigned courses match your search query.',
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.primary,
              child: ListView.builder(
                padding: AppSpacing.screen,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _TeacherCourseCard(
                    course: course,
                    onTap: () =>
                        Get.to(() => TeacherCourseDetailView(course: course)),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TeacherCourseCard extends StatelessWidget {
  final TeacherCourse course;
  final VoidCallback onTap;

  const _TeacherCourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                Row(
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
                    AppSpacing.hGap8,
                    Text(
                      '${course.section}  •  Sem ${course.semester}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppStatusBadge(
                  label: '${course.credits} CREDITS',
                  color: AppColors.primary,
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
            AppSpacing.vGap8,
            Row(
              children: [
                const Icon(
                  Icons.people_outline_rounded,
                  size: 15,
                  color: AppColors.secondaryText,
                ),
                AppSpacing.hGap4,
                Text(
                  '${course.enrolledStudentCount} Enrolled Students',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
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
                Text(
                  'View syllabus & student roster',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Course Roster',
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
