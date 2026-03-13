import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 字体系统 - iOS 风格
class AppTextStyles {
  // ==================== 标题样式 ====================
  static TextStyle get displayLarge => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get headline => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get title => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get subtitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ==================== 正文样式 ====================
  static TextStyle get body => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ==================== 辅助文字样式 ====================
  static TextStyle get caption => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get footnote => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  // ==================== 按钮文字样式 ====================
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // ==================== 标签样式 ====================
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static const TextStyle labelTiny = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // ==================== 芯片/按钮样式 ====================
  static const TextStyle chipLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static const TextStyle chipLabelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // ==================== Tab栏样式 ====================
  static TextStyle get tabBarLabel => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ==================== 分节标题样式 ====================
  static TextStyle get sectionTitle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get sectionSubtitle => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ==================== 下拉选项样式 ====================
  static TextStyle get dropdownItem => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
    height: 1.4,
  );
}
