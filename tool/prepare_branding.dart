import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final brandingDir = Directory('assets/branding');
  if (!brandingDir.existsSync()) {
    stderr.writeln('未找到目录: assets/branding');
    exitCode = 1;
    return;
  }

  final tasks = <({String src, String dst})>[
    (src: 'assets/branding/app_icon.webp', dst: 'assets/branding/app_icon.png'),
    (src: 'assets/branding/splash_logo.webp', dst: 'assets/branding/splash_logo.png'),
  ];

  var hasError = false;

  for (final task in tasks) {
    final source = File(task.src);
    if (!source.existsSync()) {
      stderr.writeln('缺少文件: ${task.src}');
      hasError = true;
      continue;
    }

    final bytes = source.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      stderr.writeln('无法解析图片: ${task.src}');
      hasError = true;
      continue;
    }

    final output = File(task.dst);
    output.parent.createSync(recursive: true);
    output.writeAsBytesSync(img.encodePng(decoded));
    stdout.writeln('已生成: ${task.dst}');
  }

  if (hasError) {
    stderr.writeln('存在失败项，请补齐 webp 文件后重试。');
    exitCode = 1;
    return;
  }

  stdout.writeln('品牌素材转换完成，可执行图标与开屏生成命令。');
}
