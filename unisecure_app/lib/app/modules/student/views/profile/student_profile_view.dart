import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/student_controller.dart';

class StudentProfileView extends GetView<StudentController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Student Identity Card')),
      body: Obx(() {
        final p = controller.profile.value;

        if (p == null) {
          return const Center(child: AppLoading(message: 'Loading profile...'));
        }

        return ListView(
          padding: AppSpacing.screen,
          children: [
            // Digital Student ID Card (University Card Aesthetic)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: AppDimensions.strokeWidthThick,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Card Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.card - 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 20,
                            ),
                            AppSpacing.hGap8,
                            Text(
                              'NUML UNIVERSITY',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'STUDENT',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppAvatar(name: p.name, size: 76, role: 'student'),
                        AppSpacing.hGap16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: AppTypography.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mainText,
                                ),
                              ),
                              AppSpacing.vGap4,
                              Text(
                                'ID: ${p.studentIdNumber}',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.primary,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              AppSpacing.vGap6,
                              Text(
                                p.program,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Barcode / Verification footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.card - 2),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border,
                          width: AppDimensions.strokeWidth,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              AppIcons.check,
                              size: 14,
                              color: AppColors.success,
                            ),
                            AppSpacing.hGap6,
                            Text(
                              p.status,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Valid: Fall 2026',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vGap24,

            // Academic Standing Details
            AppSectionHeader(title: 'Academic Standing'),
            AppSpacing.vGap8,
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _InfoTile(label: 'Enrolled Degree', value: p.program),
                  const AppDivider(),
                  _InfoTile(label: 'Department', value: p.department),
                  const AppDivider(),
                  _InfoTile(
                    label: 'Current Semester',
                    value: 'Semester ${p.semester} (${p.section})',
                  ),
                  const AppDivider(),
                  _InfoTile(
                    label: 'Cumulative GPA',
                    value: '${p.cgpa.toStringAsFixed(2)} / 4.00',
                  ),
                  const AppDivider(),
                  _InfoTile(label: 'Academic Advisor', value: p.advisorName),
                  const AppDivider(),
                  _InfoTile(
                    label: 'Enrolled Credits',
                    value: '${p.enrolledCredits} Credit Hours',
                  ),
                ],
              ),
            ),
            AppSpacing.vGap24,

            // Contact & Security
            AppSectionHeader(title: 'Contact Information'),
            AppSpacing.vGap8,
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _InfoTile(label: 'University Email', value: p.email),
                  const AppDivider(),
                  _InfoTile(label: 'Mobile Contact', value: p.phone),
                ],
              ),
            ),
            AppSpacing.vGap24,
          ],
        );
      }),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
