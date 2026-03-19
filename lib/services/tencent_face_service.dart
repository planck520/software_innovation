import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../config/tencent_config.dart';

/// 腾讯云人脸检测与属性分析服务
///
/// 使用 DetectFaceAttributes API 获取情绪分析结果
class TencentFaceService {
  final String secretId;
  final String secretKey;
  final String region;
  final String endpoint;

  TencentFaceService({
    String? secretId,
    String? secretKey,
    String? region,
    String? endpoint,
  })  : secretId = secretId ?? TencentConfig.secretId,
        secretKey = secretKey ?? TencentConfig.secretKey,
        region = region ?? TencentConfig.region,
        endpoint = endpoint ?? TencentConfig.endpoint;

  /// 调用腾讯云 DetectFaceAttributes API 进行情绪分析
  Future<DetectFaceResult?> detectFaceAttributes(Uint8List imageBytes) async {
    try {
      print('[Tencent API] === 开始人脸检测与情绪分析 ===');
      print('[Tencent API] 图片大小: ${imageBytes.length} bytes');

      // 将图片转换为 Base64
      final imageBase64 = base64Encode(imageBytes);

      // 构造请求参数（Action、Version、Region 通过 Header 传递）
      final requestParams = {
        'Image': imageBase64,
        'FaceAttributesType': 'Emotion',
      };

      // 发送请求
      final response = await _sendRequest(requestParams);

      // 解析响应
      final result = _parseResponse(response);

      if (result != null) {
        print('[Tencent API] ✅ 情绪识别成功');
        print('[Tencent API] 主要情绪: ${result.emotion} (${result.chineseEmotion})');
        print('[Tencent API] 置信度: ${(result.confidence * 100).toStringAsFixed(1)}%');
      } else {
        print('[Tencent API] ❌ 未检测到人脸');
      }

      return result;
    } catch (e) {
      print('[Tencent API] ❌ 异常: $e');
      return null;
    }
  }

  /// 发送 HTTP 请求（实现 TC3-HMAC-SHA256 签名）
  Future<http.Response> _sendRequest(Map<String, String> params) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final date = _formatDate(DateTime.now());
    const service = 'iai';
    const algorithm = 'TC3-HMAC-SHA256';

    // 1. 拼接规范请求串
    final httpRequestMethod = 'POST';
    final canonicalUri = '/';
    final canonicalQueryString = '';
    final ct = 'application/json; charset=utf-8';
    final actionLower = TencentConfig.action.toLowerCase();
    final canonicalHeaders = 'content-type:$ct\nhost:$endpoint\nx-tc-action:$actionLower\n';
    final signedHeaders = 'content-type;host;x-tc-action';
    final hashedRequestPayload = sha256.convert(utf8.encode(jsonEncode(params))).toString();

    final canonicalRequest = '$httpRequestMethod\n'
        '$canonicalUri\n'
        '$canonicalQueryString\n'
        '$canonicalHeaders\n'
        '$signedHeaders\n'
        '$hashedRequestPayload';

    print('[Tencent API] CanonicalRequest: $canonicalRequest');

    // 2. 拼接待签名字符串
    final credentialScope = '$date/$service/tc3_request';
    final hashedCanonicalRequest = sha256.convert(utf8.encode(canonicalRequest)).toString();
    final stringToSign = '$algorithm\n'
        '$timestamp\n'
        '$credentialScope\n'
        '$hashedCanonicalRequest';

    print('[Tencent API] StringToSign: $stringToSign');

    // 3. 计算签名
    // Step 1: SecretDate = HMAC("TC3" + SecretKey, Date)
    final secretDate = _sign(utf8.encode('TC3$secretKey'), date);

    // Step 2: SecretService = HMAC(SecretDate, service)
    final secretService = _sign(secretDate, service);

    // Step 3: SecretSigning = HMAC(SecretService, "tc3_request")
    final secretSigning = _sign(secretService, 'tc3_request');

    // Step 4: Signature = HMAC(SecretSigning, StringToSign)
    final signature = Hmac(sha256, secretSigning).convert(utf8.encode(stringToSign)).toString();

    print('[Tencent API] Signature: $signature');

    // 4. 拼接 Authorization
    final authorization = '$algorithm Credential=$secretId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    // 发送请求
    final uri = Uri.parse('https://$endpoint');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': authorization,
        'Content-Type': ct,
        'Host': endpoint,
        'X-TC-Action': TencentConfig.action,
        'X-TC-Version': TencentConfig.apiVersion,
        'X-TC-Region': region,
        'X-TC-Timestamp': timestamp.toString(),
      },
      body: jsonEncode(params),
    );

    return response;
  }

  /// HMAC-SHA256 签名辅助函数
  List<int> _sign(List<int> key, String msg) {
    final hmacSha256 = Hmac(sha256, key);
    return hmacSha256.convert(utf8.encode(msg)).bytes;
  }

  /// 解析 API 响应
  DetectFaceResult? _parseResponse(http.Response response) {
    print('[Tencent API] 响应状态: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('[Tencent API] 响应内容: ${response.body}');
      return null;
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('[Tencent API] 响应数据: ${jsonEncode(data)}');

      // 检查错误响应
      if (data['Response'] == null) {
        print('[Tencent API] 响应格式错误');
        return null;
      }

      final resp = data['Response'] as Map<String, dynamic>;

      // 检查是否有错误
      if (resp['Error'] != null) {
        final error = resp['Error'] as Map<String, dynamic>;
        print('[Tencent API] API 错误: ${error['Message']}');
        return null;
      }

      // 提取人脸信息
      final faceDetailInfos = resp['FaceDetailInfos'] as List<dynamic>?;
      if (faceDetailInfos == null || faceDetailInfos.isEmpty) {
        print('[Tencent API] 未检测到人脸');
        return null;
      }

      // 获取第一个人脸的情绪信息
      final faceInfo = faceDetailInfos[0] as Map<String, dynamic>;
      final faceAttributes = faceInfo['FaceDetailAttributesInfo'] as Map<String, dynamic>?;

      if (faceAttributes == null) {
        print('[Tencent API] 未获取到人脸属性');
        return null;
      }

      // 提取情绪数据
      final emotionData = faceAttributes['Emotion'] as Map<String, dynamic>?;
      if (emotionData == null) {
        print('[Tencent API] 未获取到情绪数据');
        return null;
      }

      print('[Tencent API] 情绪数据: $emotionData');

      // 腾讯云返回 Type(情绪类型编码) 和 Probability(置信度)
      final emotionType = emotionData['Type'] as int? ?? 0;
      final probability = (emotionData['Probability'] as num?)?.toDouble() ?? 0.0;

      // 腾讯云情绪类型编码映射
      const emotionTypeMap = {
        0: 'neutral',
        1: 'happy',
        2: 'sad',
        3: 'angry',
        4: 'disgusted',
        5: 'fearful',
        6: 'surprised',
        7: 'neutral',
      };

      final emotion = emotionTypeMap[emotionType] ?? 'neutral';
      final chineseEmotion = TencentConfig.getChineseEmotion(emotion);

      // 构造 allEmotions（只返回主要情绪）
      final allEmotions = <String, double>{
        emotion: probability,
      };

      print('[Tencent API] 情绪: $emotion ($chineseEmotion), 置信度: $probability');

      return DetectFaceResult(
        emotion: emotion,
        confidence: probability,
        chineseEmotion: chineseEmotion,
        allEmotions: allEmotions,
      );
    } catch (e) {
      print('[Tencent API] 解析响应失败: $e');
      return null;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// SHA256 加密
  String _sha256Hex(String data) {
    final digest = sha256.convert(utf8.encode(data));
    return digest.toString();
  }

  /// 字节数组转十六进制字符串
  String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// 腾讯云人脸检测结果
class DetectFaceResult {
  final String emotion;
  final double confidence;
  final String chineseEmotion;
  final Map<String, double> allEmotions;

  DetectFaceResult({
    required this.emotion,
    required this.confidence,
    required this.chineseEmotion,
    required this.allEmotions,
  });

  /// 转换为与 EmotionResult 兼容的格式
  Map<String, dynamic> toEmotionResultFormat() {
    return {
      'emotion': emotion,
      'confidence': confidence,
      'chineseEmotion': chineseEmotion,
      'allEmotions': allEmotions,
      'source': 'tencent_detect_face',
    };
  }
}
