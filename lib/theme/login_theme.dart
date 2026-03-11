import 'package:flutter/material.dart';

/// 登录页面黑白简约风格主题（深色版）
/// 同时作为全局主界面主题
class LoginTheme {
  // ==================== 基础颜色 ====================

  // 背景色 - 深黑
  static const Color background = Color(0xFF1A1A1A);

  // 卡片样式 - 深灰
  static const Color cardBackground = Color(0xFF2D2D2D);
  static const Color cardBorder = Color(0xFF404040);
  static const Color surface = Color(0xFF3A3A3A);

  // 文字颜色 - 浅色
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);

  // 按钮样式 - 深色按钮
  static const Color buttonBackground = Color(0xFF1A1A1A);
  static const Color buttonText = Color(0xFFFFFFFF);

  // 输入框样式 - 深灰
  static const Color inputBackground = Color(0xFF3A3A3A);
  static const Color inputBorder = Color(0xFF505050);
  static const Color inputFocusBorder = Color(0xFFFFFFFF);

  // 复选框颜色
  static const Color checkboxActive = Color(0xFFFFFFFF);

  // 链接颜色
  static const Color linkColor = Color(0xFFFFFFFF);

  // ==================== 彩色强调色（用于文字/图标点缀） ====================

  // 蓝色强调 - 面试房间
  static const Color accentBlue = Color(0xFF135BEC);

  // 青色强调 - 定制面试
  static const Color accentCyan = Color(0xFF00BCD4);

  // 绿色强调 - 签到
  static const Color accentGreen = Color(0xFF4CAF50);

  // 橙色强调 - 选中状态
  static const Color accentOrange = Color(0xFFFF8C00);

  // 紫色强调
  static const Color accentPurple = Color(0xFF9C27B0);

  // 黄色强调
  static const Color accentYellow = Color(0xFFFFD54F);

  // 红色强调 - 错误状态
  static const Color accentRed = Color(0xFFEF4444);
}
