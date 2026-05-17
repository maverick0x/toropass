import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = NotifierProvider<Loading, bool>(Loading.new);

class Loading extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;

  // Useful for wrapping futures directly
  Future<T> wrap<T>(Future<T> Function() action) async {
    show();
    try {
      return await action();
    } finally {
      hide();
    }
  }
}
