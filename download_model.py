#!/usr/bin/env python3
"""
下载情绪识别模型到本地缓存
运行一次即可，模型会保存到 ~/.cache/huggingface/hub/
"""

from transformers import pipeline
import torch

def download_model():
    print("正在下载情绪识别模型...")
    print("模型: dima806/facial_emotions_image_detection")

    # 指定本地优先模式，避免再次尝试下载
    classifier = pipeline(
        "image-classification",
        model="dima806/facial_emotions_image_detection",
        device=0 if torch.cuda.is_available() else -1,
        local_files_only=False  # 首次运行设为False下载模型
    )

    # 测试一下模型是否可用
    from PIL import Image
    test_result = classifier(Image.new('RGB', (224, 224), color='red'), top_k=3)
    print("模型测试成功!")
    print("测试结果:", test_result)

    print("\n✅ 模型下载完成!")
    print("模型缓存目录: ~/.cache/huggingface/hub/")
    print("\n请将整个缓存目录上传到服务器，例如:")
    print("  scp -r ~/.cache/huggingface/hub/ root@你的服务器:/root/.cache/huggingface/hub/")

if __name__ == "__main__":
    download_model()
