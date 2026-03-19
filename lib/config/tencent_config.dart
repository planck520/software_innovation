/// 腾讯云配置
class TencentConfig {
  // 人脸检测与属性分析 API 配置
  static const String secretId = 'AKIDBwVu7EBzfJl2AEJMJEFBxzEVfGrKdptl';
  static const String secretKey = 'vSoyynSvFOM8i8MODsrgO8oijlfbeZfr';

  // API 配置
  static const String endpoint = 'iai.tencentcloudapi.com';
  static const String region = 'ap-guangzhou';
  static const String apiVersion = '2018-03-01';
  static const String action = 'DetectFaceAttributes';

  /// 腾讯云情绪映射到中文
  static const Map<String, String> emotionMap = {
    'happy': '快乐',
    'sad': '悲伤',
    'angry': '愤怒',
    'disgusted': '厌恶',
    'fearful': '恐惧',
    'surprised': '惊讶',
    'neutral': '平静',
  };

  /// 获取默认的情绪中文映射
  static String getChineseEmotion(String englishEmotion) {
    return emotionMap[englishEmotion] ?? '未知';
  }
}
