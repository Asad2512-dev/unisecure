import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../profile/views/shared_profile_view.dart';
import '../../controllers/teacher_controller.dart';
import '../roster/teacher_roster_view.dart';

class TeacherHomeTab extends GetView<TeacherController> {
  const TeacherHomeTab({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: AppLoading(message: 'Loading teaching workspace...'),
        );
      }

      final p = controller.profile.value;
      final activeAction = controller.activeSessionToMark;
      final nextClass = controller.nextScheduledClass;
      final todaySessions = controller.todaySessions;
      final recentFinalized = controller.recentlyCompletedSessions;

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            // Teacher Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACULTY WORKSPACE',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.teacherAccent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        '${_greeting()}, ${p?.name ?? 'Professor'}',
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
                          color: AppColors.teacherAccent.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          '${p?.designation ?? 'Associate Professor'} • ${p?.officeRoom ?? 'Room 314'}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.teacherAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap12,
                InkWell(
                  onTap: () => Get.to(
                    () => const SharedProfileView(overrideRole: 'teacher'),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: AppAvatar(
                    name: p?.name,
                    size: AppDimensions.avatarMd,
                    role: 'teacher',
                    badgeIcon: AppIcons.check,
                    badgeColor: AppColors.success,
                  ),
                ),
              ],
            ),
            AppSpacing.vGap24,

            // ATTENDANCE ACTION REQUIRED BANNER
            if (activeAction != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.35),
                    width: AppDimensions.strokeWidthThick,
                  ),
                ),
                padding: const EdgeInsets.all(18),
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
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  color: AppColors.warning,
                                  size: AppDimensions.iconSm,
                                ),
                              ),
                              AppSpacing.hGap8,
                              Flexible(
                                child: Text(
                                  'ATTENDANCE REQUIRED',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hGap8,
                        const AppStatusBadge(
                          label: 'ACTIVE',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    AppSpacing.vGap12,
                    Text(
                      '${activeAction.courseCode} • ${activeAction.courseTitle}',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      '${activeAction.section}  •  ${activeAction.room}  •  Today (${activeAction.timeRange})',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    AppSpacing.vGap16,
                    AppButton.primary(
                      text: 'Take Class Attendance',
                      icon: AppIcons.attendance,
                      onPressed: () => Get.to(
                        () => TeacherRosterView(session: activeAction),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vGap24,
            ],

            // Next Scheduled Class Card
            if (nextClass != null) ...[
              AppSectionHeader(title: 'Next Scheduled Class'),
              AppSpacing.vGap10,
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          nextClass.startTime,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.hGap14,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextClass.courseTitle,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.vGap4,
                          Text(
                            '${nextClass.courseCode} (${nextClass.section}) • ${nextClass.room}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hGap8,
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () =>
                          Get.to(() => TeacherRosterView(session: nextClass)),
                      tooltip: 'View class roster',
                    ),
                  ],
                ),
              ),
              AppSpacing.vGap24,
            ],

            // Teaching Sessions Scheduled Today
            AppSectionHeader(
              title: 'Today\'s Sessions',
              subtitle:
                  '${todaySessions.length} sessions on today\'s teaching calendar',
              actionLabel: 'All Sessions',
              onAction: () => controller.changeTab(1),
            ),
            AppSpacing.vGap12,
            if (todaySessions.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      'No teaching sessions scheduled for today.',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                ),
              )
            else
              ...todaySessions.map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    session.courseCode,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AppSpacing.hGap8,
                                  Text(
                                    '(${session.section})',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vGap4,
                              Text(
                                session.courseTitle,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppSpacing.vGap4,
                              Text(
                                '${session.timeRange}  •  ${session.room}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hGap12,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppStatusBadge.fromString(session.status),
                            AppSpacing.vGap6,
                            TextButton(
                              onPressed: () => Get.to(
                                () => TeacherRosterView(session: session),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(48, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                session.isOpen
                                    ? 'Take Mark'
                                    : (session.isFinalized ? 'Review' : 'Open'),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            AppSpacing.vGap24,

            // Recently Finalized Sessions
            if (recentFinalized.isNotEmpty) ...[
              AppSectionHeader(
                title: 'Recently Finalized Attendance',
                subtitle: 'Attendance locked and recorded in database',
              ),
              AppSpacing.vGap12,
              ...recentFinalized.take(2).map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () =>
                        Get.to(() => TeacherRosterView(session: session)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.courseTitle,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppSpacing.vGap4,
                              Text(
                                '${session.courseCode} (${session.section}) • ${session.timeRange}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hGap12,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppStatusBadge(
                              label: 'FINALIZED',
                              color: AppColors.success,
                            ),
                            AppSpacing.vGap4,
                            Text(
                              '${session.presentCount}P / ${session.lateCount}L / ${session.absentCount}A',
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
              }),
            ],
            AppSpacing.vGap16,
          ],
        ),
      );
    });
  }
}
