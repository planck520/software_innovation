import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';
import '../models/solution.dart';

/// 解法方法选择器
/// 横向可滚动的解法标签列表，支持推荐标记和选中态
class SolutionMethodSelector extends StatelessWidget {
  final List<Solution> solutions;
  final int selectedIndex;
  final ValueChanged<int> onMethodSelected;

  const SolutionMethodSelector({
    super.key,
    required this.solutions,
    required this.selectedIndex,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (solutions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择解法',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppTokens.space3),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: solutions.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppTokens.space2),
            itemBuilder: (context, index) {
              final solution = solutions[index];
              final isSelected = index == selectedIndex;
              return _SolutionMethodTag(
                solution: solution,
                isSelected: isSelected,
                onTap: () => onMethodSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 单个解法标签
class _SolutionMethodTag extends StatefulWidget {
  final Solution solution;
  final bool isSelected;
  final VoidCallback onTap;

  const _SolutionMethodTag({
    required this.solution,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SolutionMethodTag> createState() => _SolutionMethodTagState();
}

class _SolutionMethodTagState extends State<_SolutionMethodTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.isSelected) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_SolutionMethodTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color get _tagColor {
    // 根据解法类型返回不同颜色
    switch (widget.solution.method) {
      case SolutionMethod.hashMap:
        return const Color(0xFF4EC9B0); // 青色
      case SolutionMethod.twoPointers:
        return const Color(0xFF569CD6); // 蓝色
      case SolutionMethod.dynamicProgramming:
        return const Color(0xFFC586C0); // 紫色
      case SolutionMethod.bruteForce:
        return const Color(0xFFCE9178); // 橙色
      case SolutionMethod.binarySearch:
        return const Color(0xFFDCDCAA); // 黄色
      case SolutionMethod.slidingWindow:
        return const Color(0xFF9CDCFE); // 浅蓝
      case SolutionMethod.recursion:
        return const Color(0xFFF44747); // 红色
      case SolutionMethod.greedy:
        return const Color(0xFF4FC1FF); // 天蓝
      case SolutionMethod.stack:
      case SolutionMethod.queue:
        return const Color(0xFFB180D7); // 淡紫
      case SolutionMethod.bfs:
      case SolutionMethod.dfs:
        return const Color(0xFF6A9955); // 绿色
      case SolutionMethod.backtracking:
        return const Color(0xFFFF6B6B); // 珊瑚红
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _tagColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space3,
              vertical: AppTokens.space2,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(widget.isSelected ? 0.25 : 0.15),
                  color.withOpacity(widget.isSelected ? 0.15 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              border: Border.all(
                color: color.withOpacity(widget.isSelected ? 0.7 : 0.4),
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 推荐标记
                if (widget.solution.isRecommended) ...[
                  Icon(
                    Icons.star,
                    size: 12,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  widget.solution.method.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.3,
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
