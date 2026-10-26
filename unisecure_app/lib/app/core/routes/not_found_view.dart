import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_layout.dart';
import 'app_routes.dart';

/// Clean fallback screen for unrecognized routes.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.sheet,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.info,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.vGap20,
              Text(
                'Page Not Found',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainText,
                ),
              ),
              AppSpacing.vGap8,
              Text(
                'The requested page or route does not exist.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              AppSpacing.vGap24,
              AppButton.primary(
                text: 'Go to Home',
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                isFullWidth: false,
                height: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
