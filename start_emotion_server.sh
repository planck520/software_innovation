#!/bin/bash
# 情绪识别服务器启动脚本

echo "========================================="
echo "情绪识别服务器启动中..."
echo "========================================="

# 设置Python环境
export PYTHONPATH=/root/miniconda3/envs/your_env/bin/python  # 根据实际情况修改

# 启动服务
cd /root/  # 模型所在目录
python emotion_detector_server.py
