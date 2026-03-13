import 'package:flutter/material.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';

/// 代码编辑器设置页面
class EditorSettingsPage extends StatefulWidget {
  final double initialFontSize;
  final int initialTabSize;
  final bool initialWrapEnabled;
  final Function(double fontSize, int tabSize, bool wrapEnabled) onSave;

  const EditorSettingsPage({
    super.key,
    required this.initialFontSize,
    required this.initialTabSize,
    required this.initialWrapEnabled,
    required this.onSave,
  });

  @override
  State<EditorSettingsPage> createState() => _EditorSettingsPageState();
}

class _EditorSettingsPageState extends State<EditorSettingsPage> {
  late double _fontSize;
  late int _tabSize;
  late bool _wrapEnabled;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
    _tabSize = widget.initialTabSize;
    _wrapEnabled = widget.initialWrapEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BubeiColors.background,
      appBar: AppBar(
        backgroundColor: BubeiColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '编辑器设置',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSave(_fontSize, _tabSize, _wrapEnabled);
              Navigator.pop(context);
            },
            child: const Text(
              '保存',
              style: TextStyle(color: BubeiColors.success, fontSize: 14),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 字体大小
          _buildSectionCard(
            '字体大小',
            '调整代码编辑器的字体大小',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '大小',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${_fontSize.toInt()}px',
                      style: const TextStyle(color: BubeiColors.primaryLight, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _fontSize,
                  min: 10,
                  max: 24,
                  divisions: 14,
                  activeColor: BubeiColors.primaryLight,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickSizeBtn(10, '极小', _fontSize),
                    _buildQuickSizeBtn(14, '小', _fontSize),
                    _buildQuickSizeBtn(16, '中', _fontSize),
                    _buildQuickSizeBtn(18, '大', _fontSize),
                    _buildQuickSizeBtn(22, '极大', _fontSize),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tab长度
          _buildSectionCard(
            'Tab长度',
            '设置Tab键的空格数量',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '空格数',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Row(
                  children: [
                    _buildTabSizeBtn(2),
                    _buildTabSizeBtn(4),
                    _buildTabSizeBtn(8),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 自动换行
          _buildSectionCard(
            '自动换行',
            '长代码行是否自动换行显示',
            Switch(
              value: _wrapEnabled,
              activeColor: BubeiColors.success,
              onChanged: (value) {
                setState(() {
                  _wrapEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // 预览
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BubeiColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: BubeiColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '预览',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'class Solution:\n    def twoSum(self, nums, target):\n        # Two Sum\n        return [0, 1]',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: _fontSize,
                    color: const Color(0xFF9CDCFE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String subtitle, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildQuickSizeBtn(double size, String label, double currentSize) {
    final isSelected = (currentSize - size).abs() < 0.5;
    return GestureDetector(
      onTap: () {
        setState(() {
          _fontSize = size;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BubeiColors.primaryLight.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(
            color: isSelected ? BubeiColors.primaryLight : BubeiColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? BubeiColors.primaryLight : Colors.white70,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildTabSizeBtn(int size) {
    final isSelected = _tabSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabSize = size;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BubeiColors.success.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(
            color: isSelected ? BubeiColors.success : BubeiColors.divider,
          ),
        ),
        child: Text(
          '$size',
          style: TextStyle(
            color: isSelected ? BubeiColors.success : Colors.white70,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
