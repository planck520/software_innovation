import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../config/aliyun_config.dart';

/// 阿里云表情识别服务
class AliyunExpressionService {
  final String accessKeyId;
  final String accessKeySecret;
  final String endpoint;
  final String ossBucket;
  final String ossEndpoint;

  // OSS 客户端（延迟初始化）
  FlutterOssAliyun? _ossClient;

  AliyunExpressionService({
    String? accessKeyId,
    String? accessKeySecret,
    this.endpoint = AliyunConfig.facebodyEndpoint,
    this.ossBucket = AliyunConfig.ossBucket,
    this.ossEndpoint = AliyunConfig.ossEndpoint,
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

  /// 初始化 OSS 客户端
  Future<void> _initOssClient() async {
    if (_ossClient != null) return;

    if (!AliyunConfig.isOssConfigured) {
      print('[Aliyun API] ⚠️ OSS 未配置，使用模拟数据');
      print('[Aliyun API] 请在 lib/config/aliyun_config.dart 中配置 OSS Bucket');
      return;
    }

    try {
      _ossClient = FlutterOssAliyun(
        endpoint: ossEndpoint,
        bucketName: ossBucket,
        credentialsDirection: '',  // 使用默认凭证目录
      );

      // 配置认证信息
      await _ossClient!.initOSSClient();
      print('[Aliyun API] ✅ OSS 客户端初始化成功');
    } catch (e) {
      print('[Aliyun API] ❌ OSS 初始化失败: $e');
      _ossClient = null;
    }
  }

  /// 上传图片到 OSS 并获取 URL
  Future<String?> _uploadImageToOss(Uint8List imageBytes) async {
    try {
      await _initOssClient();

      if (_ossClient == null) {
        print('[Aliyun OSS] OSS 客户端未初始化');
        return null;
      }

      // 生成唯一的文件名
      final fileName = 'emotion_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}.jpg';

      // 保存临时文件
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(imageBytes);

      print('[Aliyun OSS] 上传图片: $fileName');

      // 上传到 OSS
      await _ossClient!.putObjectFile(
        file: tempFile,
        key: fileName,
      );

      // 获取公开访问 URL
      final imageUrl = 'https://$ossBucket.$ossEndpoint/$fileName';

      // 删除临时文件
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      print('[Aliyun OSS] ✅ 上传成功: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('[Aliyun OSS] ❌ 上传失败: $e');
      return null;
    }
  }

  /// 生成随机字符串
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final sb = StringBuffer();
    for (int i = 0; i < length; i++) {
      sb.write(chars[(random + i) % chars.length]);
    }
    return sb.toString();
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

  /// 调用表情识别 API
  Future<ExpressionResult?> recognizeExpression(Uint8List imageBytes) async {
    try {
      print('[Aliyun API] === 开始表情识别 ===');

      // 检查 OSS 是否已配置
      if (!AliyunConfig.isOssConfigured) {
        print('[Aliyun API] ⚠️ OSS 未配置，使用模拟数据');
        print('[Aliyun API] 请按照以下步骤配置 OSS:');
        print('[Aliyun API] 1. 登录阿里云控制台');
        print('[Aliyun API] 2. 创建 OSS Bucket（区域：华东2-上海）');
        print('[Aliyun API] 3. 修改 lib/config/aliyun_config.dart 中的 ossBucket');

        // 返回模拟数据
        return _getSimulatedResult();
      }

      // 上传图片到 OSS
      print('[Aliyun API] 步骤 1/3: 上传图片到 OSS...');
      final imageUrl = await _uploadImageToOss(imageBytes);

      if (imageUrl == null) {
        print('[Aliyun API] ❌ 图片上传失败，使用模拟数据');
        return _getSimulatedResult();
      }

      // 调用 FaceBody API
      print('[Aliyun API] 步骤 2/3: 调用 FaceBody API...');
      final result = await _callFacebodyApi(imageUrl);

      if (result == null) {
        print('[Aliyun API] ❌ API 调用失败，使用模拟数据');
        return _getSimulatedResult();
      }

      print('[Aliyun API] ✅ 表情识别成功');
      return result;
    } catch (e, stackTrace) {
      print('[Aliyun API] ❌ 异常: $e');
      print('[Aliyun API] 堆栈: $stackTrace');
      return _getSimulatedResult();
    }
  }

  /// 调用阿里云 FaceBody API
  Future<ExpressionResult?> _callFacebodyApi(String imageUrl) async {
    try {
      // 准备公共参数
      String timestamp = DateTime.now()
          .toUtc()
          .toIso8601String()
          .split('.')[0] + 'Z';
      String nonce = DateTime.now().millisecondsSinceEpoch.toString();
      String apiVersion = AliyunConfig.apiVersion;

      print('[Aliyun API] 时间戳: $timestamp');
      print('[Aliyun API] 图片 URL: $imageUrl');

      // 准备 API 参数
      Map<String, String> params = {
        'Action': 'RecognizeExpression',
        'Version': apiVersion,
        'Format': 'JSON',
        'AccessKeyId': accessKeyId,
        'SignatureMethod': 'HMAC-SHA1',
        'SignatureVersion': '1.0',
        'SignatureNonce': nonce,
        'Timestamp': timestamp,
        'ImageURL': imageUrl,  // 使用 OSS URL
      };

      // 生成签名
      String signature = _generateSignature('POST', params);
      params['Signature'] = signature;

      print('[Aliyun API] 步骤 3/3: 发送 API 请求...');

      // 发送请求
      final response = await http.post(
        Uri.parse('https://$endpoint'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[Aliyun API] ❌ 请求超时');
          throw Exception('请求超时');
        },
      );

      print('[Aliyun API] 响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        print('[Aliyun API] 响应数据: ${result.keys}');

        // 解析结果
        if (result['Data'] != null &&
            result['Data']['Elements'] != null &&
            result['Data']['Elements'].length > 0) {
          print('[Aliyun API] ✅ 检测到表情');
          final element = result['Data']['Elements'][0];
          return ExpressionResult.fromJson(element);
        } else {
          print('[Aliyun API] ⚠️ 未检测到人脸或表情');
          print('[Aliyun API] 完整响应: $result');
        }
      } else {
        print('[Aliyun API] ❌ HTTP 错误: ${response.statusCode}');
        print('[Aliyun API] 响应内容: ${response.body}');
      }

      return null;
    } catch (e) {
      print('[Aliyun API] ❌ API 调用异常: $e');
      return null;
    }
  }

  /// 获取模拟结果（用于测试或降级）
  ExpressionResult _getSimulatedResult() {
    // 模拟不同的情绪（随机）
    final emotions = ['neutral', 'happiness', 'surprise', 'sadness'];
    final random = DateTime.now().millisecond % emotions.length;
    final emotion = emotions[random];
    final confidence = 0.6 + (DateTime.now().millisecond % 40) / 100.0;

    return ExpressionResult(
      expression: emotion,
      confidence: confidence,
      chineseExpression: expressionMap[emotion] ?? '平静',
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
