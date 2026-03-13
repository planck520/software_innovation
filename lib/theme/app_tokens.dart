import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 设计系统 Tokens - stitch_login_screen 风格
class AppTokens {
  // ==================== 间距系统 (8pt 基础网格) ====================
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;

  // ==================== 圆角系统 (stitch 规范) ====================
  static const double radiusXs = 4.0;    // 0.25rem - 默认小圆角
  static const double radiusSm = 8.0;    // 0.5rem - lg
  static const double radiusMd = 12.0;   // 0.75rem - xl
  static const double radiusLg = 16.0;   // 1rem - 2xl
  static const double radiusXl = 20.0;   // 1.25rem
  static const double radius2xl = 24.0;  // 1.5rem - 3xl
  static const double radiusFull = 9999.0; // 全圆

  // ==================== 网格背景参数 ====================
  static const double cyberGridSize = 20.0;  // 网格大小 20px
  static const double cyberGridLineWidth = 1.0;

  // ==================== 阴影层级 ====================
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 12),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 0), blurRadius: 24),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 16),
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 0), blurRadius: 32),
  ];

  // ==================== 玻璃态阴影 (stitch 风格) ====================
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.1),
      offset: const Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  // ==================== 霓虹发光阴影 ====================
  static List<BoxShadow> get neonGlowShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  // ==================== 动画时长 ====================
  static const int durationFast = 150;
  static const int durationNormal = 250;
  static const int durationSlow = 350;
  static const int durationSlower = 500;
  static const int durationStagger = 100;    // 交错动画间隔
  static const int durationPulse = 1500;     // 脉冲动画周期
  static const int durationEntry = 900;      // 入场动画总时长

  // ==================== 动画曲线 ====================
  static const Curve curveIOS = Cubic(0.25, 0.1, 0.25, 1.0);
  static const Curve curveSpring = Cubic(0.175, 0.885, 0.32, 1.275);
  static const Curve curveEaseOut = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve curveEaseInOut = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve curveBounce = Cubic(0.68, -0.55, 0.265, 1.55);  // 弹跳效果
  static const Curve curveDecelerate = Cubic(0.0, 0.0, 0.2, 1.0);    // 减速曲线

  // ==================== 渐变 (stitch 风格) ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.primaryGradient,
  );

  static const LinearGradient techGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.techGradient,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.cyberGradient,
  );

  // 背景装饰渐变 (模糊球)
  static LinearGradient get blurBallGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary.withOpacity(0.1),
      AppColors.cyberPurple.withOpacity(0.1),
    ],
  );

  // ==================== 输入框高度 ====================
  static const double inputHeight = 39.0; // 缩小30%: 56 * 0.7 = 39.2 ≈ 39

  // ==================== 按钮尺寸 ====================
  static const double buttonHeight = 39.0;       // 缩小30%: 56 * 0.7 = 39.2 ≈ 39
  static const double buttonHeightSm = 28.0;     // 缩小30%: 40 * 0.7 = 28
  static const double buttonHeightLg = 45.0;     // 缩小30%: 64 * 0.7 = 44.8 ≈ 45

  // ==================== 芯片尺寸 ====================
  static const double chipHeight = 36.0;
  static const double chipHeightSmall = 28.0;

  // ==================== 开关尺寸 ====================
  static const double toggleWidth = 44.0;
  static const double toggleHeight = 24.0;

  // ==================== 图标尺寸 ====================
  static const double iconSm = 11.2;
  static const double iconMd = 14.0;
  static const double iconLg = 16.8;
  static const double iconXl = 22.4;
}
