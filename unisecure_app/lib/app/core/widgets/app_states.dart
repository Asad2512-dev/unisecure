import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_icons.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import 'app_buttons.dart';

/// Clean empty state with restrained icon, title, helper text, and optional action.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.title = AppStrings.emptyDefaultTitle,
    this.message = AppStrings.emptyDefaultMessage,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.sheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimensions.strokeWidth,
                ),
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconLg,
                color: AppColors.secondaryText,
              ),
            ),
            AppSpacing.vGap16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.mainText,
              ),
            ),
            if (message != null) ...[
              AppSpacing.vGap8,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
            if (actionText != null && onAction != null) ...[
              AppSpacing.vGap20,
              AppButton.secondary(
                text: actionText!,
                onPressed: onAction,
                isFullWidth: false,
                height: 42,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Backward compatibility alias for existing code
class EmptyState extends StatelessWidget {
  final String text;
  const EmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) => AppEmptyState(message: text);
}

/// Actionable error state with clear explanation and retry trigger.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const AppErrorState({
    super.key,
    this.title = AppStrings.errorDefaultTitle,
    this.message = AppStrings.errorDefaultMessage,
    this.onRetry,
    this.retryText = AppStrings.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.sheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                  width: AppDimensions.strokeWidth,
                ),
              ),
              child: const Icon(
                AppIcons.error,
                size: AppDimensions.iconLg,
                color: AppColors.error,
              ),
            ),
            AppSpacing.vGap16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.mainText,
              ),
            ),
            AppSpacing.vGap8,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            if (onRetry != null) ...[
              AppSpacing.vGap20,
              AppButton.outlined(
                text: retryText,
                onPressed: onRetry,
                isFullWidth: false,
                height: 42,
                icon: AppIcons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmering/pulsing skeleton loader placeholder for cards and lists.
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const AppSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      shape = BoxShape.circle;

  const AppSkeleton.card({
    super.key,
    this.width = double.infinity,
    this.height = 100.0,
  }) : borderRadius = null,
       shape = BoxShape.rectangle;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: _animation.value),
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle
              ? (widget.borderRadius ?? BorderRadius.circular(AppRadius.sm))
              : null,
        ),
      ),
    );
  }
}

/// Inline or full-page loading indicator with optional label.
class AppLoading extends StatelessWidget {
  final String? message;
  final double size;
  final bool isCentered;

  const AppLoading({
    super.key,
    this.message,
    this.size = 28.0,
    this.isCentered = true,
  });

  @override
  Widget build(BuildContext context) {
    final widgetContent = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        if (message != null) ...[
          AppSpacing.vGap12,
          Text(
            message!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ],
    );

    if (isCentered) return Center(child: widgetContent);
    return widgetContent;
  }
}

/// Backward compatibility alias for existing code
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) => const AppLoading();
}
