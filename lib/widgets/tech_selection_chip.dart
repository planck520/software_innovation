import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

/// 芯片尺寸枚举
enum ChipSize {
  small,
  medium,
  large,
}

/// 技术选择芯片组件
/// - 支持单选
/// - 选中时使用 primaryGradient 渐变背景
/// - 圆角统一为 radiusMd (12px)
/// - 支持小/中/大三种尺寸
/// - 支持图标、发光效果
class TechSelectionChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;
  final IconData? icon;
  final bool showGlow;
  final Color? selectedColor;
  final double? width;
  final ChipSize size;

  const TechSelectionChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onChanged,
    this.isEnabled = true,
    this.icon,
    this.showGlow = false,
    this.selectedColor,
    this.width,
    this.size = ChipSize.medium,
  });

  @override
  State<TechSelectionChip> createState() => _TechSelectionChipState();
}

class _TechSelectionChipState extends State<TechSelectionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: AppTokens.durationNormal),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppTokens.curveIOS,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get _height {
    switch (widget.size) {
      case ChipSize.small:
        return AppTokens.chipHeightSmall;
      case ChipSize.medium:
        return AppTokens.chipHeight;
      case ChipSize.large:
        return AppTokens.buttonHeight;
    }
  }

  double get _horizontalPadding {
    switch (widget.size) {
      case ChipSize.small:
        return AppTokens.space2;
      case ChipSize.medium:
        return AppTokens.space3;
      case ChipSize.large:
        return AppTokens.space4;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case ChipSize.small:
        return AppTextStyles.chipLabelSmall;
      case ChipSize.medium:
      case ChipSize.large:
        return AppTextStyles.chipLabel;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ChipSize.small:
        return 12.0;
      case ChipSize.medium:
        return 14.0;
      case ChipSize.large:
        return 16.0;
    }
  }

  void _handleTap() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _scaleController.forward().then((_) {
      _scaleController.reverse();
      setState(() => _isPressed = false);
    });
    widget.onChanged?.call(!widget.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: AppTokens.durationNormal),
              curve: AppTokens.curveIOS,
              width: widget.width,
              height: _height,
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.primaryGradient,
                      )
                    : null,
                color: widget.isSelected ? null : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.transparent
                      : AppColors.border.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: widget.isSelected && widget.isEnabled
                    ? [
                        if (widget.showGlow)
                          BoxShadow(
                            color: (widget.selectedColor ?? AppColors.primary)
                                .withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: AppTokens.space1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: _iconSize,
                        color: widget.isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: AppTokens.space1),
                    ],
                    Text(
                      widget.label,
                      style: _textStyle.copyWith(
                        color: widget.isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 分段控制组件
/// - 用于分段选择（如时间限制）
/// - 自动均分宽度
/// - 统一样式与 TechSelectionChip 保持一致
class TechSegmentedControl extends StatefulWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;
  final bool isEnabled;
  final double? height;
  final double? width;

  const TechSegmentedControl({
    super.key,
    required this.options,
    this.selectedIndex = 0,
    this.onIndexChanged,
    this.isEnabled = true,
    this.height,
    this.width,
  });

  @override
  State<TechSegmentedControl> createState() => _TechSegmentedControlState();
}

class _TechSegmentedControlState extends State<TechSegmentedControl> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(TechSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  void _handleTap(int index) {
    if (!widget.isEnabled) return;
    setState(() => _selectedIndex = index);
    widget.onIndexChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? AppTokens.chipHeight;

    return Container(
      width: widget.width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd - 1),
        child: Row(
          children: List.generate(widget.options.length, (index) {
            final isSelected = _selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _handleTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: AppTokens.durationNormal),
                  curve: AppTokens.curveIOS,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.primaryGradient,
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd - 1),
                  ),
                  child: Center(
                    child: Text(
                      widget.options[index],
                      style: AppTextStyles.chipLabel.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
