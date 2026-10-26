import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_dimensions.dart';
import '../../../app/core/constants/app_icons.dart';
import '../../../app/core/constants/app_radius.dart';
import '../../../app/core/constants/app_spacing.dart';
import '../../../app/core/constants/app_strings.dart';
import '../../../app/core/constants/app_typography.dart';
import '../../../app/core/widgets/app_buttons.dart';
import '../../../app/core/widgets/app_layout.dart';
import '../../../app/core/widgets/app_text_fields.dart';
import '../../../core/auth/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthController get _auth => Get.find<AuthController>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      _auth.login(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSpacing.vGap16,
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimensions.strokeWidth,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  AppSpacing.vGap24,
                  Text(
                    AppStrings.loginTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  AppSpacing.vGap8,
                  Text(
                    AppStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  AppSpacing.vGap32,
                  AppTextField(
                    controller: _email,
                    label: AppStrings.email,
                    hint: 'student@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                      size: AppDimensions.iconSm,
                      color: AppColors.secondaryText,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid university email address';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.vGap16,
                  AppPasswordField(
                    controller: _password,
                    label: AppStrings.password,
                    hint: '12345678',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (v.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleSignIn(),
                  ),
                  AppSpacing.vGap16,
                  Obx(
                    () => _auth.error.value.isEmpty
                        ? const SizedBox.shrink()
                        : Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorSoft,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.2),
                                width: AppDimensions.strokeWidth,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  AppIcons.error,
                                  size: AppDimensions.iconSm,
                                  color: AppColors.error,
                                ),
                                AppSpacing.hGap8,
                                Expanded(
                                  child: Text(
                                    _auth.error.value,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Obx(
                    () => AppButton.primary(
                      text: AppStrings.signIn,
                      isLoading: _auth.loading.value,
                      onPressed: _handleSignIn,
                    ),
                  ),
                  AppSpacing.vGap32,
                  Text(
                    'NUML University • Campus Attendance & Security System',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  AppSpacing.vGap16,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
