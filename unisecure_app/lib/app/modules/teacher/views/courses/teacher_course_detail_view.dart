import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/mock/teacher_mock_data.dart';
import '../../../../data/models/teacher_models.dart';

class TeacherCourseDetailView extends StatelessWidget {
  final TeacherCourse course;

  const TeacherCourseDetailView({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final rosterPreview = TeacherMockData.defaultRoster;

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
                  '${course.section} • Semester ${course.semester} • ${course.enrolledStudentCount} Enrolled Students',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,

          // Class Logistics
          AppSectionHeader(title: 'Class Logistics'),
          AppSpacing.vGap8,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(course.room),
                  subtitle: const Text('Designated Lecture Hall'),
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

          // Syllabus Description
          AppSectionHeader(title: 'Syllabus & Course Objectives'),
          AppSpacing.vGap8,
          AppCard(
            child: Text(
              course.syllabus,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mainText,
                height: 1.6,
              ),
            ),
          ),
          AppSpacing.vGap24,

          // Enrolled Student Roster Preview
          AppSectionHeader(
            title: 'Enrolled Student Roster',
            subtitle:
                '${course.enrolledStudentCount} students registered in this section',
          ),
          AppSpacing.vGap12,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: rosterPreview.map((student) {
                return Column(
                  children: [
                    AppListTile(
                      leading: AppAvatar(
                        name: student.name,
                        size: 36,
                        role: 'student',
                      ),
                      title: Text(student.name),
                      subtitle: Text(
                        '${student.studentIdNumber} • ${student.email}',
                      ),
                    ),
                    if (student != rosterPreview.last) const AppDivider(),
                  ],
                );
              }).toList(),
            ),
          ),
          AppSpacing.vGap24,
        ],
      ),
    );
  }
}
