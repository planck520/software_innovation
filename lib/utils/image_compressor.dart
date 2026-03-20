import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 图片压缩工具
class ImageCompressor {
  /// 压缩图片到指定大小（使用Isolate异步处理，不阻塞主线程）
  static Future<Uint8List> compress(Uint8List imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    final params = _CompressParams(
      imageBytes: imageBytes,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );

    return await compute(_compressIsolate, params);
  }
}

/// Isolate压缩参数
class _CompressParams {
  final Uint8List imageBytes;
  final int maxWidth;
  final int maxHeight;
  final int quality;

  _CompressParams({
    required this.imageBytes,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
  });
}

/// 在Isolate中执行的压缩函数
Uint8List _compressIsolate(_CompressParams params) {
  try {
    // 解码图片
    img.Image? image = img.decodeImage(params.imageBytes);
    if (image == null) {
      return params.imageBytes;  // 解码失败，返回原图
    }

    // 计算缩放比例
    int width = image.width;
    int height = image.height;

    if (width > params.maxWidth || height > params.maxHeight) {
      double ratio = width > height
          ? params.maxWidth / width
          : params.maxHeight / height;
      width = (width * ratio).round();
      height = (height * ratio).round();
    }

    // 调整大小
    img.Image resized = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    // 编码为 JPEG
    Uint8List compressed = Uint8List.fromList(img.encodeJpg(resized, quality: params.quality));

    // 检查是否小于 3MB
    if (compressed.length > 3 * 1024 * 1024) {
      // 如果还太大，降低质量重新压缩
      final newParams = _CompressParams(
        imageBytes: params.imageBytes,
        maxWidth: params.maxWidth,
        maxHeight: params.maxHeight,
        quality: params.quality - 10,
      );
      return _compressIsolate(newParams);
    }

    return compressed;
  } catch (e) {
    print('图片压缩失败: $e');
    return params.imageBytes;  // 压缩失败，返回原图
  }
}
