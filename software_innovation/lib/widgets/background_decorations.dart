import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../main.dart' show isDarkBackground;

/// stitch_login_screen 风格背景装饰组件
class TechBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final bool showGradientOrbs;
  final List<Color>? gradientColors;
  final double gridSize;

  const TechBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.showGradientOrbs = true,
    this.gradientColors,
    this.gridSize = 20, // stitch 风格: 20px
  });

  @override
  Widget build(BuildContext context) {
    // 根据全局设置选择背景色
    final backgroundColor = isDarkBackground
        ? const Color(0xFF101622)  // 深色背景
        : AppColors.background;     // 浅色背景

    final gridColor = isDarkBackground
        ? AppColors.primary.withOpacity(0.08)
        : AppColors.primary.withOpacity(0.05);

    return Stack(
      children: [
        // 基础背景色
        Container(color: backgroundColor),
        // 网格装饰
        if (showGrid)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CyberGridPainter(
                  color: gridColor,
                  gridSize: gridSize,
                ),
              ),
            ),
          ),
        // 渐变光球
        if (showGradientOrbs) ...[
          // 左上蓝色模糊球
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: _BlurOrb(
              size: MediaQuery.of(context).size.width * 0.4,
              color: AppColors.primary,
              blur: 120,
            ),
          ),
          // 右下紫色模糊球
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: _BlurOrb(
              size: MediaQuery.of(context).size.width * 0.5,
              color: AppColors.cyberPurple,
              blur: 150,
            ),
          ),
        ],
        // 内容
        child,
      ],
    );
  }
}

/// 模糊球组件
class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const _BlurOrb({
    required this.size,
    required this.color,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: blur,
              spreadRadius: size * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}

/// 赛博网格绘制器 (20px 间隔)
class _CyberGridPainter extends CustomPainter {
  final Color color;
  final double gridSize;

  _CyberGridPainter({
    required this.color,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // 垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 动态粒子背景
class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color? particleColor;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.background),
        ...List.generate(widget.particleCount, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = (_controller.value + index / widget.particleCount) % 1.0;
              return Positioned(
                left: _random.nextDouble() * MediaQuery.of(context).size.width,
                top: (offset * MediaQuery.of(context).size.height) % MediaQuery.of(context).size.height,
                child: Container(
                  width: _random.nextDouble() * 4 + 2,
                  height: _random.nextDouble() * 4 + 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (widget.particleColor ?? AppColors.primary).withOpacity(0.2),
                  ),
                ),
              );
            },
          );
        }),
        widget.child,
      ],
    );
  }
}

/// 扫描线动画装饰
class ScanlineOverlay extends StatefulWidget {
  final Widget child;
  final Color? lineColor;
  final double lineThickness;
  final Duration duration;

  const ScanlineOverlay({
    super.key,
    required this.child,
    this.lineColor,
    this.lineThickness = 2,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ScanlineOverlay> createState() => _ScanlineOverlayState();
}

class _ScanlineOverlayState extends State<ScanlineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -0.1, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              top: _animation.value * screenSize.height,
              left: 0,
              right: 0,
              child: Container(
                height: widget.lineThickness,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (widget.lineColor ?? AppColors.primary).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 毛玻璃覆盖层
class GlassOverlay extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? overlayColor;

  const GlassOverlay({
    super.key,
    required this.child,
    this.blur = 12, // stitch 风格: blur(12px)
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                color: (overlayColor ?? Colors.white).withOpacity(0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 渐变分隔线
class GradientDivider extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;

  const GradientDivider({
    super.key,
    this.height = 1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.border.withOpacity(0.5),
            AppColors.border.withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const [0, 0.2, 0.8, 1],
        ),
      ),
    );
  }
}

/// 霓虹边框装饰
class NeonBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final double glowIntensity;

  const NeonBorder({
    super.key,
    required this.child,
    this.color = AppColors.primary,
    this.borderRadius = AppTokens.radiusMd,
    this.glowIntensity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(glowIntensity),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}
