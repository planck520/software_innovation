import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:web_socket_channel/io.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 导入新的设计系统
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/app_tokens.dart';
import 'theme/app_text_styles.dart';

// 导入新的UI组件
import 'widgets/glass_card.dart';
import 'widgets/tech_button.dart';
import 'widgets/ios_text_field.dart';
import 'widgets/ios_bottom_nav.dart';
import 'widgets/tech_progress_indicator.dart';
import 'widgets/page_transitions.dart';
import 'widgets/staggered_list_view.dart';
import 'widgets/loading_states.dart';
import 'widgets/background_decorations.dart';
import 'widgets/digital_avatar.dart';

List<CameraDescription> _cameras = [];

// 全局主题模式：true为深色背景，false为浅色背景
bool isDarkBackground = false;

// 用于通知整个应用刷新主题的通知器
final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(false);

List<Map<String, dynamic>> globalUsers = [
  {
    "username": "admin",
    "password": "123",
    "name": "系统管理员",
    "avatarPath": null,
    "history": <Map<String, dynamic>>[], // 明确指定类型
  },
  {
    "username": "huster",
    "password": "666",
    "name": "面试者小王",
    "avatarPath": null,
    "history": <Map<String, dynamic>>[], // 明确指定类型
  },
];

// 记录当前登录的用户索引
int currentUserIndex = -1;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _cameras = await availableCameras();
  } catch (e) {
    debugPrint("相机初始化失败");
  }
  // 在这里加载本地保存的用户数据
  await loadUserData();

  runApp(const HusterviewApp());
}

// 保存数据到本地磁盘
Future<void> saveUserData() async {
  final prefs = await SharedPreferences.getInstance();
  // 将 List 转换成 JSON 字符串
  String jsonStr = jsonEncode(globalUsers);
  await prefs.setString('user_data_key', jsonStr);
}

// 启动时加载数据
Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  String? jsonStr = prefs.getString('user_data_key');
  if (jsonStr != null) {
    List<dynamic> decoded = jsonDecode(jsonStr);
    // 还原 globalUsers
    globalUsers = List<Map<String, dynamic>>.from(decoded);
  }
  // 加载主题设置
  isDarkBackground = prefs.getBool('is_dark_background') ?? false;
  themeNotifier.value = isDarkBackground;
}

// 保存主题设置
Future<void> saveThemeSetting() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_dark_background', isDarkBackground);
}

// --- 鉴权工具类 ---
class XfAuth {
  static const String appId = "c9945e5e";
  static const String apiKey = "0a3dbc14d9fe900ecff024e108105748";
  static const String apiSecret = "YWQyZDE1Y2I3MjBlNmIwMTA0OTM0ZTE1";

  static String getUrl(String hostUrl) {
    Uri uri = Uri.parse(hostUrl);
    String date = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').format(DateTime.now().toUtc()) + " GMT";
    String signatureOrigin = "host: ${uri.host}\ndate: $date\nGET ${uri.path} HTTP/1.1";
    var hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    var signature = base64.encode(hmacSha256.convert(utf8.encode(signatureOrigin)).bytes);
    String authOrigin = 'api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signature"';
    String authorization = base64.encode(utf8.encode(authOrigin)).replaceAll('\n', '').replaceAll('\r', '');
    return "wss://${uri.host}${uri.path}?authorization=$authorization&date=${Uri.encodeComponent(date)}&host=${uri.host}";
  }
}

class HusterviewApp extends StatelessWidget {
  const HusterviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Husterview',
          theme: AppTheme.lightTheme,
          home: const LoginPage(),
        );
      },
    );
  }
}

// Logo背景网格绘制器
class _LogoGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // 绘制垂直线
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // 绘制水平线
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- 1. 登录界面 (stitch_login_screen 风格) ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    String inputUser = _userController.text.trim();
    String inputPass = _passController.text.trim();

    if (inputUser.isEmpty || inputPass.isEmpty) {
      _showMsg("请输入完整信息", AppColors.warning);
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    int foundIndex = globalUsers.indexWhere(
            (u) => u['username'] == inputUser && u['password'] == inputPass
    );

    setState(() => _isLoading = false);

    if (foundIndex != -1) {
      currentUserIndex = foundIndex;
      Navigator.pushReplacement(
          context,
          TechPageTransitions.fadeScale(builder: (c) => const MainEntryPage())
      );
    } else {
      _showMsg("身份验证失败", AppColors.error);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        )
    );
  }

  // 密码验证：至少6位，包含字母和数字
  bool _isValidPassword(String password) {
    if (password.length < 6) return false;
    bool hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    return hasLetter && hasDigit;
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    int step = 1; // 1: 输入邮箱, 2: 设置新密码

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  step == 1 ? Icons.email_outlined : Icons.lock_reset,
                  color: AppColors.primary,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                step == 1 ? "验证邮箱" : "设置新密码",
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (step == 1) ...[
                Text(
                  "请输入您注册时使用的邮箱地址",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "example@email.com",
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                  ),
                ),
              ] else ...[
                Text(
                  "密码要求：至少6位，包含字母和数字",
                  style: TextStyle(fontSize: 12, color: AppColors.warning),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "新密码",
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassController,
                  obscureText: true,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "确认新密码",
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("取消", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (step == 1) {
                  // 验证邮箱格式
                  String email = emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    _showMsg("请输入有效的邮箱地址", AppColors.warning);
                    return;
                  }
                  // 模拟验证成功，进入下一步
                  setDialogState(() => step = 2);
                } else {
                  // 验证新密码
                  String newPass = newPassController.text;
                  String confirmPass = confirmPassController.text;

                  if (!_isValidPassword(newPass)) {
                    _showMsg("密码需至少6位，包含字母和数字", AppColors.warning);
                    return;
                  }
                  if (newPass != confirmPass) {
                    _showMsg("两次密码不一致", AppColors.warning);
                    return;
                  }

                  // 重置密码（这里简单处理，实际应该通过邮箱验证）
                  // 假设重置第一个用户的密码作为演示
                  Navigator.pop(context);
                  _showMsg("密码重置成功，请使用新密码登录", AppColors.success);
                }
              },
              child: Text(step == 1 ? "下一步" : "确认重置"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 430,
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顶部导航栏
                  _buildHeader(),
                  const SizedBox(height: 12),
                  // Logo 区域
                  _buildLogoSection(),
                  const SizedBox(height: 8),
                  // 标题
                  _buildTitle(),
                  const SizedBox(height: 16),
                  // 输入卡片
                  _buildInputCard(),
                  const SizedBox(height: 24),
                  // 注册链接
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: const Icon(Icons.terminal, color: Colors.white, size: 16.8),
            ),
            const SizedBox(width: 12),
            Text(
              "系统访问",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "在线",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.sensors, color: AppColors.primary, size: 9.8),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.cyberPurple.withOpacity(0.08),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 背景装饰网格
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              child: CustomPaint(
                painter: _LogoGridPainter(),
              ),
            ),
          ),
          // Logo图片
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo图片 - 更大尺寸
                  Container(
                    constraints: const BoxConstraints(maxWidth: 360, maxHeight: 180),
                    child: Image.asset(
                      'logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 0),
                  // 状态标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "AI面试引擎就绪",
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "AI 门户登录",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "初始化您的认知会话",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户名输入
          Text(
            "邮箱或手机号",
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _userController,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: "user_id@simulation.io",
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: Icon(Icons.alternate_email, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 密码输入
          Text(
            "访问码",
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: "••••••••",
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          // 忘记密码链接
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                "忘记密码?",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 登录按钮
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 39,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return TechButton(
      text: "进入",
      icon: Icons.login,
      onPressed: _handleLogin,
      isFullWidth: true,
    );
  }

  Widget _buildBiometricSection() {
    return Column(
      children: [
        // 分隔线
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.border.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "生物识别访问",
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: AppColors.border.withOpacity(0.3))),
          ],
        ),
        const SizedBox(height: 24),
        // 人脸识别按钮
        GestureDetector(
          onTap: () => _showMsg("生物识别功能开发中", AppColors.warning),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Icon(Icons.face, color: AppColors.primary, size: 22.4),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "新研究员？ ",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                TechPageTransitions.fadeScale(builder: (c) => const RegisterPage()),
              );
            },
            child: Text(
              "注册账号",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 注册界面 (stitch_login_screen 风格) ---
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showMsg("请填写完整信息", AppColors.warning);
      return;
    }

    if (password != confirmPassword) {
      _showMsg("两次密码不一致", AppColors.error);
      return;
    }

    // 检查用户名是否已存在
    bool exists = globalUsers.any((u) => u['username'] == username);
    if (exists) {
      _showMsg("用户名已存在", AppColors.error);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    // 添加新用户
    globalUsers.add({
      "username": username,
      "password": password,
      "name": username,
      "email": email,
      "avatarPath": null,
      "history": <Map<String, dynamic>>[],
    });

    await saveUserData();

    setState(() => _isLoading = false);

    _showMsg("注册成功！", AppColors.success);
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pop(context);
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 430,
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顶部导航
                  _buildHeader(),
                  const SizedBox(height: 32),
                  // 标题
                  _buildTitle(),
                  const SizedBox(height: 24),
                  // 进度指示
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),
                  // 表单卡片
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  // 返回登录
                  _buildBackToLogin(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 9.8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            "初始化档案",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // AES-256 加密提示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, color: AppColors.success, size: 8.4),
              const SizedBox(width: 4),
              Text(
                "AES-256",
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "创建新档案",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "建立您的神经链路身份",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: AppColors.surfaceDim,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "100% 已就绪",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "数据加密中...",
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户别名
          _buildInputField(
            label: "用户别名",
            hint: "neural_user_01",
            controller: _usernameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          // 邮箱
          _buildInputField(
            label: "邮箱地址",
            hint: "user@simulation.io",
            controller: _emailController,
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          // 密码
          _buildInputField(
            label: "访问密钥",
            hint: "••••••••",
            controller: _passwordController,
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 20),
          // 确认密码
          _buildInputField(
            label: "确认密钥",
            hint: "••••••••",
            controller: _confirmPasswordController,
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 24),
          // 注册按钮
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            keyboardType: keyboardType,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              prefixIcon: Icon(icon, color: AppColors.textTertiary),
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 39,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return TechButton(
      text: "激活档案",
      icon: Icons.rocket_launch,
      onPressed: _handleRegister,
      isFullWidth: true,
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "已有档案？ ",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              "返回登录",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 主入口页 (科技风格美化) ---
class MainEntryPage extends StatefulWidget {
  const MainEntryPage({super.key});

  @override
  State<MainEntryPage> createState() => _MainEntryPageState();
}

class _MainEntryPageState extends State<MainEntryPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final List<Widget> _pages = [
    const SetupPage(),        // 首页 - 开始面试
    const QuestionBankPage(), // 题库
    const HistoryPage(),      // 历史
    const ProfilePage(),      // 我的
  ];

  // 自定义底部导航项，与页面对应
  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: "面试"),
    NavItem(icon: Icons.quiz_outlined, activeIcon: Icons.quiz, label: "题库"),
    NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: "历史"),
    NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "我的"),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: IosBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }
}

// --- 历史记录页 (stitch interview_history 风格) ---
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = "全部记录";
  final List<String> _filters = ["全部记录", "技术研发", "产品设计", "数据分析", "人工智能", "市场运营", "管理岗位"];

  // 批量删除相关
  bool _isSelectMode = false;
  Set<int> _selectedIndices = {};

  List<dynamic> _getFilteredHistory(List<dynamic> history) {
    if (_selectedFilter == "全部记录") return history;
    return history.where((e) {
      final jobCategory = e['jobCategory'] ?? '';
      final job = e['job'] ?? '';
      return jobCategory.contains(_selectedFilter) || job.contains(_selectedFilter);
    }).toList();
  }

  Map<DateTime, int> _getInterviewData(List<dynamic> history) {
    final data = <DateTime, int>{};
    for (final item in history) {
      final dateStr = item['date'];
      if (dateStr == null) continue;
      final parsed = DateTime.tryParse(dateStr);
      if (parsed == null) continue;
      final day = DateTime(parsed.year, parsed.month, parsed.day);
      data[day] = (data[day] ?? 0) + 1;
    }
    return data;
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll(List<dynamic> history) {
    setState(() {
      if (_selectedIndices.length == history.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices = Set.from(List.generate(history.length, (i) => i));
      }
    });
  }

  // 显示面试详情底部弹窗
  void _showInterviewDetail(Map<String, dynamic> item) {
    final qaDetails = (item['qaDetails'] as List<dynamic>?) ?? [];
    final interviewerType = item['interviewerType'] ?? "技术专家";
    final duration = item['duration'] ?? "00:00";
    final emotionScore = item['emotionScore'] ?? 85;

    // 根据面试官类型获取头像URL
    final Map<String, String> interviewerAvatars = {
      '技术专家': 'https://api.dicebear.com/9.x/micah/png?seed=Alex&backgroundColor=b6e3f4&size=128&baseColor=f9c9b6',
      '行为面试专家': 'https://api.dicebear.com/9.x/micah/png?seed=JordanSmile&backgroundColor=c0aede&size=128&baseColor=f9c9b6&mouth=smile',
      '业务主管': 'https://api.dicebear.com/9.x/micah/png?seed=Sophia&backgroundColor=d1f4d1&size=128&baseColor=f9c9b6&earringsProbability=100',
      'HR总监': 'https://api.dicebear.com/9.x/micah/png?seed=EmmaHappy&backgroundColor=ffd5dc&size=128&baseColor=f9c9b6&earringsProbability=100&mouth=smile',
    };
    final avatarUrl = interviewerAvatars[interviewerType] ?? interviewerAvatars['技术专家']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // 拖拽条
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 头部信息
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        // 面试官头像
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.person, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 面试官信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['job'] ?? "未知岗位",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      interviewerType,
                                      style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item['date'] ?? "",
                                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 总分
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${item['totalScore'] ?? 0}",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text("总分", style: TextStyle(fontSize: 10, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 统计信息栏
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(Icons.timer_outlined, "时长", duration),
                        Container(width: 1, height: 30, color: AppColors.border),
                        _buildStatItem(Icons.quiz_outlined, "问题", "${qaDetails.length}题"),
                        Container(width: 1, height: 30, color: AppColors.border),
                        _buildStatItem(Icons.mood, "情绪", "$emotionScore%"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 问答列表标题
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.format_list_numbered, color: AppColors.primary, size: 9.8),
                        const SizedBox(width: 8),
                        Text(
                          "问答详情",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 问答列表
                  Expanded(
                    child: qaDetails.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 33.6, color: AppColors.textTertiary.withOpacity(0.5)),
                                const SizedBox(height: 12),
                                Text("暂无问答记录", style: TextStyle(color: AppColors.textTertiary)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: qaDetails.length,
                            itemBuilder: (context, index) {
                              final qa = qaDetails[index];
                              return _buildQAItem(index + 1, qa);
                            },
                          ),
                  ),
                  // 底部按钮
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDim,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "关闭",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  TechPageTransitions.iosSlide(builder: (c) => ReportPage(reportData: item)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    "查看报告",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 12.6, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildQAItem(int index, Map<String, dynamic> qa) {
    final int score = qa['score'] ?? 0;
    final Color scoreColor = score >= 85 ? AppColors.success : score >= 70 ? AppColors.primary : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 问题标题栏
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    "$index",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "问题",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1),
                ),
              ),
              // 分数标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 8.4, color: scoreColor),
                    const SizedBox(width: 4),
                    Text(
                      "$score分",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scoreColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 问题内容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              qa['question'] ?? "",
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          // 回答标题
          Row(
            children: [
              Icon(Icons.record_voice_over, size: 9.8, color: AppColors.cyberPurple),
              const SizedBox(width: 6),
              Text(
                "我的回答",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 回答内容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              qa['answer'] ?? "",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusXl)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16.8),
            const SizedBox(width: 10),
            const Text("确认删除"),
          ],
        ),
        content: Text("确定要删除选中的 ${_selectedIndices.length} 条记录吗？此操作不可恢复。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("取消", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              // 按索引从大到小删除，避免索引错位
              final sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
              for (int index in sortedIndices) {
                globalUsers[currentUserIndex]['history'].removeAt(index);
              }
              saveUserData();
              Navigator.pop(context);
              setState(() {
                _selectedIndices.clear();
                _isSelectMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("已删除 ${sortedIndices.length} 条记录"),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text("删除", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> userHistory = globalUsers[currentUserIndex]['history'];
    final filteredHistory = _getFilteredHistory(userHistory);
    final interviewData = _getInterviewData(userHistory);

    // 计算统计数据
    int totalInterviews = userHistory.length;
    double avgTechScore = totalInterviews == 0 ? 0 :
      userHistory.map((e) => (e['totalScore'] ?? 0) as int).reduce((a, b) => a + b) / totalInterviews;

    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // 顶部导航
              _buildHeader(filteredHistory),
              // 统计卡片 (非选择模式时显示)
              if (!_isSelectMode) _buildStatsSection(avgTechScore, totalInterviews, interviewData),
              // 选择模式工具栏
              if (_isSelectMode) _buildSelectToolbar(filteredHistory),
              // 筛选标签
              if (!_isSelectMode) _buildFilterTabs(),
              const SizedBox(height: 16),
              // 列表
              Expanded(
                child: filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(filteredHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<dynamic> history) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: const Icon(Icons.history, color: Colors.white, size: 9.8),
          ),
          const SizedBox(width: 12),
          Text(
            _isSelectMode ? "已选 ${_selectedIndices.length} 项" : "面试历史",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // 管理/完成按钮
          if (history.isNotEmpty)
            GestureDetector(
              onTap: _toggleSelectMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isSelectMode ? AppColors.primary : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                  border: Border.all(color: _isSelectMode ? AppColors.primary : AppColors.border.withOpacity(0.5)),
                ),
                child: Text(
                  _isSelectMode ? "完成" : "管理",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _isSelectMode ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectToolbar(List<dynamic> history) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // 全选按钮
          GestureDetector(
            onTap: () => _selectAll(history),
            child: Row(
              children: [
                Icon(
                  _selectedIndices.length == history.length
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: AppColors.primary,
                  size: 15.4,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedIndices.length == history.length ? "取消全选" : "全选",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 删除按钮
          GestureDetector(
            onTap: _selectedIndices.isNotEmpty ? _deleteSelected : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedIndices.isNotEmpty
                    ? AppColors.error
                    : AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: _selectedIndices.isNotEmpty ? Colors.white : AppColors.textTertiary,
                    size: 12.6,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "删除",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedIndices.isNotEmpty ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// 新增：日历热力图组件
  Widget _buildInterviewCalendar(Map<DateTime, int> interviewData) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final startRange = normalizedToday.subtract(const Duration(days: 364));
    final startWeekdayIndex = (startRange.weekday + 6) % 7; // 以周一为起点
    final firstCellDate = startRange.subtract(Duration(days: startWeekdayIndex));
    final totalDays = normalizedToday.difference(firstCellDate).inDays + 1;
    final weekCount = (totalDays / 7).ceil();
    final dateFormatter = DateFormat('yyyy-MM-dd');

    Color _colorForCount(int? count) {
      if (count == null) {
        return Colors.transparent;
      }
      if (count == 0) {
        return AppColors.border.withOpacity(0.25);
      }
      if (count <= 5) {
        final ratio = count / 5;
        return Color.lerp(const Color(0xFFDCFCE7), const Color(0xFF064E3B), ratio)!;
      }
      if (count <= 10) {
        return const Color(0xFFF87171);
      }
      return const Color(0xFFB91C1C);
    }

    List<Widget> _buildWeekColumns() {
      return List.generate(weekCount, (week) {
        return Padding(
          padding: EdgeInsets.only(right: week == weekCount - 1 ? 0 : 3),
          child: Column(
            children: List.generate(7, (weekdayIndex) {
              final date = firstCellDate.add(Duration(days: week * 7 + weekdayIndex));
              final normalized = DateTime(date.year, date.month, date.day);
              final bool inRange =
                  !normalized.isBefore(startRange) && !normalized.isAfter(normalizedToday);
              final int? count = inRange ? (interviewData[normalized] ?? 0) : null;
              final tooltipText =
                  "${dateFormatter.format(normalized)} · ${count == null ? 0 : count} 场";

              final cell = Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: _colorForCount(count),
                  borderRadius: BorderRadius.circular(2),
                  border: inRange
                      ? null
                      : Border.all(color: AppColors.border.withOpacity(0.15), width: 0.5),
                ),
              );

              if (!inRange) {
                return cell;
              }

              return Tooltip(
                message: tooltipText,
                triggerMode: TooltipTriggerMode.longPress,
                waitDuration: const Duration(milliseconds: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border.withOpacity(0.6)),
                ),
                textStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                preferBelow: false,
                child: cell,
              );
            }),
          ),
        );
      });
    }

    const weekdayLabels = ["一", "二", "三", "四", "五", "六", "日"];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyberPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.video_camera_front_outlined,
                  color: AppColors.cyberPurple,
                  size: 11.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "面试场次",
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                "过去一年",
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekdayLabels
                    .map((label) => SizedBox(
                          height: 13,
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 9, color: AppColors.textTertiary),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _buildWeekColumns()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(AppColors.border.withOpacity(0.25), "0"),
              _buildLegendItem(const Color(0xFFDCFCE7), "1-2"),
              _buildLegendItem(const Color(0xFF34D399), "3-5"),
              _buildLegendItem(const Color(0xFFF87171), "6-10"),
              _buildLegendItem(const Color(0xFFB91C1C), ">10"),
            ],
          ),
        ],
      ),
    );
  }

  // 新增：图例小方块
  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            color: color,
            margin: const EdgeInsets.only(right: 2),
          ),
          Text(
            text,
            style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      double avgScore, int totalCount, Map<DateTime, int> interviewData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 平均技术分
          Expanded(
            child: _buildStatCard(
              label: "平均技术分",
              value: avgScore.toStringAsFixed(1),
              icon: Icons.analytics_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // 面试场次
          Expanded(
            child: _buildInterviewCalendar(interviewData),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 11.2),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: AppColors.success, size: 9.8),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(colors: AppColors.primaryGradient) : null,
                color: isSelected ? null : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                border: isSelected ? null : Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(List<dynamic> history) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryCard(item, index);
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    final int score = item['totalScore'] ?? 0;
    final int techScore = (score * 0.9).round();  // 模拟技术分
    final int commScore = (score * 0.85).round(); // 模拟沟通分
    final bool isSelected = _selectedIndices.contains(index);
    final String interviewerType = item['interviewerType'] ?? "技术专家";

    return GestureDetector(
      onTap: () {
        if (_isSelectMode) {
          _toggleSelection(index);
        } else {
          _showInterviewDetail(item);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: AppTokens.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：职位和日期
            Row(
              children: [
                // 选择模式下显示复选框
                if (_isSelectMode) ...[
                  GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 11.2)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work_outline, color: AppColors.primary, size: 9.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['job'] ?? "未知岗位",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cyberPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              interviewerType,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.cyberPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['date'] ?? "",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 分数徽章
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                  ),
                  child: Text(
                    "$score分",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 进度条区域
            _buildProgressRow("技术能力", techScore, AppColors.primary),
            const SizedBox(height: 10),
            _buildProgressRow("沟通表达", commScore, AppColors.cyberPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppColors.surfaceDim,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$value%",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_outlined, size: 19.6, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text(
            "暂无面试记录",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "开始您的第一次模拟面试吧",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}


// --- 个人资料页 (stitch personal_center 风格) ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _pickAvatar() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        setState(() {
          globalUsers[currentUserIndex]['avatarPath'] = result.files.single.path;
        });
        _showStatus("头像更新成功", AppColors.success);
      }
    } catch (e) {
      _showStatus("更新失败", AppColors.error);
    }
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusXl)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 9.8),
            ),
            const SizedBox(width: 12),
            const Text("修改密码", style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(oldPassController, "原密码", true),
            const SizedBox(height: 12),
            _buildDialogField(newPassController, "新密码", true),
            const SizedBox(height: 12),
            _buildDialogField(confirmPassController, "确认密码", true),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("取消", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      String currentActualPass = globalUsers[currentUserIndex]['password'];
                      if (oldPassController.text != currentActualPass) {
                        _showStatus("原密码错误", AppColors.error);
                        return;
                      }
                      if (newPassController.text.isEmpty) {
                        _showStatus("新密码不能为空", AppColors.warning);
                        return;
                      }
                      if (newPassController.text != confirmPassController.text) {
                        _showStatus("两次密码不一致", AppColors.warning);
                        return;
                      }
                      setState(() {
                        globalUsers[currentUserIndex]['password'] = newPassController.text;
                      });
                      Navigator.pop(context);
                      _showStatus("密码修改成功", AppColors.success);
                    },
                    child: const Text("确认", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.caption,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: globalUsers[currentUserIndex]['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusXl)),
        title: const Text("修改昵称"),
        content: TextField(
          controller: nameController,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("取消", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        globalUsers[currentUserIndex]['name'] = nameController.text;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("保存", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 简历管理功能
  void _showResumeManager() {
    final user = globalUsers[currentUserIndex];
    final resumePath = user['resumePath'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description, color: AppColors.primary, size: 16.8),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "我的简历",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 当前简历状态
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: resumePath != null
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: resumePath != null
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.border.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      resumePath != null ? Icons.check_circle : Icons.info_outline,
                      color: resumePath != null ? AppColors.success : AppColors.textSecondary,
                      size: 14,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resumePath != null ? "已上传简历" : "暂未上传简历",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (resumePath != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              resumePath.split('/').last.split('\\').last,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 提示信息
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 12.6),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "上传简历后，AI面试官将根据您的简历进行针对性提问",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 操作按钮
              Row(
                children: [
                  if (resumePath != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            globalUsers[currentUserIndex]['resumePath'] = null;
                          });
                          saveUserData();
                          setSheetState(() {});
                          _showStatus("简历已删除", AppColors.warning);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline, color: AppColors.error, size: 12.6),
                              const SizedBox(width: 6),
                              Text(
                                "删除简历",
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (resumePath != null) const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx'],
                          );
                          if (result != null && result.files.single.path != null) {
                            setState(() {
                              globalUsers[currentUserIndex]['resumePath'] = result.files.single.path;
                            });
                            saveUserData();
                            setSheetState(() {});
                            _showStatus("简历上传成功", AppColors.success);
                          }
                        } catch (e) {
                          _showStatus("上传失败", AppColors.error);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.primaryGradient),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              resumePath != null ? Icons.refresh : Icons.upload_file,
                              color: Colors.white,
                              size: 12.6,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              resumePath != null ? "更换简历" : "上传简历",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 支持格式提示
              Text(
                "支持 PDF、DOC、DOCX 格式",
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 面试技巧建议功能
  void _showInterviewTips() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cyberPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tips_and_updates, color: AppColors.cyberPurple, size: 16.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "面试技巧建议",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "AI根据您的面试表现生成的个性化建议",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 技巧列表
            Expanded(
              child: ListView(
                children: [
                  _buildTipCard(
                    "自我介绍技巧",
                    Icons.person_outline,
                    AppColors.primary,
                    [
                      "控制时长在1-3分钟，突出关键经历",
                      "采用'现在-过去-未来'的叙述结构",
                      "量化成果，用数据说话",
                      "与目标岗位建立关联性",
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    "行为面试STAR法则",
                    Icons.stars_outlined,
                    AppColors.cyberPurple,
                    [
                      "Situation: 描述具体背景和情境",
                      "Task: 说明你的任务和目标",
                      "Action: 详述你采取的行动",
                      "Result: 展示最终成果和影响",
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    "技术面试要点",
                    Icons.code,
                    const Color(0xFF10B981),
                    [
                      "先理清思路再写代码，边写边讲解",
                      "考虑边界条件和异常处理",
                      "分析时间复杂度和空间复杂度",
                      "不懂就承认，展示学习态度",
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    "沟通表达建议",
                    Icons.chat_outlined,
                    const Color(0xFFF59E0B),
                    [
                      "保持眼神接触，展现自信",
                      "语速适中，表达清晰有条理",
                      "善用停顿，给面试官思考时间",
                      "认真倾听，回答紧扣问题",
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    "常见问题准备",
                    Icons.quiz_outlined,
                    const Color(0xFFEF4444),
                    [
                      "准备3个有深度的问题问面试官",
                      "研究公司背景、产品和文化",
                      "准备离职原因的合理解释",
                      "思考职业规划与岗位的契合度",
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, IconData icon, Color color, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 12.6),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // 面试题库功能
  void _showQuestionBank() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const QuestionBankPage()),
    );
  }

  void _showStatus(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = globalUsers[currentUserIndex];
    final historyCount = (user['history'] as List).length;
    final avgScore = historyCount == 0 ? 0.0 :
      (user['history'] as List).map((e) => (e['totalScore'] ?? 0) as int).reduce((a, b) => a + b) / historyCount;

    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 顶部导航
                _buildHeader(),
                // 头像和统计区域
                _buildProfileHeaderSection(user, historyCount, avgScore),
                const SizedBox(height: 24),
                // 功能菜单
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuSection("实用工具", [
                        _buildMenuItem(Icons.description_outlined, "我的简历", "管理和更新您的简历", _showResumeManager),
                        _buildMenuItem(Icons.tips_and_updates_outlined, "面试技巧建议", "AI个性化建议", _showInterviewTips),
                      ]),
                      const SizedBox(height: 16),
                      _buildMenuSection("账户设置", [
                        _buildMenuItem(Icons.person_outline, "修改昵称", user['name'], _showEditNameDialog),
                        _buildMenuItem(Icons.lock_outline, "账户安全", "修改密码", _showChangePasswordDialog),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 9.8),
          ),
          const SizedBox(width: 12),
          Text(
            "个人中心",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // 设置按钮
          GestureDetector(
            onTap: _showSettingsMenu,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 9.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖动条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Text(
              "设置",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // 背景切换
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDarkBackground ? Icons.light_mode : Icons.dark_mode,
                  color: AppColors.primary,
                  size: 14,
                ),
              ),
              title: Text(
                "背景颜色",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                isDarkBackground ? "当前：深色背景" : "当前：浅色背景",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              trailing: Switch(
                value: isDarkBackground,
                onChanged: (value) {
                  isDarkBackground = value;
                  themeNotifier.value = value;  // 触发全局刷新
                  saveThemeSetting();  // 持久化保存
                  Navigator.pop(context);  // 关闭设置菜单
                  // 重新导航到MainEntryPage以刷新所有组件
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (c) => const MainEntryPage()),
                    (route) => false,
                  );
                },
                activeColor: AppColors.primary,
              ),
            ),
            const Divider(height: 1),
            // 退出登录
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: AppColors.error, size: 9.8),
              ),
              title: Text(
                "退出登录",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              subtitle: Text(
                "结束当前会话",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                currentUserIndex = -1;
                Navigator.pushAndRemoveUntil(
                  context,
                  TechPageTransitions.fade(builder: (context) => const LoginPage()),
                  (route) => false,
                );
                _showStatus("已退出登录", AppColors.primary);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderSection(Map<String, dynamic> user, int totalCount, double avgScore) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // 左侧：头像和用户信息
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // 头像带虚线圆环
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 虚线圆环
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                        ),
                      ),
                      // 头像
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: AppColors.primaryGradient),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: AppColors.surface,
                            backgroundImage: user['avatarPath'] != null ? FileImage(File(user['avatarPath'])) : null,
                            child: user['avatarPath'] == null
                                ? Text(
                                    user['name'][0],
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      // 在线状态点
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F2FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00F2FF).withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 用户信息列
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户名
                    Text(
                      user['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 用户ID
                    Text(
                      "@${user['username']}",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: AppTokens.shadowSm,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              int idx = entry.key;
              Widget item = entry.value;
              if (idx < items.length - 1) {
                return Column(
                  children: [
                    item,
                    Divider(height: 1, color: AppColors.border.withOpacity(0.3), indent: 56),
                  ],
                );
              }
              return item;
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 9.8),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 9.8, color: AppColors.textTertiary),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        currentUserIndex = -1;
        Navigator.pushAndRemoveUntil(
          context,
          TechPageTransitions.fade(builder: (context) => const LoginPage()),
          (route) => false,
        );
        _showStatus("已退出登录", AppColors.primary);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: AppColors.error, size: 12.6),
              const SizedBox(width: 8),
              Text(
                "结束会话",
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 面试题库页面 ---
class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = '全部';

  // 面试题库数据
  final Map<String, List<Map<String, dynamic>>> questionBank = {
    '技术基础': [
      {'q': '请解释什么是面向对象编程的三大特性？', 'a': '封装、继承、多态。封装是将数据和方法包装在一起，隐藏内部实现；继承是子类可以继承父类的属性和方法；多态是同一方法在不同对象中有不同的实现。', 'difficulty': '基础', 'hot': true},
      {'q': '什么是RESTful API？它有哪些特点？', 'a': 'RESTful是一种API设计风格，特点包括：使用HTTP方法（GET、POST、PUT、DELETE）表示操作；无状态；使用URI标识资源；支持多种数据格式（JSON、XML）。', 'difficulty': '基础', 'hot': true},
      {'q': '解释TCP三次握手和四次挥手的过程', 'a': '三次握手：客户端发SYN，服务端回SYN+ACK，客户端发ACK。四次挥手：主动方发FIN，被动方回ACK，被动方发FIN，主动方回ACK。', 'difficulty': '中等', 'hot': true},
      {'q': 'HTTP和HTTPS的区别是什么？', 'a': 'HTTPS在HTTP基础上加入SSL/TLS加密层，数据传输加密；HTTPS默认端口443，HTTP是80；HTTPS需要CA证书；HTTPS更安全但性能略低。', 'difficulty': '基础', 'hot': true},
      {'q': '什么是进程和线程？它们的区别是什么？', 'a': '进程是资源分配的基本单位，线程是CPU调度的基本单位。进程有独立内存空间，线程共享进程内存；进程切换开销大，线程切换开销小；进程间通信复杂，线程间通信简单。', 'difficulty': '基础', 'hot': true},
      {'q': '什么是死锁？如何避免死锁？', 'a': '死锁是多个进程互相等待对方释放资源而无法继续执行。避免方法：破坏互斥条件、破坏请求保持条件、破坏不可剥夺条件、破坏循环等待条件（如按顺序申请资源）。', 'difficulty': '中等', 'hot': false},
      {'q': '解释什么是索引？为什么能提高查询速度？', 'a': '索引是数据库中用于快速查找数据的数据结构（如B+树）。它通过建立数据的有序结构，将全表扫描变为树形查找，时间复杂度从O(n)降到O(logn)。', 'difficulty': '基础', 'hot': true},
      {'q': '什么是事务？ACID特性分别指什么？', 'a': '事务是一组原子操作。A原子性（全部成功或全部失败）、C一致性（状态转换一致）、I隔离性（事务间互不干扰）、D持久性（提交后永久保存）。', 'difficulty': '基础', 'hot': true},
      {'q': '解释什么是设计模式中的单例模式？', 'a': '单例模式确保一个类只有一个实例，并提供全局访问点。实现方式：懒汉式（延迟加载）、饿汉式（类加载时创建）、双重检查锁、静态内部类等。', 'difficulty': '基础', 'hot': false},
      {'q': 'Git中merge和rebase的区别是什么？', 'a': 'merge会创建一个新的合并提交，保留完整历史；rebase会将提交重新应用到目标分支上，历史更线性。rebase不应用于公共分支，merge更安全。', 'difficulty': '中等', 'hot': false},
    ],
    '算法数据结构': [
      {'q': '请解释时间复杂度和空间复杂度', 'a': '时间复杂度描述算法执行时间与输入规模的关系，常见有O(1)、O(logn)、O(n)、O(nlogn)、O(n²)。空间复杂度描述算法所需额外空间与输入规模的关系。', 'difficulty': '基础', 'hot': true},
      {'q': '数组和链表的区别是什么？各有什么优缺点？', 'a': '数组连续存储，支持随机访问O(1)，插入删除O(n)；链表非连续存储，不支持随机访问O(n)，插入删除O(1)。数组适合查询多的场景，链表适合增删多的场景。', 'difficulty': '基础', 'hot': true},
      {'q': '什么是二叉搜索树？它的特点是什么？', 'a': '二叉搜索树是一种二叉树，左子树所有节点值小于根节点，右子树所有节点值大于根节点。查找、插入、删除平均时间复杂度O(logn)，最坏O(n)。', 'difficulty': '基础', 'hot': true},
      {'q': '解释什么是哈希表？如何解决哈希冲突？', 'a': '哈希表通过哈希函数将键映射到数组位置，实现O(1)查找。解决冲突方法：开放寻址法（线性探测、二次探测）、链地址法、再哈希法。', 'difficulty': '中等', 'hot': true},
      {'q': '请描述快速排序的原理和时间复杂度', 'a': '快排采用分治思想，选择基准元素，将数组分为小于和大于基准的两部分，递归排序。平均时间复杂度O(nlogn)，最坏O(n²)，空间复杂度O(logn)。', 'difficulty': '中等', 'hot': true},
      {'q': '什么是动态规划？它适用于什么问题？', 'a': '动态规划将复杂问题分解为重叠子问题，通过存储子问题解避免重复计算。适用于具有最优子结构和重叠子问题性质的问题，如背包问题、最长公共子序列等。', 'difficulty': '困难', 'hot': true},
      {'q': '解释BFS和DFS的区别和应用场景', 'a': 'BFS广度优先，使用队列，适合最短路径问题；DFS深度优先，使用栈/递归，适合连通性、拓扑排序问题。BFS空间消耗大，DFS可能栈溢出。', 'difficulty': '中等', 'hot': true},
      {'q': '什么是红黑树？它有什么特点？', 'a': '红黑树是自平衡二叉搜索树，节点有红黑色，满足：根黑、叶黑、红节点子节点黑、任意节点到叶节点黑色数相同。保证最坏O(logn)操作。', 'difficulty': '困难', 'hot': false},
      {'q': '如何判断一个链表是否有环？', 'a': '快慢指针法：快指针每次走2步，慢指针每次走1步，若相遇则有环。哈希表法：遍历时存储访问过的节点，若重复则有环。', 'difficulty': '中等', 'hot': true},
      {'q': 'LRU缓存如何实现？', 'a': '使用哈希表+双向链表。哈希表O(1)查找，双向链表维护访问顺序。访问时将节点移到链表头部，淘汰时删除链表尾部节点。', 'difficulty': '困难', 'hot': true},
    ],
    '前端开发': [
      {'q': '解释什么是虚拟DOM？它的优势是什么？', 'a': '虚拟DOM是真实DOM的JS对象表示。优势：减少直接操作DOM的性能消耗，通过diff算法最小化更新，实现跨平台，便于实现声明式编程。', 'difficulty': '基础', 'hot': true},
      {'q': 'Vue和React的区别是什么？', 'a': 'Vue是渐进式框架，双向绑定，模板语法，学习曲线低；React是库，单向数据流，JSX语法，更灵活。Vue适合中小项目快速开发，React适合大型复杂应用。', 'difficulty': '中等', 'hot': true},
      {'q': '什么是闭包？请举例说明', 'a': '闭包是函数和其词法环境的组合，内部函数可以访问外部函数的变量。例如：function outer(){let x=1; return function(){return x;}} 常用于数据私有化、柯里化等。', 'difficulty': '基础', 'hot': true},
      {'q': '解释JavaScript的事件循环机制', 'a': 'JS是单线程，通过事件循环处理异步。执行栈执行同步代码，异步任务放入任务队列（宏任务、微任务），执行栈空时从队列取任务执行。微任务优先于宏任务。', 'difficulty': '中等', 'hot': true},
      {'q': 'CSS中position有哪些值？各有什么特点？', 'a': 'static默认值；relative相对自身定位；absolute相对最近定位祖先定位，脱离文档流；fixed相对视口定位；sticky粘性定位，滚动到阈值时固定。', 'difficulty': '基础', 'hot': false},
      {'q': '什么是跨域？如何解决跨域问题？', 'a': '跨域是浏览器同源策略限制不同源请求。解决方法：CORS（服务端设置响应头）、JSONP（仅GET）、代理服务器、WebSocket、postMessage等。', 'difficulty': '中等', 'hot': true},
      {'q': 'Promise和async/await的区别？', 'a': 'Promise是异步解决方案，通过then链式调用；async/await是Promise的语法糖，使异步代码看起来像同步，更易读。async函数返回Promise，await等待Promise解决。', 'difficulty': '中等', 'hot': true},
      {'q': '什么是Webpack？它的核心概念有哪些？', 'a': 'Webpack是模块打包工具。核心概念：Entry入口、Output输出、Loader转换文件、Plugin扩展功能、Mode模式、Chunk代码块。', 'difficulty': '中等', 'hot': false},
      {'q': '如何优化前端性能？', 'a': '减少HTTP请求、使用CDN、压缩资源、懒加载、缓存策略、代码分割、SSR、减少重排重绘、使用Web Workers、图片优化等。', 'difficulty': '中等', 'hot': true},
      {'q': 'TypeScript相比JavaScript有什么优势？', 'a': 'TS增加静态类型检查，编译时发现错误；更好的IDE支持和代码提示；支持接口、泛型等高级特性；适合大型项目协作开发；JS的超集，兼容JS。', 'difficulty': '基础', 'hot': true},
    ],
    '后端开发': [
      {'q': '什么是微服务架构？它的优缺点是什么？', 'a': '微服务将应用拆分为独立部署的小服务。优点：独立部署、技术多样性、故障隔离、团队自治。缺点：分布式复杂性、数据一致性、运维成本高、网络延迟。', 'difficulty': '中等', 'hot': true},
      {'q': '解释什么是消息队列？常见的有哪些？', 'a': '消息队列是异步通信中间件，解耦生产者消费者。常见：RabbitMQ（AMQP协议）、Kafka（高吞吐）、RocketMQ（阿里）、Redis（简单场景）。', 'difficulty': '中等', 'hot': true},
      {'q': '什么是Redis？它支持哪些数据类型？', 'a': 'Redis是内存键值数据库，支持持久化。数据类型：String字符串、List列表、Set集合、Hash哈希、ZSet有序集合、Bitmap、HyperLogLog、Stream等。', 'difficulty': '基础', 'hot': true},
      {'q': 'MySQL和MongoDB的区别是什么？', 'a': 'MySQL是关系型数据库，表结构固定，支持事务和复杂查询；MongoDB是文档型数据库，Schema灵活，适合非结构化数据，水平扩展好。', 'difficulty': '基础', 'hot': true},
      {'q': '如何保证接口的幂等性？', 'a': '幂等性指多次调用结果一致。方法：唯一索引防重复、Token机制、乐观锁版本号、状态机、分布式锁、请求序列号去重等。', 'difficulty': '中等', 'hot': true},
      {'q': '什么是JWT？它的优缺点是什么？', 'a': 'JWT是JSON Web Token，用于身份认证。优点：无状态、跨域、自包含。缺点：无法主动过期、Token较大、泄露风险、不支持刷新。', 'difficulty': '基础', 'hot': true},
      {'q': '解释CAP定理和BASE理论', 'a': 'CAP：分布式系统无法同时满足一致性、可用性、分区容错性。BASE：基本可用、软状态、最终一致性，是CAP的妥协方案。', 'difficulty': '困难', 'hot': false},
      {'q': '什么是分布式锁？如何实现？', 'a': '分布式锁协调分布式环境下的资源访问。实现：Redis（SETNX+过期时间）、ZooKeeper（临时顺序节点）、MySQL（唯一索引）、Redisson等。', 'difficulty': '困难', 'hot': true},
      {'q': 'Docker和虚拟机的区别是什么？', 'a': 'Docker是容器化技术，共享宿主机内核，启动快、资源占用少；虚拟机包含完整OS，隔离性更好但资源消耗大。Docker适合微服务部署。', 'difficulty': '基础', 'hot': true},
      {'q': '什么是负载均衡？常见算法有哪些？', 'a': '负载均衡将请求分发到多台服务器。算法：轮询、加权轮询、随机、加权随机、最小连接数、IP哈希、一致性哈希等。', 'difficulty': '中等', 'hot': true},
    ],
    '系统设计': [
      {'q': '如何设计一个短链接系统？', 'a': '方案：发号器生成唯一ID，转换为62进制作为短码；存储映射关系到数据库和缓存；访问时重定向到原URL。考虑：分布式ID、缓存策略、过期机制、统计分析。', 'difficulty': '中等', 'hot': true},
      {'q': '如何设计一个秒杀系统？', 'a': '关键：限流（令牌桶/漏桶）、缓存预热、异步处理（消息队列）、库存扣减（Redis原子操作）、分布式锁、CDN静态化、降级熔断。', 'difficulty': '困难', 'hot': true},
      {'q': '如何设计一个分布式ID生成系统？', 'a': '方案：UUID（无序）、数据库自增（单点）、Redis（原子自增）、雪花算法（时间戳+机器ID+序列号）、Leaf（美团）、UidGenerator（百度）。', 'difficulty': '中等', 'hot': true},
      {'q': '如何设计一个消息推送系统？', 'a': '方案：长轮询、WebSocket、SSE。架构：接入层（负载均衡）、连接管理、消息路由、存储层（消息持久化）。考虑：心跳保活、重连机制、消息可靠性。', 'difficulty': '困难', 'hot': false},
      {'q': '如何设计一个评论系统？', 'a': '数据模型：评论表（ID、内容、用户、父评论ID）。功能：楼中楼结构、分页加载、热门排序。优化：缓存热门评论、异步计数、敏感词过滤、反垃圾。', 'difficulty': '中等', 'hot': false},
      {'q': '如何设计一个限流系统？', 'a': '算法：计数器（固定窗口）、滑动窗口、漏桶、令牌桶。实现：单机（Guava RateLimiter）、分布式（Redis+Lua）。考虑：限流粒度、熔断降级。', 'difficulty': '中等', 'hot': true},
      {'q': '如何保证分布式系统的数据一致性？', 'a': '方案：强一致性（2PC/3PC）、最终一致性（TCC、SAGA、消息队列）。实践：本地消息表、事务消息、定时补偿、对账机制。', 'difficulty': '困难', 'hot': true},
      {'q': '如何设计一个搜索系统？', 'a': '架构：数据采集、索引构建（Elasticsearch）、查询服务、排序算法。功能：分词、倒排索引、相关性排序、搜索建议、纠错。', 'difficulty': '困难', 'hot': false},
      {'q': '如何设计高可用系统？', 'a': '策略：冗余部署（主从、集群）、故障转移、限流熔断、降级预案、监控告警、灰度发布、容灾备份。指标：SLA、可用性（99.99%）。', 'difficulty': '困难', 'hot': true},
      {'q': '如何设计一个Feed流系统？', 'a': '方案：推模式（写扩散）、拉模式（读扩散）、推拉结合。架构：消息队列、缓存（Timeline）、存储（MongoDB/HBase）。优化：大V特殊处理。', 'difficulty': '困难', 'hot': false},
    ],
    '行为面试': [
      {'q': '请做一个简单的自我介绍', 'a': '结构：现在（当前工作/学习）、过去（相关经历）、未来（职业规划）。要点：突出与岗位匹配的能力和经历，用数据量化成果，控制在1-3分钟。', 'difficulty': '基础', 'hot': true},
      {'q': '你的优点和缺点是什么？', 'a': '优点：选择与岗位相关的优势，用具体事例证明。缺点：选择可改进的非致命弱点，说明正在如何改进。避免：过于谦虚或自夸。', 'difficulty': '基础', 'hot': true},
      {'q': '为什么想加入我们公司？', 'a': '从公司文化、业务方向、技术栈、团队氛围、个人发展等角度回答。展示对公司的了解和认同，说明个人能力与岗位的匹配度。', 'difficulty': '基础', 'hot': true},
      {'q': '你遇到过最大的挑战是什么？如何解决的？', 'a': '用STAR法则：描述具体情境和任务，说明面临的困难，详述采取的行动，展示最终结果和收获。选择能体现关键能力的经历。', 'difficulty': '中等', 'hot': true},
      {'q': '说说你的职业规划', 'a': '短期（1-3年）：具体技能提升和岗位目标。长期（5年+）：职业方向和成长路径。要点：展示稳定性和上进心，与公司发展相匹配。', 'difficulty': '基础', 'hot': true},
      {'q': '你如何处理工作中的压力？', 'a': '策略：合理安排优先级、分解任务、及时沟通、适当运动放松。举例说明曾经成功应对高压情况的经历和结果。', 'difficulty': '中等', 'hot': false},
      {'q': '描述一次与团队成员发生冲突的经历', 'a': '重点：客观描述冲突情境，说明如何沟通解决，展示同理心和协作能力，强调从中学到的教训。避免：指责他人。', 'difficulty': '中等', 'hot': true},
      {'q': '你为什么从上一家公司离职？', 'a': '正面理由：寻求更大发展空间、新的技术挑战、职业转型。避免：抱怨前公司或同事。即使是被动离职也要积极表达。', 'difficulty': '基础', 'hot': true},
      {'q': '你期望的薪资是多少？', 'a': '策略：了解市场行情，给出合理范围而非具体数字。可以询问公司薪资结构，表达对整体package的关注。', 'difficulty': '中等', 'hot': true},
      {'q': '你有什么问题想问我们吗？', 'a': '好问题：团队技术栈和工作方式、项目情况、成长机会、公司文化。避免：薪资福利（初面）、网上能查到的信息。', 'difficulty': '基础', 'hot': true},
    ],
    '智力题': [
      {'q': '8个球，其中一个偏重，用天平最少称几次能找出？', 'a': '2次。第一次将8球分成3、3、2组，称3对3。若平衡则在2中再称找出；若不平衡则在重的3中取2个称，平衡则剩下那个重，否则重的那个。', 'difficulty': '中等', 'hot': true},
      {'q': '两个人分一块蛋糕，如何保证公平？', 'a': '一人切，另一人先选。扩展：N人时，一人切成N份，从最后切的人开始反向选择。', 'difficulty': '基础', 'hot': false},
      {'q': '25匹马，5个赛道，最少比几次能找出最快的3匹？', 'a': '7次。先分5组各赛1次（5次），取每组第一名赛1次（1次），第1名确定。第2、3名在：第1名所在组的第2、3名、总决赛第2名所在组的第2名、总决赛第3名中产生，再赛1次。', 'difficulty': '困难', 'hot': true},
      {'q': '烧一根不均匀的绳子需要1小时，如何用两根绳子计时45分钟？', 'a': '绳子A两头点燃，绳子B一头点燃。A烧完时（30分钟）点燃B的另一头，B剩余部分烧完再用15分钟，共45分钟。', 'difficulty': '中等', 'hot': true},
      {'q': '1000瓶水中有1瓶毒药，用小白鼠最少需要几只能找出？', 'a': '10只。将1000瓶水编号为二进制，每只小鼠对应一个二进制位，喝该位为1的所有水。根据死亡小鼠确定毒药编号。2^10=1024>1000。', 'difficulty': '困难', 'hot': true},
      {'q': '如何用3升和5升的杯子量出4升水？', 'a': '方法一：5升装满，倒入3升杯，剩2升；3升倒掉，2升倒入3升杯；5升装满倒入3升杯，剩4升。', 'difficulty': '基础', 'hot': false},
      {'q': '有100层楼和2个鸡蛋，如何用最少次数找到鸡蛋刚好摔碎的楼层？', 'a': '最优策略：第一个蛋从第14、27、39...层扔（间隔递减）。最坏情况14次。数学推导：n(n+1)/2 >= 100，n=14。', 'difficulty': '困难', 'hot': true},
      {'q': '三个人住酒店，一共30元，后来退了5元，服务员贪污2元，每人退1元，即每人付9元共27元加贪污2元共29元，少的1元去哪了？', 'a': '逻辑陷阱。正确算法：每人付9元共27元=房费25元+贪污2元。服务员手里的2元已包含在27元中，不应再加。', 'difficulty': '基础', 'hot': false},
      {'q': '海盗分金币问题：5个海盗分100枚金币，如何分配？', 'a': '结果：(98,0,1,0,1)或(97,0,1,2,0)。倒推：若只剩2人，老大全拿；3人时老大给最小的1枚换支持；依次倒推。', 'difficulty': '困难', 'hot': false},
      {'q': '一个房间有3个开关控制另一个房间的3盏灯，只能进一次另一个房间，如何判断对应关系？', 'a': '打开开关1一段时间后关闭，打开开关2，进入房间。亮着的对应开关2，热的对应开关1，冷且灭的对应开关3。', 'difficulty': '中等', 'hot': true},
    ],
  };

  List<String> get categories => ['全部', ...questionBank.keys];

  List<Map<String, dynamic>> get filteredQuestions {
    if (_selectedCategory == '全部') {
      return questionBank.values.expand((list) => list).toList();
    }
    return questionBank[_selectedCategory] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _selectedCategory = categories[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCategoryTabs(),
              _buildStatsBar(),
              Expanded(child: _buildQuestionList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: const Icon(Icons.quiz, color: Colors.white, size: 9.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "面试题库",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "精选高频经典面试题目",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 9.8),
                const SizedBox(width: 4),
                Text(
                  "${questionBank.values.expand((e) => e).length}题",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: categories.map((c) => Tab(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(c),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStatsBar() {
    final questions = filteredQuestions;
    final hotCount = questions.where((q) => q['hot'] == true).length;
    final basicCount = questions.where((q) => q['difficulty'] == '基础').length;
    final mediumCount = questions.where((q) => q['difficulty'] == '中等').length;
    final hardCount = questions.where((q) => q['difficulty'] == '困难').length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("热门", "$hotCount题", AppColors.error),
          _buildStatItem("基础", "$basicCount题", AppColors.success),
          _buildStatItem("中等", "$mediumCount题", AppColors.warning),
          _buildStatItem("困难", "$hardCount题", AppColors.cyberPurple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionList() {
    final questions = filteredQuestions;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        return _buildQuestionCard(q, index + 1);
      },
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final difficulty = question['difficulty'] as String;
    final isHot = question['hot'] == true;

    Color difficultyColor;
    switch (difficulty) {
      case '基础':
        difficultyColor = AppColors.success;
        break;
      case '中等':
        difficultyColor = AppColors.warning;
        break;
      case '困难':
        difficultyColor = AppColors.cyberPurple;
        break;
      default:
        difficultyColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: () => _showQuestionDetail(question),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: AppTokens.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "$index",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: difficultyColor,
                    ),
                  ),
                ),
                if (isHot) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, size: 8.4, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          "高频热门",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 9.8, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question['q'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionDetail(Map<String, dynamic> question) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖拽指示器
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 标签
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question['difficulty'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (question['hot'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, size: 8.4, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          "高频热门",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            // 问题
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: AppColors.primary, size: 12.6),
                      const SizedBox(width: 8),
                      Text(
                        "面试问题",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question['q'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 参考答案
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.success, size: 12.6),
                        const SizedBox(width: 8),
                        Text(
                          "参考答案",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          question['a'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 按钮
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "关闭",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- 面试设置页 (stitch customize_interview 风格) ---
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});



  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  String selectedJobCategory = '技术研发';  // 职位大类
  String selectedJob = '算法工程师';  // 具体职位
  String companySize = '大型企业';
  String? selectedCompany;  // 具体公司（仅大型企业时使用）

  // 职位二级分类
  final Map<String, List<String>> jobCategories = {
    '技术研发': ['算法工程师', '前端开发', '后端开发', 'iOS开发', 'Android开发', '全栈开发', '数据工程师', '测试工程师', '运维工程师', '架构师'],
    '产品设计': ['产品经理', 'UI设计师', 'UX设计师', '交互设计师', '视觉设计师'],
    '数据分析': ['数据分析师', '商业分析师', '数据科学家', 'BI工程师'],
    '人工智能': ['机器学习工程师', '深度学习工程师', 'NLP工程师', '计算机视觉工程师', 'AI产品经理'],
    '市场运营': ['市场经理', '运营经理', '内容运营', '用户运营', '增长策略师'],
    '管理岗位': ['技术主管', '项目经理', '部门经理', 'CTO', 'CEO'],
  };

  // 大型企业公司列表
  final List<String> majorCompanies = [
    '华为', '腾讯', '阿里巴巴', '字节跳动', '百度', '小米',
    '京东', '美团', '网易', '拼多多', 'OPPO', 'vivo',
    '滴滴', '快手', 'B站', '蚂蚁集团', '微软中国', '谷歌中国',
  ];

  // AI 面试官选择 (2x2 网格)
  int selectedInterviewer = 0;
  final List<Map<String, dynamic>> interviewers = [
    {
      'name': 'Alex',
      'role': '技术专家',
      'icon': Icons.computer,
      'color': AppColors.primary,
      'traits': ['深度技术追问', '代码实现验证', '系统设计评估'],
      'style': '严谨型',
      'description': '专注于技术深度，会针对你的回答进行层层追问，验证技术功底。',
      'avatarUrl': 'https://api.dicebear.com/9.x/micah/png?seed=Alex&backgroundColor=b6e3f4&size=128&baseColor=f9c9b6',
    },
    {
      'name': 'Jordan',
      'role': '行为面试专家',
      'icon': Icons.psychology,
      'color': AppColors.cyberPurple,
      'traits': ['压力测试', '情景模拟', 'STAR方法'],
      'style': '挑战型',
      'description': '擅长压力面试，通过行为问题挖掘你的真实能力和性格特点。',
      'avatarUrl': 'https://api.dicebear.com/9.x/micah/png?seed=JordanSmile&backgroundColor=c0aede&size=128&baseColor=f9c9b6&mouth=smile',
    },
    {
      'name': 'Sophia',
      'role': '业务主管',
      'icon': Icons.business_center,
      'color': const Color(0xFF10B981),
      'traits': ['业务理解', '项目经验', '团队协作'],
      'style': '务实型',
      'description': '关注实际业务能力，评估你如何将技术应用到真实业务场景。',
      'avatarUrl': 'https://api.dicebear.com/9.x/micah/png?seed=Sophia&backgroundColor=d1f4d1&size=128&baseColor=f9c9b6&earringsProbability=100',
    },
    {
      'name': 'Emma',
      'role': 'HR总监',
      'icon': Icons.people,
      'color': const Color(0xFFF59E0B),
      'traits': ['文化匹配', '职业规划', '沟通能力'],
      'style': '温和型',
      'description': '注重软技能和文化契合度，评估你的沟通表达和职业发展潜力。',
      'avatarUrl': 'https://api.dicebear.com/9.x/micah/png?seed=EmmaHappy&backgroundColor=ffd5dc&size=128&baseColor=f9c9b6&earringsProbability=100&mouth=smile',
    },
  ];

  // 题目配置 (stepper)
  int subjectiveCount = 5;
  int objectiveCount = 3;
  int algorithmCount = 2;

  // 自适应难度
  bool adaptiveDifficulty = true;

  // 显示面试官详情
  void _showInterviewerDetail(int index) {
    final interviewer = interviewers[index];
    final Color color = interviewer['color'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 头像和名称
            Row(
              children: [
                DigitalAvatar(
                  name: interviewer['name'],
                  imageUrl: interviewer['avatarUrl'],
                  size: 44.8,
                  accentColor: color,
                  isSelected: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interviewer['name'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              interviewer['role'],
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDim,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              interviewer['style'],
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 描述
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Text(
                interviewer['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 面试特征
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "面试特征",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: (interviewer['traits'] as List<String>).map((trait) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: color, size: 9.8),
                      const SizedBox(width: 6),
                      Text(
                        trait,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // 选择按钮
            GestureDetector(
              onTap: () {
                setState(() => selectedInterviewer = index);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    selectedInterviewer == index ? "已选择" : "选择此面试官",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部导航
                _buildHeader(),
                const SizedBox(height: 24),
                // 标题
                _buildTitle(),
                const SizedBox(height: 24),
                // AI 面试官选择 (2x2 网格)
                _buildInterviewerSection(),
                const SizedBox(height: 24),
                // 题目配置
                _buildQuestionComposition(),
                const SizedBox(height: 24),
                // 职位信息
                _buildJobSection(),
                const SizedBox(height: 24),
                // 自适应难度
                _buildAdaptiveDifficulty(),
                const SizedBox(height: 32),
                // 开始面试按钮
                _buildStartButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 9.8),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "定制面试",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 在线状态
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "AI 就绪",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "选择AI面试官",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "定制您的模拟面试体验",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildInterviewerSection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: interviewers.length,
      itemBuilder: (context, index) {
        final interviewer = interviewers[index];
        final isSelected = selectedInterviewer == index;
        final Color color = interviewer['color'];

        return GestureDetector(
          onTap: () => setState(() => selectedInterviewer = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(
                color: isSelected ? color : AppColors.border.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 数字人头像
                      AnimatedDigitalAvatar(
                        name: interviewer['name'],
                        imageUrl: interviewer['avatarUrl'],
                        size: 36.4,
                        accentColor: color,
                        isSelected: isSelected,
                      ),
                      const SizedBox(height: 8),
                      // 名称
                      Text(
                        interviewer['name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 角色
                      Text(
                        interviewer['role'],
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 风格标签
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          interviewer['style'],
                          style: TextStyle(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 选中标记
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 7),
                    ),
                  ),
                // 查看详情按钮
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => _showInterviewerDetail(index),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDim,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.info_outline, color: AppColors.textTertiary, size: 8.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionComposition() {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz_outlined, color: AppColors.primary, size: 12.6),
              ),
              const SizedBox(width: 12),
              Text("题目组成", style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 12),
          _buildStepper("主观题", subjectiveCount, (v) => setState(() => subjectiveCount = v)),
          const SizedBox(height: 10),
          _buildStepper("客观题", objectiveCount, (v) => setState(() => objectiveCount = v)),
          const SizedBox(height: 10),
          _buildStepper("算法题", algorithmCount, (v) => setState(() => algorithmCount = v)),
        ],
      ),
    );
  }

  Widget _buildStepper(String label, int value, Function(int) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.circle, size: 4, color: AppColors.primary.withOpacity(0.5)),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // 减少按钮
        GestureDetector(
          onTap: () {
            if (value > 0) onChanged(value - 1);
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.remove, color: AppColors.textSecondary, size: 12.6),
          ),
        ),
        // 数值
        Container(
          width: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        // 增加按钮
        GestureDetector(
          onTap: () {
            if (value < 10) onChanged(value + 1);
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 12.6),
          ),
        ),
      ],
    );
  }

  Widget _buildJobSection() {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work_outline, color: AppColors.primary, size: 12.6),
              ),
              const SizedBox(width: 12),
              Text("职位信息", style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 12),
          // 职位大类
          Row(
              children: [
                Icon(Icons.brightness_1, size: 4, color: AppColors.cyberPurple.withOpacity(0.5)),
                SizedBox(width: 6),
                Text(
                "职位类别",
                style: TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedJobCategory,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                items: jobCategories.keys.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                )).toList(),
                onChanged: (v) => setState(() {
                  selectedJobCategory = v!;
                  selectedJob = jobCategories[v]!.first;
                }),
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 具体职位
          Row(
              children: [
                Icon(Icons.star, size: 4, color: AppColors.success.withOpacity(0.5)),
                SizedBox(width: 6),
                Text(
                "目标职位",
                style: TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedJob,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                items: jobCategories[selectedJobCategory]!.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                )).toList(),
                onChanged: (v) => setState(() => selectedJob = v!),
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 企业规模
          Row(
              children: [
                Icon(Icons.apps, size: 4, color: AppColors.primary.withOpacity(0.5)),
                SizedBox(width: 6),
                Text(
                "企业规模",
                style: TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: companySize,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                items: ['初创公司', '中型企业', '大型企业'].map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                )).toList(),
                onChanged: (v) => setState(() {
                  companySize = v!;
                  if (v != '大型企业') {
                    selectedCompany = null;
                  }
                }),
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textTertiary),
              ),
            ),
          ),
          // 具体公司选择（仅大型企业时显示）
          if (companySize == '大型企业') ...[
            const SizedBox(height: 16),
            Text(
              "目标公司",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCompany,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  hint: Text("选择目标公司", style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  items: majorCompanies.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedCompany = v),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdaptiveDifficulty() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 12.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("自适应难度", style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(
                  "AI根据表现动态调整难度",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Toggle Switch
          GestureDetector(
            onTap: () => setState(() => adaptiveDifficulty = !adaptiveDifficulty),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: adaptiveDifficulty ? AppColors.primary : AppColors.surfaceDim,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: adaptiveDifficulty ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        TechPageTransitions.iosSlide(builder: (c) => InterviewChatPage(
          job: selectedJob,
          jobCategory: selectedJobCategory,
          interviewerType: interviewers[selectedInterviewer]['name'],
          company: selectedCompany,
        )),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16.8),
            const SizedBox(width: 8),
            Text(
              "开始面试",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- AI 评估报告页 (stitch 面试分析报告界面 风格) ---
class ReportPage extends StatelessWidget {
  final Map<String, dynamic> reportData;
  const ReportPage({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final int score = reportData['totalScore'] ?? reportData['score'] ?? 85;

    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 顶部导航
                _buildHeader(context),
                const SizedBox(height: 20),
                // 圆形分数仪表盘
                _buildScoreGauge(score),
                const SizedBox(height: 24),
                // 能力评估
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildAbilitySection(),
                ),
                const SizedBox(height: 20),
                // 情绪趋势
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildEmotionTrend(),
                ),
                const SizedBox(height: 20),
                // AI 诊断
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildAIDiagnosis(),
                ),
                const SizedBox(height: 24),
                // 底部按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildActionButtons(context),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 9.8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "面试分析报告",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 分享按钮
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 9.8),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreGauge(int score) {
    final Color scoreColor = score >= 80 ? AppColors.primary : score >= 60 ? AppColors.secondary : AppColors.warning;
    final String grade = score >= 90 ? "优秀" : score >= 80 ? "良好" : score >= 60 ? "合格" : "需提升";

    return Column(
      children: [
        // 圆形仪表盘
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 12,
                  backgroundColor: AppColors.surfaceDim,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surfaceDim),
                ),
              ),
              // 进度圆环
              SizedBox(
                width: 180,
                height: 180,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              // 中心内容
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$score",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                    ),
                    child: Text(
                      grade,
                      style: TextStyle(
                        fontSize: 12,
                        color: scoreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "综合评分",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAbilitySection() {
    final abilities = [
      {'name': '技术广度', 'value': 90, 'color': AppColors.primary},
      {'name': '逻辑思维', 'value': 85, 'color': AppColors.cyberPurple},
      {'name': '沟通表达', 'value': 78, 'color': const Color(0xFF10B981)},
      {'name': '情绪控制', 'value': 82, 'color': const Color(0xFFF59E0B)},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart, color: AppColors.primary, size: 12.6),
              ),
              const SizedBox(width: 12),
              Text("能力评估", style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 20),
          ...abilities.map((ability) => _buildAbilityBar(
            ability['name'] as String,
            ability['value'] as int,
            ability['color'] as Color,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAbilityBar(String name, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text("$value%", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, child) {
                return LinearProgressIndicator(
                  value: animValue,
                  backgroundColor: AppColors.surfaceDim,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionTrend() {
    // 模拟情绪趋势数据 (Q1-Q10)
    final emotions = [65, 70, 60, 75, 80, 72, 85, 78, 88, 82];

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyberPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.show_chart, color: AppColors.cyberPurple, size: 12.6),
              ),
              const SizedBox(width: 12),
              Text("情绪趋势", style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 20),
          // 柱状图
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: emotions.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final normalizedHeight = (value / 100) * 100;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: normalizedHeight),
                          duration: Duration(milliseconds: 800 + index * 100),
                          curve: Curves.easeOutCubic,
                          builder: (context, animValue, child) {
                            return Container(
                              height: animValue,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.cyberPurple,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Q${index + 1}",
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIDiagnosis() {
    return Column(
      children: [
        // 核心优势 (绿色边框)
        _buildDiagnosisCard(
          title: "核心优势",
          icon: Icons.check_circle_outline,
          color: const Color(0xFF10B981),
          items: [
            "技术基础扎实，算法理解深入",
            "表达清晰，逻辑性强",
            "应变能力好，抗压性高",
          ],
        ),
        const SizedBox(height: 16),
        // 待提升点 (琥珀色边框)
        _buildDiagnosisCard(
          title: "待提升点",
          icon: Icons.lightbulb_outline,
          color: const Color(0xFFF59E0B),
          items: [
            "项目经验描述可以更具体",
            "行业知识面可进一步拓宽",
            "部分回答可以更加简洁",
          ],
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 9.8),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 重新面试
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "再次面试",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 返回首页
        GestureDetector(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                "返回首页",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- 核心面试界面 (stitch interview_room 风格) ---
class InterviewChatPage extends StatefulWidget {
  final String job;
  final String jobCategory;
  final String interviewerType;
  final String? company;

  const InterviewChatPage({
    super.key,
    required this.job,
    required this.jobCategory,
    required this.interviewerType,
    this.company,
  });

  @override
  State<InterviewChatPage> createState() => _InterviewChatPageState();
}

class _InterviewChatPageState extends State<InterviewChatPage> with SingleTickerProviderStateMixin {
  // --- 变量定义区 ---
  CameraController? _cameraController;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  bool _isTypingMode = false;
  String _currentStatus = "就绪";

  List<Map<String, dynamic>> messages = [];

  // 面试进度
  int _currentQuestionIndex = 0;
  final int _totalQuestions = 10;

  // 计时器
  int _sessionSeconds = 0;

  // 情绪状态
  String _emotionStatus = "沉稳自如";
  int _emotionScore = 85;

  // 实时情绪数据 (模拟)
  final List<double> _emotionHistory = [65, 70, 68, 75, 80, 78, 82, 85];

  // 动画控制器
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    messages.add({"role": "assistant", "content": "你好，欢迎参加${widget.job}面试。请开始你的自我介绍。"});
    _initEngine();

    // 脉冲动画
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // 模拟计时器
    Future.delayed(Duration.zero, () {
      _startTimer();
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _sessionSeconds++);
        return true;
      }
      return false;
    });
  }

  String get _formattedTime {
    int minutes = _sessionSeconds ~/ 60;
    int seconds = _sessionSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> _initEngine() async {
    await _recorder.openRecorder();
    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(_cameras.first, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraController?.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  // --- 语音转文字 + AI回复逻辑 ---
  void _start() async {
    final path = "${(await getTemporaryDirectory()).path}/voice.pcm";
    await _recorder.startRecorder(toFile: path, codec: Codec.pcm16, numChannels: 1, sampleRate: 16000);
    setState(() { _isRecording = true; _currentStatus = "正在聆听..."; });
  }

  void _stop() async {
    final path = await _recorder.stopRecorder();
    setState(() { _isRecording = false; _currentStatus = "AI分析中..."; });
    if (path != null) _processVoice(path);
  }

  void _processVoice(String path) async {
    final bytes = await File(path).readAsBytes();
    final url = XfAuth.getUrl("https://iat-api.xfyun.cn/v2/iat");
    final channel = IOWebSocketChannel.connect(Uri.parse(url));
    String userText = "";
    channel.stream.listen((msg) {
      final res = jsonDecode(msg);
      if (res['code'] == 0) {
        final ws = res['data']['result']['ws'] as List;
        for (var w in ws) { userText += w['cw'][0]['w']; }
        if (res['data']['status'] == 2) {
          setState(() { messages.add({"role": "user", "content": userText}); });
          _askSpark();
        }
      }
    });
    for (int i = 0; i < bytes.length; i += 1280) {
      int end = (i + 1280 > bytes.length) ? bytes.length : i + 1280;
      channel.sink.add(jsonEncode({"common": {"app_id": XfAuth.appId},"business": {"language": "zh_cn", "domain": "iat", "accent": "mandarin"},"data": {"status": (i == 0) ? 0 : (end == bytes.length ? 2 : 1), "format": "audio/L16;rate=16000", "encoding": "raw", "audio": base64.encode(bytes.sublist(i, end))}}));
    }
  }

  void _askSpark() {
    final url = XfAuth.getUrl("https://spark-api.xf-yun.com/v3.5/chat");
    final channel = IOWebSocketChannel.connect(Uri.parse(url));
    messages.add({"role": "assistant", "content": ""});
    int lastIdx = messages.length - 1;
    String fullReply = "";
    channel.stream.listen((msg) {
      final res = jsonDecode(msg);
      if (res['header']['code'] == 0) {
        fullReply += res['payload']['choices']['text'][0]['content'];
        setState(() { messages[lastIdx]['content'] = fullReply; });
        if (res['header']['status'] == 2) {
          setState(() {
            _currentStatus = "就绪";
            _currentQuestionIndex = (_currentQuestionIndex + 1).clamp(0, _totalQuestions - 1);
          });
          channel.sink.close();
        }
      }
    });
    channel.sink.add(jsonEncode({"header": {"app_id": XfAuth.appId},"parameter": {"chat": {"domain": "generalv3.5", "temperature": 0.5}},"payload": {"message": {"text": messages}}}));
  }

  void _handleTextSend() {
    if (_textController.text.isEmpty) return;
    setState(() {
      messages.add({"role": "user", "content": _textController.text});
      _textController.clear();
    });
    _askSpark();
  }

  void _finishInterview() {
    // 构建问答详情列表，为每个问答对生成分数
    final List<Map<String, dynamic>> qaDetails = [];
    for (int i = 0; i < messages.length; i++) {
      if (messages[i]['role'] == 'assistant' && i + 1 < messages.length && messages[i + 1]['role'] == 'user') {
        // 生成模拟分数 (75-95之间随机)
        final int questionScore = 75 + (DateTime.now().microsecond % 21);
        qaDetails.add({
          "question": messages[i]['content'] ?? "",
          "answer": messages[i + 1]['content'] ?? "",
          "score": questionScore,
        });
      }
    }

    // 计算总分（基于问答分数平均值）
    final int avgScore = qaDetails.isEmpty
        ? 85
        : (qaDetails.map((e) => e['score'] as int).reduce((a, b) => a + b) / qaDetails.length).round();

    final Map<String, dynamic> newReport = {
      "job": widget.job,
      "jobCategory": widget.jobCategory,
      "company": widget.company,
      "date": DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      "totalScore": avgScore,
      "feedback": "你在${widget.job}面试中表现稳健，逻辑清晰。",
      "interviewerType": widget.interviewerType,
      "duration": _formattedTime,
      "questionCount": _currentQuestionIndex + 1,
      "emotionScore": _emotionScore,
      "qaDetails": qaDetails,
    };
    globalUsers[currentUserIndex]['history'].insert(0, newReport);
    saveUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (c) => ReportPage(reportData: newReport)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TechBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // 顶部状态栏
              _buildHeader(),
              // 视频预览区 + 当前问题 + 情绪曲线
              _buildVideoSection(),
              // 聊天区
              Expanded(child: _buildChatArea()),
              // 输入区
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => _showExitDialog(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,  // 使用深色模式感知的颜色
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 12.6),
            ),
          ),
          const SizedBox(width: 10),
          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  "${widget.interviewerType} · 进行中",
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          // 计时器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.primary, size: 8.4),
                const SizedBox(width: 4),
                Text(
                  _formattedTime,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 结束按钮
          GestureDetector(
            onTap: _finishInterview,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              ),
              child: Text("结束", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }

  // 视频区域
  Widget _buildVideoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: _buildVideoPreview(),
    );
  }

  // 视频预览区域
  Widget _buildVideoPreview() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1f2e),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Stack(
          children: [
            // 摄像头预览 - 使用FittedBox填满容器
            Positioned.fill(
              child: _cameraController != null && _cameraController!.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: _cameraController!.value.previewSize?.height ?? 1,
                        height: _cameraController!.value.previewSize?.width ?? 1,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF1a1f2e),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                              ),
                              child: Icon(Icons.person, color: AppColors.primary.withOpacity(0.5), size: 24.5),
                            ),
                            const SizedBox(height: 8),
                            Text("摄像头预览", style: TextStyle(color: AppColors.cardBackground, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
            ),
            // 角标装饰
            _buildCornerMark(Alignment.topLeft),
            _buildCornerMark(Alignment.topRight),
            _buildCornerMark(Alignment.bottomLeft),
            _buildCornerMark(Alignment.bottomRight),
            // 左上角 - 录制状态
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "REC",
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // 右上角 - 迷你情绪曲线
            Positioned(
              right: 2,
              top: 2,
              child: _buildMiniEmotionCurve(),
            ),
            // 底部 - 题目进度（左下角）
            Positioned(
              left: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
                child: Text(
                  "Q${_currentQuestionIndex + 1}/$_totalQuestions",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // 声波组件 - 底部中间
            Positioned(
              left: 0,
              right: 0,
              bottom: 2,
              child: Center(
                child: _buildVocalBars(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 迷你情绪曲线 (放在视频右上角)
  Widget _buildMiniEmotionCurve() {
    return Container(
      width: 100,
      height: 45,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "情绪",
                style: TextStyle(color: AppColors.cardBackground, fontSize: 8),
              ),
              Text(
                "$_emotionScore%",
                style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 20),
              painter: _MiniEmotionCurvePainter(_emotionHistory),
            ),
          ),
        ],
      ),
    );
  }

  // 当前问题卡片
  Widget _buildCurrentQuestion() {
    String currentQuestion = messages.isNotEmpty && messages.last['role'] == 'assistant'
        ? messages.last['content'] ?? "请开始作答..."
        : "请开始作答...";

    if (currentQuestion.length > 40) {
      currentQuestion = "${currentQuestion.substring(0, 40)}...";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.cyberPurple.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.help_outline, color: AppColors.primary, size: 11.2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              currentQuestion,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return _buildVideoSection();
  }

  Widget _buildCornerMark(Alignment alignment) {
    return Positioned(
      left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? 0 : null,
      right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? 0 : null,
      top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? 0 : null,
      bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? 0 : null,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildVocalBars() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            double height = 8 + (_pulseController.value * 12) * ((index + 1) / 5);
            if (!_isRecording) height = 8;
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _isRecording ? AppColors.primary : AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          bool isAi = msg['role'] == 'assistant';
          return _buildChatBubble(msg['content'] ?? "", isAi);
        },
      ),
    );
  }

  Widget _buildChatBubble(String content, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isAi ? 0 : 24,
          right: isAi ? 24 : 0,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isAi ? null : LinearGradient(colors: AppColors.primaryGradient),
          color: isAi ? AppColors.surfaceDim : null,  // AI消息用深色模式感知的颜色
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAi ? 4 : 16),
            bottomRight: Radius.circular(isAi ? 16 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isAi ? AppColors.textPrimary : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.3))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 键盘/麦克风切换
            GestureDetector(
              onTap: () => setState(() => _isTypingMode = !_isTypingMode),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: Icon(
                  _isTypingMode ? Icons.mic : Icons.keyboard,
                  color: AppColors.primary,
                  size: 15.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 输入区域
            Expanded(
              child: _isTypingMode
                  ? TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "输入回复...",
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceDim,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleTextSend(),
                    )
                  : GestureDetector(
                      onLongPressStart: (_) => _start(),
                      onLongPressEnd: (_) => _stop(),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          double scale = _isRecording ? 1 + (_pulseController.value * 0.1) : 1;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: _isRecording
                                    ? LinearGradient(colors: [AppColors.error, AppColors.error.withOpacity(0.8)])
                                    : LinearGradient(colors: AppColors.primaryGradient),
                                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                boxShadow: _isRecording ? [
                                  BoxShadow(
                                    color: AppColors.error.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ] : [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isRecording ? Icons.stop : Icons.mic,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isRecording ? "松开发送" : "按住说话",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            // 发送按钮 (仅文字模式)
            if (_isTypingMode) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _handleTextSend,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 9.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusXl)),
        title: Text("确认退出？", style: TextStyle(color: AppColors.textPrimary)),
        content: Text("退出后当前面试进度将不会保存", style: TextStyle(color: AppColors.textSecondary)),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("继续面试", style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("确认退出", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}

// 情绪曲线绘制器
class _EmotionCurvePainter extends CustomPainter {
  final List<double> data;

  _EmotionCurvePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.primary.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = range == 0 ? 0.5 : (data[i] - minVal) / range;
      final y = size.height - (normalizedY * size.height * 0.8 + size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // 使用曲线连接点
        final prevX = (i - 1) * stepX;
        final prevNormalizedY = range == 0 ? 0.5 : (data[i - 1] - minVal) / range;
        final prevY = size.height - (prevNormalizedY * size.height * 0.8 + size.height * 0.1);

        final controlX1 = prevX + stepX / 2;
        final controlX2 = x - stepX / 2;

        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
        fillPath.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }
    }

    // 完成填充路径
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // 绘制填充
    canvas.drawPath(fillPath, fillPaint);

    // 绘制曲线
    canvas.drawPath(path, paint);

    // 绘制数据点
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = range == 0 ? 0.5 : (data[i] - minVal) / range;
      final y = size.height - (normalizedY * size.height * 0.8 + size.height * 0.1);

      // 只绘制最后一个点 (当前点)
      if (i == data.length - 1) {
        canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EmotionCurvePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

// 迷你情绪曲线绘制器 (用于视频角落)
class _MiniEmotionCurvePainter extends CustomPainter {
  final List<double> data;

  _MiniEmotionCurvePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = range == 0 ? 0.5 : (data[i] - minVal) / range;
      final y = size.height - (normalizedY * size.height * 0.8 + size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNormalizedY = range == 0 ? 0.5 : (data[i - 1] - minVal) / range;
        final prevY = size.height - (prevNormalizedY * size.height * 0.8 + size.height * 0.1);
        final controlX1 = prevX + stepX / 2;
        final controlX2 = x - stepX / 2;
        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniEmotionCurvePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

