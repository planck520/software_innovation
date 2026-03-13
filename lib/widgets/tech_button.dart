import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/login_theme.dart';

/// 磨砂玻璃按钮样式
enum GlassButtonStyle {
  checkIn,   // 签到按钮 - 绿色主题
  interview, // 面试房间 - 蓝紫渐变
  custom,    // 定制面试 - 青色渐变
}

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

  Color _getBackgroundColor(bool isEnabled) {
    if (!isEnabled) return LoginTheme.cardBackground;
    if (widget.isDanger) return AppColors.error;
    if (widget.isSecondary || widget.isOutlined) {
      return LoginTheme.buttonBackground;
    }
    // 黑白简约风格：黑色背景
    return LoginTheme.buttonBackground;
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) return LoginTheme.textSecondary;
    if (widget.isDanger) return Colors.white;
    if (widget.isOutlined || widget.isSecondary) return LoginTheme.textPrimary;
    return LoginTheme.textPrimary;
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
      decoration: _buildDecoration(enabled),
      child: Center(child: buttonContent),
    );
  }

  BoxDecoration _buildDecoration(bool enabled) {
    // Outlined 样式
    if (widget.isOutlined) {
      return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: enabled
              ? (widget.isDanger ? AppColors.error : LoginTheme.textPrimary).withOpacity(0.3)
              : LoginTheme.textSecondary.withOpacity(0.3),
          width: 1,
        ),
      );
    }

    // 黑白简约风格：纯色背景，无渐变，无霓虹发光
    return BoxDecoration(
      color: _getBackgroundColor(enabled),
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      border: Border.all(color: LoginTheme.cardBorder),
      // 简单的投影效果
      boxShadow: enabled
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
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

/// 不背单词风格按钮
class BubeiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isOutlined;
  final bool isDanger;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isFullWidth;

  const BubeiButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isDanger = false,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;

    if (isDanger) {
      backgroundColor = BubeiColors.error;
      foregroundColor = Colors.white;
    } else if (isOutlined) {
      backgroundColor = Colors.transparent;
      foregroundColor = LoginTheme.textPrimary;
    } else if (isSecondary) {
      backgroundColor = LoginTheme.cardBackground;
      foregroundColor = LoginTheme.textPrimary;
    } else {
      backgroundColor = LoginTheme.buttonBackground;
      foregroundColor = LoginTheme.textPrimary;
    }

    if (!enabled) {
      backgroundColor = LoginTheme.cardBackground;
      foregroundColor = LoginTheme.textSecondary;
    }

    Widget buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: foregroundColor, size: 18),
          ],
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: LoginTheme.cardBackground,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: LoginTheme.cardBorder),
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}

// ==================== 科技进化风磨砂玻璃按钮 ====================

/// 磨砂玻璃按钮 - 科技进化风
/// - BackdropFilter 模糊效果 (sigmaX: 10, sigmaY: 10)
/// - 半透明背景 (40%透明度)
/// - 渐变边框 (动态流光效果)
/// - 图标动画 (脉冲/旋转/播放)
class FrostedGlassButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final GlassButtonStyle style;
  final bool showArrow;

  const FrostedGlassButton({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.style = GlassButtonStyle.interview,
    this.showArrow = true,
  });

  @override
  State<FrostedGlassButton> createState() => _FrostedGlassButtonState();
}

class _FrostedGlassButtonState extends State<FrostedGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _glassColor {
    // 根据按钮类型返回不同颜色
    switch (widget.style) {
      case GlassButtonStyle.checkIn:
        return TechEvolutionColors.glassGreenDim;  // 绿色 40%
      case GlassButtonStyle.interview:
        return TechEvolutionColors.glassBlue;       // 蓝紫色 40%
      case GlassButtonStyle.custom:
        return TechEvolutionColors.glassCyan;       // 青色 40%
    }
  }

  Color get _iconColor {
    // 图标使用白色
    return Colors.white.withOpacity(0.95);
  }

  void _handlePressDown() {
    if (_isPressed || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handlePressUp() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _handlePressDown() : null,
      onTapUp: widget.onTap != null ? (_) => _handlePressUp() : null,
      onTapCancel: widget.onTap != null ? _handlePressUp : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.97 : 1.0,
            child: _buildButton(),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    // 获取图标对应的强调色（用于图标颜色点缀）
    Color accentColor;
    switch (widget.style) {
      case GlassButtonStyle.checkIn:
        accentColor = LoginTheme.accentGreen;
        break;
      case GlassButtonStyle.interview:
        accentColor = LoginTheme.accentBlue;
        break;
      case GlassButtonStyle.custom:
        accentColor = LoginTheme.accentCyan;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            // 黑白简约风格：深灰卡片背景
            color: LoginTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LoginTheme.cardBorder),
            // 简单的投影效果
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              _buildIcon(accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: LoginTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.showArrow) ...[
                Icon(
                  Icons.arrow_forward_ios,
                  color: LoginTheme.textSecondary,
                  size: 12,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color accentColor) {
    // 静态图标 - 固定尺寸容器确保居中
    return SizedBox(
      width: 32,
      height: 32,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: accentColor, size: 20),
        ),
      ),
    );
  }
}

/// 脉冲呼吸图标 - 签到按钮
class _PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _PulseIcon({required this.icon, required this.color, required this.bgColor});

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.bgColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
        );
      },
    );
  }
}

/// 播放波纹图标 - 面试房间按钮
class _PlayRippleIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _PlayRippleIcon({required this.icon, required this.color, required this.bgColor});

  @override
  State<_PlayRippleIcon> createState() => _PlayRippleIconState();
}

class _PlayRippleIconState extends State<_PlayRippleIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 第一个波纹圆环
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              final progress = _rippleController.value;
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.bgColor.withOpacity((1 - progress) * 0.3),
                    width: 1,
                  ),
                ),
              );
            },
          ),
          // 第二个波纹圆环 (错开相位)
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              final progress = (_rippleController.value + 0.5) % 1.0;
              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.bgColor.withOpacity((1 - progress) * 0.2),
                    width: 1,
                  ),
                ),
              );
            },
          ),
          // 中心图标
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.bgColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 16),
          ),
        ],
      ),
    );
  }
}

/// 旋转齿轮图标 - 定制面试按钮
class _RotatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _RotatingIcon({required this.icon, required this.color, required this.bgColor});

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.bgColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 18),
          ),
        );
      },
    );
  }
}
