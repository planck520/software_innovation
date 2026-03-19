#!/usr/bin/env python3
#cd D:\code\Android\back\Hustview\Hustview\backend
#python emotion_detector_server.py
"""
情感检测服务器 - 接收前端视频帧并进行情感分析
运行在5000端口，提供RESTful API
"""

import os
import base64
import json
import logging
import numpy as np
import cv2
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
from transformers import pipeline
import torch
import asyncio
import websocket
from io import BytesIO

# 设置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # 允许跨域请求

# 全局变量
emotion_classifier = None
ws_connection = None

# 情感映射
EMOTION_CHINESE_MAP = {
    'happy': '快乐',
    'sad': '悲伤', 
    'angry': '愤怒',
    'fear': '恐惧',
    'surprise': '惊讶',
    'disgust': '厌恶',
    'neutral': '平静',
    'calm': '平静',
    'confused': '困惑'
}

def init_emotion_model():
    """初始化情感检测模型"""
    global emotion_classifier

    # 添加这行：指定本地模型路径
    model_path = "/root/.cache/huggingface/hub/models--dima806--facial_emotions_image_detection"

    try:
        model_name = "dima806/facial_emotions_image_detection"
        device = 0 if torch.cuda.is_available() else -1

        logger.info(f"正在加载情感检测模型: {model_name}")
        logger.info(f"使用设备: {'GPU' if device == 0 else 'CPU'}")

        # 使用 local_files_only=True 确保从本地加载
        emotion_classifier = pipeline(
            "image-classification",
            model=model_path if os.path.exists(model_path) else model_name,
            device=device,
            local_files_only=True  # 新增：强制从本地加载
        )

        logger.info("✅ 情感检测模型加载成功!")
        return True

    except Exception as e:
        logger.error(f"❌ 加载情感检测模型失败: {e}")
        return False

def connect_to_websocket(session_id):
    """连接到主WebSocket服务器"""
    global ws_connection
    
    try:
        ws_url = f"ws://localhost:8001/ws/{session_id}"
        ws_connection = websocket.create_connection(ws_url)
        logger.info(f"已连接到WebSocket服务器: {ws_url}")
        return True
    except Exception as e:
        logger.error(f"连接WebSocket失败: {e}")
        return False

def analyze_emotion(image_data):
    """分析图像中的情感"""
    if not emotion_classifier:
        return None
        
    try:
        # 解码base64图像
        image_bytes = base64.b64decode(image_data)
        image = Image.open(BytesIO(image_bytes))
        
        # 进行情感检测
        results = emotion_classifier(image, top_k=7)
        
        if not results:
            return None
            
        # 获取最高概率的情感
        top_result = results[0]
        emotion = top_result["label"]
        confidence = top_result["score"]
        
        # 构建所有情感的概率分布
        all_emotions = {result["label"]: result["score"] for result in results}
        
        return {
            "emotion": emotion,
            "confidence": confidence,
            "chineseEmotion": EMOTION_CHINESE_MAP.get(emotion, emotion),
            "allEmotions": all_emotions,
            "source": "dima806_model"
        }
        
    except Exception as e:
        logger.error(f"情感分析失败: {e}")
        return None

@app.route('/health', methods=['GET'])
def health():
    """健康检查接口"""
    return jsonify({
        "status": "ok",
        "model_loaded": emotion_classifier is not None,
        "service": "emotion_detector"
    })

@app.route('/analyze_frame', methods=['POST'])
def analyze_frame():
    """分析单个视频帧的情感"""
    try:
        data = request.json
        session_id = data.get('session_id')
        frame_data = data.get('frame_data')
        
        if not session_id or not frame_data:
            return jsonify({"error": "缺少必要参数"}), 400
            
        # 确保WebSocket连接
        if not ws_connection or ws_connection.connected == False:
            connect_to_websocket(session_id)
            
        # 分析情感
        emotion_result = analyze_emotion(frame_data)
        
        if emotion_result:
            # 发送到主WebSocket服务器
            if ws_connection and ws_connection.connected:
                message = {
                    "type": "emotion_data",
                    "data": emotion_result
                }
                ws_connection.send(json.dumps(message))
                
            return jsonify({
                "success": True,
                "result": emotion_result
            })
        else:
            return jsonify({
                "success": False,
                "error": "情感分析失败"
            }), 500
            
    except Exception as e:
        logger.error(f"处理请求失败: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/start_detection', methods=['POST'])
def start_detection():
    """启动情感检测（连接WebSocket）"""
    try:
        data = request.json
        session_id = data.get('session_id')
        
        if not session_id:
            return jsonify({"error": "缺少session_id"}), 400
            
        success = connect_to_websocket(session_id)
        
        return jsonify({
            "success": success,
            "session_id": session_id
        })
        
    except Exception as e:
        logger.error(f"启动检测失败: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/stop_detection', methods=['POST'])
def stop_detection():
    """停止情感检测（断开WebSocket）"""
    global ws_connection
    
    try:
        if ws_connection:
            ws_connection.close()
            ws_connection = None
            
        return jsonify({"success": True})
        
    except Exception as e:
        logger.error(f"停止检测失败: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # 初始化模型
    init_emotion_model()
    
    # 启动Flask服务器
    logger.info("=" * 60)
    logger.info("情感检测服务器")
    logger.info("运行在: http://localhost:5000")
    logger.info("=" * 60)
    
    app.run(host='0.0.0.0', port=5000, debug=False) 