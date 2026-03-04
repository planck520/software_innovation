import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// stitch_login_screen 风格赛博网格背景
/// 模拟 CSS:
/// ```css
/// .cyber-grid {
///   background-image:
///     linear-gradient(rgba(19, 91, 236, 0.05) 1px, transparent 1px),
///     linear-gradient(90deg, rgba(19, 91, 236, 0.05) 1px, transparent 1px);
///   background-size: 20px 20px;
/// }
/// ```
class CyberGrid extends StatelessWidget {
  final double gridSize;
  final Color? gridColor;
  final double opacity;

  const CyberGrid({
    super.key,
    this.gridSize = AppTokens.cyberGridSize,
    this.gridColor,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CyberGridPainter(
        gridSize: gridSize,
        gridColor: (gridColor ?? AppColors.primary).withOpacity(opacity),
      ),
      size: Size.infinite,
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double gridSize;
  final Color gridColor;

  _CyberGridPainter({
    required this.gridSize,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // 垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize || oldDelegate.gridColor != gridColor;
  }
}

/// 模糊装饰球背景
/// 模拟 stitch 的固定位置大型模糊渐变圆形
class BlurBallDecoration extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;
  final double blur;

  const BlurBallDecoration({
    super.key,
    required this.alignment,
    this.size = 0.4,
    required this.color,
    this.blur = 120,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final ballSize = screenSize.width * size;

    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(
              alignment.x < 0 ? -ballSize * 0.3 : (alignment.x > 0 ? ballSize * 0.3 : 0),
              alignment.y < 0 ? -ballSize * 0.3 : (alignment.y > 0 ? ballSize * 0.3 : 0),
            ),
            child: Container(
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: blur,
                    spreadRadius: ballSize * 0.2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 完整的 stitch 风格赛博背景
/// 包含：网格 + 模糊装饰球
class CyberBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final bool showBlurBalls;
  final Color? backgroundColor;

  const CyberBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.showBlurBalls = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.background,
      child: Stack(
        children: [
          // 网格背景
          if (showGrid)
            const Positioned.fill(
              child: CyberGrid(),
            ),

          // 左上模糊球 (蓝色)
          if (showBlurBalls)
            const BlurBallDecoration(
              alignment: Alignment.topLeft,
              size: 0.4,
              color: AppColors.primary,
              blur: 120,
            ),

          // 右下模糊球 (紫色)
          if (showBlurBalls)
            const BlurBallDecoration(
              alignment: Alignment.bottomRight,
              size: 0.5,
              color: AppColors.cyberPurple,
              blur: 150,
            ),

          // 内容
          child,
        ],
      ),
    );
  }
}

/// 深色赛博背景 (用于面试房间等)
class DarkCyberBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;

  const DarkCyberBackground({
    super.key,
    required this.child,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF00FF88), // 顶部绿色，可自定义
            Color(0xFF000000), // 底部黑色
          ],
        ),
      ),
      child: Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              child: CyberGrid(
                gridColor: AppColors.cyberBlue,
                opacity: 0.03,
              ),
            ),
          child,
        ],
      ),
    );
  }
}
