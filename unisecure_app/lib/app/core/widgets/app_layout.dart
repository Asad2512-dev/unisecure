import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Responsive wrapper constraining max content width for tablets and desktop viewports.
class AppResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const AppResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppDimensions.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

/// Base screen scaffold with integrated responsive constraints, light-mode background, and SafeArea.
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final bool useSafeArea;
  final double maxWidth;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding = EdgeInsets.zero,
    this.useSafeArea = true,
    this.maxWidth = AppDimensions.maxContentWidth,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (padding != EdgeInsets.zero) {
      content = Padding(padding: padding, child: content);
    }
    content = AppResponsiveContainer(maxWidth: maxWidth, child: content);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: useSafeArea ? SafeArea(child: content) : content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Standardized list item with icon container, title, subtitle, and chevron.
class AppListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final EdgeInsetsGeometry padding;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading != null) ...[leading!, AppSpacing.hGap16],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: AppTypography.titleSmall.copyWith(
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.mainText,
                      fontWeight: FontWeight.w600,
                    ),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    AppSpacing.vGap4,
                    DefaultTextStyle(
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              AppSpacing.hGap8,
              trailing!,
            ] else if (onTap != null) ...[
              AppSpacing.hGap8,
              const Icon(
                Icons.chevron_right_rounded,
                size: AppDimensions.iconSm,
                color: AppColors.secondaryText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Clean subtle divider.
class AppDivider extends StatelessWidget {
  final bool vertical;
  final double? height;
  final Color? color;
  final double? indent;
  final double? endIndent;

  const AppDivider({
    super.key,
    this.vertical = false,
    this.height,
    this.color,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return VerticalDivider(
        width: height ?? AppDimensions.strokeWidth,
        thickness: AppDimensions.strokeWidth,
        color: color ?? AppColors.divider,
        indent: indent,
        endIndent: endIndent,
      );
    }
    return Divider(
      height: height ?? 1.0,
      thickness: AppDimensions.strokeWidth,
      color: color ?? AppColors.divider,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
