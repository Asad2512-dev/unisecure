import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/guard_models.dart';
import '../../controllers/guard_controller.dart';
import '../verification/guard_face_scan_view.dart';
import '../verification/guard_manual_verification_view.dart';
import '../visitors/guard_register_visitor_view.dart';

/// Primary Gate Desk operational dashboard.
class GuardGateTab extends GetView<GuardController> {
  const GuardGateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppLoading(message: 'Connecting to gate security desk...');
      }

      final profile = controller.profile.value;
      final summary = controller.deskSummary.value;
      final recent = controller.recentTransactions;

      return RefreshIndicator(
        onRefresh: controller.refreshDesk,
        color: AppColors.primary,
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            // GATE DESK OPERATIONAL HEADER
            AppCard(
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
                              decoration: const BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.security_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            AppSpacing.hGap8,
                            Expanded(
                              child: Text(
                                summary?.assignedGate ?? 'Main Gate 1',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
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
                      const AppStatusBadge(
                        label: 'ON DUTY',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  AppSpacing.vGap12,
                  Row(
                    children: [
                      AppAvatar(name: profile?.name, size: 40, role: 'guard'),
                      AppSpacing.hGap12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.name ?? 'Security Officer',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            AppSpacing.vGap2,
                            Text(
                              '${profile?.guardIdNumber} • ${profile?.shift}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.vGap16,

            // RAPID VERIFICATION ACTIONS
            AppSectionHeader(
              title: 'Verification Actions',
              subtitle: 'Select campus access verification method',
            ),
            AppSpacing.vGap10,

            // Primary: Face Verification Preview
            AppCard(
              onTap: () => Get.to(() => const GuardFaceScanView()),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                      size: AppDimensions.iconLg,
                    ),
                  ),
                  AppSpacing.hGap14,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Face Verification Preview',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            AppSpacing.hGap8,
                            const AppStatusBadge(
                              label: 'PREVIEW',
                              color: AppColors.info,
                            ),
                          ],
                        ),
                        AppSpacing.vGap4,
                        Text(
                          'Simulated camera viewfinder with biometric match demonstration.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hGap8,
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            AppSpacing.vGap10,

            // Secondary: Manual Student Lookup
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    onTap: () =>
                        Get.to(() => const GuardManualVerificationView()),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        AppSpacing.vGap10,
                        Text(
                          'Manual Student Audit',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.vGap4,
                        Text(
                          'Search student by name or ID & record entry/exit.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.hGap10,
                Expanded(
                  child: AppCard(
                    onTap: () => Get.to(() => const GuardRegisterVisitorView()),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        AppSpacing.vGap10,
                        Text(
                          'Register Visitor',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.vGap4,
                        Text(
                          'Issue visitor badge with vehicle & host check.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vGap24,

            // LIVE METRICS ROW
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    label: "Today's Entries",
                    value: '${summary?.todayEntryCount ?? 0}',
                    icon: Icons.login_rounded,
                    color: AppColors.success,
                  ),
                ),
                AppSpacing.hGap10,
                Expanded(
                  child: AppStatCard(
                    label: "Today's Exits",
                    value: '${summary?.todayExitCount ?? 0}',
                    icon: Icons.logout_rounded,
                    color: AppColors.info,
                  ),
                ),
                AppSpacing.hGap10,
                Expanded(
                  child: AppStatCard(
                    label: 'Active Visitors',
                    value: '${summary?.activeVisitorsCount ?? 0}',
                    icon: Icons.group_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            AppSpacing.vGap24,

            // RECENT GATE ACTIVITY FEED
            AppSectionHeader(
              title: 'Recent Gate Activity',
              subtitle: 'Live campus perimeter entry & exit transactions',
              actionLabel: 'View All History',
              onAction: () => controller.changeTab(2),
            ),
            AppSpacing.vGap10,

            if (recent.isEmpty)
              const AppEmptyState(
                icon: Icons.access_time_rounded,
                title: 'No Recent Activity',
                message: 'No transactions recorded at this gate desk today.',
              )
            else
              ...recent.map((tx) {
                return _GateActivityRow(transaction: tx);
              }),
          ],
        ),
      );
    });
  }
}

class _GateActivityRow extends StatelessWidget {
  final GateTransaction transaction;

  const _GateActivityRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Direction icon badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: transaction.isEntry
                    ? AppColors.successSoft
                    : AppColors.infoSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction.isEntry
                    ? Icons.login_rounded
                    : Icons.logout_rounded,
                color: transaction.isEntry ? AppColors.success : AppColors.info,
                size: 18,
              ),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.subjectName,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.hGap6,
                      Text(
                        '(${transaction.subjectIdentifier})',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap2,
                  Text(
                    '${transaction.gate} • ${transaction.methodDisplayName}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hGap8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppStatusBadge(
                  label: transaction.eventType.toUpperCase(),
                  color: transaction.isEntry
                      ? AppColors.success
                      : AppColors.info,
                ),
                AppSpacing.vGap4,
                Text(
                  transaction.timeFormatted,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
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
