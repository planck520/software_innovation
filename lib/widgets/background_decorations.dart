import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';
import '../config/app_config.dart' show isDarkBackground;

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

// ==================== 代码矩阵背景（登录页） ====================

/// 代码矩阵背景绘制器 - 黑客帝国风格的二进制代码流
class TechCodeBackgroundPainter extends CustomPainter {
  final double animationValue;

  TechCodeBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 深蓝色渐变背景
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0A0E1A), // 深蓝黑
        const Color(0xFF101622), // 深蓝灰
      ],
    );
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()..shader = backgroundGradient.createShader(backgroundRect);
    canvas.drawRect(backgroundRect, backgroundPaint);

    // 代码流颜色（绿色矩阵风格）
    final codeColor = const Color(0xFF00FF41).withOpacity(0.3);
    final gridColor = const Color(0xFF00FF41).withOpacity(0.1);

    // 绘制网格线
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    const gridSize = 30.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 绘制二进制代码流 (0/1)
    final textStyle = TextStyle(
      color: codeColor,
      fontSize: 10,
      fontFamily: 'Courier',
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final random = math.Random(42); // 固定种子保证一致性
    final columns = (size.width / gridSize).floor();

    for (int col = 0; col < columns; col++) {
      // 每列代码流的偏移（模拟流动）
      final offset = (animationValue * 100 + col * 13) % (size.height / gridSize + 20);

      for (int row = -5; row < size.height / gridSize + 5; row++) {
        final y = (row - offset) * gridSize;
        if (y < -20 || y > size.height + 20) continue;

        // 随机生成0或1
        final code = random.nextDouble() > 0.5 ? '1' : '0';

        // 根据距离顶部的位置调整透明度
        final distanceFromTop = y.abs();
        final alpha = (1.0 - (distanceFromTop / size.height) * 0.8).clamp(0.1, 0.5);

        textPainter.text = TextSpan(
          text: code,
          style: textStyle.copyWith(color: codeColor.withOpacity(alpha)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(col * gridSize + gridSize / 2 - 3, y),
        );
      }
    }

    // 绘制发光节点
    final nodePaint = Paint()
      ..color = const Color(0xFF00FF41).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = const Color(0xFF00FF41).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (int i = 0; i < 8; i++) {
      final x = (i * 137.5 + animationValue * 50) % size.width;
      final y = (i * 89.3 + animationValue * 30) % size.height;

      // 绘制光晕
      canvas.drawCircle(Offset(x, y), 6, glowPaint);
      // 绘制节点
      canvas.drawCircle(Offset(x, y), 2, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 代码矩阵背景组件（带动画）
class TechCodeBackground extends StatefulWidget {
  final Widget child;

  const TechCodeBackground({
    super.key,
    required this.child,
  });

  @override
  State<TechCodeBackground> createState() => _TechCodeBackgroundState();
}

class _TechCodeBackgroundState extends State<TechCodeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
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
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TechCodeBackgroundPainter(
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

// ==================== 计算机领军人物背景（登录页）- 代码雨效果 ====================

/// 代码字符类型（用于语法高亮）
enum _CodeCharType {
  digit,      // 数字 - 青色
  keyword,    // 关键字 - 绿色
  symbol,     // 符号 - 黄色
  bracket,    // 括号 - 紫色
}

/// 代码字符及其类型
class _CodeChar {
  final String value;
  final _CodeCharType type;
  const _CodeChar(this.value, this.type);
}

/// 计算机领军人物背景绘制器（登录页）- 高级代码雨效果
class TechPioneersBackgroundPainter extends CustomPainter {
  final double animationValue;

  // 代码字符集 - 带类型信息用于语法高亮
  static const List<_CodeChar> _codeChars = [
    _CodeChar('0', _CodeCharType.digit),
    _CodeChar('1', _CodeCharType.digit),
    _CodeChar('01', _CodeCharType.digit),
    _CodeChar('10', _CodeCharType.digit),
    _CodeChar('110', _CodeCharType.digit),
    _CodeChar('101', _CodeCharType.digit),
    _CodeChar('{', _CodeCharType.bracket),
    _CodeChar('}', _CodeCharType.bracket),
    _CodeChar('<', _CodeCharType.bracket),
    _CodeChar('>', _CodeCharType.bracket),
    _CodeChar('/', _CodeCharType.symbol),
    _CodeChar('\\', _CodeCharType.symbol),
    _CodeChar('if', _CodeCharType.keyword),
    _CodeChar('for', _CodeCharType.keyword),
    _CodeChar('while', _CodeCharType.keyword),
    _CodeChar('return', _CodeCharType.keyword),
    _CodeChar('func', _CodeCharType.keyword),
    _CodeChar('var', _CodeCharType.keyword),
    _CodeChar('let', _CodeCharType.keyword),
    _CodeChar('const', _CodeCharType.keyword),
    _CodeChar('class', _CodeCharType.keyword),
    _CodeChar('import', _CodeCharType.keyword),
    _CodeChar('=>', _CodeCharType.symbol),
    _CodeChar('==', _CodeCharType.symbol),
    _CodeChar('!=', _CodeCharType.symbol),
    _CodeChar('&&', _CodeCharType.symbol),
    _CodeChar('||', _CodeCharType.symbol),
  ];

  // 语法高亮颜色映射
  static const Map<_CodeCharType, Color> _colorMap = {
    _CodeCharType.digit: Color(0xFF00FFFF),    // 青色
    _CodeCharType.keyword: Color(0xFF00FF41),  // 绿色
    _CodeCharType.symbol: Color(0xFFFFFF00),   // 黄色
    _CodeCharType.bracket: Color(0xFFFF00FF),  // 紫色
  };

  TechPioneersBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 动态渐变背景 - 随时间缓慢变化
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0A0E1A), // 深蓝黑
        const Color(0xFF16213E), // 深蓝灰
        const Color(0xFF0F2847).withOpacity(0.3), // 动态层
      ],
    );
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()..shader = backgroundGradient.createShader(backgroundRect);
    canvas.drawRect(backgroundRect, backgroundPaint);

    // 绘制星空粒子背景
    _drawStarField(canvas, size);

    // 绘制网格背景
    _drawGrid(canvas, size);

    // 绘制能量波纹（中心扩散）
    _drawEnergyWaves(canvas, size);

    // 绘制DNA双螺旋代码链
    _drawDNASpiral(canvas, size);

    // 绘制脉冲扩散圆环
    _drawPulseRings(canvas, size);

    // 绘制代码雨效果 - 多层带语法高亮
    _drawCodeRainLayer(canvas, size, 1.0, 0.15, 12);  // 主层
    _drawCodeRainLayer(canvas, size, 0.7, 0.08, 10);  // 中层
    _drawCodeRainLayer(canvas, size, 0.4, 0.05, 8);   // 远层

    // 绘制斜向代码雨
    _drawDiagonalCodeRain(canvas, size);

    // 绘制漂浮代码片段（带光标效果）
    _drawFloatingSnippets(canvas, size);

    // 绘制数据流粒子
    _drawDataFlowParticles(canvas, size);

    // 绘制发光节点
    _drawGlowingNodes(canvas, size);

    // 绘制浮动几何图形
    _drawFloatingGeometry(canvas, size);

    // 绘制扫描激光线
    _drawScanLine(canvas, size);

    // 绘制垂直闪电效果
    _drawLightning(canvas, size);

    // 偶尔的VHS故障效果
    _drawVHSGlitch(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00FF41).withOpacity(0.03)
      ..strokeWidth = 0.5;

    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawPulseRings(Canvas canvas, Size size) {
    // 从多个源点扩散的脉冲圆环
    final centers = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.5),
    ];

    for (final center in centers) {
      // 每个源点产生多个扩散圆环
      for (int i = 0; i < 3; i++) {
        final ringPhase = ((animationValue * 0.5 + i * 0.33) % 1.0);
        final radius = ringPhase * 200;
        final alpha = (1 - ringPhase) * 0.15;

        final ringPaint = Paint()
          ..color = const Color(0xFF00FF41).withOpacity(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * (1 - ringPhase)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(center, radius, ringPaint);
      }
    }
  }

  void _drawCodeRainLayer(Canvas canvas, Size size, double speedMultiplier, double baseOpacity, int fontSize) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 代码雨列数
    const columnCount = 25;
    final columnWidth = size.width / columnCount;

    // 使用伪随机但确定性的位置计算
    for (int col = 0; col < columnCount; col++) {
      // 每列的起始偏移（基于列索引的伪随机）
      final columnOffset = (col * 73.7) % 100 / 100;
      // 计算当前列的整体移动位置
      final flowPosition = ((animationValue * speedMultiplier * 200 + columnOffset * size.height) % (size.height + 100)) - 50;

      // 在该列绘制多个字符形成雨滴效果
      final dropLength = 15 + (col % 5) * 3; // 每列的雨滴长度
      for (int i = 0; i < dropLength; i++) {
        final charY = flowPosition - i * fontSize * 1.2;

        // 只绘制在屏幕内的字符
        if (charY < -fontSize || charY > size.height + fontSize) continue;

        // 计算透明度：头部最亮，尾部渐隐
        final distanceFromHead = i / dropLength;
        final alpha = baseOpacity * (1 - distanceFromHead * 0.8);

        // 头部字符高亮（白色）
        final isHead = i == 0;
        Color charColor;

        if (isHead) {
          charColor = const Color(0xFFFFFFFF).withOpacity(alpha * 1.5);
        } else {
          // 选择字符（基于位置的伪随机）
          final charIndex = ((col * 7 + i * 3 + animationValue * 10) % _codeChars.length).floor();
          final codeChar = _codeChars[charIndex];
          // 使用语法高亮颜色
          charColor = _colorMap[codeChar.type]!.withOpacity(alpha);
        }

        // 选择字符
        final charIndex = ((col * 7 + i * 3 + animationValue * 10) % _codeChars.length).floor();
        final char = _codeChars[charIndex].value;

        final textStyle = TextStyle(
          color: charColor,
          fontSize: fontSize.toDouble(),
          fontFamily: 'Courier',
          height: 1.2,
        );

        textPainter.text = TextSpan(text: char, style: textStyle);
        textPainter.layout();
        textPainter.paint(canvas, Offset(col * columnWidth + columnWidth / 2 - textPainter.width / 2, charY));
      }
    }
  }

  void _drawFloatingSnippets(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final snippets = [
      'function solve()',
      'return result;',
      'if (condition)',
      '// TODO: optimize',
      'const π = 3.14159',
      'while (running)',
      'class Solution',
      'async/await',
      'null ?? defaultValue',
      'import { useState }',
      'export default App',
      'array.map(x => x * 2)',
      'try { } catch (e)',
      'SELECT * FROM users',
      '<div className="app">',
    ];

    // 计算光标闪烁状态
    final cursorVisible = (animationValue * 8) % 2 < 1;

    for (int i = 0; i < snippets.length; i++) {
      // 每个代码片段独立的运动轨迹
      final snippetOffset = (animationValue * 30 + i * 50) % (size.height + 100);
      final x = (i * 103.7) % (size.width - 150) + 20;
      final y = snippetOffset - 50;

      // 边界淡入淡出效���
      final fadeZone = 80.0;
      double alpha = 0.25;
      if (y < fadeZone) {
        alpha = 0.25 * (y / fadeZone);
      } else if (y > size.height - fadeZone) {
        alpha = 0.25 * ((size.height - y) / fadeZone);
      }

      // 绘制代码片段
      final textStyle = TextStyle(
        color: const Color(0xFF00FF41).withOpacity(alpha.clamp(0.0, 0.25)),
        fontSize: 10,
        fontFamily: 'Courier',
      );

      textPainter.text = TextSpan(text: snippets[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));

      // 绘制终端光标（闪烁效果）
      if (cursorVisible) {
        final cursorX = x + textPainter.width + 2;
        final cursorPaint = Paint()
          ..color = const Color(0xFF00FF41).withOpacity(alpha.clamp(0.0, 0.4));
        canvas.drawRect(
          Rect.fromLTWH(cursorX, y, 6, 10),
          cursorPaint,
        );
      }
    }
  }

  void _drawDataFlowParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // 沿贝塞尔曲线流动的粒子
    const particleCount = 12;
    for (int i = 0; i < particleCount; i++) {
      final t = ((animationValue * 0.4 + i / particleCount) % 1.0);

      // 创建S形曲线路径
      final startX = 0.0;
      final startY = size.height * (0.2 + (i % 3) * 0.2);
      final endX = size.width;
      final endY = size.height * (0.8 - (i % 3) * 0.2);

      // 二次贝塞尔曲线控制点
      final controlX = size.width * 0.5;
      final controlY = size.height * 0.5;

      // 计算曲线上的位置
      final invT = 1 - t;
      final x = invT * invT * startX + 2 * invT * t * controlX + t * t * endX;
      final y = invT * invT * startY + 2 * invT * t * controlY + t * t * endY;

      // 边界淡入淡出
      final edgeFade = t < 0.1 ? t * 10 : (t > 0.9 ? (1 - t) * 10 : 1.0);

      // 绘制粒子光晕
      canvas.drawCircle(Offset(x, y), 6 * edgeFade, glowPaint..color = const Color(0xFF00FFFF).withOpacity(0.3 * edgeFade));
      // 绘制粒子核心
      canvas.drawCircle(Offset(x, y), 2 * edgeFade, particlePaint..color = const Color(0xFF00FFFF).withOpacity(edgeFade));
    }
  }

  void _drawGlowingNodes(Canvas canvas, Size size) {
    final nodePaint = Paint()
      ..color = const Color(0xFF00FF41).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = const Color(0xFF00FF41).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // 节点数量和位置基于动画时间平滑移动
    const nodeCount = 6;
    for (int i = 0; i < nodeCount; i++) {
      final t = (animationValue * 0.3 + i / nodeCount) % 1.0;

      // 使用正弦波形创建平滑的节点轨迹
      final x = (t * size.width * 1.2) % (size.width + 40) - 20;
      final wave = math.sin(t * math.pi * 2 + i) * 0.5 + 0.5;
      final y = size.height * 0.2 + wave * size.height * 0.6;

      // 绘制光晕
      canvas.drawCircle(Offset(x, y), 8, glowPaint);
      // 绘制节点核心
      canvas.drawCircle(Offset(x, y), 3, nodePaint);
    }
  }

  void _drawScanLine(Canvas canvas, Size size) {
    // 水平扫描激光线
    final scanY = (animationValue * 150) % (size.height + 100) - 50;

    // 扫描线渐变
    final scanGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        const Color(0xFF00FF41).withOpacity(0.3),
        const Color(0xFFFFFFFF).withOpacity(0.5),
        const Color(0xFF00FF41).withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );

    final scanRect = Rect.fromLTWH(0, scanY, size.width, 2);
    final scanPaint = Paint()
      ..shader = scanGradient.createShader(scanRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRect(scanRect, scanPaint);
  }

  void _drawVHSGlitch(Canvas canvas, Size size) {
    // 偶尔的VHS故障效果 - 每隔一段时间触发
    final glitchCycle = (animationValue * 100) % 20;
    if (glitchCycle < 0.5) {
      // 随机水平偏移
      final offset = (math.Random(animationValue.toInt()).nextDouble() - 0.5) * 10;

      // 绘制偏移的条纹
      final glitchPaint = Paint()
        ..color = const Color(0xFF00FF41).withOpacity(0.1);

      for (int i = 0; i < 5; i++) {
        final y = (math.Random(animationValue.toInt() + i).nextDouble() * size.height).floor().toDouble();
        final h = (math.Random(animationValue.toInt() + i + 1).nextDouble() * 5 + 1);
        canvas.drawRect(
          Rect.fromLTWH(offset, y, size.width, h),
          glitchPaint,
        );
      }
    }
  }

  void _drawStarField(Canvas canvas, Size size) {
    // 星空粒子��景 - 闪烁的微小星星
    final starPaint = Paint()
      ..color = const Color(0xFF00FF41)
      ..style = PaintingStyle.fill;

    const starCount = 50;
    for (int i = 0; i < starCount; i++) {
      // 使用确定性伪随机位置
      final seed = i * 7919;
      final x = ((seed * 123.45) % size.width);
      final y = ((seed * 678.9) % size.height);

      // 闪烁效果 - 不同星星有不同的闪烁周期
      final twinklePhase = ((animationValue * 2 + i * 0.1) % 1.0);
      // 确保brightness在0-1范围内
      final brightness = 0.3 + 0.7 * ((math.sin(twinklePhase * math.pi * 2) + 1) / 2);

      canvas.drawCircle(
        Offset(x, y),
        1.0 * brightness,
        starPaint..color = const Color(0xFF00FF41).withOpacity(0.15 * brightness),
      );
    }
  }

  void _drawEnergyWaves(Canvas canvas, Size size) {
    // 从中心扩散的能量波纹
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < 4; i++) {
      final phase = ((animationValue * 0.3 + i * 0.25) % 1.0);
      final radius = phase * size.width * 0.8;
      final alpha = (1 - phase) * 0.1;

      final wavePaint = Paint()
        ..color = const Color(0xFF00FF41).withOpacity(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - phase)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(centerX, centerY), radius, wavePaint);
    }
  }

  void _drawDNASpiral(Canvas canvas, Size size) {
    // DNA双螺旋代码链
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final chars = ['A', 'T', 'G', 'C', '0', '1'];

    final spiralCenterX = size.width * 0.85;
    final spiralCenterY = size.height * 0.5;
    final spiralHeight = size.height * 0.7;

    for (int i = 0; i < 20; i++) {
      final t = ((animationValue * 0.5 + i / 20) % 1.0);
      final y = spiralCenterY + (t - 0.5) * spiralHeight;

      // 两条螺旋链
      for (int strand = 0; strand < 2; strand++) {
        final angle = t * math.pi * 6 + strand * math.pi;
        final x = spiralCenterX + math.sin(angle) * 40;

        final charIndex = ((i + strand) % chars.length);
        final alpha = 0.4 + 0.3 * math.sin(angle);

        textPainter.text = TextSpan(
          text: chars[charIndex],
          style: TextStyle(
            color: strand == 0
                ? const Color(0xFF00FFFF).withOpacity(alpha)
                : const Color(0xFFFF00FF).withOpacity(alpha),
            fontSize: 10,
            fontFamily: 'Courier',
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));

        // 绘制连接线
        if (i < 19) {
          final otherStrandAngle = t * math.pi * 6 + (1 - strand) * math.pi;
          final otherX = spiralCenterX + math.sin(otherStrandAngle) * 40;

          final linePaint = Paint()
            ..color = const Color(0xFF00FF41).withOpacity(0.15)
            ..strokeWidth = 1;

          canvas.drawLine(Offset(x, y), Offset(otherX, y), linePaint);
        }
      }
    }
  }

  void _drawDiagonalCodeRain(Canvas canvas, Size size) {
    // 斜向代码雨（对角线方向）
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const rainCount = 8;
    for (int i = 0; i < rainCount; i++) {
      final t = ((animationValue * 0.6 + i / rainCount) % 1.0);

      // 对角线位置
      final x = t * (size.width + size.height);
      final y = t * size.height;

      // 限制在屏幕内
      if (x < -50 || x > size.width + 50 || y < 0 || y > size.height) continue;

      for (int j = 0; j < 8; j++) {
        final trailX = x - j * 12;
        final trailY = y - j * 12;

        if (trailX < -20 || trailX > size.width + 20 || trailY < -20 || trailY > size.height + 20) continue;

        final alpha = (1 - j / 8) * 0.2;
        final charIndex = ((i * 7 + j) % _codeChars.length);
        final char = _codeChars[charIndex].value;

        textPainter.text = TextSpan(
          text: char,
          style: TextStyle(
            color: _colorMap[_codeChars[charIndex].type]!.withOpacity(alpha),
            fontSize: 10.0,
            fontFamily: 'Courier',
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(trailX, trailY));
      }
    }
  }

  void _drawFloatingGeometry(Canvas canvas, Size size) {
    // 浮动的旋转几何图形
    final shapes = [
      {'sides': 3, 'color': const Color(0xFF00FFFF)}, // 三角形 - 青色
      {'sides': 4, 'color': const Color(0xFFFF00FF)}, // 正方形 - 紫色
      {'sides': 6, 'color': const Color(0xFFFFFF00)}, // 六边形 - 黄色
    ];

    for (int i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final t = ((animationValue * 0.2 + i * 0.33) % 1.0);

      final x = size.width * (0.2 + i * 0.3);
      final y = size.height * 0.3 + math.sin(t * math.pi * 2) * 100;
      final rotation = animationValue * math.pi * 2 * (i % 2 == 0 ? 1 : -1);
      final size2 = 20 + 10 * math.sin(animationValue * math.pi * 2 + i);

      final path = Path();
      final sides = shape['sides'] as int;

      for (int j = 0; j < sides; j++) {
        final angle = rotation + j * 2 * math.pi / sides - math.pi / 2;
        final px = x + size2 * math.cos(angle);
        final py = y + size2 * math.sin(angle);

        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();

      final paint = Paint()
        ..color = (shape['color'] as Color).withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawPath(path, paint);
    }
  }

  void _drawLightning(Canvas canvas, Size size) {
    // 偶尔的垂直闪电效果
    final lightningCycle = (animationValue * 100) % 30;
    if (lightningCycle < 0.3) {
      final lightningProgress = lightningCycle / 0.3;
      final alpha = (1 - lightningProgress) * 0.6;

      // 使用确定性随机数生成器
      final seed = (animationValue * 10).floor();
      final baseX = ((seed * 456.7) % size.width);
      final startY = ((seed * 123.4) % size.height * 0.3);

      final path = Path();
      path.moveTo(baseX, startY);

      var currentX = baseX;
      var currentY = startY;
      final segments = 8 + (seed % 5);

      for (int i = 0; i < segments; i++) {
        final segmentY = startY + (size.height * 0.6) * (i + 1) / segments;
        final offsetX = ((seed * 789.1 + i * 123) % 40) - 20;
        currentX = baseX + offsetX * lightningProgress;

        path.moveTo(currentX, currentY);
        path.lineTo(currentX, segmentY);
        currentY = segmentY;
      }

      final lightningPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(alpha)
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawPath(path, lightningPaint);

      // 闪电光晕
      final glowPaint = Paint()
        ..color = const Color(0xFF00FF41).withOpacity(alpha * 0.5)
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 计算机领军人物背景组件（登录页）
class TechPioneersBackground extends StatefulWidget {
  final Widget child;

  const TechPioneersBackground({
    super.key,
    required this.child,
  });

  @override
  State<TechPioneersBackground> createState() => _TechPioneersBackgroundState();
}

class _TechPioneersBackgroundState extends State<TechPioneersBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
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
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TechPioneersBackgroundPainter(
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

// ==================== 科技网格背景（主界面） ====================

/// 科技网格背景绘制器
class TechGridBackgroundPainter extends CustomPainter {
  final double animationValue;

  TechGridBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 深蓝色渐变背景
    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0A0E1A),
        const Color(0xFF16213E),
        const Color(0xFF0F172A),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()..shader = backgroundGradient.createShader(backgroundRect);
    canvas.drawRect(backgroundRect, backgroundPaint);

    // 网格线颜色
    final gridColor = BubeiColors.primary.withOpacity(0.08);
    final linePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // 绘制主网格线
    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // 绘制发光连接线
    final connectionPaint = Paint()
      ..color = BubeiColors.primary.withOpacity(0.15)
      ..strokeWidth = 1.5;

    // 绘制发光节点
    final nodePaint = Paint()
      ..color = BubeiColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = BubeiColors.primary.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // 静态节点位置（基于网格）
    final nodes = <Offset>[];
    for (double x = gridSize; x < size.width - gridSize; x += gridSize * 2) {
      for (double y = gridSize; y < size.height - gridSize; y += gridSize * 2) {
        nodes.add(Offset(x, y));
      }
    }

    // 绘制节点间的连接线
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      // 连接右方节点
      if (i + 1 < nodes.length && (nodes[i + 1].dy - node.dy).abs() < 1) {
        canvas.drawLine(node, nodes[i + 1], connectionPaint);
      }
      // 连接下方节点
      final belowNode = nodes.isNotEmpty
          ? nodes.firstWhere(
              (n) => (n.dx - node.dx).abs() < 1 && n.dy > node.dy,
              orElse: () => node,
            )
          : node;
      if (belowNode != node) {
        canvas.drawLine(node, belowNode, connectionPaint);
      }
    }

    // 绘制节点
    for (final node in nodes) {
      // 呼吸效果
      final breathe = (math.sin(animationValue * math.pi * 2 + node.dx * 0.01) + 1) / 2;
      final glowRadius = 4.0 + breathe * 3.0;

      // 绘制光晕
      canvas.drawCircle(node, glowRadius, glowPaint);
      // 绘制核心节点
      canvas.drawCircle(node, 2.0, nodePaint);
    }

    // 绘制移动的光点（模拟数据传输）
    final movingDotPaint = Paint()
      ..color = BubeiColors.primaryLight.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    final movingDotGlow = Paint()
      ..color = BubeiColors.primaryLight.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final dotCount = 5;
    for (int i = 0; i < dotCount; i++) {
      final progress = ((animationValue + i / dotCount) % 1.0);
      final startNode = nodes[(i * 7) % nodes.length];
      final endNode = nodes[(i * 7 + 1) % nodes.length];

      final x = startNode.dx + (endNode.dx - startNode.dx) * progress;
      final y = startNode.dy + (endNode.dy - startNode.dy) * progress;

      canvas.drawCircle(Offset(x, y), 4, movingDotGlow);
      canvas.drawCircle(Offset(x, y), 2, movingDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 科技网格背景组件（带动画）
class TechGridBackground extends StatefulWidget {
  final Widget child;

  const TechGridBackground({
    super.key,
    required this.child,
  });

  @override
  State<TechGridBackground> createState() => _TechGridBackgroundState();
}

class _TechGridBackgroundState extends State<TechGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
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
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TechGridBackgroundPainter(
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

// ==================== 计算机领军人物背景（主界面）- 代码雨效果 ====================

/// 代码字符类型（用于语法高亮）
enum _HomeCodeCharType {
  digit,      // 数字 - 青色
  keyword,    // 关键字 - 绿色
  symbol,     // 符号 - 黄色
  bracket,    // 括号 - 橙色
  string,     // 字符串 - 粉色
}

/// 代码字符及其类型
class _HomeCodeChar {
  final String value;
  final _HomeCodeCharType type;
  const _HomeCodeChar(this.value, this.type);
}

/// 计算机领军人物背景绘制器（主界面 - 绿色主题代码雨效果）
class TechPioneersHomeBackgroundPainter extends CustomPainter {
  final double animationValue;

  // 代码字符集 - 带类型信息用于语法高亮
  static const List<_HomeCodeChar> _codeChars = [
    _HomeCodeChar('0', _HomeCodeCharType.digit),
    _HomeCodeChar('1', _HomeCodeCharType.digit),
    _HomeCodeChar('01', _HomeCodeCharType.digit),
    _HomeCodeChar('10', _HomeCodeCharType.digit),
    _HomeCodeChar('110', _HomeCodeCharType.digit),
    _HomeCodeChar('101', _HomeCodeCharType.digit),
    _HomeCodeChar('{', _HomeCodeCharType.bracket),
    _HomeCodeChar('}', _HomeCodeCharType.bracket),
    _HomeCodeChar('<', _HomeCodeCharType.bracket),
    _HomeCodeChar('>', _HomeCodeCharType.bracket),
    _HomeCodeChar('/', _HomeCodeCharType.symbol),
    _HomeCodeChar('\\', _HomeCodeCharType.symbol),
    _HomeCodeChar('if', _HomeCodeCharType.keyword),
    _HomeCodeChar('for', _HomeCodeCharType.keyword),
    _HomeCodeChar('while', _HomeCodeCharType.keyword),
    _HomeCodeChar('return', _HomeCodeCharType.keyword),
    _HomeCodeChar('func', _HomeCodeCharType.keyword),
    _HomeCodeChar('var', _HomeCodeCharType.keyword),
    _HomeCodeChar('let', _HomeCodeCharType.keyword),
    _HomeCodeChar('const', _HomeCodeCharType.keyword),
    _HomeCodeChar('class', _HomeCodeCharType.keyword),
    _HomeCodeChar('import', _HomeCodeCharType.keyword),
    _HomeCodeChar('=>', _HomeCodeCharType.symbol),
    _HomeCodeChar('==', _HomeCodeCharType.symbol),
    _HomeCodeChar('!=', _HomeCodeCharType.symbol),
    _HomeCodeChar('&&', _HomeCodeCharType.symbol),
    _HomeCodeChar('||', _HomeCodeCharType.symbol),
  ];

  // 语法高亮颜色映射（绿色主题）
  static const Map<_HomeCodeCharType, Color> _colorMap = {
    _HomeCodeCharType.digit: Color(0xFF80DEEA),       // 浅青色
    _HomeCodeCharType.keyword: Color(0xFF4CAF50),     // 绿色
    _HomeCodeCharType.symbol: Color(0xFFFFEB3B),      // 黄色
    _HomeCodeCharType.bracket: Color(0xFFFF9800),     // 橙色
    _HomeCodeCharType.string: Color(0xFFF48FB1),      // 粉色
  };

  TechPioneersHomeBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 深蓝色渐变背景
    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0A0E1A),
        const Color(0xFF16213E),
        const Color(0xFF0F172A),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()..shader = backgroundGradient.createShader(backgroundRect);
    canvas.drawRect(backgroundRect, backgroundPaint);

    // 绘制星空粒子背景
    _drawStarField(canvas, size);

    // 绘制六边形网格背景
    _drawHexGrid(canvas, size);

    // 绘制音频频谱模拟
    _drawAudioSpectrum(canvas, size);

    // 绘制脉冲扩散圆环
    _drawPulseRings(canvas, size);

    // 绘制电路板路径
    _drawCircuitPaths(canvas, size);

    // 绘制代码雨效果 - 多层带语法高亮
    _drawCodeRainLayer(canvas, size, 0.8, 0.12, 11);
    _drawCodeRainLayer(canvas, size, 0.5, 0.08, 9);
    _drawCodeRainLayer(canvas, size, 0.3, 0.05, 7);

    // 绘制漂浮代码片段（带光标效果）
    _drawFloatingSnippets(canvas, size);

    // 绘制数据流粒子
    _drawDataFlowParticles(canvas, size);

    // 绘制发光连接网络
    _drawNetworkNodes(canvas, size);

    // 绘制呼吸光环
    _drawBreathingRings(canvas, size);

    // 绘制扫描激光线
    _drawScanLine(canvas, size);
  }

  void _drawHexGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF2D5016).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制六边形网格
    const hexSize = 30.0;
    final hexHeight = hexSize * math.sqrt(3);
    final hexWidth = hexSize * 2;

    for (int row = -1; row < (size.height / hexHeight * 0.75).ceil() + 1; row++) {
      for (int col = -1; col < (size.width / (hexWidth * 0.75)).ceil() + 1; col++) {
        final x = col * hexWidth * 0.75;
        final y = row * hexHeight + (col % 2 == 0 ? 0 : hexHeight / 2);

        final hexPath = _createHexagonPath(x, y, hexSize - 2);
        canvas.drawPath(hexPath, gridPaint);
      }
    }
  }

  Path _createHexagonPath(double centerX, double centerY, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawPulseRings(Canvas canvas, Size size) {
    // 从多个源点扩散的脉冲圆环
    final centers = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.25),
    ];

    for (final center in centers) {
      // 每个源点产生多个扩散圆环
      for (int i = 0; i < 2; i++) {
        final ringPhase = ((animationValue * 0.4 + i * 0.5 + centers.indexOf(center) * 0.25) % 1.0);
        final radius = ringPhase * 180;
        final alpha = (1 - ringPhase) * 0.12;

        final ringPaint = Paint()
          ..color = const Color(0xFF4CAF50).withOpacity(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1 - ringPhase)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

        canvas.drawCircle(center, radius, ringPaint);
      }
    }
  }

  void _drawCodeRainLayer(Canvas canvas, Size size, double speed, double baseOpacity, int fontSize) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 代码雨列数
    const columnCount = 30;
    final columnWidth = size.width / columnCount;

    // 使用伪随机但确定性的位置计算
    for (int col = 0; col < columnCount; col++) {
      // 每列的起始偏移（基于列索引的伪随机）
      final columnOffset = (col * 83.7) % 100 / 100;
      // 计算当前列的整体移动位置
      final flowPosition = ((animationValue * speed * 150 + columnOffset * size.height) % (size.height + 80)) - 40;

      // 在该列绘制多个字符形成雨滴效果
      final dropLength = 12 + (col % 4) * 4;
      for (int i = 0; i < dropLength; i++) {
        final charY = flowPosition - i * fontSize * 1.2;

        // 只绘制在屏幕内的字符
        if (charY < -fontSize || charY > size.height + fontSize) continue;

        // 计算透明度：头部最亮，尾部渐隐
        final distanceFromHead = i / dropLength;
        final alpha = baseOpacity * (1 - distanceFromHead * 0.7);

        // 头部字符高亮（白色）
        final isHead = i == 0;
        Color charColor;

        if (isHead) {
          charColor = const Color(0xFFFFFFFF).withOpacity((alpha * 1.8).clamp(0.0, 1.0));
        } else {
          // 选择字符（基于位置的伪随机）
          final charIndex = ((col * 11 + i * 5 + animationValue * 8) % _codeChars.length).floor();
          final codeChar = _codeChars[charIndex];
          // 使用语法高亮颜色
          charColor = _colorMap[codeChar.type]!.withOpacity(alpha.clamp(0.0, 1.0));
        }

        // 选择字符
        final charIndex = ((col * 11 + i * 5 + animationValue * 8) % _codeChars.length).floor();
        final char = _codeChars[charIndex].value;

        final textStyle = TextStyle(
          color: charColor,
          fontSize: fontSize.toDouble(),
          fontFamily: 'Courier',
          height: 1.2,
        );

        textPainter.text = TextSpan(text: char, style: textStyle);
        textPainter.layout();
        textPainter.paint(canvas, Offset(col * columnWidth + columnWidth / 2 - textPainter.width / 2, charY));
      }
    }
  }

  void _drawFloatingSnippets(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final snippets = [
      'function solve()',
      'return result;',
      'if (condition)',
      '// TODO: fix',
      'const π = 3.14159',
      'while (running)',
      'class Solution',
      'async/await',
      'null ?? value',
      'useState(false)',
      'export default',
      'array.map(x => x)',
      'try { catch }',
      'SELECT * FROM',
      '<Component />',
      'interface User',
      'type Result =',
      '&str mut',
      'fn main()',
      'let x = 42;',
    ];

    // 计算光标闪烁状态
    final cursorVisible = (animationValue * 6) % 2 < 1;

    for (int i = 0; i < snippets.length; i++) {
      // 每个代码片段独立的运动轨迹
      final snippetOffset = (animationValue * 25 + i * 45) % (size.height + 80);
      final x = (i * 97.3) % (size.width - 120) + 15;
      final y = snippetOffset - 40;

      // 边界淡入淡出效果
      final fadeZone = 60.0;
      double alpha = 0.2;
      if (y < fadeZone) {
        alpha = 0.2 * (y / fadeZone);
      } else if (y > size.height - fadeZone) {
        alpha = 0.2 * ((size.height - y) / fadeZone);
      }

      // 绘制代码片段
      final textStyle = TextStyle(
        color: const Color(0xFF4CAF50).withOpacity(alpha.clamp(0.0, 0.2)),
        fontSize: 9,
        fontFamily: 'Courier',
      );

      textPainter.text = TextSpan(text: snippets[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));

      // 绘制终端光标（闪烁效果）
      if (cursorVisible) {
        final cursorX = x + textPainter.width + 2;
        final cursorPaint = Paint()
          ..color = const Color(0xFF4CAF50).withOpacity(alpha.clamp(0.0, 0.35));
        canvas.drawRect(
          Rect.fromLTWH(cursorX, y, 5, 9),
          cursorPaint,
        );
      }
    }
  }

  void _drawDataFlowParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = const Color(0xFF80DEEA)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = const Color(0xFF80DEEA).withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // 沿贝塞尔曲线流动的粒子
    const particleCount = 10;
    for (int i = 0; i < particleCount; i++) {
      final t = ((animationValue * 0.3 + i / particleCount) % 1.0);

      // 创建S形曲线路径
      final startX = size.width * 0.1;
      final startY = size.height * (0.15 + (i % 3) * 0.25);
      final endX = size.width * 0.9;
      final endY = size.height * (0.85 - (i % 3) * 0.25);

      // 二次贝塞尔曲线控制点
      final controlX = size.width * 0.5;
      final controlY = size.height * 0.5;

      // 计算曲线上的位置
      final invT = 1 - t;
      final x = invT * invT * startX + 2 * invT * t * controlX + t * t * endX;
      final y = invT * invT * startY + 2 * invT * t * controlY + t * t * endY;

      // 边界淡入淡出
      final edgeFade = t < 0.15 ? t / 0.15 : (t > 0.85 ? (1 - t) / 0.15 : 1.0);

      // 绘制粒子光晕
      canvas.drawCircle(Offset(x, y), 5 * edgeFade, glowPaint..color = const Color(0xFF80DEEA).withOpacity(0.25 * edgeFade));
      // 绘制粒子核心
      canvas.drawCircle(Offset(x, y), 1.5 * edgeFade, particlePaint..color = const Color(0xFF80DEEA).withOpacity(edgeFade));
    }
  }

  void _drawNetworkNodes(Canvas canvas, Size size) {
    final nodePaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.1)
      ..strokeWidth = 1;

    // 创建节点网络
    const nodeCount = 10;
    final nodes = <Offset>[];

    for (int i = 0; i < nodeCount; i++) {
      final t = (animationValue * 0.15 + i / nodeCount) % 1.0;

      // 使用正弦波形创建平滑的节点轨迹
      final x = (t * size.width * 1.4) % (size.width + 60) - 30;
      final wave = math.sin(t * math.pi * 2 + i * 0.5) * 0.5 + 0.5;
      final y = size.height * 0.15 + wave * size.height * 0.7;

      nodes.add(Offset(x, y));
    }

    // 绘制连接线
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final distance = (nodes[i] - nodes[j]).distance;
        if (distance < 220) {
          final lineAlpha = (1 - distance / 220) * 0.18;
          canvas.drawLine(
            nodes[i],
            nodes[j],
            linePaint..color = const Color(0xFF4CAF50).withOpacity(lineAlpha.clamp(0.0, 0.18)),
          );
        }
      }
    }

    // 绘制节点
    for (final node in nodes) {
      // 绘制光晕
      canvas.drawCircle(node, 12, glowPaint);
      // 绘制节点核心
      canvas.drawCircle(node, 3, nodePaint);
    }
  }

  void _drawScanLine(Canvas canvas, Size size) {
    // 水平扫描激光线（绿色主题）
    final scanY = (animationValue * 120) % (size.height + 80) - 40;

    // 扫描线渐变
    final scanGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        const Color(0xFF4CAF50).withOpacity(0.25),
        const Color(0xFFFFFFFF).withOpacity(0.4),
        const Color(0xFF4CAF50).withOpacity(0.25),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );

    final scanRect = Rect.fromLTWH(0, scanY, size.width, 2);
    final scanPaint = Paint()
      ..shader = scanGradient.createShader(scanRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRect(scanRect, scanPaint);
  }

  void _drawStarField(Canvas canvas, Size size) {
    // 星空粒子背景 - 绿色主题（低透明度，不遮挡代码雨）
    final starPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    const starCount = 60;
    for (int i = 0; i < starCount; i++) {
      final seed = i * 7919;
      final x = ((seed * 123.45) % size.width);
      final y = ((seed * 678.9) % size.height);

      final twinklePhase = ((animationValue * 1.5 + i * 0.15) % 1.0);
      // 确保brightness在0-1范围内
      final brightness = 0.3 + 0.7 * ((math.sin(twinklePhase * math.pi * 2) + 1) / 2);

      canvas.drawCircle(
        Offset(x, y),
        0.8 * brightness,
        starPaint..color = const Color(0xFF4CAF50).withOpacity(0.1 * brightness),
      );
    }
  }

  void _drawAudioSpectrum(Canvas canvas, Size size) {
    // 音频频谱模拟 - 底部跳动的频谱条
    const barCount = 16;
    final barWidth = size.width / barCount * 0.8;
    final gap = size.width / barCount * 0.2;

    for (int i = 0; i < barCount; i++) {
      // 每个频谱条有独立的动画相位
      final phase = (animationValue * 2 + i * 0.3) % 1.0;
      // 确保barHeight为正值
      final barHeight = 30 + 50 * ((math.sin(phase * math.pi * 2) + 1) / 2);

      final x = gap / 2 + i * (barWidth + gap);
      final y = size.height - barHeight;

      // 频谱条渐变
      final barGradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF4CAF50).withOpacity(0.4),
          const Color(0xFF80DEEA).withOpacity(0.2),
          Colors.transparent,
        ],
      );

      final barRect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final barPaint = Paint()
        ..shader = barGradient.createShader(barRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawRect(barRect, barPaint);
    }
  }

  void _drawCircuitPaths(Canvas canvas, Size size) {
    // 电路板路径 - 科技感连接线
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.12)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 创建电路板节点网格
    const gridSize = 120.0;
    for (double gx = gridSize / 2; gx < size.width; gx += gridSize) {
      for (double gy = gridSize / 2; gy < size.height; gy += gridSize) {
        // 绘制节点
        canvas.drawCircle(Offset(gx, gy), 4, nodePaint);

        // 随机连接到相邻节点
        final seed = ((gx + gy) * 100).floor() % 10;
        if (seed < 5) {
          // 向右连接
          if (gx + gridSize < size.width) {
            final progress = ((animationValue * 0.5 + seed * 0.1) % 1.0);
            final endX = gx + gridSize * progress;
            canvas.drawLine(Offset(gx, gy), Offset(endX, gy), linePaint);
          }
        }
        if (seed >= 5) {
          // 向下连接
          if (gy + gridSize < size.height) {
            final progress = ((animationValue * 0.5 + seed * 0.1) % 1.0);
            final endY = gy + gridSize * progress;
            canvas.drawLine(Offset(gx, gy), Offset(gx, endY), linePaint);
          }
        }
      }
    }
  }

  void _drawBreathingRings(Canvas canvas, Size size) {
    // 呼吸光环 - 周期性放大缩小
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;

    for (int i = 0; i < 3; i++) {
      final phase = ((animationValue * 0.4 + i * 0.33) % 1.0);
      // 呼吸效果：先放大后缩小
      final breathe = math.sin(phase * math.pi);
      final radius = 100 + breathe * 80;
      final alpha = (breathe * 0.5 + 0.5) * 0.08;

      final ringPaint = Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(centerX, centerY), radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 计算机领军人物背景组件（主界面）
class TechPioneersHomeBackground extends StatefulWidget {
  final Widget child;

  const TechPioneersHomeBackground({
    super.key,
    required this.child,
  });

  @override
  State<TechPioneersHomeBackground> createState() => _TechPioneersHomeBackgroundState();
}

class _TechPioneersHomeBackgroundState extends State<TechPioneersHomeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20), // 更慢的动画
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
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TechPioneersHomeBackgroundPainter(
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

// ==================== 科技进化风特效组件 ====================

/// 签到爆炸粒子特效
/// 粒子数量: 40个
/// 粒子类型: 圆形、星形、三角形
/// 爆炸速度: 随机 200-500 px/s
/// 方向: 360度均匀分布
/// 重力: 200 px/s²
/// 生命周期: 1.0秒
/// 颜色: 绿色(#4CAF50) + 金色(#FFD700) + 青色(#80DEEA)
class CheckInExplosion extends StatefulWidget {
  final bool trigger;
  final Offset center;
  final VoidCallback? onComplete;

  const CheckInExplosion({
    super.key,
    required this.trigger,
    required this.center,
    this.onComplete,
  });

  @override
  State<CheckInExplosion> createState() => _CheckInExplosionState();
}

class _CheckInExplosionState extends State<CheckInExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ExplosionParticle> _particles = [];
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.addListener(() {
      if (_controller.isCompleted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(CheckInExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !_hasTriggered) {
      _hasTriggered = true;
      _createParticles();
      _controller.forward(from: 0);
    } else if (!widget.trigger) {
      _hasTriggered = false;
      _controller.reset();
    }
  }

  void _createParticles() {
    _particles.clear();
    final random = math.Random();

    for (int i = 0; i < 40; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 200 + random.nextDouble() * 300;
      final colorIndex = random.nextInt(TechEvolutionColors.explosionColors.length);
      final shapeIndex = random.nextInt(3); // 0: 圆形, 1: 星形, 2: 三角形

      _particles.add(ExplosionParticle(
        angle: angle,
        speed: speed,
        color: TechEvolutionColors.explosionColors[colorIndex],
        shape: shapeIndex,
        size: 4 + random.nextDouble() * 6,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.trigger || _controller.value == 0) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ExplosionPainter(
            particles: _particles,
            progress: _controller.value,
            center: widget.center,
          ),
        ),
      ),
    );
  }
}

/// 爆炸粒子数据类
class ExplosionParticle {
  final double angle;
  final double speed;
  final Color color;
  final int shape; // 0: 圆形, 1: 星形, 2: 三角形
  final double size;

  ExplosionParticle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.shape,
    required this.size,
  });
}

/// 爆炸特效绘制器
class _ExplosionPainter extends CustomPainter {
  final List<ExplosionParticle> particles;
  final double progress;
  final Offset center;

  _ExplosionPainter({
    required this.particles,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gravity = 200.0;
    const duration = 1.0;

    for (final particle in particles) {
      final t = progress * duration;
      final distance = particle.speed * t;
      final gravityOffset = 0.5 * gravity * t * t;

      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance + gravityOffset;

      final alpha = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withOpacity(alpha)
        ..style = PaintingStyle.fill;

      _drawParticleShape(canvas, x, y, particle.size, particle.shape, paint);
    }
  }

  void _drawParticleShape(Canvas canvas, double x, double y, double size, int shape, Paint paint) {
    switch (shape) {
      case 0: // 圆形
        canvas.drawCircle(Offset(x, y), size / 2, paint);
        break;
      case 1: // 星形
        _drawStar(canvas, x, y, size, paint);
        break;
      case 2: // 三角形
        _drawTriangle(canvas, x, y, size, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    const points = 5;
    final outerRadius = size / 2;
    final innerRadius = size / 4;

    for (int i = 0; i < points * 2; i++) {
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final angle = (i * math.pi / points) - math.pi / 2;
      final px = x + math.cos(angle) * radius;
      final py = y + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;

    path.moveTo(x, y - radius);
    path.lineTo(x + radius * math.sin(math.pi / 3), y + radius * math.cos(math.pi / 3));
    path.lineTo(x - radius * math.sin(math.pi / 3), y + radius * math.cos(math.pi / 3));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 数据波形背景覆盖层
/// 波纹数量: 4条
/// 波浪幅度: 25px
/// 流动速度: 每条约20-40秒完成一次循环
/// 颜色: 蓝紫渐变与绿色代码雨融合
/// 透明度: 15%（不干扰内容）
/// 位置: 屏幕中下部
class DataWaveOverlay extends StatefulWidget {
  final Widget child;

  const DataWaveOverlay({
    super.key,
    required this.child,
  });

  @override
  State<DataWaveOverlay> createState() => _DataWaveOverlayState();
}

class _DataWaveOverlayState extends State<DataWaveOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
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
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _DataWavePainter(
                    animationValue: _controller.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 数据波形绘制器
class _DataWavePainter extends CustomPainter {
  final double animationValue;

  _DataWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 波纹配置
    final waves = [
      {'amplitude': 20.0, 'frequency': 0.01, 'speed': 0.5, 'offset': 0.0},
      {'amplitude': 25.0, 'frequency': 0.008, 'speed': 0.3, 'offset': 1.5},
      {'amplitude': 15.0, 'frequency': 0.012, 'speed': 0.4, 'offset': 3.0},
      {'amplitude': 18.0, 'frequency': 0.009, 'speed': 0.35, 'offset': 4.5},
    ];

    final baseY = size.height * 0.75; // 波浪在屏幕中下部

    for (int i = 0; i < waves.length; i++) {
      final wave = waves[i];
      final amplitude = wave['amplitude'] as double;
      final frequency = wave['frequency'] as double;
      final speed = wave['speed'] as double;
      final offset = wave['offset'] as double;

      final path = Path();
      final phase = animationValue * speed + offset;

      // 使用渐变色
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: i % 2 == 0
            ? [
                TechEvolutionColors.dataWave,
                TechEvolutionColors.dataWaveAccent,
              ]
            : [
                TechEvolutionColors.dataWaveAccent,
                TechEvolutionColors.dataWave,
              ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, baseY - 50, size.width, 100))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      // 绘制波浪
      for (double x = 0; x <= size.width; x += 2) {
        final y = baseY +
            math.sin(x * frequency + phase * 2 * math.pi) * amplitude +
            math.sin(x * frequency * 0.5 + phase * math.pi) * amplitude * 0.5;

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }

    // 绘制底部渐变填充
    final fillPath = Path();
    final baseWave = waves[0];
    final baseAmplitude = baseWave['amplitude'] as double;
    final baseFrequency = baseWave['frequency'] as double;
    final baseSpeed = baseWave['speed'] as double;
    final baseOffset = baseWave['offset'] as double;
    final basePhase = animationValue * baseSpeed + baseOffset;

    fillPath.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 2) {
      final y = baseY +
          math.sin(x * baseFrequency + basePhase * 2 * math.pi) * baseAmplitude +
          math.sin(x * baseFrequency * 0.5 + basePhase * math.pi) * baseAmplitude * 0.5;
      fillPath.lineTo(x, y);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        TechEvolutionColors.dataWave.withOpacity(0.1),
        TechEvolutionColors.dataWave.withOpacity(0.05),
        Colors.transparent,
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, baseY - 50, size.width, size.height - baseY + 50))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
