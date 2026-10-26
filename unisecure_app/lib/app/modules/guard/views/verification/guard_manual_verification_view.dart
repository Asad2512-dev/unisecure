import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/guard_models.dart';
import '../../controllers/guard_verification_controller.dart';

/// Screen for searching students and recording audited manual entry/exit gate transactions.
class GuardManualVerificationView extends StatelessWidget {
  final StudentVerificationCard? initialStudent;

  const GuardManualVerificationView({super.key, this.initialStudent});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuardVerificationController());

    if (initialStudent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectStudent(initialStudent!);
      });
    }

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Manual Student Verification'),
        actions: [
          Obx(() {
            if (controller.selectedStudent.value != null) {
              return TextButton(
                onPressed: controller.clearSelectedStudent,
                child: const Text('Change Student'),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final selected = controller.selectedStudent.value;

        if (selected != null) {
          return _SelectedStudentDetailView(
            student: selected,
            controller: controller,
          );
        }

        return _StudentSearchRosterView(controller: controller);
      }),
    );
  }
}

class _StudentSearchRosterView extends StatelessWidget {
  final GuardVerificationController controller;

  const _StudentSearchRosterView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: AppSearchField(
            hint: 'Search student name or ID (e.g. CS-2023)...',
            onChanged: controller.searchStudents,
          ),
        ),

        // Search Results / Student Roster
        Expanded(
          child: Obx(() {
            if (controller.isSearching.value) {
              return const AppLoading(
                message: 'Searching registered student roster...',
              );
            }

            final results = controller.searchResults;

            if (results.isEmpty) {
              return const AppEmptyState(
                icon: Icons.person_search_rounded,
                title: 'No Student Found',
                message:
                    'No student matching the entered name or ID was found. Verify the institutional identifier or contact Admissions desk.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final student = results[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => controller.selectStudent(student),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        AppAvatar(
                          name: student.name,
                          size: AppDimensions.avatarMd,
                          role: 'student',
                        ),
                        AppSpacing.hGap14,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              AppSpacing.vGap4,
                              Text(
                                '${student.studentIdNumber} • ${student.section}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryText,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              AppSpacing.vGap2,
                              Text(
                                student.program,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hGap8,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppStatusBadge(
                              label: student.isValid ? 'VALID' : 'HOLD',
                              color: student.isValid
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            AppSpacing.vGap6,
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _SelectedStudentDetailView extends StatelessWidget {
  final StudentVerificationCard student;
  final GuardVerificationController controller;

  const _SelectedStudentDetailView({
    required this.student,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.screen,
      children: [
        // Student Identity Card Summary
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    name: student.name,
                    size: 64,
                    role: 'student',
                    badgeIcon: student.isValid
                        ? Icons.check
                        : Icons.warning_amber_rounded,
                    badgeColor: student.isValid
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  AppSpacing.hGap16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.vGap4,
                        Text(
                          student.studentIdNumber,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.vGap4,
                        Text(
                          student.email,
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
              _DetailRow(label: 'Academic Program', value: student.program),
              _DetailRow(
                label: 'Class Status',
                value: 'Semester ${student.semester} (${student.section})',
              ),
              _DetailRow(
                label: 'Security Status',
                value: student.validityStatus,
                isHighlight: true,
                highlightColor: student.isValid
                    ? AppColors.success
                    : AppColors.error,
              ),
            ],
          ),
        ),
        AppSpacing.vGap16,

        // Last Known Transaction
        AppSectionHeader(title: 'Last Known Gate Transaction'),
        AppSpacing.vGap8,
        AppCard(
          child: student.lastTransaction != null
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: student.lastTransaction!.isEntry
                            ? AppColors.successSoft
                            : AppColors.infoSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        student.lastTransaction!.isEntry
                            ? Icons.login_rounded
                            : Icons.logout_rounded,
                        color: student.lastTransaction!.isEntry
                            ? AppColors.success
                            : AppColors.info,
                      ),
                    ),
                    AppSpacing.hGap14,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${student.lastTransaction!.eventType.toUpperCase()} • ${student.lastTransaction!.gate}',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.vGap2,
                          Text(
                            'Logged at ${student.lastTransaction!.timeFormatted} on ${student.lastTransaction!.dateFormatted}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No prior campus access transaction found for today.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ),
        ),
        AppSpacing.vGap20,

        // Direction Selection & Audit Action
        AppSectionHeader(
          title: 'Manual Verification Action',
          subtitle: 'Select direction and confirm physical audit check',
        ),
        AppSpacing.vGap12,

        // Direction Selector (Entry / Exit)
        Obx(() {
          final direction = controller.selectedDirection.value;
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.setDirection('entry'),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: direction == 'entry'
                          ? AppColors.successSoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: direction == 'entry'
                            ? AppColors.success
                            : AppColors.border,
                        width: direction == 'entry' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.login_rounded,
                          color: direction == 'entry'
                              ? AppColors.success
                              : AppColors.secondaryText,
                        ),
                        AppSpacing.vGap6,
                        Text(
                          'Grant Entry',
                          style: AppTypography.titleSmall.copyWith(
                            color: direction == 'entry'
                                ? AppColors.success
                                : AppColors.mainText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: InkWell(
                  onTap: () => controller.setDirection('exit'),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: direction == 'exit'
                          ? AppColors.infoSoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: direction == 'exit'
                            ? AppColors.info
                            : AppColors.border,
                        width: direction == 'exit' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: direction == 'exit'
                              ? AppColors.info
                              : AppColors.secondaryText,
                        ),
                        AppSpacing.vGap6,
                        Text(
                          'Record Exit',
                          style: AppTypography.titleSmall.copyWith(
                            color: direction == 'exit'
                                ? AppColors.info
                                : AppColors.mainText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        AppSpacing.vGap16,

        // Audit Reason Note Field
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security Audit Note (Optional)',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.vGap8,
              AppTextField(
                hint: 'e.g. Physical badge checked / Library departure...',
                onChanged: (val) => controller.auditReasonText.value = val,
              ),
            ],
          ),
        ),
        AppSpacing.vGap20,

        // Submit Action Button
        Obx(() {
          final isSubmitting = controller.isSubmitting.value;
          final direction = controller.selectedDirection.value;

          return AppButton.primary(
            text: direction == 'entry'
                ? 'Confirm & Grant Entry'
                : 'Confirm & Record Exit',
            icon: direction == 'entry'
                ? Icons.check_circle_outline
                : Icons.arrow_circle_right_outlined,
            isLoading: isSubmitting,
            onPressed: isSubmitting
                ? null
                : () async {
                    final ok = await controller.confirmAndRecordTransaction(
                      context: context,
                      student: student,
                      method: 'manual_guard',
                    );
                    if (ok) {
                      Get.back();
                    }
                  },
          );
        }),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final Color? highlightColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? highlightColor : AppColors.mainText,
            ),
          ),
        ],
      ),
    );
  }
}
