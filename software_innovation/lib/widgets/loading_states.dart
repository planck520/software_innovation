import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 科技感加载指示器
class TechLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const TechLoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 外圆环
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // 背景圆环
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceDim.withOpacity(0.3),
                ),
              ),
              // 旋转圆环
              Center(
                child: SizedBox(
                  width: size * 0.8,
                  height: size * 0.8,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              // 内圆点
              Center(
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}

/// 脉冲加载指示器
class PulseLoadingIndicator extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final double minOpacity;
  final double maxOpacity;

  const PulseLoadingIndicator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.9,
    this.maxScale = 1.0,
    this.minOpacity = 0.5,
    this.maxOpacity = 1.0,
  });

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: widget.minOpacity, end: widget.maxOpacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 波浪加载指示器
class WaveLoadingIndicator extends StatefulWidget {
  final int waveCount;
  final double waveSize;
  final Color? color;

  const WaveLoadingIndicator({
    super.key,
    this.waveCount = 3,
    this.waveSize = 12,
    this.color,
  });

  @override
  State<WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
}

class _WaveLoadingIndicatorState extends State<WaveLoadingIndicator>
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
    final color = widget.color ?? AppColors.primary;

    return SizedBox(
      height: widget.waveSize * 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.waveCount, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final animation = Tween<double>(begin: 0.2, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(delay, delay + 0.6, curve: Curves.easeInOut),
                ),
              );

              return Container(
                width: widget.waveSize,
                height: widget.waveSize * animation.value,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.waveSize / 2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 旋转加载指示器（带渐变）
class GradientLoadingIndicator extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final List<Color>? colors;

  const GradientLoadingIndicator({
    super.key,
    this.size = 40,
    this.strokeWidth = 4,
    this.colors,
  });

  @override
  State<GradientLoadingIndicator> createState() => _GradientLoadingIndicatorState();
}

class _GradientLoadingIndicatorState extends State<GradientLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final colors = widget.colors ?? AppColors.techGradient;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _GradientLoaderPainter(
                colors: colors,
                strokeWidth: widget.strokeWidth,
                progress: _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GradientLoaderPainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;
  final double progress;

  _GradientLoaderPainter({
    required this.colors,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final gradient = SweepGradient(
      colors: colors,
      startAngle: 0,
      endAngle: 2 * 3.14159,
      transform: const GradientRotation(3.14159 / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, 0, 2 * 3.14159 * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 骨架屏加载组件
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final baseColor = widget.baseColor ?? AppColors.surfaceDim;
    final highlightColor = widget.highlightColor ?? AppColors.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
