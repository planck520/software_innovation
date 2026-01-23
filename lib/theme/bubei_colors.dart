import 'package:flutter/material.dart';

/// 不背单词风格深色配色系统
/// 深色卡片设计风格，背景 #121212，卡片 #1E2532
class BubeiColors {
  // ==================== 背景色 ====================
  static const Color background = Color(0xFF121212);        // 深色背景
  static const Color surface = Color(0xFF1E2532);           // 卡片背景
  static const Color surfaceElevated = Color(0xFF2A3444);   // 浮起卡片
  static const Color surfaceDim = Color(0xFF1A202C);        // 暗色表面

  // ==================== 文字色 ====================
  static const Color textPrimary = Color(0xFFFFFFFF);       // 主要文字
  static const Color textSecondary = Color(0xFFB8C0CC);     // 次要文字
  static const Color textTertiary = Color(0xFF6B7280);      // 三级文字
  static const Color textDisabled = Color(0xFF4B5563);      // 禁用文字

  // ==================== 主题色 ====================
  static const Color primary = Color(0xFF3B82F6);           // 主色蓝色
  static const Color primaryDim = Color(0xFF1E40AF);        // 暗蓝色
  static const Color primaryLight = Color(0xFF60A5FA);      // 亮蓝色

  // ==================== 功能色 ====================
  static const Color success = Color(0xFF10B981);           // 成功绿色
  static const Color warning = Color(0xFFF59E0B);           // 警告橙色
  static const Color error = Color(0xFFEF4444);             // 错误红色
  static const Color info = Color(0xFF06B6D4);              // 信息青色

  // ==================== 渐变色 ====================
  static const List<Color> primaryGradient = [
    Color(0xFF3B82F6),
    Color(0xFF2563EB),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  // ==================== 遮罩色 ====================
  static const Color overlay = Color(0x80000000);           // 半透明遮罩
  static const Color overlayLight = Color(0x40000000);      // 轻遮罩

  // ==================== 边框色 ====================
  static const Color border = Color(0xFF374151);            // 边框色
  static const Color divider = Color(0xFF2D3748);           // 分割线

  // ==================== 阴影 ====================
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  // ==================== 输入框背景 ====================
  static const Color inputBackground = Color(0xFF2A3444);
  static const Color inputBorder = Color(0xFF374151);
  static const Color inputFocusedBorder = Color(0xFF3B82F6);

  // ==================== 按钮样式 ====================
  static const Color buttonBackground = Color(0xFF3B82F6);
  static const Color buttonBackgroundDisabled = Color(0xFF374151);
  static const Color buttonForeground = Color(0xFFFFFFFF);

  // ==================== 卡片圆角 ====================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusFull = 999.0;

  // ==================== 间距 ====================
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
}

// ==================== 科技进化风配色系统 ====================
/// 科技进化风磨砂玻璃按钮配色
class TechEvolutionColors {
  // 纯磨砂玻璃按钮 - 参考不背单词样式
  static const Color glassFrosted = Color(0x33FFFFFF);     // 白色 20% - 适中透明度
  static const Color glassIconBg = Color(0x1AFFFFFF);      // 图标背景 10%
  static const Color glassGreen = Color(0xFF4CAF50);       // 签到绿色（不背单词风格���
  static const Color glassGreenDim = Color(0x664CAF50);    // 绿色 40%

  // 彩色磨砂玻璃（保留用于其他组件）
  static const Color glassBlue = Color(0x66135bec);       // 蓝色 40%
  static const Color glassPurple = Color(0x66bc13fe);     // 紫色 40%
  static const Color glassCyan = Color(0x6680DEEA);       // 青色 40%

  // 边框渐变色
  static const List<Color> greenGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];

  static const List<Color> bluePurpleGradient = [
    Color(0xFF135bec),
    Color(0xFFbc13fe),
  ];

  static const List<Color> cyanGradient = [
    Color(0xFF80DEEA),
    Color(0xFF26C6DA),
  ];

  // 爆炸粒子色
  static const List<Color> explosionColors = [
    Color(0xFF4CAF50),  // 绿
    Color(0xFFFFD700),  // 金
    Color(0xFF80DEEA),  // 青
  ];

  // 数据波形色 - 15% 透明度
  static const Color dataWave = Color(0x2600F5FF);  // 青色 15%
  static const Color dataWaveAccent = Color(0x26bc13fe);  // 紫色 15%
}
