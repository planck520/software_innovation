import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 霓虹边框卡片组件
/// - 渐变边框效果
/// - 发光脉冲动画
/// - 毛玻璃背景
class NeonBorderCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final double glowIntensity;
  final bool showPulse;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final bool isEnabled;

  const NeonBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppTokens.radiusLg,
    this.borderColor,
    this.glowIntensity = 0.4,
    this.showPulse = false,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
    this.isEnabled = true,
  });

  @override
  State<NeonBorderCard> createState() => _NeonBorderCardState();
}

class _NeonBorderCardState extends State<NeonBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: AppTokens.durationPulse),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showPulse && widget.isEnabled) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonBorderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse != oldWidget.showPulse ||
        widget.isEnabled != oldWidget.isEnabled) {
      if (widget.showPulse && widget.isEnabled) {
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

  Color get _borderColor => widget.borderColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null && widget.isEnabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null && widget.isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null && widget.isEnabled
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height,
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            child: _buildCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    final glowOpacity = widget.showPulse
        ? _pulseAnimation.value * widget.glowIntensity
        : widget.glowIntensity;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.isEnabled
            ? [
                BoxShadow(
                  color: _borderColor.withOpacity(glowOpacity),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(AppTokens.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isEnabled
                    ? [
                        _borderColor.withOpacity(0.1),
                        _borderColor.withOpacity(0.05),
                      ]
                    : [
                        AppColors.surfaceDim,
                        AppColors.surfaceDim,
                      ],
              ),
              border: Border.all(
                color: widget.isEnabled
                    ? _borderColor.withOpacity(
                        widget.showPulse
                            ? 0.3 + _pulseAnimation.value * 0.4
                            : 0.3,
                      )
                    : AppColors.border.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Opacity(
              opacity: widget.isEnabled ? 1.0 : 0.5,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 渐变边框卡片
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final List<Color> gradientColors;
  final double borderWidth;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppTokens.radiusLg,
    this.gradientColors = AppColors.neonGradient,
    this.borderWidth = 2,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          ),
          padding: padding ?? const EdgeInsets.all(AppTokens.space4),
          child: child,
        ),
      ),
    );
  }
}

/// 赛博风格发光卡片（带扫描线效果）
class CyberGlowCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color glowColor;
  final bool showScanline;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const CyberGlowCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppTokens.radiusLg,
    this.glowColor = AppColors.primary,
    this.showScanline = false,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  State<CyberGlowCard> createState() => _CyberGlowCardState();
}

class _CyberGlowCardState extends State<CyberGlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanlineController;
  late Animation<double> _scanlineAnimation;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanlineAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(
        parent: _scanlineController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.glowColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              // 扫描线效果
              if (widget.showScanline)
                AnimatedBuilder(
                  animation: _scanlineAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanlineAnimation.value *
                          (widget.height ?? 200),
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              widget.glowColor.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              // 内容
              Padding(
                padding: widget.padding ??
                    const EdgeInsets.all(AppTokens.space4),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 选中态发光卡片
class SelectedGlowCard extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color selectedColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const SelectedGlowCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.padding,
    this.borderRadius = AppTokens.radiusLg,
    this.selectedColor = AppColors.primary,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<SelectedGlowCard> createState() => _SelectedGlowCardState();
}

class _SelectedGlowCardState extends State<SelectedGlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _selectionController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(SelectedGlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final glowOpacity = _glowAnimation.value * 0.5;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.isSelected
                    ? widget.selectedColor
                    : AppColors.border.withOpacity(0.3),
                width: 1 + _glowAnimation.value,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.selectedColor.withOpacity(glowOpacity),
                        blurRadius: 12 + _glowAnimation.value * 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: widget.padding ??
                  const EdgeInsets.all(AppTokens.space4),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
