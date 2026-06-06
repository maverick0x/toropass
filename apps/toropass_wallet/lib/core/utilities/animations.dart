import 'package:flutter/material.dart';

class Animations {
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration duration = Duration(milliseconds: 500);

  static Widget textTransition(Widget child, Animation<double> animation) {
    final isExiting = animation.status == AnimationStatus.reverse;
    final offsetTween = isExiting
        ? Tween<Offset>(begin: Offset.zero, end: const Offset(-0.12, 0))
        : Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: offsetTween.animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: child,
      ),
    );
  }

  static Widget widgetTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.5),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  static Widget iconTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
        child: child,
      ),
    );
  }
}
