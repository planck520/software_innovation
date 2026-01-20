import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// stitch_login_screen 风格科技按钮组件
/// - 蓝紫渐变
/// - 霓虹发光效果: box-shadow: 0 0 15px rgba(19, 91, 236, 0.4)
/// - 字母间距: 0.2em
class TechButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isOutlined;
  final bool isDanger;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;
  final bool isFullWidth;
  final bool showNeonGlow;

  const TechButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isDanger = false,
    this.icon,
    this.width,
    this.height = 56, // h-14 = 56px
    this.isLoading = false,
    this.isFullWidth = false,
    this.showNeonGlow = true, // 默认显示霓虹发光
  });

  @override
  State<TechButton> createState() => _TechButtonState();
}

class _TechButtonState extends State<TechButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppTokens.durationNormal),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppTokens.curveIOS),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGlowColor() {
    if (widget.isDanger) return AppColors.error.withOpacity(0.4);
    if (widget.isSecondary || widget.isOutlined) return AppColors.primary.withOpacity(0.2);
    // stitch 风格: rgba(19, 91, 236, 0.4)
    return AppColors.primary.withOpacity(0.4);
  }

  List<Color> _getGradientColors(bool isEnabled) {
    if (!isEnabled) return [AppColors.surfaceDim, AppColors.surfaceDim];
    if (widget.isDanger) return [AppColors.error, AppColors.error.withOpacity(0.8)];
    if (widget.isSecondary || widget.isOutlined) {
      return [AppColors.background, AppColors.surfaceDim];
    }
    // stitch 风格: 蓝紫渐变
    return AppColors.primaryGradient;
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) return AppColors.textTertiary;
    if (widget.isDanger) return Colors.white;
    if (widget.isOutlined || widget.isSecondary) return AppColors.primary;
    return Colors.white;
  }

  void _handlePressDown() {
    if (_isPressed || !isEnabled()) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handlePressUp() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  bool isEnabled() => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled();

    return GestureDetector(
      onTapDown: enabled ? (_) => _handlePressDown() : null,
      onTapUp: enabled ? (_) => _handlePressUp() : null,
      onTapCancel: enabled ? _handlePressUp : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: _buildButton(enabled),
          );
        },
      ),
    );
  }

  Widget _buildButton(bool enabled) {
    final gradientColors = _getGradientColors(enabled);
    final textColor = _getTextColor(enabled);

    Widget buttonContent;

    if (widget.isLoading) {
      buttonContent = SizedBox(
        width: widget.height - 24,
        height: widget.height - 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      buttonContent = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 3.6, // stitch 风格: 0.2em ≈ 3.6px (18 * 0.2)
            ),
          ),
          if (widget.icon != null) ...[
            const SizedBox(width: 8),
            Icon(
              widget.icon,
              color: textColor,
              size: 14,
            ),
          ],
        ],
      );
    }

    return Container(
      width: widget.isFullWidth ? double.infinity : widget.width,
      height: widget.height,
      decoration: _buildDecoration(enabled, gradientColors),
      child: Center(child: buttonContent),
    );
  }

  BoxDecoration _buildDecoration(bool enabled, List<Color> gradientColors) {
    // Outlined 样式
    if (widget.isOutlined) {
      return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: enabled
              ? (widget.isDanger ? AppColors.error : AppColors.primary).withOpacity(0.3)
              : AppColors.textTertiary.withOpacity(0.3),
          width: 1,
        ),
      );
    }

    // 渐变按钮样式 (stitch 风格)
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      // stitch 风格霓虹发光: box-shadow: 0 0 15px rgba(19, 91, 236, 0.4)
      boxShadow: enabled && widget.showNeonGlow
          ? [
              BoxShadow(
                color: _getGlowColor(),
                blurRadius: 15,
                spreadRadius: 0,
              ),
            ]
          : null,
    );
  }
}

/// 小型科技按钮
class TechButtonSmall extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isDanger;
  final IconData? icon;

  const TechButtonSmall({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.isDanger = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TechButton(
      text: text,
      onPressed: onPressed,
      isSecondary: isSecondary,
      isDanger: isDanger,
      icon: icon,
      height: 40,
    );
  }
}

/// stitch 风格图标按钮
class TechIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool showNeonGlow;

  const TechIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 30.8,
    this.tooltip,
    this.showNeonGlow = false,
  });

  @override
  State<TechIconButton> createState() => _TechIconButtonState();
}

class _TechIconButtonState extends State<TechIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppTokens.durationFast),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppTokens.curveIOS),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = widget.color ?? AppColors.primary;
    final bgColor = widget.backgroundColor ?? color.withOpacity(0.1);

    Widget button = GestureDetector(
      onTapDown: enabled ? (_) => _handlePressDown() : null,
      onTapUp: enabled ? (_) => _handlePressUp() : null,
      onTapCancel: enabled ? _handlePressUp : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: enabled ? bgColor : AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                boxShadow: widget.showNeonGlow && enabled
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: enabled ? color : AppColors.textTertiary,
                size: widget.size * 0.45,
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }

  void _handlePressDown() {
    if (_isPressed) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handlePressUp() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }
}

/// 圆形脉冲按钮（用于麦克风等）
class PulseMicButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final bool isActive;
  final double size;
  final IconData icon;

  const PulseMicButton({
    super.key,
    this.onPressed,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.isActive = false,
    this.size = 39.2,
    this.icon = Icons.mic,
  });

  @override
  State<PulseMicButton> createState() => _PulseMicButtonState();
}

class _PulseMicButtonState extends State<PulseMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.isActive) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(PulseMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPressStart: widget.onLongPressStart != null
          ? (_) => widget.onLongPressStart!()
          : null,
      onLongPressEnd: widget.onLongPressEnd != null
          ? (_) => widget.onLongPressEnd!()
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 脉冲动画环
          if (widget.isActive)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: widget.size + 14,
                  height: widget.size + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.2 * (1 - _pulseController.value)),
                  ),
                );
              },
            ),
          // 外圈边框
          Container(
            width: widget.size + 8,
            height: widget.size + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // 主按钮
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: widget.size * 0.45,
            ),
          ),
        ],
      ),
    );
  }
}
