import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_dimensions.dart';
import '../../../app/core/constants/app_radius.dart';
import '../../../app/core/routes/app_routes.dart';
import '../../../app/core/constants/app_spacing.dart';
import '../../../app/core/constants/app_strings.dart';
import '../../../app/core/constants/app_typography.dart';
import '../../../core/auth/auth_controller.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final auth = Get.find<AuthController>();
    final hasSession = await auth.restore();
    if (!mounted) return;
    if (hasSession && auth.user.value != null) {
      auth.routeForRole();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: AppSpacing.sheet,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimensions.strokeWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              AppSpacing.vGap24,
              Text(
                AppStrings.appName,
                style: AppTypography.displaySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainText,
                  letterSpacing: -0.5,
                ),
              ),
              AppSpacing.vGap4,
              Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              AppSpacing.vGap32,
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
