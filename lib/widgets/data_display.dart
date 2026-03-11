import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';

/// 数据展示组件 - 包含渐变进度条、指标卡片、空状态组件

/// 渐变进度条
class ProgressBar extends StatefulWidget {
  final double value;
  final double maxValue;
  final Color? color;
  final List<Color>? gradientColors;
  final double height;
  final BorderRadius? borderRadius;
  final bool showLabel;
  final String? label;
  final bool animated;
  final Duration animationDuration;

  const ProgressBar({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.color,
    this.gradientColors,
    this.height = 6,
    this.borderRadius,
    this.showLabel = false,
    this.label,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: widget.value / widget.maxValue)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value || widget.maxValue != oldWidget.maxValue) {
      _animation = Tween<double>(begin: 0.0, end: widget.value / widget.maxValue)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.color ?? BubeiColors.primary;
    final gradientColors = widget.gradientColors ??
        [
          progressColor,
          progressColor.withOpacity(0.7),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label ?? '进度',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(widget.value / widget.maxValue * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space2),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: BubeiColors.surfaceDim,
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(widget.height / 2),
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(widget.height / 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _animation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                        borderRadius: widget.borderRadius ??
                            BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 指标卡片
class MetricCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? unit;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool? trendIsPositive;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.unit,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.trendIsPositive,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? BubeiColors.primary;

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            }
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () {
              _controller.reverse();
              setState(() => _isPressed = false);
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildCard(color),
          );
        },
      ),
    );
  }

  Widget _buildCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppTokens.space2),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              if (widget.unit != null) ...[
                const SizedBox(width: AppTokens.space1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.unit!,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (widget.showTrend && widget.trendValue != null)
                _buildTrendIndicator(color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(Color color) {
    final isPositive = widget.trendIsPositive ?? true;
    final trendColor = isPositive ? BubeiColors.success : BubeiColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: trendColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.trendValue!.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: trendColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 空状态组件
class EmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Widget? customIllustration;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIllustration != null)
              customIllustration!
            else if (icon != null)
              Container(
                padding: const EdgeInsets.all(AppTokens.space6),
                decoration: BoxDecoration(
                  color: BubeiColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: BubeiColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: BubeiColors.primary.withOpacity(0.5),
                ),
              )
            else
              _buildDefaultIllustration(),
            const SizedBox(height: AppTokens.space4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTokens.space2),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppTokens.space6),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BubeiColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space4,
                    vertical: AppTokens.space3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIllustration() {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _EmptyStateIllustrationPainter(),
      ),
    );
  }
}

class _EmptyStateIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = BubeiColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circle
    canvas.drawCircle(center, size.width / 3, paint);

    // Draw search icon
    final searchPaint = Paint()
      ..color = BubeiColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final circleCenter = Offset(center.dx - 10, center.dy - 10);
    canvas.drawCircle(circleCenter, 20, searchPaint);

    final lineStart = Offset(circleCenter.dx + 14, circleCenter.dy + 14);
    final lineEnd = Offset(circleCenter.dx + 28, circleCenter.dy + 28);
    canvas.drawLine(lineStart, lineEnd, searchPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 加载状态指示器
class LoadingState extends StatelessWidget {
  final String? message;
  final bool showBackground;

  const LoadingState({
    super.key,
    this.message,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(BubeiColors.primary),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppTokens.space4),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (showBackground) {
      return Container(
        color: BubeiColors.background.withOpacity(0.8),
        child: content,
      );
    }

    return content;
  }
}

/// 错误状态组件
class ErrorState extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorState({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTokens.space6),
              decoration: BoxDecoration(
                color: BubeiColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: BubeiColors.error.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: BubeiColors.error,
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (details != null) ...[
              const SizedBox(height: AppTokens.space2),
              Text(
                details!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppTokens.space6),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryLabel ?? '重试'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BubeiColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space4,
                    vertical: AppTokens.space3,
                  ),
                  side: BorderSide(
                    color: BubeiColors.error.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 统计数据卡片网格
class StatsGrid extends StatelessWidget {
  final List<StatItem> items;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const StatsGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = AppTokens.space3,
    this.crossAxisSpacing = AppTokens.space3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return MetricCard(
          label: items[index].label,
          value: items[index].value,
          icon: items[index].icon,
          color: items[index].color,
          unit: items[index].unit,
        );
      },
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? unit;

  const StatItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.unit,
  });
}
