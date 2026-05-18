import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/config/themes/colors.dart';
import '../../core/config/themes/styles.dart';
import '../../core/config/themes/themes.dart';
import '../../core/providers/loading_notifier.dart';
import '../../core/services/storage_service.dart';
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
  bool _isCompromised = false;
  bool _showPrivacyOverlay = false;

  final _scaleTween = Tween<double>(
    begin: 1.0,
    end: 1.2,
  ).chain(CurveTween(curve: Curves.easeInOutSine));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    try {
      final isJailbroken = await FlutterJailbreakDetection.jailbroken;
      if (!isJailbroken) return;
      ref.read(storageServiceProvider).clearAllDataFromDisk();
      setState(() => _isCompromised = true);
    } catch (_) {}
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
        _checkSecurity();
        break;

      default:
        break;
    }
  }

  Widget _buildCompromisedWidget() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .center,
            children: [
              Icon(
                Icons.security_update_warning,
                size: 128.radius,
                color: appColors.error,
              ),
              64.verticalSpacer,
              Text(
                'Security Risk Detected',
                style: appStyles.sectionTitle.copyWith(color: appColors.error),
                textAlign: TextAlign.center,
              ),
              32.verticalSpacer,
              Text(
                'This device appears to be compromised',
                style: appStyles.cardTitle.copyWith(color: appColors.error),
                textAlign: TextAlign.center,
              ),
              12.verticalSpacer,
              Text(
                'For your security, the application has blocked access until the issue is resolved.',
                style: appStyles.body.copyWith(
                  color: appColors.neutral.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
          // Main app content or compromised warning based on security status
          switch (_isCompromised) {
            true => _buildCompromisedWidget(),
            false => widget.child,
          },

          // Overlay for loading state or privacy when app is backgrounded
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: Animations.duration,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
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
