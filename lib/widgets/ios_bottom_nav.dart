import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';

/// 底部导航项数据类
class NavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// 不背单词风格底部导航栏
/// - 3 个标签页布局
/// - 透明背景
/// - 白色图标，橙色选中态
class IosBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final bool showBlur;

  const IosBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: ""),
      NavItem(icon: Icons.quiz_outlined, activeIcon: Icons.quiz, label: ""),
      NavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: ""),
    ],
    this.showBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildNavItem(index, item);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItem item) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space4, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? (item.activeIcon ?? item.icon) : item.icon,
            color: isSelected ? const Color(0xFFFF8C00) : Colors.white.withOpacity(0.6),
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// stitch 风格浮动导航栏
class IosFloatingNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;

  const IosFloatingNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      NavItem(icon: Icons.home_outlined, label: "首页"),
      NavItem(icon: Icons.play_circle_outline, label: "开始"),
      NavItem(icon: Icons.history_outlined, label: "历史"),
      NavItem(icon: Icons.person_outline, label: "我的"),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTokens.space4),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3, vertical: AppTokens.space2),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavItem(index, item);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItem item) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: AppColors.primaryGradient)
              : null,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 14,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
