import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';

class XfVoiceHandler {
  final String appId = "c9945e5e";
  final String apiKey = "0a3dbc14d9fe900ecff024e108105748";
  final String apiSecret = "YWQyZDE1Y2I3MjBlNmIwMTA0OTM0ZTE1";

  IOWebSocketChannel? _channel;

  // 生成讯飞鉴权 URL
  String _getAuthUrl() {
    final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss ' + 'GMT').format(DateTime.now().toUtc());
    final signatureOrigin = "host: iat-api.xfyun.cn\ndate: $date\nGET /v2/iat HTTP/1.1";
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final signature = base64.encode(hmacSha256.convert(utf8.encode(signatureOrigin)).bytes);
    final authorizationOrigin = 'api_key="$apiKey", algorithm="hmac-sha256", headers="host date", signature="$signature"';
    final authorization = base64.encode(utf8.encode(authorizationOrigin));

    return "wss://iat-api.xfyun.cn/v2/iat?authorization=$authorization&date=${Uri.encodeComponent(date)}&host=iat-api.xfyun.cn";
  }

  // 连接并开启识别流
  Future<Stream<String>> connect() async {
    final controller = StreamController<String>();
    final url = _getAuthUrl();
    _channel = IOWebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen((message) {
      final res = jsonDecode(message);
      if (res['code'] != 0) {
        controller.addError("讯飞报错: ${res['message']}");
        return;
      }

      // 解析讯飞返回的 JSON 文字结果
      final data = res['data'];
      if (data != null && data['result'] != null) {
        final ws = data['result']['ws'] as List;
        String text = "";
        for (var w in ws) {
          text += w['cw'][0]['w'];
        }
        controller.add(text); // 向 UI 发送识别到的文字
      }

      if (res['code'] == 0 && data['status'] == 2) {
        _channel?.sink.close();
      }
    });

    return controller.stream;
  }

  void sendAudio(List<int> bytes, {int status = 1}) {
    final frame = {
      "common": {"app_id": appId},
      "business": {
        "language": "zh_cn",
        "domain": "iat",
        "accent": "mandarin",
      },
      "data": {
        "status": status,
        "format": "audio/L16;rate=16000",
        "encoding": "raw",
        "audio": base64.encode(bytes),
      }
    };
    _channel?.sink.add(jsonEncode(frame));
  }

  void close() => _channel?.sink.close();
}