import 'package:flutter/material.dart';
import 'login_theme.dart';

/// 面试页面专用主题
/// 使用色卡颜色与登录界面保持一致的深色风格
class InterviewTheme {
  // ==================== 基础颜色（与LoginTheme一致）====================

  // 背景色 - 深黑
  static const Color background = LoginTheme.background;

  // 卡片样式 - 深灰
  static const Color cardBackground = LoginTheme.cardBackground;
  static const Color cardBorder = LoginTheme.cardBorder;

  // 表面颜色 - 中灰
  static const Color surface = LoginTheme.inputBackground;

  // 文字颜色 - 浅色
  static const Color textPrimary = LoginTheme.textPrimary;
  static const Color textSecondary = LoginTheme.textSecondary;

  // ==================== 色卡强调色 ====================

  // 浅蓝 - 主要操作、AI就绪、主观题
  static const Color accentBlue = Color(0xFF4DA3D6);

  // 浅绿 - 成功、基础难度、算法题
  static const Color accentGreen = Color(0xFF8FB35A);

  // 橙色 - 警告、中等难度
  static const Color accentOrange = Color(0xFFCF7E3D);

  // 暖红 - 错误、困难
  static const Color accentRed = Color(0xFFBF6969);

  // 浅紫 - 客观题、辅助强调
  static const Color accentPurple = Color(0xFF9B8AA6);

  // 浅粉 - 特殊标签
  static const Color accentPink = Color(0xFFAF949D);

  // 浅黄 - 特殊强调
  static const Color accentYellow = Color(0xFFE8D89C);

  // ==================== 辅助方法 ====================

  /// 根据难度等级获取颜色
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '基础':
        return accentGreen;
      case '中等':
        return accentOrange;
      case '困难':
        return accentRed;
      case '自适应':
        return accentBlue;
      default:
        return accentBlue;
    }
  }

  /// 根据题目类型获取颜色
  static Color getQuestionTypeColor(String type) {
    switch (type) {
      case '主观题':
        return accentBlue;
      case '客观题':
        return accentPurple;
      case '算法题':
        return accentGreen;
      default:
        return accentBlue;
    }
  }
}
