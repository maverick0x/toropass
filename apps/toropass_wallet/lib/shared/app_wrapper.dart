import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/config/themes/colors.dart';
import '../../core/config/themes/themes.dart';
import '../../core/providers/loading_notifier.dart';
import '../../core/utilities/animations.dart';
import '../../core/utilities/extensions/numbers.dart';
import '../../generated/assets.gen.dart';

class AppWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper>
    with WidgetsBindingObserver {
  bool _showPrivacyOverlay = false;

  final _scaleTween = Tween<double>(
    begin: 1.0,
    end: 1.2,
  ).chain(CurveTween(curve: Curves.easeInOutSine));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        if (kDebugMode) return;
        setState(() => _showPrivacyOverlay = true);
        break;

      case AppLifecycleState.resumed:
        if (kDebugMode) return;
        setState(() => _showPrivacyOverlay = false);
        break;

      default:
        break;
    }
  }

  Widget _buildOverlay() {
    final appColors = AppColors.of(context);

    return Container(
      key: ValueKey('loading'),
      width: double.infinity,
      height: double.infinity,
      color: appColors.black.withAlpha(150),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const SizedBox.shrink(),
            ),
          ),
          if (!_showPrivacyOverlay)
            Center(
              child: RepeatingAnimationBuilder(
                duration: Duration(milliseconds: 1000),
                repeatMode: RepeatMode.reverse,
                animatable: Tween<double>(begin: 0.0, end: 1.0),
                child: Shimmer.fromColors(
                  period: const Duration(milliseconds: 1500),
                  baseColor: appColors.white,
                  highlightColor: appColors.primary,
                  child: Image.asset(
                    Assets.images.toroPass.path,
                    width: 150.width,
                    height: 150.width,
                    fit: BoxFit.cover,
                  ),
                ),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: _scaleTween.transform(value),
                    child: child,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final bool isDarkMode = context.isDarkMode;

    final loading = ref.watch(loadingProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: appColors.transparent,
        systemNavigationBarColor: appColors.transparent,
        systemNavigationBarDividerColor: appColors.transparent,

        // Android: Light icons for dark mode, dark icons for light mode
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,

        // iOS: Opposite naming convention
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Stack(
        children: [
          widget.child,

          // Overlay for loading state or privacy when app is backgrounded
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: Animations.duration,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                // final slideAnimation = Tween<Offset>(
                //   begin: const Offset(1.0, 0.0),
                //   end: Offset.zero,
                // ).animate(animation);
                return FadeTransition(opacity: animation, child: child);
              },
              child: switch (loading || _showPrivacyOverlay) {
                true => _buildOverlay(),
                false => const SizedBox.shrink(key: ValueKey('not-loading')),
              },
            ),
          ),
        ],
      ),
    );
  }
}
