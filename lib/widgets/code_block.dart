import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/languages/all.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';

/// 初始化语法高亮引擎
final Highlight _highlightEngine = Highlight()..registerLanguages(builtinAllLanguages);

/// 代码展示组件 - 包含代码块+复制功能、语法高亮

/// 代码块组件 - 带复制功能和语法高亮
class CodeBlock extends StatefulWidget {
  final String code;
  final String? language;
  final String? title;
  final bool showLineNumbers;
  final bool showCopyButton;
  final bool enableSelection;
  final int? maxLines;
  final VoidCallback? onCopy;
  final bool enableHighlight;

  const CodeBlock({
    super.key,
    required this.code,
    this.language,
    this.title,
    this.showLineNumbers = true,
    this.showCopyButton = true,
    this.enableSelection = true,
    this.maxLines,
    this.onCopy,
    this.enableHighlight = true,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _isCopied = true;
    });
    _pulseController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isCopied = false;
          });
          _pulseController.reset();
        }
      });
    });
    widget.onCopy?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: BubeiColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null || widget.showCopyButton)
            _buildHeader(context),
          _buildCodeContent(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTokens.radiusMd),
          topRight: Radius.circular(AppTokens.radiusMd),
        ),
        border: Border(
          bottom: BorderSide(
            color: BubeiColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.title != null)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          if (widget.showCopyButton) _buildCopyButton(),
        ],
      ),
    );
  }

  Widget _buildCopyButton() {
    return GestureDetector(
      onTap: _copyCode,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space2,
              vertical: AppTokens.space1,
            ),
            decoration: BoxDecoration(
              color: _isCopied
                  ? BubeiColors.success.withOpacity(0.3)
                  : BubeiColors.primary.withOpacity(0.1 + _pulseController.value * 0.2),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              border: Border.all(
                color: _isCopied
                    ? BubeiColors.success
                    : BubeiColors.primary.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: _isCopied
                  ? [
                      BoxShadow(
                        color: BubeiColors.success.withOpacity(0.4 * _pulseController.value),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isCopied ? Icons.check : Icons.content_copy,
                  size: 14,
                  color: _isCopied ? BubeiColors.success : BubeiColors.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  _isCopied ? '已复制' : '复制',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isCopied ? BubeiColors.success : BubeiColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCodeContent() {
    final lines = widget.code.split('\n');

    return Container(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLineNumbers) _buildLineNumbers(lines),
            const SizedBox(width: AppTokens.space3),
            if (widget.enableHighlight)
              _buildHighlightedCode()
            else
              _buildPlainCode(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlainCode() {
    return SelectableText(
      widget.code,
      maxLines: widget.maxLines,
      style: const TextStyle(
        fontFamily: 'Consolas, Monaco, monospace',
        fontSize: 12,
        height: 1.6,
        color: Color(0xFFD4D4D4),
      ),
    );
  }

  String _getHighlightLanguage() {
    final lang = widget.language?.toLowerCase() ?? 'python';
    switch (lang) {
      case 'python':
      case 'py':
        return 'python';
      case 'java':
        return 'java';
      case 'javascript':
      case 'js':
      case 'typescript':
      case 'ts':
        return 'javascript';
      case 'cpp':
      case 'c++':
      case 'c':
        return 'cpp';
      case 'dart':
        return 'dart';
      default:
        return 'python';
    }
  }

  Widget _buildHighlightedCode() {
    try {
      final language = _getHighlightLanguage();
      final result = _highlightEngine.highlight(code: widget.code, language: language);

      // 使用 VSCode Dark+ 主题
      final renderer = TextSpanRenderer(
        const TextStyle(
          fontFamily: 'Consolas, Monaco, monospace',
          fontSize: 12,
          height: 1.6,
          color: Color(0xFFD4D4D4),
        ),
        _vsCodeDarkTheme,
      );

      result.render(renderer);

      if (renderer.span != null) {
        return SelectableText.rich(renderer.span!);
      }
    } catch (e) {
      debugPrint('Syntax highlight error: $e');
    }

    // 回退：返回普通文本
    return SelectableText(
      widget.code,
      style: const TextStyle(
        fontFamily: 'Consolas, Monaco, monospace',
        fontSize: 12,
        height: 1.6,
        color: Color(0xFFD4D4D4),
      ),
    );
  }

  Widget _buildLineNumbers(List<String> lines) {
    return Container(
      padding: const EdgeInsets.only(right: AppTokens.space2),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFF4A4A4A),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          lines.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontFamily: 'Consolas, Monaco, monospace',
                fontSize: 11,
                height: 1.6,
                color: Color(0xFF858585),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// VSCode Dark+ 主题配置
final Map<String, TextStyle> _vsCodeDarkTheme = {
  'root': const TextStyle(
    backgroundColor: Color(0xFF1E1E1E),
    color: Color(0xFFD4D4D4),
  ),
  'keyword': const TextStyle(color: Color(0xFF569CD6)),
  'built_in': const TextStyle(color: Color(0xFF4EC9B0)),
  'type': const TextStyle(color: Color(0xFF4EC9B0)),
  'literal': const TextStyle(color: Color(0xFF569CD6)),
  'number': const TextStyle(color: Color(0xFFB5CEA8)),
  'operator': const TextStyle(color: Color(0xFFD4D4D4)),
  'punctuation': const TextStyle(color: Color(0xFFD4D4D4)),
  'property': const TextStyle(color: Color(0xFF9CDCFE)),
  'regexp': const TextStyle(color: Color(0xFFD16969)),
  'string': const TextStyle(color: Color(0xFFCE9178)),
  'char.escape': const TextStyle(color: Color(0xFFD7BA7D)),
  'subst': const TextStyle(color: Color(0xFF9CDCFE)),
  'symbol': const TextStyle(color: Color(0xFFB5CEA8)),
  'variable': const TextStyle(color: Color(0xFF9CDCFE)),
  'variable.language': const TextStyle(color: Color(0xFF569CD6)),
  'variable.constant': const TextStyle(color: Color(0xFF4FC1FF)),
  'title': const TextStyle(color: Color(0xFFDCDCAA)),
  'title.class': const TextStyle(color: Color(0xFF4EC9B0)),
  'title.function': const TextStyle(color: Color(0xFFDCDCAA)),
  'params': const TextStyle(color: Color(0xFF9CDCFE)),
  'comment': const TextStyle(color: Color(0xFF6A9955)),
  'doctag': const TextStyle(color: Color(0xFF608B4E)),
  'meta': const TextStyle(color: Color(0xFF808080)),
  'meta.prompt': const TextStyle(color: Color(0xFF808080)),
  'meta.keyword': const TextStyle(color: Color(0xFF569CD6)),
  'meta.string': const TextStyle(color: Color(0xFFCE9178)),
  'section': const TextStyle(color: Color(0xFF4EC9B0)),
  'addition': const TextStyle(color: Color(0xFFB5CEA8)),
  'deletion': const TextStyle(color: Color(0xFFCE9178)),
  'class': const TextStyle(color: Color(0xFF4EC9B0)),
  'function': const TextStyle(color: Color(0xFFDCDCAA)),
  'attr': const TextStyle(color: Color(0xFF9CDCFE)),
  'attribute': const TextStyle(color: Color(0xFF9CDCFE)),
  'name': const TextStyle(color: Color(0xFF9CDCFE)),
  'tag': const TextStyle(color: Color(0xFF569CD6)),
  'selector-tag': const TextStyle(color: Color(0xFFD7BA7D)),
  'selector-id': const TextStyle(color: Color(0xFFD7BA7D)),
  'selector-class': const TextStyle(color: Color(0xFFD7BA7D)),
  'selector-attr': const TextStyle(color: Color(0xFFD7BA7D)),
  'selector-pseudo': const TextStyle(color: Color(0xFFD7BA7D)),
};

/// 简化的代码展示卡片
class SimpleCodeCard extends StatelessWidget {
  final String code;
  final String? language;
  final String title;
  final VoidCallback? onCopy;

  const SimpleCodeCard({
    super.key,
    required this.code,
    this.language,
    this.title = '代码',
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: BubeiColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildCodeContent(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      decoration: BoxDecoration(
        color: BubeiColors.surfaceDim,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTokens.radiusMd),
          topRight: Radius.circular(AppTokens.radiusMd),
        ),
        border: Border(
          bottom: BorderSide(
            color: BubeiColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.code, size: 14, color: BubeiColors.primaryLight),
              const SizedBox(width: 6),
              Text(
                language ?? 'Python',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              onCopy?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('代码已复制'),
                  duration: Duration(seconds: 1),
                  backgroundColor: BubeiColors.success,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space2,
                vertical: AppTokens.space1,
              ),
              decoration: BoxDecoration(
                color: BubeiColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.content_copy, size: 12, color: BubeiColors.primaryLight),
                  SizedBox(width: 4),
                  Text(
                    '复制',
                    style: TextStyle(
                      fontSize: 10,
                      color: BubeiColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeContent() {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: SelectableText(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.6,
          color: Color(0xFF9CDCFE),
        ),
      ),
    );
  }
}
