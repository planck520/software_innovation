import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 动画输入框组件
/// - 标签浮动动画（类似Material Design 3）
/// - 焦点时边框发光脉冲
/// - 密码切换图标旋转
class AnimatedInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool isPassword;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final bool enabled;
  final int? maxLines;
  final Color? focusColor;

  const AnimatedInputField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.focusColor,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _iconController;
  late Animation<double> _iconRotationAnimation;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _obscureText = widget.obscureText;

    // 发光脉冲动画控制器
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // 图标旋转动画控制器
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconRotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeInOut,
      ),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_isFocused) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _glowController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
    if (_obscureText) {
      _iconController.reverse();
    } else {
      _iconController.forward();
    }
  }

  Color get _focusColor => widget.focusColor ?? AppColors.primary;

  bool get _hasText => widget.controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _iconController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (widget.onTap != null) widget.onTap!();
            _focusNode.requestFocus();
          },
          child: Container(
            decoration: _buildBoxDecoration(),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.isPassword ? _obscureText : false,
              keyboardType: widget.keyboardType,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: widget.hintText ?? widget.label,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused ? _focusColor : AppColors.textTertiary,
                        size: 16,
                      )
                    : null,
                suffixIcon: widget.isPassword
                    ? Transform.rotate(
                        angle: _iconRotationAnimation.value * 3.14159,
                        child: GestureDetector(
                          onTap: _togglePasswordVisibility,
                          child: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.textTertiary,
                            size: 14,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildBoxDecoration() {
    final glowColor = _focusColor;

    return BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      border: Border.all(
        color: _isFocused
            ? glowColor.withOpacity(0.5 + _glowAnimation.value * 0.3)
            : AppColors.border.withOpacity(0.5),
        width: _isFocused ? 1.5 : 1,
      ),
      boxShadow: _isFocused
          ? [
              BoxShadow(
                color: glowColor.withOpacity(0.1 + _glowAnimation.value * 0.2),
                blurRadius: 12,
                offset: const Offset(0, 0),
              ),
            ]
          : null,
    );
  }
}

/// 浮动标签输入框（Material Design 3 风格）
class FloatingLabelInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool isPassword;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final Color? focusColor;

  const FloatingLabelInputField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusColor,
  });

  @override
  State<FloatingLabelInputField> createState() => _FloatingLabelInputFieldState();
}

class _FloatingLabelInputFieldState extends State<FloatingLabelInputField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _labelController;
  late Animation<Offset> _labelSlideAnimation;
  late Animation<double> _labelFadeAnimation;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _obscureText = widget.obscureText;

    _labelController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _labelSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeOut,
    ));

    _labelFadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      _updateLabelPosition();
    });

    // 初始化标签位置
    if (widget.controller.text.isNotEmpty) {
      _labelController.value = 1.0;
    }

    widget.controller.addListener(_updateLabelPosition);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _labelController.dispose();
    widget.controller.removeListener(_updateLabelPosition);
    super.dispose();
  }

  void _updateLabelPosition() {
    if (_isFocused || widget.controller.text.isNotEmpty) {
      _labelController.forward();
    } else {
      _labelController.reverse();
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Color get _focusColor => widget.focusColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _labelController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: _isFocused
                    ? _focusColor.withOpacity(0.5)
                    : AppColors.border.withOpacity(0.5),
                width: _isFocused ? 1.5 : 1,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: _focusColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 浮动标签
                Positioned(
                  left: widget.prefixIcon != null ? 32 : 4,
                  top: _labelController.value * 20,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Transform.translate(
                      offset: Offset(0, -_labelController.value * 28),
                      child: Container(
                        color: AppColors.cardBackground,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: _isFocused ? _focusColor : AppColors.textSecondary,
                            fontSize: 10 * (1 - _labelController.value * 0.3),
                            fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 输入框
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword ? _obscureText : false,
                  keyboardType: widget.keyboardType,
                  enabled: widget.enabled,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: _isFocused ? _focusColor : AppColors.textTertiary,
                            size: 16,
                          )
                        : null,
                    suffixIcon: widget.isPassword
                        ? GestureDetector(
                            onTap: _togglePasswordVisibility,
                            child: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.textTertiary,
                              size: 14,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
