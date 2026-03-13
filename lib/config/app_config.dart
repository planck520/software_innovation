import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用配置 - 避免循环依赖
/// 此文件包含需要在 main.dart 和 app_colors.dart 之间共享的配置

/// 是否使���深色背景
bool isDarkBackground = false;

/// 初始化应用配置
Future<void> initAppConfig() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkBackground = prefs.getBool('is_dark_background') ?? false;
}

/// 切换深色/浅色背景
Future<void> toggleDarkBackground(bool value) async {
  isDarkBackground = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_dark_background', value);
}

/// 主题变更通知器
class ThemeNotifier extends ValueNotifier<bool> {
  ThemeNotifier(bool value) : super(value);

  void updateTheme(bool isDark) {
    value = isDark;
  }
}

/// 全局主题通知器
late ThemeNotifier themeNotifier;
