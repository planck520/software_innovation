import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 环境变量配置加载器
class EnvConfig {
  static bool _initialized = false;

  /// 初始化环境变量
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      await dotenv.load(fileName: ".env");
      _initialized = true;
      print("✓ 环境变量加载成功");
    } catch (e) {
      print("✗ 环境变量加载失败: $e");
      print("请确保 .env 文件存在且格式正确");
      rethrow;
    }
  }

  /// 获取环境变量值
  static String getValue(String key, {String? defaultValue}) {
    if (!_initialized) {
      throw StateError("EnvConfig 未初始化，请先调用 EnvConfig.init()");
    }

    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw ArgumentError("环境变量 '$key' 未配置");
    }
    return value;
  }

  /// 获取环境变量值（可空）
  static String? getOrNull(String key) {
    if (!_initialized) {
      throw StateError("EnvConfig 未初始化，请先调用 EnvConfig.init()");
    }
    return dotenv.env[key];
  }

  /// 检查环境变量是否已配置
  static bool has(String key) {
    if (!_initialized) {
      throw StateError("EnvConfig 未初始化，请先调用 EnvConfig.init()");
    }
    final value = dotenv.env[key];
    return value != null && value.isNotEmpty;
  }

  /// 腾讯云配置
  static String get tencentSecretId => getValue('TENCENT_SECRET_ID');
  static String get tencentSecretKey => getValue('TENCENT_SECRET_KEY');

  /// 讯飞配置
  static String get xfyunAppId => getValue('XFYUN_APP_ID');
  static String get xfyunApiKey => getValue('XFYUN_API_KEY');
  static String get xfyunApiSecret => getValue('XFYUN_API_SECRET');

  /// DeepSeek 配置
  static String get apiKey => getValue('DEEPSEEK_API_KEY');
}