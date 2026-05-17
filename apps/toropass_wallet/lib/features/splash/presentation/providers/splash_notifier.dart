import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/token/token_notifier.dart';

part 'splash_notifier.g.dart';

@riverpod
class SplashNotifier extends _$SplashNotifier {
  @override
  double build() => 0.0;

  Future<void> animateSplash() async {
    ref.read(tokenProvider.notifier).markReady(false);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!ref.mounted) return;
    state = 1.0;
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!ref.mounted) return;
    await ref.read(tokenProvider.future);

    if (!ref.mounted) return;
    ref.read(tokenProvider.notifier).markReady(true);
  }
}
