import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/config/keys.dart';
import '../../core/config/themes/colors.dart';
import '../../core/config/themes/styles.dart';
import '../../core/config/themes/themes.dart';
import '../../core/providers/loading_notifier.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utilities/animations.dart';
import '../../core/utilities/extensions/numbers.dart';
import '../../generated/assets.gen.dart';
import '../../generated/fonts.gen.dart';
import 'app_button.dart';

class AppWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper>
    with WidgetsBindingObserver {
  bool _showPrivacyOverlay = false;
  bool _isBiometricLocked = false;
  bool _isAuthenticating = false;

  final _scaleTween = Tween<double>(
    begin: 1.0,
    end: 1.2,
  ).chain(CurveTween(curve: Curves.easeInOutSine));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricGate(prompt: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(biometricServiceProvider).cancelAuthentication();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final biometricService = ref.read(biometricServiceProvider);
    if (biometricService.isAuthenticating) return;

    switch (state) {
      case AppLifecycleState.inactive:
        setState(() => _showPrivacyOverlay = true);
        break;

      case AppLifecycleState.resumed:
        setState(() => _showPrivacyOverlay = false);
        if (biometricService.consumeSkipNextResumePrompt()) {
          break;
        }
        _checkBiometricGate(prompt: true);
        break;

      default:
        break;
    }
  }

  Future<void> _checkBiometricGate({required bool prompt}) async {
    final shouldLock = await _shouldRequireBiometricUnlock();
    if (!mounted) return;

    if (!shouldLock) {
      if (_isBiometricLocked) {
        setState(() => _isBiometricLocked = false);
      }
      return;
    }

    if (!_isBiometricLocked) {
      setState(() => _isBiometricLocked = true);
    }

    if (prompt) {
      await _promptBiometricUnlock();
    }
  }

  Future<bool> _shouldRequireBiometricUnlock() async {
    final storage = ref.read(storageServiceProvider);
    final biometricsEnabled =
        storage.getDataFromDisk(AppKeys.biometricsEnabled) as bool? ?? false;
    if (!biometricsEnabled) return false;

    final refreshToken = await storage.getRefreshTokenFromDisk();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final biometricService = ref.read(biometricServiceProvider);
    return biometricService.isBiometricAvailable();
  }

  Future<void> _promptBiometricUnlock() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);
    final biometricService = ref.read(biometricServiceProvider);
    final unlocked = await biometricService.authenticate();
    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _isBiometricLocked = !unlocked;
    });
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

  Widget _buildBiometricLockOverlay() {
    final appColors = AppColors.of(context);
    final appStyles = context.appStyles;

    return Material(
      key: const ValueKey('biometric-lock'),
      color: appColors.surface,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.width),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(18.radius),
                  decoration: BoxDecoration(
                    color: appColors.primary.withAlpha(12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 48.width,
                    color: appColors.primary,
                  ),
                ),
                28.verticalSpacer,
                Text(
                  'ToroPass',
                  style: appStyles.sectionTitle.copyWith(
                    color: appColors.header,
                  ),
                  textAlign: TextAlign.center,
                ),
                15.verticalSpacer,
                Text(
                  'Use your biometrics to continue into your wallet securely.',
                  style: appStyles.body.copyWith(
                    color: appColors.text.withAlpha(190),
                  ),
                  textAlign: TextAlign.center,
                ),
                40.verticalSpacer,
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: _isAuthenticating ? 'Checking...' : 'Unlock',
                    callback: _isAuthenticating ? null : _promptBiometricUnlock,
                  ),
                ),
                20.verticalSpacer,
                Text(
                  'Biometric unlock is enabled for this device.',
                  style: appStyles.caption.copyWith(
                    color: appColors.text.withAlpha(150),
                    fontFamily: FontFamily.interRegular,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
              child: _isBiometricLocked
                  ? _buildBiometricLockOverlay()
                  : switch (loading || _showPrivacyOverlay) {
                      true => _buildOverlay(),
                      false => const SizedBox.shrink(
                        key: ValueKey('not-loading'),
                      ),
                    },
            ),
          ),
        ],
      ),
    );
  }
}
