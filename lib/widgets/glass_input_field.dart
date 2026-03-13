import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/bubei_colors.dart';

/// 连接状态枚举
enum ConnectionStatus {
  online,    // 在线 - 绿色
  offline,   // 离线 - 灰色
  connecting // 连接中 - 黄色动画
}

/// 输入类型枚举
enum InputType {
  email,     // 邮箱
  phone,     // 手机号
  username,  // 用户名
  password,  // 密码
  general    // 通用
}

/// 毛玻璃拟态风格输入框组件
///
/// 功能特性：
/// - 毛玻璃背景效果
/// - 渐变边框动画
/// - 动态阴影
/// - 浮动标签动画
/// - 输入反馈微动画
/// - 智能清除按钮
/// - 账号格式检测（邮箱/手机/用户名）
/// - 输入波纹效果
/// - 霓虹发光脉冲
/// - 错误震动反馈
/// - 连接状态指示点
/// - CapsLock 提示
/// - 密码可见性切换动画
class GlassInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final bool enabled;
  final int? maxLines;
  final Color? focusColor;
  final String? errorText;
  final bool autoDetectType;
  final ConnectionStatus? connectionStatus;
  final bool showCapsLockHint;
  final bool enableClearButton;

  const GlassInputField({
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
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.focusColor,
    this.errorText,
    this.autoDetectType = false,
    this.connectionStatus,
    this.showCapsLockHint = true,
    this.enableClearButton = true,
  });

  @override
  State<GlassInputField> createState() => _GlassInputFieldState();
}

class _GlassInputFieldState extends State<GlassInputField>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  InputType _detectedType = InputType.general;
  bool _isCapsLockOn = false;

  // 动画控制器
  late AnimationController _borderAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _labelAnimationController;
  late AnimationController _rippleAnimationController;
  late AnimationController _shakeAnimationController;
  late AnimationController _iconAnimationController;
  late AnimationController _bounceAnimationController;
  late AnimationController _statusAnimationController;

  // 动画对象
  late Animation<double> _borderAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _labelSlideAnimation;
  late Animation<double> _labelScaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _statusAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ? true : widget.obscureText;
    _initAnimations();
    _initFocusNode();
    _setupControllerListener();
    if (widget.autoDetectType) {
      _detectInputType();
    }
  }

  void _initAnimations() {
    // 渐变边框动画
    _borderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderAnimationController, curve: Curves.linear),
    );

    // 霓虹发光脉冲
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowAnimationController, curve: Curves.easeInOut),
    );

    // 浮动标签动画
    _labelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _labelSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _labelAnimationController, curve: Curves.easeOut));
    _labelScaleAnimation = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(parent: _labelAnimationController, curve: Curves.easeOut),
    );

    // 输入波纹效果
    _rippleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleAnimationController, curve: Curves.easeOut),
    );

    // 错误震动反馈
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeAnimationController, curve: Curves.easeInOut),
    );

    // 密码可见性切换动画
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeInOut),
    );
    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeInOut),
    );

    // 输入弹性反馈
    _bounceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _bounceAnimationController, curve: Curves.easeOut),
    );

    // 状态指示点动画
    _statusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statusAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _statusAnimationController, curve: Curves.easeInOut),
    );

    // 启动动画
    _borderAnimationController.repeat();
    if (widget.connectionStatus == ConnectionStatus.connecting ||
        widget.connectionStatus == ConnectionStatus.online) {
      _statusAnimationController.repeat(reverse: true);
    }
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

    if (_isFocused) {
      _glowAnimationController.repeat(reverse: true);
      _rippleAnimationController.forward(from: 0);
      _updateLabelPosition();
    } else {
      _glowAnimationController.stop();
      _glowAnimationController.reset();
      _updateLabelPosition();
    }
  }

  void _onTextChange() {
    if (widget.autoDetectType) {
      _detectInputType();
    }
    if (_isFocused) {
      _bounceAnimationController.forward(from: 0);
    }
    _updateLabelPosition();
    _detectCapsLock();
  }

  void _detectInputType() {
    final text = widget.controller.text.trim();
    InputType newType = InputType.general;

    if (text.isEmpty) {
      newType = InputType.general;
    } else if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) {
      newType = InputType.email;
    } else if (RegExp(r'^1[3-9]\d{9}$').hasMatch(text)) {
      newType = InputType.phone;
    } else {
      newType = InputType.username;
    }

    if (newType != _detectedType) {
      setState(() {
        _detectedType = newType;
      });
    }
  }

  void _detectCapsLock() {
    // 简单的 CapsLock 检测（检查是否全大写且没有数字）
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

  void _updateLabelPosition() {
    if (_isFocused || widget.controller.text.isNotEmpty) {
      _labelAnimationController.forward();
    } else {
      _labelAnimationController.reverse();
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
    if (_obscureText) {
      _iconAnimationController.reverse();
    } else {
      _iconAnimationController.forward();
    }
  }

  void _clearText() {
    widget.controller.clear();
    _bounceAnimationController.forward(from: 0);
    if (widget.autoDetectType) {
      setState(() {
        _detectedType = InputType.general;
      });
    }
  }

  /// 触发错误震动反馈
  void shakeError() {
    _shakeAnimationController.forward(from: 0);
  }

  Color get _focusColor => widget.focusColor ?? BubeiColors.primary;

  bool get _hasText => widget.controller.text.isNotEmpty;

  bool get _hasError => widget.errorText != null;

  IconData _getPrefixIcon() {
    if (widget.prefixIcon != null) return widget.prefixIcon!;
    switch (_detectedType) {
      case InputType.email:
        return Icons.email_outlined;
      case InputType.phone:
        return Icons.phone_outlined;
      case InputType.username:
        return Icons.person_outlined;
      case InputType.password:
        return Icons.lock_outline;
      default:
        return Icons.text_fields;
    }
  }

  Color _getStatusColor() {
    if (widget.connectionStatus == null) return Colors.transparent;
    switch (widget.connectionStatus!) {
      case ConnectionStatus.online:
        return BubeiColors.success;
      case ConnectionStatus.offline:
        return BubeiColors.textTertiary;
      case ConnectionStatus.connecting:
        return BubeiColors.warning;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChange);
    _borderAnimationController.dispose();
    _glowAnimationController.dispose();
    _labelAnimationController.dispose();
    _rippleAnimationController.dispose();
    _shakeAnimationController.dispose();
    _iconAnimationController.dispose();
    _bounceAnimationController.dispose();
    _statusAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _borderAnimationController,
        _glowAnimationController,
        _labelAnimationController,
        _rippleAnimationController,
        _shakeAnimationController,
        _iconAnimationController,
        _bounceAnimationController,
        _statusAnimationController,
      ]),
      builder: (context, child) {
        final shakeOffset = _shakeAnimation.value > 0
            ? (1 - _shakeAnimation.value) *
                  (1 - _shakeAnimation.value) *
                  10 *
                  (_shakeAnimation.value > 0.5 ? -1 : 1)
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform.scale(
            scale: _bounceAnimation.value,
            child: GestureDetector(
              onTap: () {
                if (widget.onTap != null) widget.onTap!();
                _focusNode.requestFocus();
              },
              child: _buildGlassContainer(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer() {
    return Container(
      decoration: _buildBoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (BubeiColors.surface).withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 波纹效果
                if (_isFocused)
                  Positioned(
                    right: 12,
                    top: -20,
                    child: _buildRippleEffect(),
                  ),
                // 浮动标签
                _buildFloatingLabel(),
                // 连接状态指示点
                if (widget.connectionStatus != null)
                  _buildConnectionStatusIndicator(),
                // 输入框
                _buildTextField(),
                // CapsLock 提示
                if (_isCapsLockOn && widget.showCapsLockHint && widget.isPassword)
                  _buildCapsLockHint(),
                // 错误提示
                if (_hasError)
                  _buildErrorText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    final glowOpacity = _isFocused ? 0.2 + _glowAnimation.value * 0.2 : 0.0;
    final borderColor = _hasError
        ? BubeiColors.error
        : _isFocused
            ? _focusColor.withOpacity(0.5 + _glowAnimation.value * 0.3)
            : BubeiColors.border.withOpacity(0.5);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      border: Border.all(
        color: borderColor,
        width: _isFocused ? 1.5 : 1,
      ),
      boxShadow: [
        if (_isFocused)
          BoxShadow(
            color: _focusColor.withOpacity(glowOpacity),
            blurRadius: 12 + _glowAnimation.value * 8,
            offset: Offset(0, 4 + _glowAnimation.value * 4),
            spreadRadius: 0,
          ),
        if (_hasError)
          BoxShadow(
            color: BubeiColors.error.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  Widget _buildRippleEffect() {
    return Container(
      width: 40 + _rippleAnimation.value * 80,
      height: 40 + _rippleAnimation.value * 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _focusColor.withOpacity((1 - _rippleAnimation.value) * 0.3),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildFloatingLabel() {
    final labelOffset = _labelAnimationController.value * 28;
    final labelScale = 1 - _labelAnimationController.value * 0.25;

    return Positioned(
      left: widget.prefixIcon != null || _detectedType != InputType.general ? 44 : 16,
      top: 16 - labelOffset,
      child: Transform.translate(
        offset: Offset(0, -labelOffset),
        child: Transform.scale(
          scale: labelScale,
          alignment: Alignment.centerLeft,
          child: Container(
            color: (BubeiColors.surface).withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.label,
              style: TextStyle(
                color: _hasError
                    ? BubeiColors.error
                    : _isFocused
                        ? _focusColor
                        : BubeiColors.textSecondary,
                fontSize: 13 * labelScale,
                fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatusIndicator() {
    final statusColor = _getStatusColor();

    return Positioned(
      top: 12,
      right: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(_statusAnimation.value),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          if (widget.connectionStatus == ConnectionStatus.connecting)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      style: TextStyle(
        color: BubeiColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      onChanged: (value) {
        if (widget.onChanged != null) widget.onChanged!(value);
      },
      onSubmitted: (value) {
        if (widget.onSubmitted != null) widget.onSubmitted!(value);
      },
      decoration: InputDecoration(
        hintText: widget.hintText ?? widget.label,
        hintStyle: TextStyle(
          color: BubeiColors.textTertiary,
          fontSize: 15,
        ),
        prefixIcon: _buildPrefixIcon(),
        suffixIcon: _buildSuffixIcon(),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
      ),
    );
  }

  Widget _buildPrefixIcon() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Icon(
        _getPrefixIcon(),
        key: ValueKey(_getPrefixIcon()),
        color: _isFocused ? _focusColor : BubeiColors.textSecondary,
        size: 18,
      ),
    );
  }

  Widget _buildSuffixIcon() {
    List<Widget> icons = [];

    // 清除按钮
    if (widget.enableClearButton && _hasText && _isFocused) {
      icons.add(
        GestureDetector(
          onTap: _clearText,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.cancel,
              color: BubeiColors.textTertiary,
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
          child: Transform.rotate(
            angle: _iconRotationAnimation.value * 3.14159,
            child: Transform.scale(
              scale: _iconScaleAnimation.value,
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: BubeiColors.textTertiary,
                size: 16,
              ),
            ),
          ),
        ),
      );
    }

    if (icons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons
          .map((e) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: e,
              ))
          .toList(),
    );
  }

  Widget _buildCapsLockHint() {
    return Positioned(
      bottom: -22,
      left: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_capslock,
            size: 10,
            color: BubeiColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            "大写锁定已开启",
            style: TextStyle(
              fontSize: 10,
              color: BubeiColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorText() {
    return Positioned(
      bottom: -22,
      right: 0,
      child: Text(
        widget.errorText ?? "",
        style: TextStyle(
          fontSize: 11,
          color: BubeiColors.error,
        ),
      ),
    );
  }
}

/// 毛玻璃输入框卡片包装器
/// 提供统一的卡片样式和布局
class GlassInputCard extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData? icon;
  final bool isPassword;
  final bool autoDetectType;
  final ConnectionStatus? connectionStatus;
  final String? errorText;
  final Function(String)? onChanged;

  const GlassInputCard({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.icon,
    this.isPassword = false,
    this.autoDetectType = false,
    this.connectionStatus,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassInputField(
          label: label,
          controller: controller,
          hintText: hintText,
          prefixIcon: icon,
          isPassword: isPassword,
          autoDetectType: autoDetectType,
          connectionStatus: connectionStatus,
          errorText: errorText,
          onChanged: onChanged,
        ),
        if (errorText != null)
          SizedBox(height: 24)
        else if (isPassword)
          SizedBox(height: 4)
        else
          SizedBox(height: 4),
      ],
    );
  }
}
