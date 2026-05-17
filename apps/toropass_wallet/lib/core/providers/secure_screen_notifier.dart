import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

final secureScreenProvider = NotifierProvider<SecureScreenNotifier, bool>(
  SecureScreenNotifier.new,
);

class SecureScreenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> enable() async {
    if (!state) {
      await ScreenProtector.preventScreenshotOn();
      state = true;
    }
  }

  Future<void> disable() async {
    if (state) {
      await ScreenProtector.preventScreenshotOff();
      state = false;
    }
  }
}

/// USAGE
/// In the widget where you want to enable secure screen, use the following code:
// @override
// void initState() {
//   super.initState();
//   // Enable FLAG_SECURE
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     ref.read(secureScreenProvider.notifier).enable();
//   });
// }

// @override
// void dispose() {
//   // Clear FLAG_SECURE
//   ref.read(secureScreenProvider.notifier).disable();
//   super.dispose();
// }
