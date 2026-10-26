import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_icons.dart';
import '../constants/app_radius.dart';
import '../constants/app_typography.dart';

/// Clean search input field with clear action and debounce-ready callback.
class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search records...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateClearState);
  }

  void _updateClearState() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText && mounted) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_updateClearState);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.mainText),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.subtleText,
        ),
        prefixIcon: const Icon(
          AppIcons.search,
          size: AppDimensions.iconSm,
          color: AppColors.secondaryText,
        ),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(
                  AppIcons.close,
                  size: AppDimensions.iconSm,
                  color: AppColors.secondaryText,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                  widget.onClear?.call();
                },
                splashRadius: 18,
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
      ),
    );
  }
}
