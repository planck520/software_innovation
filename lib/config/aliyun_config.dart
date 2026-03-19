/// 阿里云配置
class AliyunConfig {
  // FaceBody API 配置
  static const String accessKeyId = 'LTAI5t7e7h1cEcr56ymnAgvm';
  static const String accessKeySecret = 'wekeJpmt4m7nRvT4DMaRXvdiFmQvzT';
  static const String facebodyEndpoint = 'facebody.cn-shanghai.aliyuncs.com';
  static const String apiVersion = '2019-12-30';

  // OSS 配置（需要自己创建）
  static const String ossBucket = 'your-bucket-name';  // TODO: 替换为你的 OSS Bucket 名称
  static const String ossEndpoint = 'oss-cn-shanghai.aliyuncs.com';  // 上海区域
  static const String ossRegion = 'cn-shanghai';

  /// 是否已配置 OSS
  static bool get isOssConfigured =>
      ossBucket != 'your-bucket-name' &&
      ossBucket.isNotEmpty;

  /// 获取完整的 OSS 端点
  static String get ossFullEndpoint => 'https://$ossBucket.$ossEndpoint';
}
