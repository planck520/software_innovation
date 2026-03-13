import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_text_styles.dart';
import 'bubei_colors.dart';

/// 主题配置 - stitch_login_screen 蓝紫赛博风格
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      // 基础配置
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.divider,

      // ColorScheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.cyberPurple,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.label,
        unselectedLabelStyle: AppTextStyles.footnote,
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.caption,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space6,
            vertical: 16,
          ),
          minimumSize: Size(double.infinity, AppTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space4,
            vertical: 8,
          ),
          textStyle: AppTextStyles.buttonSmall,
        ),
      ),

      // 轮廓按钮主题
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space4,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          textStyle: AppTextStyles.buttonSmall,
        ),
      ),

      // 文字主题
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headline,
        headlineMedium: AppTextStyles.title,
        headlineSmall: AppTextStyles.subtitle,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.subtitle,
        titleSmall: AppTextStyles.body,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.buttonSmall,
        labelSmall: AppTextStyles.label,
      ),

      // Icon 主题
      iconTheme: IconThemeData(
        color: AppColors.textSecondary,
        size: 16.8,
      ),

      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 16.8,
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        ),
        elevation: 0,
      ),

      // Snackbar 主题
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // 进度指示器主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceDim,
        circularTrackColor: AppColors.surfaceDim,
      ),

      // Slider 主题
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceDim,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 20,
        ),
      ),

      // Switch 主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.4);
          }
          return AppColors.surfaceDim;
        }),
      ),

      // Checkbox 主题
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: AppColors.border, width: 2),
      ),

      // Chip 主题
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.label,
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        ),
      ),
    );
  }

  /// 不背单词风格深色主题
  static ThemeData get bubeiDarkTheme {
    return ThemeData.dark().copyWith(
      // 基础配置
      primaryColor: BubeiColors.primary,
      scaffoldBackgroundColor: BubeiColors.background,
      cardColor: BubeiColors.surface,
      dividerColor: BubeiColors.divider,

      // ColorScheme
      colorScheme: ColorScheme.dark(
        primary: BubeiColors.primary,
        secondary: BubeiColors.primaryLight,
        surface: BubeiColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: BubeiColors.textPrimary,
        error: BubeiColors.error,
        onError: Colors.white,
        background: BubeiColors.background,
      ),

      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: BubeiColors.surface,
        foregroundColor: BubeiColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: BubeiColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: BubeiColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BubeiColors.surface,
        selectedItemColor: BubeiColors.primary,
        unselectedItemColor: BubeiColors.textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: BubeiColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BubeiColors.radiusMedium),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BubeiColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BubeiColors.radiusSmall),
          borderSide: const BorderSide(color: BubeiColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BubeiColors.radiusSmall),
          borderSide: const BorderSide(color: BubeiColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BubeiColors.radiusSmall),
          borderSide: const BorderSide(color: BubeiColors.inputFocusedBorder, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: BubeiColors.textTertiary),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BubeiColors.buttonBackground,
          foregroundColor: BubeiColors.buttonForeground,
          disabledBackgroundColor: BubeiColors.buttonBackgroundDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BubeiColors.radiusSmall),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BubeiColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // 文字主题
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: BubeiColors.textPrimary),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: BubeiColors.textPrimary),
        headlineLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: BubeiColors.textPrimary),
        headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: BubeiColors.textPrimary),
        headlineSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: BubeiColors.textPrimary),
        titleLarge: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: BubeiColors.textPrimary),
        titleMedium: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: BubeiColors.textPrimary),
        bodyLarge: const TextStyle(fontSize: 16, color: BubeiColors.textSecondary),
        bodyMedium: const TextStyle(fontSize: 14, color: BubeiColors.textSecondary),
        bodySmall: const TextStyle(fontSize: 12, color: BubeiColors.textTertiary),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BubeiColors.textPrimary),
      ),

      // Icon 主题
      iconTheme: const IconThemeData(
        color: BubeiColors.textSecondary,
        size: 24,
      ),

      primaryIconTheme: const IconThemeData(
        color: BubeiColors.primary,
        size: 24,
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: BubeiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BubeiColors.radiusLarge),
        ),
        elevation: 0,
      ),

      // Snackbar 主题
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BubeiColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: BubeiColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BubeiColors.radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
