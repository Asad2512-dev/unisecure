import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/auth/auth_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/guard_controller.dart';

/// Guard Profile & Security Officer Digital Identity Credential.
class GuardProfileTab extends GetView<GuardController> {
  const GuardProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final profile = controller.profile.value;

      return ListView(
        padding: AppSpacing.screen,
        children: [
          // OFFICER DIGITAL CREDENTIAL CARD
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // University Security Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        AppSpacing.hGap8,
                        Text(
                          'CAMPUS SECURITY CORPS',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const AppStatusBadge(
                      label: 'AUTHORIZED',
                      color: AppColors.success,
                    ),
                  ],
                ),
                AppSpacing.vGap16,

                // Officer Photo & Core Identity
                Row(
                  children: [
                    AppAvatar(
                      name: profile?.name,
                      size: 64,
                      role: 'guard',
                      badgeIcon: Icons.verified_user_rounded,
                      badgeColor: AppColors.primary,
                    ),
                    AppSpacing.hGap16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name ?? 'Officer Tariq Khan',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          AppSpacing.vGap4,
                          Text(
                            'ID: ${profile?.guardIdNumber ?? 'SEC-2022-004'}',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.vGap2,
                          Text(
                            profile?.email ?? 'security.desk@unisecure.edu',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap16,
                const AppDivider(),
                AppSpacing.vGap12,

                // Deployment Details
                _DetailRow(
                  label: 'Assigned Gate Desk',
                  value: profile?.assignedGate ?? 'Main Gate 1 (North)',
                ),
                _DetailRow(
                  label: 'Operational Shift',
                  value: profile?.shift ?? 'Morning (06:00 - 14:00)',
                ),
                _DetailRow(
                  label: 'Radio Dispatch',
                  value: profile?.radioChannel ?? 'Channel 4',
                ),
                _DetailRow(
                  label: 'Duty Phone',
                  value: profile?.phone ?? '+1 (555) 019-3382',
                ),
              ],
            ),
          ),
          AppSpacing.vGap20,

          // SECURITY DESK PROTOCOLS CHECKLIST
          AppSectionHeader(title: 'Standard Security Protocols'),
          AppSpacing.vGap10,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ProtocolTile(
                  icon: Icons.face_rounded,
                  title: 'Biometric Camera Fallback',
                  subtitle:
                      'If face scanner reports offline, proceed with Audited Manual Verification.',
                ),
                const AppDivider(),
                _ProtocolTile(
                  icon: Icons.badge_outlined,
                  title: 'Physical Credential Audit',
                  subtitle:
                      'Inspect student hologram or QR validity on suspicious or flagged alerts.',
                ),
                const AppDivider(),
                _ProtocolTile(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Visitor Pass Logging',
                  subtitle:
                      'All external visitors must register government ID proof and host contact.',
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // SIGN OUT BUTTON
          AppButton.outlined(
            text: 'Sign Out of Gate Desk',
            icon: Icons.logout_rounded,
            onPressed: () async {
              final proceed = await AppBottomSheet.showConfirmation(
                context: context,
                title: 'Sign Out of Gate Desk?',
                message:
                    'This will terminate your current operational shift at ${profile?.assignedGate ?? 'Main Gate 1'}.',
                confirmText: 'Sign Out',
                cancelText: 'Stay on Duty',
                isDestructive: true,
                icon: AppIcons.logout,
              );
              if (proceed == true) {
                auth.logout();
              }
            },
          ),
          AppSpacing.vGap24,
        ],
      );
    });
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mainText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProtocolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap2,
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
