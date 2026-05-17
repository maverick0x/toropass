import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final keyboardProvider = NotifierProvider<KeyboardNotifier, bool>(() {
  return KeyboardNotifier();
});

class KeyboardNotifier extends Notifier<bool> with WidgetsBindingObserver {
  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return false;
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;

    final isVisible = bottomInset > 0;

    if (state != isVisible) {
      state = isVisible;
    }
  }
}
