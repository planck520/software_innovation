import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 数字人头像组件
/// 支持网络图片和自定义渐变头像
class DigitalAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final Color accentColor;
  final bool showGlow;
  final bool isSelected;

  const DigitalAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.accentColor = AppColors.primary,
    this.showGlow = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: isSelected ? accentColor : accentColor.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(isSelected ? 0.4 : 0.2),
                  blurRadius: isSelected ? 12 : 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackAvatar();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingAvatar();
                },
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.3),
            accentColor.withOpacity(0.1),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _DigitalAvatarPainter(
          name: name,
          color: accentColor,
        ),
        size: Size(size, size),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      ),
    );
  }
}

/// 自定义数字人头像绘制器
/// 绘制赛博风格的抽象头像
class _DigitalAvatarPainter extends CustomPainter {
  final String name;
  final Color color;

  _DigitalAvatarPainter({
    required this.name,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制头部轮廓
    final headPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 头部圆形
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.1),
      radius * 0.35,
      headPaint,
    );

    // 身体/肩膀轮廓
    final bodyPath = Path();
    bodyPath.moveTo(center.dx - radius * 0.4, size.height);
    bodyPath.quadraticBezierTo(
      center.dx - radius * 0.3,
      center.dy + radius * 0.4,
      center.dx,
      center.dy + radius * 0.3,
    );
    bodyPath.quadraticBezierTo(
      center.dx + radius * 0.3,
      center.dy + radius * 0.4,
      center.dx + radius * 0.4,
      size.height,
    );
    canvas.drawPath(bodyPath, headPaint);

    // 绘制装饰性电路线
    final circuitPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 水平线
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy),
      Offset(center.dx - radius * 0.2, center.dy),
      circuitPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.2, center.dy),
      Offset(center.dx + radius * 0.6, center.dy),
      circuitPaint,
    );

    // 绘制眼睛 (发光点)
    final eyePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - radius * 0.12, center.dy - radius * 0.15),
      radius * 0.06,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.12, center.dy - radius * 0.15),
      radius * 0.06,
      eyePaint,
    );

    // 绘制名字首字母
    final textPainter = TextPainter(
      text: TextSpan(
        text: name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: size.width * 0.25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius * 0.35,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _DigitalAvatarPainter oldDelegate) {
    return oldDelegate.name != name || oldDelegate.color != color;
  }
}

/// 带动画效果的数字人头像
class AnimatedDigitalAvatar extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final Color accentColor;
  final bool isSelected;

  const AnimatedDigitalAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.accentColor = AppColors.primary,
    this.isSelected = false,
  });

  @override
  State<AnimatedDigitalAvatar> createState() => _AnimatedDigitalAvatarState();
}

class _AnimatedDigitalAvatarState extends State<AnimatedDigitalAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedDigitalAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.stop();
      _controller.reset();
    }
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
          scale: widget.isSelected ? _pulseAnimation.value : 1.0,
          child: DigitalAvatar(
            name: widget.name,
            imageUrl: widget.imageUrl,
            size: widget.size,
            accentColor: widget.accentColor,
            showGlow: true,
            isSelected: widget.isSelected,
          ),
        );
      },
    );
  }
}
