import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 赛博风格加载指示器
/// - 双环旋转动画（外环顺时针，内环逆时针）
/// - 脉冲发光效果
class CyberLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const CyberLoadingIndicator({
    super.key,
    this.size = 48,
    this.color = AppColors.primary,
    this.strokeWidth = 3,
  });

  @override
  State<CyberLoadingIndicator> createState() => _CyberLoadingIndicatorState();
}

class _CyberLoadingIndicatorState extends State<CyberLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _outerRingAnimation;
  late Animation<double> _innerRingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppTokens.durationPulse),
      vsync: this,
    )..repeat();

    // 外环：顺时针旋转
    _outerRingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // 内环：逆时针旋转（速度是外环的1.5倍）
    _innerRingAnimation = Tween<double>(begin: 0, end: -1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // 脉冲发光效果
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 外环
              Transform.rotate(
                angle: _outerRingAnimation.value * 2 * 3.14159,
                child: _buildRing(
                  size: widget.size,
                  strokeWidth: widget.strokeWidth,
                  color: widget.color,
                  progress: 0.7,
                      glowOpacity: _pulseAnimation.value,
                ),
              ),
              // 内环
              Transform.rotate(
                angle: _innerRingAnimation.value * 2 * 3.14159,
                child: _buildRing(
                  size: widget.size * 0.65,
                  strokeWidth: widget.strokeWidth * 0.8,
                  color: AppColors.cyberCyan,
                  progress: 0.5,
                  glowOpacity: _pulseAnimation.value * 0.7,
                ),
              ),
              // 中心点
              Container(
                width: widget.size * 0.15,
                height: widget.size * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(_pulseAnimation.value),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRing({
    required double size,
    required double strokeWidth,
    required Color color,
    required double progress,
    required double glowOpacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(glowOpacity * 0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _RingPainter(
          color: color,
          strokeWidth: strokeWidth,
          progress: progress,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;

  _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景环
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 进度环
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14159 / 2; // 从顶部开始
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 小型赛博加载指示器
class CyberLoadingIndicatorSmall extends StatelessWidget {
  final double size;
  final Color color;

  const CyberLoadingIndicatorSmall({
    super.key,
    this.size = 24,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CyberLoadingIndicator(
      size: size,
      color: color,
      strokeWidth: 2,
    );
  }
}

/// 赛博风格点状加载指示器
class CyberDotsIndicator extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final Color color;

  const CyberDotsIndicator({
    super.key,
    this.dotCount = 3,
    this.dotSize = 8,
    this.color = AppColors.primary,
  }) : assert(dotCount >= 2 && dotCount <= 5);

  @override
  State<CyberDotsIndicator> createState() => _CyberDotsIndicatorState();
}

class _CyberDotsIndicatorState extends State<CyberDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return _buildAnimatedDot(index);
      }),
    );
  }

  Widget _buildAnimatedDot(int index) {
    final delay = index * 0.2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animValue = ((_controller.value + delay) % 1.0);

        // 计算缩放和透明度
        double scale;
        double opacity;

        if (animValue < 0.3) {
          scale = 1.0 + animValue * 0.5;
          opacity = 0.5 + animValue * 1.5;
        } else if (animValue < 0.6) {
          scale = 1.15;
          opacity = 1.0;
        } else {
          final t = (animValue - 0.6) / 0.4;
          scale = 1.15 - t * 0.15;
          opacity = 1.0 - t * 0.5;
        }

        return Container(
          width: widget.dotSize,
          height: widget.dotSize,
          margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.3),
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(opacity),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(opacity * 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
