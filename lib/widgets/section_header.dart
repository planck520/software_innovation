import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

/// 分节标题组件
/// - 统一卡片标题样式
/// - 包含图标容器（圆角8px，半透明背景）
/// - 标题使用 AppTextStyles.title
/// - 支持可选副标题
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return Row(
      children: [
        // 图标容器
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: effectiveIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Icon(
            icon,
            size: 16,
            color: effectiveIconColor,
          ),
        ),
        SizedBox(width: AppTokens.space3),
        // 标题和副标题
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.title,
              ),
              if (subtitle != null) ...[
                SizedBox(height: AppTokens.space1),
                Text(
                  subtitle!,
                  style: AppTextStyles.sectionSubtitle,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
