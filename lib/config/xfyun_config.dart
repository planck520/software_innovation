import 'env_config.dart';

/// 讯飞语音配置
class XfyunConfig {
  /// 应用ID
  static String get appId => EnvConfig.xfyunAppId;

  /// API Key
  static String get apiKey => EnvConfig.xfyunApiKey;

  /// API Secret
  static String get apiSecret => EnvConfig.xfyunApiSecret;

  // API 端点
  static const String host = 'iat-api.xfyun.cn';
  static const String path = '/v2/iat';
}