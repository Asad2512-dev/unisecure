import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_icons.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Standard styled text field with label, optional prefix/suffix, and error states.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mainText,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vGap8,
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          textInputAction: textInputAction,
          style: AppTypography.bodyMedium.copyWith(
            color: enabled ? AppColors.mainText : AppColors.secondaryText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.subtleText,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.surfaceSubtle,
            contentPadding: AppSpacing.input,
            border: OutlineInputBorder(
              borderRadius: AppRadius.fieldRadius,
              borderSide: const BorderSide(
                color: AppColors.border,
                width: AppDimensions.strokeWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.fieldRadius,
              borderSide: const BorderSide(
                color: AppColors.border,
                width: AppDimensions.strokeWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.fieldRadius,
              borderSide: const BorderSide(
                color: AppColors.borderFocused,
                width: AppDimensions.strokeWidthThick,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.fieldRadius,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppDimensions.strokeWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.fieldRadius,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppDimensions.strokeWidthThick,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Specialized password input with integrated show/hide toggle.
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Enter password',
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        size: AppDimensions.iconSm,
        color: AppColors.secondaryText,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscured ? AppIcons.visibility : AppIcons.visibilityOff,
          size: AppDimensions.iconSm,
          color: AppColors.secondaryText,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
        splashRadius: 20,
      ),
    );
  }
}
