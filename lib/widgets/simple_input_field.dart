import 'package:flutter/material.dart';
import '../theme/login_theme.dart';

/// 简洁风格输入框组件
/// 纯白背景，浅灰边框，聚焦时深灰边框
class SimpleInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final int? maxLines;
  final String? errorText;
  final bool showCapsLockHint;
  final bool enableClearButton;

  const SimpleInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.isPassword = false,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.errorText,
    this.showCapsLockHint = true,
    this.enableClearButton = true,
  });

  @override
  State<SimpleInputField> createState() => _SimpleInputFieldState();
}

class _SimpleInputFieldState extends State<SimpleInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  bool _isCapsLockOn = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ? true : widget.obscureText;
    _initFocusNode();
    _setupControllerListener();
  }

  void _initFocusNode() {
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _setupControllerListener() {
    widget.controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    _detectCapsLock();
    setState(() {});
  }

  void _detectCapsLock() {
    final text = widget.controller.text;
    if (text.isNotEmpty && widget.isPassword) {
      final hasLetters = text.contains(RegExp(r'[a-zA-Z]'));
      final allUpper = text == text.toUpperCase();
      final hasLower = text != text.toUpperCase();
      setState(() {
        _isCapsLockOn = hasLetters && allUpper && !hasLower;
      });
    } else {
      setState(() {
        _isCapsLockOn = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    widget.controller.clear();
    setState(() {});
  }

  bool get _hasText => widget.controller.text.isNotEmpty;

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: LoginTheme.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hasError
                  ? Colors.red
                  : _isFocused
                      ? LoginTheme.inputFocusBorder
                      : LoginTheme.inputBorder,
              width: _isFocused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            style: TextStyle(
              color: LoginTheme.textPrimary,
              fontSize: 15,
            ),
            onChanged: (value) {
              if (widget.onChanged != null) widget.onChanged!(value);
            },
            onSubmitted: (value) {
              if (widget.onSubmitted != null) widget.onSubmitted!(value);
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: LoginTheme.textSecondary,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? LoginTheme.textPrimary
                          : LoginTheme.textSecondary,
                      size: 18,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            ),
          ),
        ),
        // 错误提示
        if (_hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
        // CapsLock 提示
        if (_isCapsLockOn && widget.showCapsLockHint && widget.isPassword)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_capslock,
                  size: 12,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  "大写锁定已开启",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSuffixIcon() {
    List<Widget> icons = [];

    // 清除按钮
    if (widget.enableClearButton && _hasText) {
      icons.add(
        GestureDetector(
          onTap: _clearText,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.cancel,
              color: LoginTheme.textSecondary,
              size: 16,
            ),
          ),
        ),
      );
    }

    // 密码可见性切换
    if (widget.isPassword) {
      icons.add(
        GestureDetector(
          onTap: _togglePasswordVisibility,
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: LoginTheme.textSecondary,
            size: 18,
          ),
        ),
      );
    }

    if (icons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons
          .map((e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: e,
              ))
          .toList(),
    );
  }
}
