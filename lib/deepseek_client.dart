import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/env_config.dart';

/// DeepSeek Chat API 客户端，统一封装大模型调用
class DeepseekClient {
  static String get _apiKey => EnvConfig.apiKey;
  static const String _baseUrl = 'https://api.deepseek.com';

  /// 发送对话消息，返回完整回复文本（非流式）
  static Future<String> chat({
    required List<Map<String, String>> messages,
    String model = 'deepseek-chat',
    double temperature = 0.7,
  }) async {
    final uri = Uri.parse('$_baseUrl/chat/completions');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'stream': false,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('DeepSeek API error: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final msg = choices.first['message'];
      if (msg is Map && msg['content'] is String) {
        return msg['content'] as String;
      }
    }

    throw Exception('DeepSeek API 返回格式异常');
  }
}
