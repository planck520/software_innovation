# 情绪识别模型本地化方案

## 背景

- 现有 `emotion_detector_server.py` 使用 Hugging Face 在线下载模型
- 服务器在国内无法访问 Hugging Face
- **解决思路**：在本地上下载模型 → 上传到服务器 → 服务器从本地加载

---

## 实施检查清单

### ✅ 步骤1：在本地上下载模型

**脚本位置**：`D:\software_innovation\download_model.py`

在能访问 Hugging Face 的机器上运行此脚本：

```bash
cd D:\software_innovation
python download_model.py
```

**输出**：
- 模型下载完成提示
- 缓存目录路径显示

**验证**：
```bash
# 查看模型缓存位置
ls -la ~/.cache/huggingface/hub/
# 应该看到 models--dima806--facial_emotions_image_detection 目录
```

---

### ✅ 步骤2：上传模型到服务器

**在本地上执行**（根据实际服务器IP修改）：

```bash
# 方式1：使用 scp 上传整个缓存目录
scp -r ~/.cache/huggingface/hub/models--dima806--facial_emotions_image_detection root@你的服务器IP:/root/.cache/huggingface/hub/

# 方式2：如果有多个服务器，可以使用 rsync
rsync -avz ~/.cache/huggingface/hub/models--dima806--facial_emotions_image_detection root@服务器IP:/root/.cache/huggingface/hub/
```

**同时上传以下文件到服务器 `/root/` 目录**：
- `emotion_detector_server.py`（已修改）
- `run_server.py`
- `start_emotion_server.sh`

---

### ✅ 步骤3：在服务器上启动服务

**方式1：使用 Python 启动脚本**

```bash
# SSH 登录服务器后
cd /root/
python run_server.py
```

**方式2：使用 Bash 脚本**

```bash
# 首先给脚本执行权限
chmod +x start_emotion_server.sh

# 运行
./start_emotion_server.sh
```

**方式3：直接运行原脚本**

```bash
python emotion_detector_server.py
```

---

## 验证步骤

### 1. 本地验证

运行 `python download_model.py` 后，确认看到：
- ✅ "模型测试成功!"
- ✅ "✅ 模型下载完成!"

### 2. 服务器验证

**检查模型文件**：
```bash
ls -la /root/.cache/huggingface/hub/models--dima806--facial_emotions_image_detection/
```

**启动服务后检查健康状态**：
```bash
curl http://localhost:5000/health
```

**预期返回**：
```json
{
  "status": "ok",
  "model_loaded": true,
  "service": "emotion_detector"
}
```

---

## 文件清单

| 文件 | 位置 | 用途 |
|------|------|------|
| `download_model.py` | 本地 | 下载 Hugging Face 模型 |
| `emotion_detector_server.py` | 服务器 | 情绪识别服务（已修改） |
| `run_server.py` | 服务器 | Python 服务器启动脚本 |
| `start_emotion_server.sh` | 服务器 | Bash 服务器启动脚本 |
| 模型缓存 | 需上传 | `~/.cache/huggingface/hub/models--dima806--facial_emotions_image_detection` |

---

## 修改内容

### emotion_detector_server.py 修改

在 `init_emotion_model()` 函数中：
- 添加了 `model_path` 变量指定本地模型路径
- 修改 `pipeline()` 调用，使用 `local_files_only=True` 强制从本地加载
- 添加了路径检查逻辑：`model_path if os.path.exists(model_path) else model_name`

---

## 注意事项

1. **模型大小**：约 200-300MB，上传时间取决于服务器带宽
2. **Python环境**：确保服务器 Python 环境安装了所需依赖
   ```bash
   pip install torch transformers flask flask-cors pillow websocket-client numpy opencv-python
   ```
3. **首次运行**：服务器上首次运行可能需要几分钟加载模型
4. **目录权限**：确保 `/root/.cache/huggingface/` 目录有读写权限
5. **网络配置**：确保服务器 5000 端口对外开放（如需远程访问）

---

## 故障排查

### 问题1：模型加载失败

**症状**：`❌ 加载情感检测模型失败`

**解决**：
- 检查模型文件是否完整上传
- 检查路径是否正确：`/root/.cache/huggingface/hub/models--dima806--facial_emotions_image_detection`
- 确认 Python 依赖已安装

### 问题2：WebSocket 连接失败

**症状**：`连接WebSocket失败`

**解决**：
- 确认主 WebSocket 服务运行在 `localhost:8001`
- 检查防火墙设置
- 确认 session_id 正确传递

### 问题3：健康检查返回 model_loaded: false

**症状**：`/health` 返回 `"model_loaded": false`

**解决**：
- 查看服务器日志中的详细错误信息
- 确认模型缓存目录存在且可访问
- 重新上传模型文件

---

## 日志输出示例

**成功启动**：
```
============================================================
情绪识别服务器
模型加载中...
============================================================
正在加载情感检测模型: dima806/facial_emotions_image_detection
使用设备: CPU
✅ 情感检测模型加载成功!
============================================================
服务启动成功!
运行在: http://0.0.0.0:5000
============================================================
 * Running on http://0.0.0.0:5000
```

---

## 相关资源

- Hugging Face 模型：https://huggingface.co/dima806/facial_emotions_image_detection
- Transformers 文档：https://huggingface.co/docs/transformers/main_classes/pipelines
- Flask 文档：https://flask.palletsprojects.com/
