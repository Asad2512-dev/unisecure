import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/guard_verification_controller.dart';
import 'guard_manual_verification_view.dart';

/// Camera Face Verification Preview Screen with viewfinder overlay and prototype disclaimers.
class GuardFaceScanView extends StatelessWidget {
  const GuardFaceScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuardVerificationController());

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Face Verification Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Scan View',
            onPressed: controller.resetScan,
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // PROTOTYPE DISCLAIMER BANNER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.info,
                ),
                AppSpacing.hGap10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROTOTYPE PREVIEW ONLY',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      AppSpacing.vGap2,
                      Text(
                        'Actual biometric facial processing is unavailable in this frontend prototype. Simulated demonstration only. Use Manual Verification for audited access control.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mainText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap20,

          // VIEW FINDER FRAME CONTAINER
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFF131A29), // Camera feed background
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mock camera preview grid background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: GridPaper(
                        color: Colors.white,
                        divisions: 2,
                        subdivisions: 1,
                      ),
                    ),
                  ),

                  // Viewfinder Reticle / Corner Markers
                  Container(
                    width: 220,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Stack(
                      children: [
                        // Top-left corner
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                                left: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Top-right corner
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                                right: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-left corner
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                                left: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-right corner
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                                right: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reactive Scan State Overlay
                  Obx(() {
                    switch (controller.scanState.value) {
                      case FaceScanState.idle:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.face_retouching_natural_rounded,
                              size: 48,
                              color: Colors.white70,
                            ),
                            AppSpacing.vGap12,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                              ),
                              child: Text(
                                'Align student face in frame',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );

                      case FaceScanState.scanning:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            AppSpacing.vGap16,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                              ),
                              child: Text(
                                'Analyzing facial landmarks (Simulated)...',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );

                      case FaceScanState.matched:
                        final student = controller.scannedStudent.value;
                        return Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: AppColors.success,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'SIMULATED MATCH FOUND (98.4%)',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vGap10,
                              Text(
                                student?.name ?? 'Unknown Student',
                                style: AppTypography.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              AppSpacing.vGap4,
                              Text(
                                '${student?.studentIdNumber} • ${student?.program}',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );

                      case FaceScanState.error:
                        return Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Text(
                            controller.scanErrorMessage.value,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        );
                    }
                  }),
                ],
              ),
            ),
          ),
          AppSpacing.vGap20,

          // SIMULATED SCAN CONTROLS
          Obx(() {
            final state = controller.scanState.value;

            if (state == FaceScanState.matched) {
              final student = controller.scannedStudent.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.primary(
                          text: 'Confirm Entry',
                          icon: Icons.login_rounded,
                          isLoading: controller.isSubmitting.value,
                          onPressed: student == null
                              ? null
                              : () async {
                                  controller.setDirection('entry');
                                  final ok = await controller
                                      .confirmAndRecordTransaction(
                                        context: context,
                                        student: student,
                                        method: 'face_scan',
                                      );
                                  if (ok) {
                                    Get.back();
                                  }
                                },
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        child: AppButton.outlined(
                          text: 'Confirm Exit',
                          icon: Icons.logout_rounded,
                          isLoading: controller.isSubmitting.value,
                          onPressed: student == null
                              ? null
                              : () async {
                                  controller.setDirection('exit');
                                  final ok = await controller
                                      .confirmAndRecordTransaction(
                                        context: context,
                                        student: student,
                                        method: 'face_scan',
                                      );
                                  if (ok) {
                                    Get.back();
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap12,
                  TextButton.icon(
                    onPressed: controller.resetScan,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Scan Another Face'),
                  ),
                ],
              );
            }

            return AppButton.primary(
              text: state == FaceScanState.scanning
                  ? 'Analyzing Camera Feed...'
                  : 'Simulate Face Match (Faizan Khan)',
              icon: Icons.camera_alt_rounded,
              isLoading: state == FaceScanState.scanning,
              onPressed: state == FaceScanState.scanning
                  ? null
                  : controller.triggerSimulatedScan,
            );
          }),
          AppSpacing.vGap16,

          // MANUAL VERIFICATION FALLBACK LINK
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.primary,
                    size: AppDimensions.iconMd,
                  ),
                ),
                AppSpacing.hGap14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Guard Audit Fallback',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.vGap2,
                      Text(
                        'Official university security fallback for students without registered biometric templates.',
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
                  tooltip: 'Go to manual verification',
                  onPressed: () {
                    Get.to(() => const GuardManualVerificationView());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
