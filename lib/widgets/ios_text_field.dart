import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

/// iOS 风格输入框组件
class IosTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isObscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;

  const IosTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isObscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.textInputAction,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
  });

  @override
  State<IosTextField> createState() => _IosTextFieldState();
}

class _IosTextFieldState extends State<IosTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  Color _getBorderColor() {
    if (_errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.glassBorder;
  }

  Color _getIconColor() {
    if (_errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Floating label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: _isFocused ? 13 : 14,
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
            color: _errorText != null
                ? AppColors.error
                : _isFocused
                    ? AppColors.primary
                    : AppColors.textSecondary,
            letterSpacing: _isFocused ? 0.3 : 0,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(widget.label.toUpperCase()),
          ),
        ),
        // Input field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.surface : AppColors.surfaceDim,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
              color: _getBorderColor(),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused && _errorText == null
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : AppTokens.shadowSm,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isObscure,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            onTap: widget.onTap,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLength: widget.maxLength,
            onChanged: (value) {
              widget.onChanged?.call(value);
              _validateInput(value);
            },
            onSubmitted: (_) => _validateInput(widget.controller?.text),
            style: AppTextStyles.body.copyWith(
              color: widget.enabled ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space4,
                vertical: 14,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _getIconColor(),
                      size: 14,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              counterText: '',
            ),
          ),
        ),
        // Error message
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: AppTokens.space3),
            child: Text(
              _errorText!,
              style: AppTextStyles.footnote.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// iOS 风格搜索框
class IosSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;

  const IosSearchField({
    super.key,
    this.hint = '搜索...',
    this.onChanged,
    this.onClear,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<IosSearchField> createState() => _IosSearchFieldState();
}

class _IosSearchFieldState extends State<IosSearchField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.primary : AppColors.glassBorder,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: _focusNode.hasFocus ? AppTokens.shadowMd : AppTokens.shadowSm,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: (value) {
          setState(() {});
          widget.onChanged?.call(value);
        },
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.caption,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space4,
            vertical: 12,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 14,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onClear?.call();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.clear,
                    color: AppColors.textTertiary,
                    size: 12.6,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
