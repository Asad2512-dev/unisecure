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
import '../../controllers/teacher_roster_controller.dart';

class TeacherRosterView extends StatelessWidget {
  final TeacherSession session;

  const TeacherRosterView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // Unique tag based on session id to prevent controller collision
    final tag = 'roster_${session.id}';
    final controller = Get.put(
      TeacherRosterController(initialSession: session),
      tag: tag,
    );

    return PopScope(
      canPop: !controller.hasUnsavedChanges.value,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await AppBottomSheet.showConfirmation(
          context: context,
          title: 'Discard Unsaved Attendance?',
          message:
              'You have unsaved attendance mark changes. Navigating back without saving will discard your edits.',
          confirmText: 'Discard Changes',
          cancelText: 'Stay on Roster',
          isDestructive: true,
          icon: AppIcons.warning,
        );
        if (shouldLeave == true) {
          Get.back();
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${session.courseCode} Attendance Roster',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${session.section} • ${session.room} • ${session.timeRange}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          actions: [
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: AppStatusBadge.fromString(
                    controller.session.value.status,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: AppLoading(message: 'Loading class roster...'),
            );
          }

          final students = controller.filteredRoster;
          final isFinalized = controller.session.value.isFinalized;

          return Column(
            children: [
              // Live Status Counts Summary Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: AppColors.surface,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CounterBadge(
                        label: 'Present',
                        count: controller.presentCount,
                        color: AppColors.success,
                      ),
                      AppSpacing.hGap8,
                      _CounterBadge(
                        label: 'Late',
                        count: controller.lateCount,
                        color: AppColors.warning,
                      ),
                      AppSpacing.hGap8,
                      _CounterBadge(
                        label: 'Absent',
                        count: controller.absentCount,
                        color: AppColors.error,
                      ),
                      AppSpacing.hGap8,
                      _CounterBadge(
                        label: 'Unmarked',
                        count: controller.unmarkedCount,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
              const AppDivider(),

              // Search & Bulk Actions Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hint: 'Search student name or ID...',
                        onChanged: controller.searchRoster,
                      ),
                    ),
                    if (!isFinalized) ...[
                      AppSpacing.hGap8,
                      PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(
                              AppRadius.field,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.more_vert_rounded,
                            size: 20,
                            color: AppColors.mainText,
                          ),
                        ),
                        onSelected: (action) {
                          if (action == 'all_present') {
                            controller.markRemainingPresent();
                          } else if (action == 'clear') {
                            controller.clearAllMarks();
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'all_present',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text('Mark Remaining as Present'),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(width: 8),
                                Flexible(child: Text('Reset All Marks')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Unsaved Changes Banner
              if (controller.hasUnsavedChanges.value)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      AppSpacing.hGap6,
                      Text(
                        'Unsaved roster changes (draft mode)',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Student Roster List
              Expanded(
                child: students.isEmpty
                    ? const AppEmptyState(
                        title: 'No students found',
                        message:
                            'No student matching your search query was found in this session.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return _StudentRosterRow(
                            student: student,
                            isFinalized: isFinalized,
                            onStatusChanged: (status) => controller
                                .updateStudentStatus(student.id, status),
                          );
                        },
                      ),
              ),

              // Persistent Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border,
                      width: AppDimensions.strokeWidth,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      if (!isFinalized) ...[
                        Expanded(
                          flex: 4,
                          child: AppButton.outlined(
                            text: 'Save Draft',
                            isLoading: controller.isSubmitting.value,
                            onPressed: controller.hasUnsavedChanges.value
                                ? controller.saveDraft
                                : null,
                          ),
                        ),
                        AppSpacing.hGap12,
                        Expanded(
                          flex: 6,
                          child: AppButton.primary(
                            text: 'Review & Finalize',
                            isLoading: controller.isSubmitting.value,
                            icon: AppIcons.check,
                            onPressed: () =>
                                controller.finalizeAttendance(context),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: AppButton.secondary(
                            text: 'Attendance Locked • View Mode',
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CounterBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          AppSpacing.hGap6,
          Text(
            '$count $label',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRosterRow extends StatelessWidget {
  final RosterStudent student;
  final bool isFinalized;
  final ValueChanged<String> onStatusChanged;

  const _StudentRosterRow({
    required this.student,
    required this.isFinalized,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: student.isUnmarked
                ? AppColors.border
                : (student.isPresent
                      ? AppColors.success.withValues(alpha: 0.4)
                      : (student.isLate
                            ? AppColors.warning.withValues(alpha: 0.4)
                            : AppColors.error.withValues(alpha: 0.4))),
            width: AppDimensions.strokeWidth,
          ),
        ),
        child: Row(
          children: [
            AppAvatar(name: student.name, size: 38, role: 'student'),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGap2,
                  Text(
                    student.studentIdNumber,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hGap8,

            // Compact Segmented Status Selector (P / L / A)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusButton(
                  label: 'P',
                  tooltip: 'Present',
                  isActive: student.isPresent,
                  activeColor: AppColors.success,
                  onTap: isFinalized ? null : () => onStatusChanged('present'),
                ),
                AppSpacing.hGap4,
                _StatusButton(
                  label: 'L',
                  tooltip: 'Late',
                  isActive: student.isLate,
                  activeColor: AppColors.warning,
                  onTap: isFinalized ? null : () => onStatusChanged('late'),
                ),
                AppSpacing.hGap4,
                _StatusButton(
                  label: 'A',
                  tooltip: 'Absent',
                  isActive: student.isAbsent,
                  activeColor: AppColors.error,
                  onTap: isFinalized ? null : () => onStatusChanged('absent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.label,
    required this.tooltip,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? activeColor : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isActive ? activeColor : AppColors.border,
              width: AppDimensions.strokeWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.secondaryText,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
