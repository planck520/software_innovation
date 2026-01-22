import 'package:flutter/material.dart';
import '../main.dart' show isDarkBackground;

/// stitch_login_screen 风格配色系统 - 蓝紫赛博风格
class AppColors {
  // ==================== 主色调 ====================
  static const Color primary = Color(0xFF135bec);        // 主蓝色
  static const Color cyberBlue = Color(0xFF00f2ff);      // 赛博蓝
  static const Color cyberPurple = Color(0xFFbc13fe);    // 赛博紫

  // ==================== 赛博风格增强色彩 ====================
  static const Color cyberCyan = Color(0xFF00F5FF);      // 赛博青
  static const Color cyberMagenta = Color(0xFFFF00FF);   // 赛博品红
  static const Color cyberYellow = Color(0xFFFFD700);    // 赛博黄

  // ==================== 渐变增强色 ====================
  static const List<Color> neonGradient = [
    Color(0xFF00F5FF),  // 赛博青
    Color(0xFF135bec),  // 主蓝
    Color(0xFFbc13fe),  // 赛博紫
  ];

  // ==================== 状态增强色 ====================
  static const Color info = Color(0xFF06B6D4);           // 信息色
  static const Color accent = Color(0xFF8B5CF6);         // 强调色

  // ==================== 背景色 ====================
  static const Color background = Color(0xFFf6f6f8);     // 浅色背景
  static const Color backgroundDark = Color(0xFF101622); // 深色背景

  // 动态表面颜色
  static Color get surface => isDarkBackground
      ? const Color(0xFF1a1f2c)  // 深色卡片
      : const Color(0xFFFFFFFF); // 纯白卡片

  static Color get surfaceDim => isDarkBackground
      ? const Color(0xFF252b3b)
      : const Color(0xFFE8EDF3);

  // 选项框/卡片背景（深色模式用浅黑色）
  static Color get cardBackground => isDarkBackground
      ? const Color(0xFF252b3b).withOpacity(0.9)  // 深色模式：浅黑色
      : Colors.white.withOpacity(0.7);             // 浅色模式：半透明白

  // ==================== 文字色 ====================
  static Color get textPrimary => isDarkBackground
      ? const Color(0xFFFFFFFF)   // 深色模式：纯白文字
      : const Color(0xFF0d121b);  // 浅色模式：深色文字

  static Color get textSecondary => isDarkBackground
      ? const Color(0xFFB8C0CC)   // 深色模式：较亮的灰色
      : const Color(0xFF4c669a);

  static Color get textTertiary => isDarkBackground
      ? const Color(0xFF8B95A5)   // 深色模式：中等灰色
      : const Color(0xFF8B95A5);

  // ==================== 功能色 ====================
  static const Color success = Color(0xFF07883b);        // 成功：绿色
  static const Color warning = Color(0xFFd97706);        // 警告：琥珀色
  static const Color error = Color(0xFFEF4444);          // 错误：红色
  static const Color secondary = Color(0xFFbc13fe);      // 次强调：紫色

  // ==================== 边框/分隔 ====================
  static Color get border => isDarkBackground
      ? const Color(0xFF374151)
      : const Color(0xFFE2E8F0);

  static const Color shadow = Color(0x2694A3B8);         // 阴影 (rgba)

  static Color get divider => isDarkBackground
      ? const Color(0xFF374151)
      : const Color(0xFFE2E8F0);

  // ==================== 玻璃态相关 ====================
  static Color get glassSurface => isDarkBackground
      ? const Color(0xFF1a1f2c)
      : const Color(0xFFFFFFFF);

  static Color get glassBorder => isDarkBackground
      ? const Color(0x40FFFFFF)
      : const Color(0x80FFFFFF);

  static const Color glassShadow = Color(0x1A135bec);    // 10% 主蓝阴影

  static Color get glassBackground => isDarkBackground
      ? const Color(0xFF1a1f2c).withOpacity(0.8)
      : Colors.white.withOpacity(0.7);

  // ==================== 霓虹发光效果 ====================
  static Color get neonGlow => primary.withOpacity(0.4);      // 蓝色发光
  static Color get cyberGlow => cyberBlue.withOpacity(0.6);   // 赛博蓝发光
  static Color get purpleGlow => cyberPurple.withOpacity(0.4); // 紫色发光

  // ==================== 状态颜色（柔和版）====================
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warningLight = Color(0xFFFED7AA);
  static const Color errorLight = Color(0xFFFECACA);
  static const Color primaryLight = Color(0xFFDBEAFE);   // 浅蓝背景

  // ==================== 渐变色 ====================
  static const List<Color> primaryGradient = [
    Color(0xFF135bec),  // 主蓝
    Color(0xFFbc13fe),  // 赛博紫
  ];

  static const List<Color> cyberGradient = [
    Color(0xFF00f2ff),  // 赛博蓝
    Color(0xFF135bec),  // 主蓝
  ];

  static const List<Color> techGradient = [
    Color(0xFF135bec),  // 主蓝
    Color(0xFF00f2ff),  // 赛博蓝
    Color(0xFFbc13fe),  // 赛博紫
  ];

  static const List<Color> surfaceGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFC),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFf6f6f8),
    Color(0xFFE8EDF3),
  ];

  // ==================== 网格背景 ====================
  static Color get cyberGridColor => primary.withOpacity(0.05); // 5% 主蓝网格线

  // ==================== iOS 风格阴影 ====================
  static const List<BoxShadow> iosLightShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> iosMediumShadow = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  // ==================== 霓虹阴影 ====================
  static List<BoxShadow> get neonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  // ==================== 多彩发光效果 ====================
  static List<BoxShadow> get multiColorGlow => [
    BoxShadow(
      color: cyberCyan.withOpacity(0.5),
      blurRadius: 20,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: cyberPurple.withOpacity(0.3),
      blurRadius: 30,
      offset: const Offset(0, 0),
    ),
  ];

  // ==================== 脉冲发光效果 ====================
  static List<BoxShadow> get pulseGlow => [
    BoxShadow(
      color: primary.withOpacity(0.6),
      blurRadius: 8,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get glassCardShadow => [
    BoxShadow(
      color: primary.withOpacity(0.1),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== 监控区（深色）====================
  static const Color monitorBg = Color(0xFF101622);
  static const Color monitorSurface = Color(0xFF1a1f2c);

  // ==================== 输入框背景 ====================
  static Color get inputBackground => isDarkBackground
      ? const Color(0xFF252b3b)
      : Colors.white.withOpacity(0.5);
}
