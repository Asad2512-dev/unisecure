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
import '../roster/teacher_roster_view.dart';

class TeacherSessionsTab extends GetView<TeacherController> {
  const TeacherSessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips Bar (All, Open, Upcoming, Finalized)
        Obx(() {
          final activeFilter = controller.selectedSessionFilter.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Open', 'Upcoming', 'Finalized'].map((
                  filter,
                ) {
                  final isSelected =
                      activeFilter.toLowerCase() == filter.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => controller.filterSessions(filter),
                      selectedColor: AppColors.primarySoft,
                      backgroundColor: AppColors.surfaceSubtle,
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
          );
        }),

        // Sessions List
        Expanded(
          child: Obx(() {
            final sessions = controller.filteredSessions;

            if (sessions.isEmpty) {
              return const AppEmptyState(
                icon: AppIcons.sessions,
                title: 'No sessions found',
                message:
                    'No teaching sessions match the current status filter.',
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.primary,
              child: ListView.builder(
                padding: AppSpacing.screen,
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _SessionCard(
                    session: session,
                    onTap: () =>
                        Get.to(() => TeacherRosterView(session: session)),
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

class _SessionCard extends StatelessWidget {
  final TeacherSession session;
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.onTap});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = session.isOpen;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        borderColor: isOpen
            ? AppColors.warning.withValues(alpha: 0.5)
            : AppColors.border,
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
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        session.courseCode,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppSpacing.hGap8,
                    Text(
                      session.section,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppStatusBadge.fromString(session.status),
              ],
            ),
            AppSpacing.vGap10,
            Text(
              session.courseTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vGap6,
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                AppSpacing.hGap4,
                Text(
                  '${_formatDate(session.sessionDate)}  •  ${session.timeRange}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            AppSpacing.vGap4,
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                AppSpacing.hGap4,
                Text(
                  session.room,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
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
                if (session.isFinalized)
                  Text(
                    'Recorded: ${session.presentCount} Present  •  ${session.lateCount} Late  •  ${session.absentCount} Absent',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    'Class Roster: ${session.totalStudents} Enrolled Students',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      isOpen
                          ? 'Take Attendance'
                          : (session.isFinalized ? 'Review' : 'Open'),
                      style: AppTypography.labelSmall.copyWith(
                        color: isOpen ? AppColors.warning : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.hGap2,
                    Icon(
                      Icons.chevron_right_rounded,
                      size: AppDimensions.iconSm,
                      color: isOpen ? AppColors.warning : AppColors.primary,
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
