#!/usr/bin/env python3
"""
服务器启动脚本
使用方法: python run_server.py
"""

import os
import sys

# 确保使用本地缓存的模型
os.environ['HF_HOME'] = '/root/.cache/huggingface/hub'
os.environ['TRANSFORMERS_CACHE'] = '/root/.cache/huggingface/hub'

# 导入并运行原服务器
sys.path.insert(0, '/root/')  # emotion_detector_server.py 所在目录

# 启动Flask服务器
if __name__ == '__main__':
    from emotion_detector_server import app, init_emotion_model
    import logging

    logging.basicConfig(level=logging.INFO)

    print("=" * 60)
    print("情绪识别服务器")
    print("模型加载中...")
    print("=" * 60)

    # 初始化模型（会从本地缓存加载）
    init_emotion_model()

    print("=" * 60)
    print("服务启动成功!")
    print("运行在: http://0.0.0.0:5000")
    print("=" * 60)

    app.run(host='0.0.0.0', port=5000, debug=False)
