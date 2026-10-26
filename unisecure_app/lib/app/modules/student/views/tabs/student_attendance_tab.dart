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

class StudentAttendanceTab extends GetView<StudentController> {
  const StudentAttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final overall = controller.overallAttendanceRate;
      final present = controller.totalPresentCount;
      final late = controller.totalLateCount;
      final absent = controller.totalAbsentCount;
      final total = controller.totalLecturesCount;
      final courses = controller.courses;
      final records = controller.filteredAttendanceRecords;

      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Top tab selector: Summary / Course-wise vs. Session Logs
            Container(
              color: AppColors.surface,
              child: TabBar(
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.secondaryText,
                labelStyle: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: AppTypography.labelMedium,
                tabs: const [
                  Tab(text: 'Course Summary'),
                  Tab(text: 'Session History'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Course-wise summary
                  RefreshIndicator(
                    onRefresh: controller.refreshData,
                    color: AppColors.primary,
                    child: ListView(
                      padding: AppSpacing.screen,
                      children: [
                        // Overall Attendance Hero Card
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Semester Attendance',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AppStatusBadge(
                                    label: overall >= 75.0
                                        ? 'ELIGIBLE FOR EXAMS'
                                        : 'SHORT ATTENDANCE',
                                    color: overall >= 75.0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ],
                              ),
                              AppSpacing.vGap16,
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${overall.toStringAsFixed(1)}%',
                                          style: AppTypography.displayMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: overall >= 75.0
                                                    ? AppColors.success
                                                    : AppColors.error,
                                              ),
                                        ),
                                        AppSpacing.vGap4,
                                        Text(
                                          '$present of $total sessions attended',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _MetricPill(
                                          label: 'Present',
                                          value: '$present',
                                          color: AppColors.success,
                                        ),
                                        _MetricPill(
                                          label: 'Late',
                                          value: '$late',
                                          color: AppColors.warning,
                                        ),
                                        _MetricPill(
                                          label: 'Absent',
                                          value: '$absent',
                                          color: AppColors.error,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vGap16,
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                child: LinearProgressIndicator(
                                  value: (overall / 100.0).clamp(0.0, 1.0),
                                  minHeight: 10,
                                  backgroundColor: AppColors.borderLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    overall >= 75.0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                              AppSpacing.vGap12,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Minimum requirement: 75%',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    overall >= 75.0
                                        ? 'Safety margin: +${(overall - 75.0).toStringAsFixed(1)}%'
                                        : 'Deficit: -${(75.0 - overall).toStringAsFixed(1)}%',
                                    style: AppTypography.caption.copyWith(
                                      color: overall >= 75.0
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.vGap24,

                        // Course Breakdown Section
                        AppSectionHeader(
                          title: 'Course-wise Attendance',
                          subtitle:
                              'Attendance percentage across enrolled modules',
                        ),
                        AppSpacing.vGap12,

                        ...courses.map((course) {
                          final pct = course.attendancePercentage;
                          final isSafe = pct >= 75.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              course.code,
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            AppSpacing.vGap2,
                                            Text(
                                              course.title,
                                              style: AppTypography.titleSmall
                                                  .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSpacing.hGap12,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${pct.toStringAsFixed(1)}%',
                                            style: AppTypography.titleMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: isSafe
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                ),
                                          ),
                                          Text(
                                            '${course.attendedClasses}/${course.totalClasses}',
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  AppSpacing.vGap12,
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                    child: LinearProgressIndicator(
                                      value: (pct / 100.0).clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: AppColors.borderLight,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isSafe
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ),
                                  AppSpacing.vGap10,
                                  Row(
                                    children: [
                                      Text(
                                        '${course.instructorName}  •  ${course.section}',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (!isSafe)
                                        Text(
                                          'Low attendance warning',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Tab 2: Session logs with status filter chips
                  Column(
                    children: [
                      // Filter chips bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: AppColors.surfaceSubtle,
                        child: Row(
                          children: ['All', 'Present', 'Late', 'Absent'].map((
                            filter,
                          ) {
                            final isSelected =
                                controller.selectedAttendanceFilter.value ==
                                filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (_) =>
                                    controller.filterAttendance(filter),
                                selectedColor: AppColors.primarySoft,
                                backgroundColor: AppColors.surface,
                                labelStyle: AppTypography.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondaryText,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: AppDimensions.strokeWidth,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Records list
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.refreshData,
                          color: AppColors.primary,
                          child: records.isEmpty
                              ? const AppEmptyState(
                                  title: 'No attendance records',
                                  message:
                                      'No records matching the selected status filter were found.',
                                )
                              : ListView.builder(
                                  padding: AppSpacing.screen,
                                  itemCount: records.length,
                                  itemBuilder: (context, index) {
                                    final record = records[index];
                                    return _AttendanceHistoryCard(
                                      record: record,
                                      onTap: () =>
                                          _showSessionDetails(context, record),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showSessionDetails(BuildContext context, AttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.sheet,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session Attendance Detail',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppStatusBadge.fromString(record.status),
                ],
              ),
              AppSpacing.vGap16,
              _DetailRow(
                label: 'Course',
                value: '${record.courseCode} - ${record.courseTitle}',
              ),
              _DetailRow(
                label: 'Date',
                value:
                    '${record.sessionDate.year}-${record.sessionDate.month.toString().padLeft(2, '0')}-${record.sessionDate.day.toString().padLeft(2, '0')}',
              ),
              _DetailRow(label: 'Time', value: record.sessionTime),
              _DetailRow(label: 'Lecture Hall', value: record.room),
              _DetailRow(label: 'Instructor', value: record.teacher),
              if (record.remarks != null)
                _DetailRow(label: 'Verification Note', value: record.remarks!),
              AppSpacing.vGap20,
              AppButton.primary(
                text: 'Dismiss',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
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
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  final VoidCallback onTap;

  const _AttendanceHistoryCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${record.sessionDate.year}-${record.sessionDate.month.toString().padLeft(2, '0')}-${record.sessionDate.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.courseTitle,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGap4,
                  Text(
                    '${record.courseCode}  •  $dateStr (${record.sessionTime})',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hGap12,
            AppStatusBadge.fromString(record.status),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mainText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
