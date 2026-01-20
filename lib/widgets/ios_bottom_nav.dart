import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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

/// stitch_login_screen 风格底部导航栏
/// - 5 个标签页布局
/// - 玻璃态背景
/// - 蓝色选中态，点击时短暂变黄再平滑回蓝
class IosBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final bool showBlur;

  const IosBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: "首页"),
      NavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, label: "开始"),
      NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: "历史"),
      NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "我的"),
    ],
    this.showBlur = true,
  });

  @override
  State<IosBottomNav> createState() => _IosBottomNavState();
}

class _IosBottomNavState extends State<IosBottomNav> {
  // 记录正在闪烁的索引，用于“点击变黄，0.5s 后平滑回蓝”
  final Set<int> _flashing = {};
  static const Color _flashColor = Color(0xFFFFD54F); // 明亮黄
  final Map<int, double> _scaleTargets = {}; // 图标缩放目标

  void _handleTap(int index) {
    widget.onTap(index);
    setState(() => _flashing.add(index));
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _flashing.remove(index));
    });

    // 点击缩放：先缩至 0.8，再在 0.125s 后恢复为 1
    setState(() => _scaleTargets[index] = 0.8);
    Future.delayed(const Duration(milliseconds: 125), () {
      if (!mounted) return;
      setState(() => _scaleTargets[index] = 1.0);
    });
  }

  Color _targetColor(bool isSelected, bool flashing) {
    if (flashing) return _flashColor;
    return isSelected ? AppColors.primary : AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final navBar = Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavItem(index, item);
            }).toList(),
          ),
        ),
      ),
    );

    if (widget.showBlur) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: navBar,
        ),
      );
    }

    return navBar;
  }

  Widget _buildNavItem(int index, NavItem item) {
    final isSelected = widget.currentIndex == index;
    final isFlashing = _flashing.contains(index);
    final targetColor = _targetColor(isSelected, isFlashing);
    final iconData = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
    final iconScale = _scaleTargets[index] ?? 1.0;

    return GestureDetector(
      onTap: () => _handleTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标：点击瞬间黄，0.5s 后回蓝，过渡平滑
            AnimatedScale(
              scale: iconScale,
              duration: const Duration(milliseconds: 125),
              curve: Curves.easeOut,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: targetColor),
                duration: const Duration(milliseconds: 260),
                builder: (context, color, _) {
                  return Icon(
                    iconData,
                    color: color ?? targetColor,
                    size: 16.8,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            // 标签颜色与图标保持同步
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: targetColor),
              duration: const Duration(milliseconds: 260),
              builder: (context, color, _) {
                return DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: color ?? targetColor,
                  ),
                  child: Text(item.label),
                );
              },
            ),
            const SizedBox(height: 2),
            // 选中指示点也随颜色过渡
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: targetColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
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
        color: AppColors.surface.withOpacity(0.9),
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
