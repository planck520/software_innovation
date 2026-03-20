# API 密钥配置说明

## 环境变量文件

项目使用 `.env` 文件来管理 API 密钥，确保密钥不会硬编码在代码中。

### 快速开始

1. **复制模板文件**
   ```bash
   cp .env.example .env
   ```

2. **填写您的 API 密钥**

   编辑 `.env` 文件，将 `your_*_here` 替换为实际的 API 密钥。

## 获取 API 密钥

### 腾讯云 API（人脸识别/情绪检测）

1. 访问 [腾讯云控制台](https://console.cloud.tencent.com/cam/capi)
2. 登录后创建或查看 API 密钥
3. 复制 SecretId 和 SecretKey 到 `.env` 文件

环境变量名：
- `TENCENT_SECRET_ID`
- `TENCENT_SECRET_KEY`

### 讯飞语音 API

1. 访问 [讯飞开放平台](https://www.xfyun.cn/)
2. 注册并登录控制台
3. 创建应用，获取 APPID、API Key 和 API Secret
4. 将密钥填入 `.env` 文件

环境变量名：
- `XFYUN_APP_ID`
- `XFYUN_API_KEY`
- `XFYUN_API_SECRET`

###  API

1. 访问 [ DeepSeek 平台](https://platform./)
2. 注册并登录
3. 在 API Keys 页面创建并复制 API Key
4. 将密钥填入 `.env` 文件

环境变量名：
- `DEEPSEEK_API_KEY`

## 安全注意事项

### ⚠️ 重要提醒

1. **不要提交 `.env` 文件到 Git**
   - `.env` 文件已在 `.gitignore` 中配置
   - 提交前请确认 `.env` 未被追踪：`git status`

2. **保护您的密钥**
   - 不要将 API 密钥分享给他人
   - 定期轮换密钥（推荐每 3-6 个月）
   - 如果密钥泄露，立即在相应平台重新生成

3. **生产环境**
   - 使用单独的 `.env.production` 文件
   - 或使用云平台的密钥管理服务
   - 不要将开发环境的 `.env` 用于生产

## 故障排除

### 环境变量加载失败

如果应用启动时提示环境变量加载失败：

1. 确认 `.env` 文件存在于项目根目录
2. 检查文件格式是否正确（每行 `KEY=VALUE`，无引号）
3. 确认 `pubspec.yaml` 中已将 `.env` 添加到 assets

### API 调用失败

如果 API 调用返回 401 或 403 错误：

1. 检查 `.env` 中的密钥是否正确
2. 确认密钥在相应平台处于启用状态
3. 检查密钥是否有足够的配额/余额

## 新增开发者

新开发者加入项目时：

1. 复制 `.env.example` 为 `.env`
2. 在相应平台注册并获取自己的 API 密钥
3. 填入 `.env` 文件即可开始开发

无需修改任何代码！