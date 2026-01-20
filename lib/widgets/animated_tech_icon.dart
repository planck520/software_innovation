import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 科技感动画图标组件
class AnimatedTechIcon extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final bool isActive;
  final bool isRotating;
  final bool isPulsing;

  const AnimatedTechIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 16.8,
    this.isActive = false,
    this.isRotating = false,
    this.isPulsing = false,
  });

  @override
  State<AnimatedTechIcon> createState() => _AnimatedTechIconState();
}

class _AnimatedTechIconState extends State<AnimatedTechIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isActive || widget.isRotating || widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTechIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldBeActive = widget.isActive || widget.isRotating || widget.isPulsing;
    final wasActive = oldWidget.isActive || oldWidget.isRotating || oldWidget.isPulsing;

    if (shouldBeActive != wasActive) {
      if (shouldBeActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.isPulsing ? _scaleAnimation.value : 1.0;
        final angle = widget.isRotating ? _controller.value * 2 * math.pi : _rotateAnimation.value;

        return Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size * 1.5,
              height: widget.size * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.05),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                color: color,
                size: widget.size * 0.6,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 发光图标按钮
class GlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;
  final bool isActive;

  const GlowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 39.2,
    this.tooltip,
    this.isActive = false,
  });

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final enabled = widget.onPressed != null;

    Widget button = GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(widget.isActive ? _glowAnimation.value : 0.15),
                  color.withOpacity(0.05),
                ],
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Transform.scale(
              scale: _isPressed ? 0.95 : 1.0,
              child: Icon(
                widget.icon,
                color: enabled ? color : AppColors.textTertiary,
                size: widget.size * 0.4,
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
}

/// 科技状态图标
class TechStatusIcon extends StatefulWidget {
  final bool isActive;
  final String? activeLabel;
  final String? inactiveLabel;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final Color? activeColor;
  final Color? inactiveColor;

  const TechStatusIcon({
    super.key,
    required this.isActive,
    this.activeLabel,
    this.inactiveLabel,
    this.activeIcon,
    this.inactiveIcon,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<TechStatusIcon> createState() => _TechStatusIconState();
}

class _TechStatusIconState extends State<TechStatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTokens.curveSpring),
    );

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(TechStatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.success;
    final inactiveColor = widget.inactiveColor ?? AppColors.surfaceDim;
    final icon = widget.isActive
        ? (widget.activeIcon ?? Icons.check_circle)
        : (widget.inactiveIcon ?? Icons.circle);
    final color = widget.isActive ? activeColor : inactiveColor;
    final label = widget.isActive
        ? (widget.activeLabel ?? 'Active')
        : (widget.inactiveLabel ?? 'Inactive');

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 11.2 * _animation.value + 5.6,
            ),
            if (label != null) ...[
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                  letterSpacing: widget.isActive ? 0.2 : 0,
                ),
                child: Text(label!),
              ),
            ],
          ],
        );
      },
    );
  }
}
