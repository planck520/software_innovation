import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// 交错动画列表组件
class StaggeredListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;
  final double staggerDelay;

  const StaggeredListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.staggerDelay = 0.1,
  });

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalDuration = 800 + (widget.itemCount * widget.staggerDelay * 1000).round();
    _controller = AnimationController(
      duration: Duration(milliseconds: totalDuration),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * widget.staggerDelay,
                  0.5 + index * widget.staggerDelay,
                  curve: AppTokens.curveEaseOut,
                ),
              ),
            );

            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * widget.staggerDelay,
                  0.5 + index * widget.staggerDelay,
                  curve: AppTokens.curveEaseOut,
                ),
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: widget.itemBuilder(context, index),
              ),
            );
          },
        );
      },
    );
  }
}

/// 水平交错动画列表
class HorizontalStaggeredList extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;
  final double staggerDelay;

  const HorizontalStaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.staggerDelay = 0.1,
  });

  @override
  State<HorizontalStaggeredList> createState() => _HorizontalStaggeredListState();
}

class _HorizontalStaggeredListState extends State<HorizontalStaggeredList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalDuration = 600 + (widget.itemCount * widget.staggerDelay * 1000).round();
    _controller = AnimationController(
      duration: Duration(milliseconds: totalDuration),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(widget.itemCount, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    index * widget.staggerDelay,
                    0.4 + index * widget.staggerDelay,
                    curve: AppTokens.curveEaseOut,
                  ),
                ),
              );

              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    index * widget.staggerDelay,
                    0.4 + index * widget.staggerDelay,
                    curve: AppTokens.curveEaseOut,
                  ),
                ),
              );

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: widget.itemBuilder(context, index),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 列表项进入动画包装器
class StaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;
  final double delay;

  const StaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = 0.1,
  });

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: (widget.index * widget.delay * 1000).round()))
        .then((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _controller, curve: AppTokens.curveSpring),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
