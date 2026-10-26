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

class TeacherTimetableTab extends GetView<TeacherController> {
  const TeacherTimetableTab({super.key});

  static const _days = [
    {'name': 'Monday', 'short': 'Mon', 'day': 1},
    {'name': 'Tuesday', 'short': 'Tue', 'day': 2},
    {'name': 'Wednesday', 'short': 'Wed', 'day': 3},
    {'name': 'Thursday', 'short': 'Thu', 'day': 4},
    {'name': 'Friday', 'short': 'Fri', 'day': 5},
    {'name': 'Saturday', 'short': 'Sat', 'day': 6},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDay = controller.selectedDayOfWeek.value;
      final slots = controller.slotsForSelectedDay;

      return Column(
        children: [
          // Day selector bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimensions.strokeWidth,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _days.map((d) {
                  final dayNum = d['day'] as int;
                  final isSelected = dayNum == selectedDay;
                  final isToday = DateTime.now().weekday == dayNum;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => controller.selectDay(dayNum),
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isToday
                                    ? AppColors.primarySoft
                                    : AppColors.surfaceSubtle),
                          borderRadius: BorderRadius.circular(AppRadius.button),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isToday
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : AppColors.border),
                            width: AppDimensions.strokeWidth,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              d['short'] as String,
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isToday
                                          ? AppColors.primary
                                          : AppColors.secondaryText),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppSpacing.vGap2,
                            Text(
                              isToday ? 'Today' : 'Day $dayNum',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Timetable content
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.primary,
              child: slots.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: AppEmptyState(
                            icon: AppIcons.timetable,
                            title: 'No classes scheduled',
                            message:
                                'No teaching lectures or labs are assigned on this day.',
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: AppSpacing.screen,
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        return _TeacherTimetableSlotCard(slot: slot);
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class _TeacherTimetableSlotCard extends StatelessWidget {
  final TeacherTimetableSlot slot;

  const _TeacherTimetableSlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    AppSpacing.hGap6,
                    Text(
                      slot.timeRange,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    slot.type.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vGap12,
            Text(
              slot.courseTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.mainText,
              ),
            ),
            AppSpacing.vGap6,
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    slot.courseCode,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainText,
                    ),
                  ),
                ),
                AppSpacing.hGap8,
                Text(
                  'Section ${slot.section}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppSpacing.vGap12,
            const AppDivider(),
            AppSpacing.vGap8,
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: AppColors.secondaryText,
                ),
                AppSpacing.hGap6,
                Text(
                  slot.room,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
