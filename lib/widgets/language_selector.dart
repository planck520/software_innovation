import 'package:flutter/material.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';
import '../models/solution.dart';

/// 构建语言图标
Widget _buildLanguageIcon(ProgrammingLanguage language) {
  // 返回语言对应的图标或标识
  final iconData = switch (language) {
    ProgrammingLanguage.python => Icons.code,
    ProgrammingLanguage.java => Icons.coffee,
    ProgrammingLanguage.javascript => Icons.javascript,
    ProgrammingLanguage.cpp => Icons.memory,
  };

  final iconColor = switch (language) {
    ProgrammingLanguage.python => const Color(0xFF3776AB), // Python蓝
    ProgrammingLanguage.java => const Color(0xFFED8B00), // Java橙
    ProgrammingLanguage.javascript => const Color(0xFFF7DF1E), // JS黄
    ProgrammingLanguage.cpp => const Color(0xFF00599C), // C++蓝
  };

  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: iconColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Icon(
      iconData,
      size: 12,
      color: iconColor,
    ),
  );
}

/// 语言选择器
/// 基于 TechDropdownField 风格的语言下拉选择组件
class LanguageSelector extends StatelessWidget {
  final ProgrammingLanguage selectedLanguage;
  final List<ProgrammingLanguage> availableLanguages;
  final ValueChanged<ProgrammingLanguage> onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.availableLanguages,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    const langColor = Color(0xFF4DA3D6); // 蓝色
    final textColor = langColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space2,
        ),
        decoration: BoxDecoration(
          color: langColor,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageIcon(selectedLanguage),
            const SizedBox(width: AppTokens.space2),
            Text(
              selectedLanguage.label,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppTokens.space2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguagePickerSheet(
        languages: availableLanguages,
        selectedLanguage: selectedLanguage,
        onLanguageSelected: (language) {
          Navigator.pop(context);
          onLanguageChanged(language);
        },
      ),
    );
  }
}

/// 语言选择底部弹窗
class _LanguagePickerSheet extends StatelessWidget {
  final List<ProgrammingLanguage> languages;
  final ProgrammingLanguage selectedLanguage;
  final ValueChanged<ProgrammingLanguage> onLanguageSelected;

  const _LanguagePickerSheet({
    required this.languages,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTokens.radiusLg),
          topRight: Radius.circular(AppTokens.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: AppTokens.space3),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: BubeiColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(AppTokens.space4),
            child: Row(
              children: [
                const Icon(Icons.code, color: BubeiColors.primaryLight, size: 20),
                const SizedBox(width: AppTokens.space2),
                const Text(
                  '选择编程语言',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: BubeiColors.divider),
          // 语言列表
          ...languages.map((language) => _buildLanguageItem(language)),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppTokens.space4),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(ProgrammingLanguage language) {
    final isSelected = language == selectedLanguage;

    return InkWell(
      onTap: () => onLanguageSelected(language),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: isSelected ? BubeiColors.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            _buildLanguageIcon(language),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Text(
                language.label,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? BubeiColors.primaryLight : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 20,
                color: BubeiColors.primaryLight,
              ),
          ],
        ),
      ),
    );
  }
}
