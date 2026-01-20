import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// iOS 风格页面转场动画
class TechPageTransitions {
  /// iOS 风格滑动转场（从右侧滑入）
  static PageRouteBuilder<T> iosSlide<T>({
    required WidgetBuilder builder,
    bool isFullscreen = false,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => builder(context),
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      fullscreenDialog: isFullscreen,
      transitionsBuilder: (context, animation, _, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// 渐变缩放转场
  static PageRouteBuilder<T> fadeScale<T>({
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => builder(context),
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppTokens.curveSpring,
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppTokens.curveSpring,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// 淡入淡出转场
  static PageRouteBuilder<T> fade<T>({
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => builder(context),
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// 从底部滑入转场（模态页面）
  static PageRouteBuilder<T> bottomUp<T>({
    required WidgetBuilder builder,
    bool isFullscreen = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => builder(context),
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      fullscreenDialog: isFullscreen,
      opaque: false,
      transitionsBuilder: (context, animation, _, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        );
      },
    );
  }

  /// Hero 包装工具
  static Widget heroWrapper({
    required String tag,
    required Widget child,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// 自定义页面转场路由
class TechPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final TechTransitionType transitionType;

  TechPageRoute({
    required this.child,
    this.transitionType = TechTransitionType.iosSlide,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    switch (transitionType) {
      case TechTransitionType.iosSlide:
        final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0),
              ),
            ),
            child: child,
          ),
        );
      case TechTransitionType.fadeScale:
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: AppTokens.curveSpring),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: AppTokens.curveSpring),
            ),
            child: child,
          ),
        );
      case TechTransitionType.fade:
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        );
    }
  }
}

/// 页面转场类型枚举
enum TechTransitionType {
  iosSlide,
  fadeScale,
  fade,
}
