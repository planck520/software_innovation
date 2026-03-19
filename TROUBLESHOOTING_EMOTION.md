# 情绪识别调试指南

## 🔍 问题诊断

摄像头已成功开启，但情绪没有显示变化。

## 📊 可能的原因

### 1. 情绪识别未启动
- 检查 `_startEmotionLoop()` 是否被调用
- 检查 `_emotionTimer` 是否正常运行

### 2. API 调用失败
- 网络连接问题
- 阿里云 API 认证失败
- 图片压缩失败

### 3. 摄像头捕获失败
- 权限问题
- 摄像头被其他应用占用

## 🛠️ 调试步骤

### 步骤 1: 启用详细日志

在 LogCat 中搜索以下标签：

```
[Emotion]
```

你应该看到这些日志：
- `[Emotion] capturing frame...` - 每3秒一次
- `[Emotion] analyzeFrame returned null` - API返回空
- `[Emotion] analyzeFrame error: ...` - 发生错误

### 步骤 2: 检查网络连接

阿里云 API 需要互联网连接：

```bash
# 测试网络连接
ping viapi.cn-shanghai.aliyuncs.com
```

### 步骤 3: 验证 API 凭证

检查 `lib/emotion_service.dart` 中的凭证：
- AccessKey ID: `LTAI5t7e7h1cEcr56ymnAgvm`
- AccessKey Secret: `wekeJpmt4m7nRvT4DMaRXvdiFmQvzT`

### 步骤 4: 检查图片压缩

在 `lib/utils/image_compressor.dart` 中添加更多日志：

```dart
print('压缩前: ${imageBytes.length} bytes');
print('压缩后: ${compressed.length} bytes');
```

## 🔧 快速修复

### 方案 1: 添加调试日志

在 `lib/main.dart` 的 `_captureAndAnalyzeEmotion()` 方法中添加：

```dart
debugPrint('[Emotion] === 开始情绪识别 ===');
debugPrint('[Emotion] 摄像头状态: ${controller.value.isInitialized}');
debugPrint('[Emotion] 情绪会话ID: $_emotionSessionId');
```

### 方案 2: 测试 API 连接

创建一个简单的测试来验证 API 是否工作：

```dart
// 在 _captureAndAnalyzeEmotion() 开始添加
debugPrint('[Emotion] 测试网络连接...');
try {
  final response = await http.get(Uri.parse('https://viapi.cn-shanghai.aliyuncs.com'))
      .timeout(Duration(seconds: 5));
  debugPrint('[Emotion] 网络连接正常: ${response.statusCode}');
} catch (e) {
  debugPrint('[Emotion] 网络连接失败: $e');
}
```

### 方案 3: 模拟情绪数据（临时测试）

如果需要快速验证 UI，可以在 `_captureAndAnalyzeEmotion()` 中添加模拟数据：

```dart
// 临时测试：模拟情绪变化
if (mounted) {
  setState(() {
    _emotionScore = (40 + (DateTime.now().millisecond % 58));
    _emotionHistory.add(_emotionScore.toDouble());
    if (_emotionHistory.length > 20) {
      _emotionHistory.removeAt(0);
    }
  });
  debugPrint('[Emotion] 模拟情绪分数: $_emotionScore');
}
```

## 📱 实时调试

### 使用 Flutter DevTools

1. 运行应用：`flutter run`
2. 打开 DevTools：`flutter pub global run devtools`
3. 在浏览器中查看日志和网络请求

### 监控变量

在 `_InterviewChatPageState` 中监控：
- `_emotionScore` - 应该每3秒更新
- `_emotionHistory` - 应该不断增加
- `_emotionTimer` - 应该处于活动状态

## ⚠️ 常见问题

### 问题 1: "摄像头未初始化"

**原因**: 摄像头权限未授予或初始化失败

**解决**:
1. 检查应用权限设置
2. 重新启动应用
3. 清除应用数据后重试

### 问题 2: "analyzeFrame returned null"

**原因**: API 调用成功但返回空结果

**可能原因**:
- 图片中未检测到人脸
- 图片质量太低
- API 返回错误

**解决**:
1. 确保光线充足
2. 保持人脸在摄像头范围内
3. 检查 API 返回的原始数据

### 问题 3: 网络超时

**原因**: 10秒超时限制

**解决**:
1. 检查网络连接
2. 增加超时时间
3. 检查防火墙设置

## 🎯 预期行为

正常情况下，你应该看到：

1. **日志输出** (每3秒):
   ```
   [Emotion] capturing frame...
   [Emotion] 识别到情绪: 快乐 (置信度: 0.85)
   ```

2. **UI 变化**:
   - 情绪分数每3秒更新
   - 情绪曲线动态变化
   - 情绪状态文字变化

3. **数据记录**:
   - `_emotionHistory` 列表不断增长
   - 最大长度为20个数据点

## 📞 下一步

如果问题仍然存在：

1. **提供日志**: 复制 `[Emotion]` 开头的所有日志
2. **检查网络**: 确认可以访问阿里云 API
3. **测试权限**: 确认摄像头和网络权限已授予
4. **验证凭证**: 确认 AccessKey 有效且未过期

## 🔗 相关文件

- `lib/services/aliyun_expression_service.dart` - API 服务
- `lib/utils/image_compressor.dart` - 图片压缩
- `lib/emotion_service.dart` - 情绪服务
- `lib/main.dart` - 面试页面（第14130行附近）
