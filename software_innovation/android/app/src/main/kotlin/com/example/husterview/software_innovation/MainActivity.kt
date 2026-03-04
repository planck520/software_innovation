package com.example.husterview.software_innovation

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.iflytek.aiui.* // 导入讯飞 AIUI 核心包
import org.json.JSONObject
import android.widget.VideoView


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.huster.avatar/driver"
    private var mAIUIAgent: AIUIAgent? = null
    private var mVideoView: VideoView? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. 程序启动立即初始化 AIUI
        initAIUI()

        // 2. 建立 MethodChannel（保留它，以便以后 Flutter 仍然可以主动传话给数字人）
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSpeaking" -> {
                    val text = call.argument<String>("text")
                    // 如果此时 Agent 还没好，再次尝试初始化
                    if (mAIUIAgent == null) {
                        initAIUI()
                        result.success(false)
                    } else {
                        sendTextToAIUI(text ?: "")
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    // 1. 初始化 AIUI 代理
    private fun initAIUI() {
        if (mAIUIAgent == null) {
            try {
                // 1. 在创建 Agent 之前，必须先设置序列号 (SN)
                // 你可以使用 Android 的设备唯一 ID，或者先填入一个测试用的固定字符串
                com.iflytek.aiui.AIUISetting.setSystemInfo("sn", "huster_test_device_001")

                val cfgContent = assets.open("cfg/aiui_phone.cfg")
                    .bufferedReader()
                    .use { it.readText() }
                    .replace(Regex("//.*|/\\*.*?\\*/", RegexOption.DOT_MATCHES_ALL), "")

                mAIUIAgent = AIUIAgent.createAgent(this, cfgContent, mAIUIListener)

                // 2. 发送唤醒指令
                mAIUIAgent?.sendMessage(AIUIMessage(AIUIConstant.CMD_WAKEUP, 0, 0, "", null))

                println("AIUI 初始化：已设置 SN 并发送唤醒指令")
            } catch (e: Exception) {
                println("AIUI 初始化失败: ${e.message}")
            }
        }
    }

    // 2. 监听云端返回的结果 (包括数字人推流地址)
    private val mAIUIListener = AIUIListener { event ->
        when (event.eventType) {
            AIUIConstant.EVENT_STATE -> {
                val state = event.arg1
                if (state == AIUIConstant.STATE_WORKING) {
                    println("AIUI 引擎已就绪：WORKING 状态")

                    // 【核心修复】: 延迟 1 秒再发送，确保 session 彻底建立
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        val welcomeText = "你好，我是你的面试官，请问你准备好了吗？"
                        sendTextToAIUI(welcomeText)
                    }, 1000)
                }
            }
            AIUIConstant.EVENT_RESULT -> {
                // 这里会收到云端返回的流地址
                processResult(event.info, event.data)
            }
            AIUIConstant.EVENT_ERROR -> {
                val errorCode = event.arg1
                println("AIUI 错误: $errorCode, 描述: ${event.info}")

                // 如果还是报 21022，说明唤醒没成功，再次尝试唤醒
                if (errorCode == 21022) {
                    mAIUIAgent?.sendMessage(AIUIMessage(AIUIConstant.CMD_WAKEUP, 0, 0, "", null))
                }
            }
        }
    }

    // 封装一个简单的发送函数，避免代码重复
    private fun sendTextToAIUI(text: String) {
        val params = "sub=nlp,auth_id=hust_user_001,data_type=text"
        val message = AIUIMessage(AIUIConstant.CMD_WRITE, 0, 0, params, text.toByteArray())
        mAIUIAgent?.sendMessage(message)
        println("已向 AIUI 发送文本: $text")
    }

    // 3. 解析结果并通知 Flutter
    private fun processResult(info: String, data: android.os.Bundle?) {
        val infoJson = JSONObject(info)
        val dataArray = infoJson.optJSONArray("data") ?: return
        val dataObj = dataArray.getJSONObject(0)

        if (dataObj.getJSONObject("params").optString("sub") == "cbm_vms") {
            val content = dataObj.getJSONArray("content").getJSONObject(0)
            val cntId = content.getString("cnt_id")

            // 从 Bundle 中提取 ByteArray 数据
            val rawData = data?.getByteArray(cntId)

            if (rawData != null) {
                val vmsJson = JSONObject(String(rawData))
                if (vmsJson.optString("event_type") == "stream_info") {
                    val url = vmsJson.getString("stream_url")
                    startPlayer(url)
                }
            }
        }
    }

    private fun startPlayer(url: String) {
        runOnUiThread {
            println("准备播放数字人流: $url")
            try {
                // 销毁旧的 VideoView
                mVideoView?.stopPlayback()
                mVideoView = null

                // 创建新的 VideoView
                mVideoView = VideoView(this)

                // 设置布局参数
                val layoutParams = android.widget.FrameLayout.LayoutParams(
                    android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
                    android.widget.FrameLayout.LayoutParams.MATCH_PARENT
                )
                addContentView(mVideoView, layoutParams)

                // 设置视频路径并开始播放
                mVideoView?.setVideoPath(url)
                mVideoView?.start()

                println("开始播放视频流")

            } catch (e: Exception) {
                println("播放器加载失败: ${e.message}")
            }
        }
    }

    // 销毁时释放资源
    override fun onDestroy() {
        mVideoView?.stopPlayback()
        mVideoView = null
        mAIUIAgent?.destroy()
        mAIUIAgent = null
        super.onDestroy()
    }
}