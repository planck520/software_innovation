# 🔍 调试 "API 返回 null" 问题

## 📊 当前状况

根据你的日志，系统工作正常：
- ✅ 图片成功捕获（57048 bytes）
- ✅ API 调用被执行
- ❌ 但 API 返回 null

## 🎯 可能的原因

### 1. **阿里云 API 认证失败** (最可能)
- AccessKey 无效或过期
- 签名算法错误
- 时间戳格式不正确

### 2. **图片中未检测到人脸**
- 光线太暗
- 人脸太小
- 角度不正

### 3. **API 调用格式错误**
- 参数格式不对
- 编码问题
- 端点 URL 错误

## 🔧 已修复的问题

### ✅ 修复时间戳格式

**之前**:
```dart
String timestamp = DateTime.now()
    .toUtc()
    .toIso8601String()
    .replaceAll('T', ' ')
    .split('.')[0] + ' UTC';
// 结果: "2024-03-19 12:34:56 UTC" ❌
```

**现在**:
```dart
String timestamp = DateTime.now()
    .toUtc()
    .toIso8601String()
    .split('.')[0] + 'Z';
// 结果: "2024-03-19T12:34:56Z" ✅
```

### ✅ 添加详细日志

现在你会看到：
```
[Aliyun API] 发送请求到: https://viapi.cn-shanghai.aliyuncs.com
[Aliyun API] 图片大小: 123456 chars (Base64)
[Aliyun API] 时间戳: 2024-03-19T12:34:56Z
[Aliyun API] 响应状态码: 200
[Aliyun API] 响应体长度: 456
[Aliyun API] 解析后的JSON: _InternalLinkedHashMap<String, dynamic>
[Aliyun API] 完整响��: (Code, Data, Message, RequestId)
```

## 🧪 下一步调试步骤

### 步骤 1: 重新运行应用

```bash
flutter run
```

### 步骤 2: 查看新的详细日志

在 LogCat 中搜索 `[Aliyun API]`，你应该看到：

```
[Aliyun API] 发送请求到: https://viapi.cn-shanghai.aliyuncs.com
[Aliyun API] 图片大小: 123456 chars (Base64)
[Aliyun API] 时间戳: 2024-03-19T12:34:56Z
[Aliyun API] 响应状态码: 200
[Aliyun API] 响应体长度: 456
[Aliyun API] 解析后的JSON: _InternalLinkedHashMap<String, dynamic>
[Aliyun API] 完整响应: (Code, Data, Message, RequestId)
```

### 步骤 3: 检查响应内容

根据日志内容判断：

#### 情况 A: 看到 "Code" 字段
```json
{
  "Code": "InvalidAccessKey.NotFound",
  "Message": "The specified Access Key is not found.",
  "RequestId": "xxx"
}
```
**原因**: AccessKey 错误
**解决**: 检查 AccessKey ID 和 Secret

#### 情况 B: 看到 Data 为空
```json
{
  "Data": null,
  "Code": "success",
  "Message": "success"
}
```
**原因**: 未检测到人脸
**解决**: 改善光线和角度

#### 情况 C: Data 中的 Elements 为空
```json
{
  "Data": {
    "Elements": []
  },
  "Code": "success"
}
```
**原因**: 图片中没有清晰的人脸
**解决**: 确保人脸清晰可见

## 🔐 验证 AccessKey

### 检查 1: AccessKey 是否有效

1. 登录 [阿里云控制台](https://ram.console.aliyun.com/manage/ak)
2. 检查 AccessKey 状态
3. 确认 AccessKey 未被禁用

### 检查 2: 权限是否正确

AccessKey 需要以下权限：
- `viapi:RecognizeExpression`
- 或者 `viapi:*` (所有视觉智能权限)

### 检查 3: 服务是否开通

确认已开通 [视觉智能开放平台](https://www.aliyun.com/product/viapi)

## 🎭 测试建议

### 测试 1: 使用标准人脸照片

1. 从网上下载一张清晰的正脸照片
2. 确保光线充足
3. 人脸占图片比例 > 30%

### 测试 2: 检查网络连接

```bash
# 测试能否访问阿里云
curl -I https://viapi.cn-shanghai.aliyuncs.com
```

### 测试 3: 使用测试脚本

```bash
# 安装依赖
flutter pub get

# 运行测试脚本
dart test_aliyun_api.dart test_image.jpg
```

## 📸 改善人脸检测的建议

### 1. 光线
- ✅ 使用充足的自然光
- ✅ 避免背光
- ❌ 避免强烈阴影

### 2. 角度
- ✅ 正面朝向摄像头
- ✅ 水平角度
- ❌ 避免侧脸或低头

### 3. 距离
- ✅ 人脸占图片 30-50%
- ✅ 距离摄像头 0.5-2 米
- ❌ 不要太远或太近

### 4. 表情
- ✅ 尝试明显表情（微笑、惊讶）
- ✅ 保持表情 2-3 秒
- ❌ 避免模糊不清的表情

## 🚨 常见错误码

| 错误码 | 含义 | 解决方案 |
|--------|------|----------|
| `InvalidAccessKey.NotFound` | AccessKey 不存在 | 检查 AccessKey ID |
| `SignatureDoesNotMatch` | 签名不匹配 | 检查 AccessKey Secret |
| `InvalidTimeStamp.Expired` | 时间戳过期 | 检查系统时间 |
| `InvalidParameterValue` | 参数错误 | 检查图片格式和大小 |
| `Forbidden.RAM` | 权限不足 | 添加 viapi 权限 |

## 📞 需要帮助？

如果问题仍然存在，请提供：

1. **完整的 [Aliyun API] 日志**
   - 包括时间戳、响应状态码、响应内容

2. **AccessKey 状态**
   - 是否在阿里云控制台可见
   - 是否被禁用
   - 是否有 viapi 权限

3. **测试结果**
   - 使用测试图片的结果
   - 网络连接测试结果

4. **环境信息**
   - 设备型号
   - Android 版本
   - 网络类型 (WiFi/移动网络)

---

## 🎯 预期结果

修复后，你应该看到：

```
[Aliyun API] 发送请求到: https://viapi.cn-shanghai.aliyuncs.com
[Aliyun API] 图片大小: 123456 chars (Base64)
[Aliyun API] 时间戳: 2024-03-19T12:34:56Z
[Aliyun API] 响应状态码: 200
[Aliyun API] 响应体长度: 456
[Aliyun API] ✅ 检测到表情
[Emotion] ✅ 识别成功!
[Emotion] 情绪: 快乐
[Emotion] 置信度: 0.85
```

然后情绪分数会在 UI 上更新！🎉
