import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/routes.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/network/token/token_notifier.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/providers/package_info_provider.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/confirmation_dialog.dart';
import '../../../../shared/identity_card.dart';
import '../provider/settings_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsProvider.notifier).loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);
    final packageInfo = ref.watch(packageInfoProvider);
    final versionLabel = packageInfo.when(
      data: (info) => 'v${info.version} (Build ${info.buildNumber})',
      loading: () => 'Loading version...',
      error: (_, _) => 'Version unavailable',
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .center,
            children: [
              TopBar(title: 'Settings'),
              20.verticalSpacer,
              IdentityCard(),
              _buildSettingsCard(),
              _buildLogout(),
              const Spacer(),
              GestureDetector(
                onTap: _openDeveloperScreen,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.height),
                  child: Text(
                    versionLabel,
                    style: appStyles.body.copyWith(
                      color: appColors.text.withAlpha(100),
                    ),
                  ),
                ),
              ),
              30.verticalSpacer,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    final appColors = AppColors.of(context);
    final appStyles = context.appStyles;
    final settingsState = ref.watch(settingsProvider);
    final biometricsAvailable = settingsState.biometricsAvailable;
    final biometricsEnabled =
        biometricsAvailable && settingsState.biometricsEnabled;
    final biometricLabel = settingsState.biometricLabel;
    final biometricsDescription = biometricsAvailable
        ? 'Use $biometricLabel to unlock ToroPass faster.'
        : 'Biometrics is not available on this device.';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
      ).add(EdgeInsets.only(top: 30.height)),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
        vertical: 20.height,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withAlpha(10),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMenuIcon(Assets.icons.lock),
              15.horizontalSpacer,
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Biometrics',
                      style: appStyles.body.copyWith(
                        color: appColors.text,
                        fontFamily: FontFamily.interSemiBold,
                      ),
                    ),
                    Text(
                      biometricsDescription,
                      style: appStyles.caption.copyWith(
                        color: appColors.text.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
              12.horizontalSpacer,
              Switch.adaptive(
                value: biometricsEnabled,
                activeThumbColor: appColors.primary,
                activeTrackColor: appColors.primary.withAlpha(90),
                onChanged: biometricsAvailable
                    ? (value) => ref
                          .read(settingsProvider.notifier)
                          .toggleBiometrics(value)
                    : null,
              ),
            ],
          ),
          Divider(
            color: appColors.black.withAlpha(60),
            thickness: 1.height,
            height: 40.height,
          ),
          _settingsMenu(
            name: "Change Password",
            iconPath: Assets.icons.key,
            description: "Update the password for your Toronet wallet",
            callback: () => context.pushNamed(AppRoutes.CHANGE_PASSWORD_SCREEN),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(String iconPath) {
    final appColors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.all(10.radius),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appColors.surfaceContainer,
      ),
      child: AppSvg(width: 24.width, height: 24.height, path: iconPath),
    );
  }

  Widget _settingsMenu({
    required String name,
    required String iconPath,
    required String description,
    required VoidCallback callback,
  }) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return AppInkWell(
      callback: callback,
      child: Row(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          _buildMenuIcon(iconPath),
          15.horizontalSpacer,
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  name,
                  style: appStyles.body.copyWith(
                    color: appColors.text,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                  textAlign: TextAlign.start,
                ),
                Text(
                  description,
                  style: appStyles.caption.copyWith(
                    color: appColors.text.withAlpha(150),
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogout() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return AppInkWell(
      callback: _confirmLogout,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
          horizontal: AppDimens.horizontalPadding,
        ).add(EdgeInsets.only(top: 50.height)),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.horizontalPadding,
          vertical: 10.height,
        ),
        decoration: BoxDecoration(
          color: appColors.error,
          borderRadius: BorderRadius.circular(AppDimens.dialogBorderRadius),
        ),
        child: Text(
          "LOG OUT",
          style: appStyles.body.copyWith(
            color: appColors.white,
            fontFamily: FontFamily.interSemiBold,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Log Out?',
      message:
          'You will be signed out of your ToroPass wallet on this device. You can sign in again anytime with your credentials.',
      confirmText: 'LOG OUT',
      destructive: true,
    );

    if (!confirmed) return;

    await ref.read(loadingProvider.notifier).wrap(() async {
      await ref.read(tokenProvider.notifier).clearTokens();
    });
  }

  void _openDeveloperScreen() {
    setState(() {
      _tapCount++;
      if (_tapCount > 4) _tapCount = 0;
    });

    if (_tapCount >= 4) {
      context.pushNamed(AppRoutes.DEVELOPER_SCREEN);
    }
  }
}
