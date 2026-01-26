import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

/// 技术风格下拉框组件
/// - 统一下拉框样式
/// - 高度 39px，圆角 12px
/// - 字体使用 AppTextStyles.dropdownItem
/// - 支持前缀图标和标签
class TechDropdownField extends StatefulWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? hint;
  final String? label;
  final IconData? prefixIcon;
  final bool isEnabled;

  const TechDropdownField({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.label,
    this.prefixIcon,
    this.isEnabled = true,
  });

  @override
  State<TechDropdownField> createState() => _TechDropdownFieldState();
}

class _TechDropdownFieldState extends State<TechDropdownField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppTokens.space2,
              bottom: AppTokens.space1,
            ),
            child: Text(
              widget.label!,
              style: AppTextStyles.labelTiny.copyWith(
                color: widget.isEnabled
                    ? AppColors.textSecondary
                    : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space1),
        ],
        GestureDetector(
          onTap: widget.isEnabled ? _showDropdown : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppTokens.durationNormal),
            height: AppTokens.inputHeight,
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? AppColors.inputBackground
                  : AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: widget.isEnabled
                    ? AppColors.border.withOpacity(0.5)
                    : AppColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null
                    ? AppTokens.space2
                    : AppTokens.space3,
              ),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(
                      widget.prefixIcon,
                      size: 14,
                      color: widget.isEnabled
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppTokens.space2),
                  ],
                  Expanded(
                    child: Text(
                      widget.value ?? widget.hint ?? '请选择',
                      style: AppTextStyles.dropdownItem.copyWith(
                        color: widget.value != null
                            ? (widget.isEnabled
                                ? AppColors.textPrimary
                                : AppColors.textTertiary)
                            : AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: widget.isEnabled
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDropdown() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTokens.radiusLg),
              topRight: Radius.circular(AppTokens.radiusLg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppTokens.space3),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTokens.space4),
                child: Text(
                  widget.label ?? '请选择',
                  style: AppTextStyles.title,
                ),
              ),
              const Divider(height: 1),
              LimitedBox(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = item == widget.value;
                    return InkWell(
                      onTap: () {
                        widget.onChanged?.call(item);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.space4,
                          vertical: AppTokens.space3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: AppTextStyles.body.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                size: 18,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}
