import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/aliyun_config.dart';

/// 阿里云表情识别服务 V2
///
/// 使用说明：
/// 1. 阿里云 RecognizeExpression API 需要 ImageURL 参数
/// 2. 由于没有官方 Flutter SDK，我们需要先将图片上传到可访问的位置
/// 3. 本服务提供两种模式：
///    - 真实模式：上传到 OSS（需要配置 OSS）
///    - 模拟模式：返回模拟数据（用于测试）
class AliyunExpressionService {
  final String accessKeyId;
  final String accessKeySecret;
  final String endpoint;

  AliyunExpressionService({
    String? accessKeyId,
    String? accessKeySecret,
    this.endpoint = AliyunConfig.facebodyEndpoint,
  }) : accessKeyId = accessKeyId ?? AliyunConfig.accessKeyId,
       accessKeySecret = accessKeySecret ?? AliyunConfig.accessKeySecret;

  /// 表情映射到中文
  static const Map<String, String> expressionMap = {
    'neutral': '平静',
    'happiness': '快乐',
    'surprise': '惊讶',
    'sadness': '悲伤',
    'anger': '愤怒',
    'disgust': '厌恶',
    'fear': '恐惧',
    'pouty': '嘟嘴',
    'grimace': '鬼脸',
  };

  /// 调用表情识别 API
  ///
  /// 由于阿里云 API 需要 ImageURL，当前实现使用模拟数据
  /// 如果需要真实识别，请配置 OSS 或使用其他方案
  Future<ExpressionResult?> recognizeExpression(Uint8List imageBytes) async {
    try {
      print('[Aliyun API] === 开始表情识别 ===');
      print('[Aliyun API] 图片大小: ${imageBytes.length} bytes');

      // 检查是否配置了 OSS
      if (!AliyunConfig.isOssConfigured) {
        print('[Aliyun API] ⚠️ OSS 未配置');
        print('[Aliyun API] 使用模拟数据模式');
        print('[Aliyun API]');
        print('[Aliyun API] 💡 启用真实识别需要：');
        print('[Aliyun API] 1. 创建阿里云 OSS Bucket（华东2-上海）');
        print('[Aliyun API] 2. 设置读写权限为「公共读」');
        print('[Aliyun API] 3. 修改 lib/config/aliyun_config.dart 中的 ossBucket');

        return _getSimulatedResult();
      }

      // TODO: 实现真实的 OSS 上传 + API 调用
      // 由于 flutter_oss_aliyun 配置复杂，这里先使用模拟数据
      print('[Aliyun API] ⚠️ OSS 上传功能待实现');
      return _getSimulatedResult();

    } catch (e, stackTrace) {
      print('[Aliyun API] ❌ 异常: $e');
      print('[Aliyun API] 堆栈: $stackTrace');
      return _getSimulatedResult();
    }
  }

  /// 生成阿里云 API 签名
  String _generateSignature(
    String method,
    Map<String, String> params,
  ) {
    // 按字母顺序排序参数
    var sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );

    // 构造查询字符串
    String queryString = sortedParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    // 构造待签名字符串
    String stringToSign = '$method&${Uri.encodeComponent('/')}&${Uri.encodeComponent(queryString)}';

    // 生成签名
    var key = utf8.encode('$accessKeySecret&');
    var hmac = Hmac(sha1, key);
    var digest = hmac.convert(utf8.encode(stringToSign));

    return base64.encode(digest.bytes);
  }

  /// 获取模拟结果（用于测试）
  ExpressionResult _getSimulatedResult() {
    // 基于时间生成"伪随机"的情绪
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 定义情绪类型和对应的中文名称
    final emotions = [
      {'key': 'neutral', 'name': '平静'},
      {'key': 'happiness', 'name': '快乐'},
      {'key': 'surprise', 'name': '惊讶'},
      {'key': 'sadness', 'name': '悲伤'},
    ];

    // 每10秒切换一次情绪
    final emotionIndex = (timestamp ~/ 10000) % emotions.length;
    final emotion = emotions[emotionIndex];

    // 置信度在 0.6-0.95 之间波动
    final confidence = 0.6 + ((timestamp % 3500) / 10000.0);

    print('[Aliyun API] 📊 模拟情绪: ${emotion['name']} (置信度: ${confidence.toStringAsFixed(2)})');

    return ExpressionResult(
      expression: emotion['key'] as String,
      confidence: confidence,
      chineseExpression: emotion['name'] as String,
      faceRectangle: FaceRectangle(
        top: 100,
        left: 100,
        width: 200,
        height: 200,
      ),
    );
  }
}

/// 表情识别结果
class ExpressionResult {
  final String expression;  // 表情类型
  final double confidence;  // 置信度
  final String chineseExpression;  // 中文表情
  final FaceRectangle faceRectangle;  // 人脸区域

  ExpressionResult({
    required this.expression,
    required this.confidence,
    required this.chineseExpression,
    required this.faceRectangle,
  });

  factory ExpressionResult.fromJson(Map<String, dynamic> json) {
    return ExpressionResult(
      expression: json['Expression'] as String? ?? 'neutral',
      confidence: (json['FaceProbability'] as num?)?.toDouble() ?? 0.0,
      chineseExpression: AliyunExpressionService.expressionMap[
              json['Expression'] as String? ?? 'neutral'] ??
          '未知',
      faceRectangle: FaceRectangle.fromJson(
          json['FaceRectangle'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// 转换为与现有 EmotionResult 兼容的格式
  Map<String, dynamic> toEmotionResultFormat() {
    return {
      'emotion': expression,
      'confidence': confidence,
      'chineseEmotion': chineseExpression,
      'allEmotions': {
        'neutral': 0.1,
        'happiness': 0.1,
        'surprise': 0.1,
        'sadness': 0.1,
        'anger': 0.1,
        'disgust': 0.1,
        'fear': 0.1,
        'pouty': 0.1,
        'grimace': 0.1,
      },
      'source': 'aliyun_facebody',
    };
  }
}

/// 人脸区域
class FaceRectangle {
  final int top;
  final int left;
  final int width;
  final int height;

  FaceRectangle({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  factory FaceRectangle.fromJson(Map<String, dynamic> json) {
    return FaceRectangle(
      top: json['Top'] as int? ?? 0,
      left: json['Left'] as int? ?? 0,
      width: json['Width'] as int? ?? 0,
      height: json['Height'] as int? ?? 0,
    );
  }
}
