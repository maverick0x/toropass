import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/network/token/token_notifier.dart';
import '../../../../core/utilities/animations.dart';
import '../../../../core/utilities/global.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../shared/app_icon.dart';
import '../providers/splash_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tokenProvider.notifier).clearTokens();
      ref.read(splashProvider.notifier).animateSplash();
      Global.precacheAssets(context, Assets.icons.values);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final opacity = ref.watch(splashProvider);

    return Scaffold(
      backgroundColor: appColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            RepaintBoundary(
              child: AnimatedSlide(
                offset: opacity == 0 ? const Offset(0.5, 0) : Offset.zero,
                duration: Animations.duration,
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Animations.duration,
                  curve: Curves.easeIn,
                  child: AppIcon(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
