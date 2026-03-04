import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 弹跳动画对话气泡组件
class MessageBubble extends StatefulWidget {
  final String content;
  final bool isAi;
  final DateTime? timestamp;
  final String? avatarUrl;
  final VoidCallback? onThumbsUp;
  final VoidCallback? onThumbsDown;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isAi,
    this.timestamp,
    this.avatarUrl,
    this.onThumbsUp,
    this.onThumbsDown,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();

    final begin = widget.isAi ? const Offset(-0.2, 0) : const Offset(0.2, 0);
    _slideAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: AppTokens.curveSpring),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTokens.curveEaseOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: widget.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: widget.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.isAi && widget.avatarUrl != null) ...[
                    _buildAvatar(),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: _buildBubble()),
                  if (!widget.isAi && widget.avatarUrl != null) ...[
                    const SizedBox(width: 8),
                    _buildAvatar(),
                  ],
                ],
              ),
              // 反馈按钮（仅AI消息）
              if (widget.isAi && (widget.onThumbsUp != null || widget.onThumbsDown != null))
                _buildFeedbackButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble() {
    return Container(
      margin: EdgeInsets.only(
        left: widget.isAi ? 0 : 60,
        right: widget.isAi ? 60 : 0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: widget.isAi ? null : AppTokens.primaryGradient,
        color: widget.isAi ? AppColors.surface : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppTokens.radiusLg),
          topRight: const Radius.circular(AppTokens.radiusLg),
          bottomLeft: Radius.circular(widget.isAi ? 4 : AppTokens.radiusLg),
          bottomRight: Radius.circular(widget.isAi ? AppTokens.radiusLg : 4),
        ),
        boxShadow: AppTokens.shadowMd
            .map((e) => BoxShadow(
                  color: e.color.withOpacity(0.6),
                  offset: e.offset,
                  blurRadius: e.blurRadius,
                ))
            .toList(),
      ),
      child: Text(
        widget.content,
        style: TextStyle(
          color: widget.isAi ? AppColors.textPrimary : Colors.white,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.isAi ? AppTokens.primaryGradient : null,
        color: !widget.isAi ? AppColors.secondary : null,
      ),
      child: Center(
        child: Text(
          widget.isAi ? 'AI' : '我',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
      child: Row(
        children: [
          _FeedbackButton(
            icon: Icons.thumb_up,
            onPressed: widget.onThumbsUp,
          ),
          const SizedBox(width: 4),
          _FeedbackButton(
            icon: Icons.thumb_down,
            onPressed: widget.onThumbsDown,
          ),
        ],
      ),
    );
  }
}

/// 反馈按钮组件
class _FeedbackButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _FeedbackButton({
    required this.icon,
    this.onPressed,
  });

  @override
  State<_FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<_FeedbackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          widget.icon,
          size: 9.8,
          color: _isPressed ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// 打字机效果消息气泡
class TypingMessageBubble extends StatefulWidget {
  final String content;
  final bool isAi;
  final Duration duration;

  const TypingMessageBubble({
    super.key,
    required this.content,
    required this.isAi,
    this.duration = const Duration(milliseconds: 50),
  });

  @override
  State<TypingMessageBubble> createState() => _TypingMessageBubbleState();
}

class _TypingMessageBubbleState extends State<TypingMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _displayedText = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.content.length * widget.duration.inMilliseconds),
      vsync: this,
    );

    _controller.addListener(() {
      final newLength = (_controller.value * widget.content.length).floor();
      if (newLength != _displayedText.length) {
        setState(() {
          _displayedText = widget.content.substring(0, newLength);
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      content: _displayedText,
      isAi: widget.isAi,
    );
  }
}

/// AI 正在输入指示器
class TypingIndicator extends StatefulWidget {
  final Color? dotColor;

  const TypingIndicator({
    super.key,
    this.dotColor,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.dotColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final animation = Tween<double>(begin: 0.4, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(delay, delay + 0.3, curve: Curves.easeInOut),
                ),
              );

              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor.withOpacity(animation.value),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
