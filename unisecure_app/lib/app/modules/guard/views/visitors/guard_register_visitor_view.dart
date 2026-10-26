import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/guard_visitor_controller.dart';

/// Dedicated full-screen form for issuing visitor access passes.
class GuardRegisterVisitorView extends StatelessWidget {
  const GuardRegisterVisitorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuardVisitorController>();

    return AppScaffold(
      appBar: AppBar(title: const Text('Register Visitor')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // Registration Header
          const AppPageHeader(
            title: 'Campus Visitor Pass',
            subtitle:
                'Register non-university visitors, issue audited badges, and log vehicle access.',
          ),
          AppSpacing.vGap16,

          // Visitor Details Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visitor Identification',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap16,

                // Full Name
                Obx(
                  () => AppTextField(
                    controller: controller.nameController,
                    label: 'Visitor Full Name *',
                    hint: 'e.g. Sanjay Deshmukh',
                    errorText: controller.nameError.value.isNotEmpty
                        ? controller.nameError.value
                        : null,
                  ),
                ),
                AppSpacing.vGap16,

                // Contact Phone
                Obx(
                  () => AppTextField(
                    controller: controller.phoneController,
                    label: 'Contact Phone Number *',
                    hint: 'e.g. +1 (555) 019-2831',
                    keyboardType: TextInputType.phone,
                    errorText: controller.phoneError.value.isNotEmpty
                        ? controller.phoneError.value
                        : null,
                  ),
                ),
                AppSpacing.vGap16,

                // Purpose
                Obx(
                  () => AppTextField(
                    controller: controller.purposeController,
                    label: 'Purpose of Visit *',
                    hint: 'e.g. Guest Lecture, Vendor Delivery, Parent Meeting',
                    errorText: controller.purposeError.value.isNotEmpty
                        ? controller.purposeError.value
                        : null,
                  ),
                ),
                AppSpacing.vGap16,

                // Host Department or Person
                Obx(
                  () => AppTextField(
                    controller: controller.hostController,
                    label: 'Person / Department to Meet *',
                    hint: 'e.g. Dr. Evelyn Reed / Dept of Computer Science',
                    errorText: controller.hostError.value.isNotEmpty
                        ? controller.hostError.value
                        : null,
                  ),
                ),
                AppSpacing.vGap16,

                const AppDivider(),
                AppSpacing.vGap16,

                Text(
                  'Security & Proof Verification',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap16,

                // ID Proof Type Dropdown
                Obx(() {
                  const proofTypes = [
                    'National ID',
                    'Driving License',
                    'Passport',
                    'State ID Card',
                    'Employee Card',
                  ];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedIdProofType.value,
                        items: proofTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: AppTypography.bodyMedium),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedIdProofType.value = val;
                          }
                        },
                      ),
                    ),
                  );
                }),
                AppSpacing.vGap16,

                // ID Proof Number
                Obx(
                  () => AppTextField(
                    controller: controller.idProofNumberController,
                    label: 'ID Proof Document Number *',
                    hint: 'e.g. DL-9812-4029',
                    errorText: controller.idProofError.value.isNotEmpty
                        ? controller.idProofError.value
                        : null,
                  ),
                ),
                AppSpacing.vGap16,

                // Vehicle Registration (Optional)
                AppTextField(
                  controller: controller.vehicleController,
                  label: 'Vehicle Plate Number (Optional)',
                  hint: 'e.g. KA-04-MB-1024 or Leave empty if on foot',
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // Submit Button
          Obx(() {
            return AppButton.primary(
              text: 'Issue Visitor Pass & Grant Entry',
              icon: Icons.badge_outlined,
              isLoading: controller.isSubmitting.value,
              onPressed: () async {
                final success = await controller.submitVisitorRegistration(
                  context,
                );
                if (success) {
                  Get.back();
                }
              },
            );
          }),
          AppSpacing.vGap20,
        ],
      ),
    );
  }
}
