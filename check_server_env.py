#!/usr/bin/env python3
"""
服务器环境检查脚本
用于验证情绪识别服务器的环境配置
"""

import os
import sys
import importlib.util

def check_python_version():
    """检查 Python 版本"""
    version = sys.version_info
    print(f"Python 版本: {version.major}.{version.minor}.{version.micro}")

    if version.major >= 3 and version.minor >= 7:
        print("✅ Python 版本符合要求 (>= 3.7)")
        return True
    else:
        print("❌ Python 版本过低，需要 3.7 或更高版本")
        return False

def check_dependencies():
    """检查 Python 依赖"""
    required_packages = {
        'torch': 'PyTorch',
        'transformers': 'Transformers',
        'flask': 'Flask',
        'flask_cors': 'Flask-CORS',
        'PIL': 'Pillow',
        'websocket': 'websocket-client',
        'numpy': 'NumPy',
        'cv2': 'OpenCV'
    }

    print("\n检查依赖包:")
    all_installed = True

    for module_name, package_name in required_packages.items():
        spec = importlib.util.find_spec(module_name)
        if spec is not None:
            print(f"✅ {package_name:20s} 已安装")
        else:
            print(f"❌ {package_name:20s} 未安装")
            all_installed = False

    return all_installed

def check_model_cache():
    """检查模型缓存"""
    model_path = "/root/.cache/huggingface/hub/models--dima806--facial_emotions_image_detection"

    print(f"\n检查模型缓存:")
    print(f"路径: {model_path}")

    if os.path.exists(model_path):
        print("✅ 模型缓存目录存在")

        # 检查目录大小
        total_size = 0
        for dirpath, dirnames, filenames in os.walk(model_path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                if os.path.exists(filepath):
                    total_size += os.path.getsize(filepath)

        size_mb = total_size / (1024 * 1024)
        print(f"模型大小: {size_mb:.2f} MB")

        if size_mb > 100:
            print("✅ 模型文件大小合理")
            return True
        else:
            print("⚠️ 模型文件可能不完整（小于 100MB）")
            return False
    else:
        print("❌ 模型缓存目录不存在")
        print("请先上传模型文件到服务器")
        return False

def check_port_availability():
    """检查端口可用性"""
    import socket

    port = 5000
    print(f"\n检查端口 {port}:")

    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('0.0.0.0', port))
            print(f"✅ 端口 {port} 可用")
            return True
    except OSError:
        print(f"❌ 端口 {port} 已被占用")
        return False

def check_write_permissions():
    """检查写入权限"""
    paths = [
        '/root/.cache/huggingface/',
        '/root/'
    ]

    print("\n检查写入权限:")
    all_writable = True

    for path in paths:
        if os.path.exists(path):
            if os.access(path, os.W_OK):
                print(f"✅ {path} 可写")
            else:
                print(f"❌ {path} 不可写")
                all_writable = False
        else:
            print(f"⚠️ {path} 不存在")

    return all_writable

def main():
    """主检查流程"""
    print("=" * 60)
    print("情绪识别服务器环境检查")
    print("=" * 60)

    checks = [
        ("Python 版本", check_python_version),
        ("Python 依赖", check_dependencies),
        ("模型缓存", check_model_cache),
        ("端口可用性", check_port_availability),
        ("写入权限", check_write_permissions)
    ]

    results = {}
    for name, check_func in checks:
        try:
            results[name] = check_func()
        except Exception as e:
            print(f"❌ {name} 检查出错: {e}")
            results[name] = False

    # 总结
    print("\n" + "=" * 60)
    print("检查总结:")
    print("=" * 60)

    all_passed = all(results.values())

    for name, passed in results.items():
        status = "✅ 通过" if passed else "❌ 失败"
        print(f"{name:15s}: {status}")

    print("=" * 60)

    if all_passed:
        print("\n✅ 所有检查通过！可以启动服务")
        print("运行: python run_server.py")
        return 0
    else:
        print("\n❌ 部分检查失败，请先解决上述问题")
        return 1

if __name__ == "__main__":
    sys.exit(main())
