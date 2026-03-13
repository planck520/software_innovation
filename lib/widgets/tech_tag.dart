import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';

/// 科技风格标签组件 - 包含霓虹标签、难度徽章、状态徽章

/// 霓虹胶囊标签 - 带发光效果
class TechTag extends StatefulWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showGlow;

  const TechTag({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.showGlow = false,
  });

  @override
  State<TechTag> createState() => _TechTagState();
}

class _TechTagState extends State<TechTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showGlow || widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TechTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.showGlow || widget.isSelected) !=
        (oldWidget.showGlow || oldWidget.isSelected)) {
      if (widget.showGlow || widget.isSelected) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _tagColor => widget.color ?? BubeiColors.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            child: _buildTag(),
          );
        },
      ),
    );
  }

  Widget _buildTag() {
    final glowOpacity =
        (widget.showGlow || widget.isSelected) ? _pulseAnimation.value : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space1,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _tagColor.withOpacity(0.2),
            _tagColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        border: Border.all(
          color: _tagColor.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: glowOpacity > 0
            ? [
                BoxShadow(
                  color: _tagColor.withOpacity(glowOpacity * 0.6),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 12,
              color: _tagColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 11,
              color: _tagColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// 难度徽章 - 带颜色区分
class DifficultyBadge extends StatelessWidget {
  final String difficulty;
  final bool showIcon;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showIcon = true,
  });

  Color get _badgeColor {
    switch (difficulty.toLowerCase()) {
      case '简单':
      case '基础':
      case 'easy':
        return BubeiColors.success;
      case '中等':
      case 'medium':
        return BubeiColors.warning;
      case '困难':
      case 'hard':
        return BubeiColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData get _badgeIcon {
    switch (difficulty.toLowerCase()) {
      case '简单':
      case '基础':
      case 'easy':
        return Icons.check_circle;
      case '中等':
      case 'medium':
        return Icons.remove_circle;
      case '困难':
      case 'hard':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_badgeIcon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            difficulty,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 状态徽章 - 动态彩色效果
class StatusBadge extends StatefulWidget {
  final String label;
  final StatusType status;
  final VoidCallback? onTap;

  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.onTap,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case StatusType.success:
        return BubeiColors.success;
      case StatusType.error:
        return BubeiColors.error;
      case StatusType.warning:
        return BubeiColors.warning;
      case StatusType.info:
        return BubeiColors.info;
      case StatusType.processing:
        return BubeiColors.primary;
    }
  }

  IconData get _statusIcon {
    switch (widget.status) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.error:
        return Icons.cancel;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.info:
        return Icons.info;
      case StatusType.processing:
        return Icons.sync;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value * (_isPressed ? 0.95 : 1.0),
            child: _buildBadge(),
          );
        },
      ),
    );
  }

  Widget _buildBadge() {
    final color = _statusColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(_animation.value * 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == StatusType.processing)
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: color,
              ),
            )
          else
            Icon(_statusIcon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// 状态类型枚举
enum StatusType {
  success,
  error,
  warning,
  info,
  processing,
}

/// 科技感胶囊按钮
class TechCapsuleButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;

  const TechCapsuleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<TechCapsuleButton> createState() => _TechCapsuleButtonState();
}

class _TechCapsuleButtonState extends State<TechCapsuleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? BubeiColors.primary;
    final txtColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            }
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) {
              _controller.reverse();
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () {
              _controller.reverse();
              setState(() => _isPressed = false);
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(bgColor, txtColor),
          );
        },
      ),
    );
  }

  Widget _buildButton(Color bgColor, Color txtColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space4,
        vertical: AppTokens.space2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isLoading) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: txtColor,
              ),
            ),
            const SizedBox(width: 8),
          ] else if (widget.icon != null) ...[
            Icon(widget.icon, size: 14, color: txtColor),
            const SizedBox(width: 6),
          ],
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: txtColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
