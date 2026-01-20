import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 科技感线性进度指示器
class TechProgressIndicator extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? activeColor;
  final double height;
  final bool showPercentage;

  const TechProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.activeColor,
    this.height = 6,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 进度条
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceDim,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              // 背景条
              const SizedBox(width: double.infinity),
              // 进度条
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 标签
        if (label != null || showPercentage) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (showPercentage)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 环形进度指示器（带发光效果）
class CircularProgressWithGlow extends StatelessWidget {
  final double progress;
  final double size;
  final Color? color;
  final double strokeWidth;
  final Widget? center;
  final String? centerText;
  final bool showGlow;

  const CircularProgressWithGlow({
    super.key,
    required this.progress,
    this.size = 60,
    this.color,
    this.strokeWidth = 6,
    this.center,
    this.centerText,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外发光环
          if (showGlow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    activeColor.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          // 背景圆环
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceDim.withOpacity(0.3),
            ),
          ),
          // 进度圆环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(activeColor),
            ),
          ),
          // 中心内容
          if (center != null) center!,
          // 中心文字
          if (centerText != null)
            Text(
              centerText!,
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// 点状进度指示器
class DotProgressIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;

  const DotProgressIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primary;
    final inactive = inactiveColor ?? AppColors.surfaceDim;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? dotSize * 2 : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: index == currentIndex ? active : inactive,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        ),
      ),
    );
  }
}

/// 步骤进度指示器
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? labels;
  final Color? activeColor;
  final Color? completedColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
    this.activeColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primary;
    final completed = completedColor ?? AppColors.success;

    return Column(
      children: [
        // 步骤圆点
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  _buildStepDot(
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    active: active,
                    completed: completed,
                    index: index,
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isCompleted ? completed : AppColors.surfaceDim,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        // 步骤标签
        if (labels != null && labels!.length == totalSteps) ...[
          const SizedBox(height: 12),
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Text(
                  labels![index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted || isCurrent
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildStepDot({
    required bool isCompleted,
    required bool isCurrent,
    required Color active,
    required Color completed,
    required int index,
  }) {
    Color getColor() {
      if (isCompleted) return completed;
      if (isCurrent) return active;
      return AppColors.surfaceDim;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: getColor(),
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: active.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          isCompleted ? '✓' : '${index + 1}',
          style: TextStyle(
            color: isCompleted || isCurrent ? Colors.white : AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
