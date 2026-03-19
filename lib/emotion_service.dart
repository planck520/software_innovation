import 'dart:typed_data';
import 'package:software_innovation/services/tencent_face_service.dart';
import 'package:software_innovation/utils/image_compressor.dart';

/// 情绪分析结果模型
class EmotionResult {
  final String emotion; // 原始英文标签，如 happy
  final double confidence; // 最高情绪置信度
  final String chineseEmotion; // 映射后的中文情绪，如 快乐
  final Map<String, double> allEmotions; // 所有情绪的概率分布

  EmotionResult({
    required this.emotion,
    required this.confidence,
    required this.chineseEmotion,
    required this.allEmotions,
  });

  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    final all = <String, double>{};
    final allMap = result['allEmotions'] as Map<String, dynamic>?;
    if (allMap != null) {
      allMap.forEach((key, value) {
        all[key] = (value as num).toDouble();
      });
    }

    return EmotionResult(
      emotion: result['emotion'] as String? ?? 'unknown',
      confidence: (result['confidence'] as num?)?.toDouble() ?? 0.0,
      chineseEmotion: result['chineseEmotion'] as String? ?? '',
      allEmotions: all,
    );
  }
}

/// 调用情绪/表情检测的服务客户端
///
/// 现在使用腾讯云 API 进行情绪识别
class EmotionService {
  late final TencentFaceService tencentService;

  EmotionService({
    String? accessKeyId,
    String? accessKeySecret,
    String? baseUrl, // 保留此参数以兼容旧代码，但不再使用
  }) {
    final finalKeyId = accessKeyId;
    final finalSecret = accessKeySecret;
    tencentService = TencentFaceService(
      secretId: finalKeyId,
      secretKey: finalSecret,
    );
  }

  /// 分析视频帧情绪（使用腾讯云 API）
  Future<EmotionResult?> analyzeFrame({
    required String sessionId,
    required Uint8List imageBytes,
  }) async {
    try {
      // 压缩图片
      final compressed = await ImageCompressor.compress(imageBytes);

      // 调用腾讯云 API
      final result = await tencentService.detectFaceAttributes(compressed);

      if (result != null) {
        return EmotionResult(
          emotion: result.emotion,
          confidence: result.confidence,
          chineseEmotion: result.chineseEmotion,
          allEmotions: result.allEmotions,
        );
      }

      // 静默失败
      return null;
    } catch (e) {
      print('情绪分析失败: $e');
      return null;
    }
  }
}
