import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// 阿里云 API 测试脚本
void main(List<String> args) async {
  final accessKeyId = 'LTAI5t7e7h1cEcr56ymnAgvm';
  final accessKeySecret = 'wekeJpmt4m7nRvT4DMaRXvdiFmQvzT';
  final endpoint = 'https://viapi.cn-shanghai.aliyuncs.com';

  // 读取测试图片
  if (args.isEmpty) {
    print('用法: dart test_aliyun_api.dart <图片路径>');
    exit(1);
  }

  final imagePath = args[0];
  final imageFile = File(imagePath);
  if (!imageFile.existsSync()) {
    print('图片文件不存在: $imagePath');
    exit(1);
  }

  final imageBytes = await imageFile.readAsBytes();
  print('✅ 读取图片成功: ${imageBytes.length} bytes');

  // 转换为 Base64
  String imageBase64 = base64.encode(imageBytes);
  print('✅ Base64 编码完成: ${imageBase64.length} chars');

  // 准备公共参数
  String timestamp = DateTime.now()
      .toUtc()
      .toIso8601String()
      .split('.')[0] + 'Z';
  String nonce = DateTime.now().millisecondsSinceEpoch.toString();
  String signatureVersion = '1.0';
  String signatureMethod = 'HMAC-SHA1';
  String apiVersion = '2019-12-30';

  print('⏰ 时间戳: $timestamp');

  // 准备 API 参数
  Map<String, String> params = {
    'Action': 'RecognizeExpression',
    'Version': apiVersion,
    'Format': 'JSON',
    'AccessKeyId': accessKeyId,
    'SignatureMethod': signatureMethod,
    'SignatureVersion': signatureVersion,
    'SignatureNonce': nonce,
    'Timestamp': timestamp,
    'ImageData': imageBase64,
  };

  // 生成签名
  String signature = _generateSignature(accessKeySecret, 'POST', params);
  params['Signature'] = signature;

  print('🔐 签名: $signature');

  // 发送请求
  print('🚀 发送请求到阿里云 API...');
  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('请求超时');
      },
    );

    print('📡 响应状态码: ${response.statusCode}');
    print('📦 响应体长度: ${response.body.length}');

    if (response.statusCode == 200) {
      final result = json.decode(utf8.decode(response.bodyBytes));
      print('✅ 请求成功!');
      print('📄 响应JSON:');
      print(JsonEncoder.withIndent('  ').convert(result));

      // 解析结果
      if (result['Data'] != null &&
          result['Data']['Elements'] != null &&
          result['Data']['Elements'].length > 0) {
        print('✅ 检测到表情!');
        final element = result['Data']['Elements'][0];
        print('表情类型: ${element['Expression']}');
        print('置信度: ${element['FaceProbability']}');
      } else {
        print('⚠️ 未检测到人脸或表情');
        print('完整响应: ${result}');
      }
    } else {
      print('❌ HTTP 错误: ${response.statusCode}');
      print('响应内容: ${response.body}');
    }
  } catch (e, stackTrace) {
    print('❌ 异常: $e');
    print('堆栈: $stackTrace');
  }
}

String _generateSignature(String accessKeySecret, String method, Map<String, String> params) {
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
