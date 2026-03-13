import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

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

/// 调用情绪/表情检测微服务的客户端
///
/// 默认假设服务运行在 http://localhost:5000
class EmotionService {
  final String baseUrl; // 例如 http://192.168.1.10:5000

  const EmotionService({this.baseUrl = 'http://localhost:5000'});

  /// 调用 /analyze_frame 接口
  /// [sessionId] 用于和主系统的面试会话绑定，可以任意字符串
  /// [imageBytes] 是一帧图片（如相机截图）的二进制数据
  Future<EmotionResult?> analyzeFrame({
    required String sessionId,
    required Uint8List imageBytes,
  }) async {
    final url = Uri.parse('$baseUrl/analyze_frame');
    final b64 = base64Encode(imageBytes);

    final resp = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'frame_data': b64,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Emotion server error: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      return null; // 或者抛出异常，看你如何处理失败
    }

    return EmotionResult.fromJson(data);
  }
}
