import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';

/// stitch_login_screen 风格毛玻璃效果卡片组件
/// - 背景透明度 70%
/// - 模糊度 12px
/// - 蓝色调阴影
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final VoidCallback? onTap;
  final Border? border;
  final Color? backgroundColor;
  final BoxShadow? shadow;
  final double? width;
  final double? height;
  final bool showNeonGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppTokens.radius2xl,
    this.blur = 12,  // stitch 风格: blur(12px)
    this.onTap,
    this.border,
    this.backgroundColor,
    this.shadow,
    this.width,
    this.height,
    this.showNeonGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppTokens.space6),
          margin: margin,
          decoration: BoxDecoration(
            // stitch 风格: rgba(255, 255, 255, 0.7) 或深色模式
            color: backgroundColor ?? AppColors.cardBackground,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  // stitch 风格: rgba(255, 255, 255, 0.5) 或 primary/10
                  color: AppColors.glassBorder,
                  width: 1,
                ),
            boxShadow: showNeonGlow
                ? AppTokens.neonGlowShadow
                : shadow != null
                    ? [shadow!]
                    : [
                        // stitch 风格: box-shadow: 0 8px 32px 0 rgba(19, 91, 236, 0.1)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          offset: const Offset(0, 8),
                          blurRadius: 32,
                        ),
                      ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// 简化版玻璃卡片 - 无毛玻璃效果，仅用于性能考虑的场景
class SimpleGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final bool showNeonGlow;

  const SimpleGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppTokens.radius2xl,
    this.onTap,
    this.border,
    this.backgroundColor,
    this.width,
    this.height,
    this.showNeonGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppTokens.space6),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
        boxShadow: showNeonGlow ? AppTokens.neonGlowShadow : AppTokens.shadowMd,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// 霓虹发光卡片 - 用于选中态或强调
class NeonGlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color glowColor;
  final VoidCallback? onTap;

  const NeonGlowCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppTokens.radiusLg,
    this.glowColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppTokens.space4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: glowColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// 不背单词风格深色卡片组件
class BubeiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final Border? border;

  const BubeiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? BubeiColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: BubeiColors.divider,
              width: 1,
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: BubeiColors.primary.withOpacity(0.1),
          highlightColor: BubeiColors.primary.withOpacity(0.05),
          child: card,
        ),
      );
    }

    return card;
  }
}
