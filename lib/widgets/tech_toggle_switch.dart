import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 技术风格开关组件
/// - 统一开关样式（56x32px）
/// - 开启状态使用 primaryGradient 渐变
/// - 白色滑块，带阴影
class TechToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;

  const TechToggleSwitch({
    super.key,
    this.value = false,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<TechToggleSwitch> createState() => _TechToggleSwitchState();
}

class _TechToggleSwitchState extends State<TechToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppTokens.durationNormal),
      vsync: this,
    );
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppTokens.curveIOS,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TechToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled) return;
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) {
          return SizedBox(
            width: AppTokens.toggleWidth,
            height: AppTokens.toggleHeight,
            child: Stack(
              children: [
                // 背景轨道
                AnimatedContainer(
                  duration: const Duration(milliseconds: AppTokens.durationNormal),
                  curve: AppTokens.curveIOS,
                  width: AppTokens.toggleWidth,
                  height: AppTokens.toggleHeight,
                  decoration: BoxDecoration(
                    gradient: widget.value && widget.isEnabled
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.primaryGradient,
                          )
                        : null,
                    color: widget.value && widget.isEnabled
                        ? null
                        : AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTokens.toggleHeight / 2),
                  ),
                ),
                // 滑块
                AnimatedAlign(
                  duration: const Duration(milliseconds: AppTokens.durationNormal),
                  curve: AppTokens.curveIOS,
                  alignment: Alignment(
                    widget.value ? 0.6 : -0.6,
                    0,
                  ),
                  child: Container(
                    width: AppTokens.toggleHeight - 6,
                    height: AppTokens.toggleHeight - 6,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular((AppTokens.toggleHeight - 6) / 2),
                      boxShadow: widget.isEnabled
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
