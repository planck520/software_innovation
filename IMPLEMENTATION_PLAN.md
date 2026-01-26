# 毛玻璃拟态输入框组件实施计划

## 目标
创建一个全新的毛玻璃拟态风格输入框组件，并更新登录/注册界面。

---

## 实施检查清单

### 第一阶段：创建 GlassInputField 组件

**文件**: `lib/widgets/glass_input_field.dart` (新建)

#### 1.1 组件基础结构
- 创建 `GlassInputField` StatefulWidget
- 定义参数：label, controller, hintText, obscureText, isPassword, prefixIcon, keyboardType, onChanged, onSubmitted, enabled, focusColor, errorText
- 创建内部状态：_focusNode, _isFocused, _obscureText, _hasError, _inputType

#### 1.2 动画控制器初始化
- `_borderAnimationController`: 渐变边框动画 (Duration: 2000ms, repeat reverse)
- `_glowAnimationController`: 霓虹发光脉冲 (Duration: 1500ms, repeat reverse)
- `_labelAnimationController`: 浮动标签动画 (Duration: 200ms)
- `_rippleAnimationController`: 输入波纹效果 (Duration: 600ms)
- `_shakeAnimationController`: 错误震动反馈 (Duration: 400ms)
- `_iconAnimationController`: 密码可见性切换动画 (Duration: 300ms)
- `_bounceAnimationController`: 输入弹性反馈 (Duration: 150ms)

#### 1.3 毛玻璃背景实现
- 使用 `BackdropFilter` + `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`
- 半透明背景色：`AppColors.surface.withOpacity(0.6)`
- 微妙边框：`Border.all(color: AppColors.glassBorder, width: 1)`

#### 1.4 渐变边框动画
- 使用 `Container` + `BoxDecoration` + `Gradient`
- 聚焦时启用 `LinearGradient` 从 `AppColors.cyberBlue` 到 `AppColors.cyberPurple`
- 通过 `_borderAnimationController` 控制渐变位置变化

#### 1.5 动态阴影效果
- 聚焦时显示 `BoxShadow`
- 阴影颜色：`AppColors.primary.withOpacity(0.2 + glowAnimation.value * 0.2)`
- 模糊半径：`12 + glowAnimation.value * 8`
- 偏移量：`Offset(0, 4 + glowAnimation.value * 4)`

#### 1.6 浮动标签动画
- 标签位于输入框内部，使用 `Positioned` + `Transform`
- 聚焦或有内容时：标签上移 28px 并缩小到 10px
- 使用 `_labelAnimationController` 控制 `Tween<Offset>`
- 颜色变化：聚焦时使用 `_focusColor`

#### 1.7 输入反馈微动画
- 监听 `controller.addListener()`
- 每次输入内容变化时触发 `_bounceAnimationController.forward()`
- 使用 `Transform.scale` 实现轻微缩放效果 (0.98 → 1.0)

#### 1.8 智能清除按钮
- 当输入���有内容且聚焦时显示清除图标
- 使用 `AnimatedOpacity` 控制显示/隐藏
- 点击后清空输入框并触发震动反馈

#### 1.9 账号格式检测
- 监听输入内容，通过正则表达式判断类型：
  - 邮箱：`RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')`
  - 手机：`RegExp(r'^1[3-9]\d{9}$')`
  - 用户名：其他情况
- 动态切换 `prefixIcon`
- 使用 `AnimatedSwitcher` 实现图标切换动画

#### 1.10 输入波纹效果
- 聚焦时从标签位置扩散圆形波纹
- 使用 `Container` + `BoxDecoration` + `BoxShape.circle`
- 通过 `_rippleAnimationController` 控制半径和透明度变化

#### 1.11 霓虹发光脉冲
- 聚焦时启用 `_glowAnimationController.repeat(reverse: true)`
- 边框颜色透明度：`0.5 + glowAnimation.value * 0.3`
- 外发光：`BoxShadow(color: _focusColor.withOpacity(0.1 + glowAnimation.value * 0.2))`

#### 1.12 错误震动反馈
- 创建 `shakeError()` 方法触发震动
- 使用 `Tween<double>(begin: 0, end: 1)` 配合 `Transform.translate`
- 震动偏移：`Offset(sin(shakeAnimation.value * 20) * 5, 0)`

#### 1.13 连接状态指示点
- 在输入框右上角显示状态点
- 三种状态：
  - 在线：绿色 + 呼吸动画
  - 离线：灰色
  - 连接中：黄色 + 旋转动画
- 参数：`ConnectionStatus` 枚举

#### 1.14 CapsLock 提示
- 监听键盘事件检测 CapsLock 状态
- 当检测到大写锁定开启且输入小写字母时显示提示
- 显示为图标或文字在输入框下方

#### 1.15 密码可见性切换动画
- 眼睛图标旋转 + 缩放组合动画
- 旋转角度：`0 ↔ π`
- 缩放：`1.0 ↔ 0.8`
- 使用 `Transform.rotate` + `Transform.scale`

---

### 第二阶段：创建连接状态枚举和工具类

**文件**: `lib/widgets/glass_input_field.dart` (同一文件)

#### 2.1 定义 ConnectionStatus 枚举
```dart
enum ConnectionStatus {
  online,    // 在线 - 绿色
  offline,   // 离线 - 灰色
  connecting // 连接中 - 黄色动画
}
```

#### 2.2 定义 InputType 枚举
```dart
enum InputType {
  email,     // 邮箱
  phone,     // 手机号
  username,  // 用户名
  password,  // 密码
  general    // 通用
}
```

---

### 第三阶段：修改登录界面

**文件**: `lib/main.dart` 中的 `_LoginPageState`

#### 3.1 导入新组件
- 添加 `import 'widgets/glass_input_field.dart';`

#### 3.2 添加状态变量
- `ConnectionStatus _connectionStatus = ConnectionStatus.online;`
- `String? _usernameError;`
- `String? _passwordError;`

#### 3.3 替换账号输入框
- 将 `TextField` 替换为 `GlassInputField`
- 设置 `label: "账号"`
- 设置 `prefixIcon: Icons.person_outlined` (初始)
- 启用 `autoDetectType: true`
- 添加 `onChanged` 回调进行实时验证

#### 3.4 替换密码输入框
- 将 `TextField` 替换为 `GlassInputField`
- 设置 `label: "密码"`
- 设置 `isPassword: true`
- 添加 `connectionStatus: _connectionStatus`

#### 3.5 添加注册入口
- 在登录卡片底部添加"没有账号？立即注册"链接
- 点击后跳转到 `RegisterPage`

#### 3.6 添加表单验证逻辑
- 账号非空验证
- 密码强度验证（至少6位，包含字母和数字）
- 验证失败时调用 `shakeError()`

---

### 第四阶段：更新注册界面

**文件**: `lib/main.dart` 中的 `_RegisterPageState`

#### 4.1 导入新组件
- 添加 `import 'widgets/glass_input_field.dart';`

#### 4.2 替换所有输入框
- 用户别名输入框 → `GlassInputField`
- 邮箱地址输入框 → `GlassInputField` (设置 keyboardType)
- 访问密钥输入框 → `GlassInputField` (isPassword)
- 确认密钥输入框 → `GlassInputField` (isPassword)

#### 4.3 添加密码强度指示器
- 实时显示密码强度（弱/中/强）
- 使用颜色条表示：红 → 黄 → 绿

#### 4.4 添加返回登录入口
- 在注册页面底部添加"已有账号？立即登录"链接

---

### 第五阶段：添加页面跳转逻辑

**文件**: `lib/main.dart`

#### 5.1 登录到注册
- 在 `_buildLoginForm()` 下方添加注册按钮
- 使用 `Navigator.push()` 跳转到 `RegisterPage`

#### 5.2 注册到登录
- 注册成功后使用 `Navigator.pop()` 返回登录页
- 显示注册成功提示

---

### 第六阶段：键盘避让处理

**文件**: `lib/widgets/glass_input_field.dart`

#### 6.1 键盘弹出检测
- 使用 `MediaQuery.of(context).viewInsets.bottom`
- 监听键盘状态变化

#### 6.2 输入框上移动画
- 键盘弹出时，输入框整体上移
- 使用 `AnimatedContainer` + `Transform.translate`
- 平滑过渡：`Duration(milliseconds: 300)`

---

## 实施顺序

1. ✅ 创建 `GlassInputField` 组件基础结构
2. ✅ 实现毛玻璃背景和基础样式
3. ✅ 添加浮动标签动画
4. ✅ 添加渐变边框动画
5. ✅ 添加霓虹发光脉冲
6. ✅ 添加动态阴影
7. ✅ 添加输入反馈微动画
8. ✅ 添加智能清除按钮
9. ✅ 添加账号格式检测
10. ✅ 添加输入波纹效果
11. ✅ 添加错误震动反馈
12. ✅ 添加连接状态指示点
13. ✅ 添加 CapsLock 提示
14. ✅ 添加密码可见性切换动画
15. ✅ 修改登录界面使用新组件
16. ✅ 添加注册功能入口
17. ✅ 更新注册界面使用新组件
18. ✅ 添加键盘避让处理
19. ✅ 测试所有功能和动画效果
20. ✅ 最终审查和优化

---

## 最终动作

运行应用，验证：
1. 登录界面输入框所有动画效果正常
2. 注册界面可以正常访问和注册
3. 所有创新点功能正常工作
4. 无性能问题和内存泄漏
