import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// 图片压缩工具
class ImageCompressor {
  /// 压缩图片到指定大小
  static Future<Uint8List> compress(Uint8List imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      // 解码图片
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        return imageBytes;  // 解码失败，返回原图
      }

      // 计算缩放比例
      int width = image.width;
      int height = image.height;

      if (width > maxWidth || height > maxHeight) {
        double ratio = width > height
            ? maxWidth / width
            : maxHeight / height;
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
      Uint8List compressed = Uint8List.fromList(img.encodeJpg(resized, quality: quality));

      // 检查是否小于 3MB
      if (compressed.length > 3 * 1024 * 1024) {
        // 如果还太大，降低质量重新压缩
        return compress(imageBytes, maxWidth: maxWidth, maxHeight: maxHeight, quality: quality - 10);
      }

      return compressed;
    } catch (e) {
      print('图片压缩失败: $e');
      return imageBytes;  // 压缩失败，返回原图
    }
  }
}
