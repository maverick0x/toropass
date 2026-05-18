import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/network/token/token_notifier.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_icon.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';
import '../shared/identity_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: .max,
          crossAxisAlignment: .center,
          children: [
            15.verticalSpacer,
            Row(
              mainAxisSize: .max,
              crossAxisAlignment: .center,
              children: [
                20.horizontalSpacer,
                AppIcon(width: 40.width, height: 40.height),
                5.horizontalSpacer,
                Text(
                  'Settings',
                  style: appStyles.sectionTitle.copyWith(
                    color: appColors.primary,
                  ),
                ),
                const Spacer(),
                AppInkWell(
                  callback: () => context.pop(),
                  child: Icon(
                    Icons.close,
                    size: 30.width,
                    color: appColors.primary,
                  ),
                ),
                20.horizontalSpacer,
              ],
            ),
            30.verticalSpacer,
            IdentityCard(),
            _buildSettingsCard(),
            _buildLogout(),
            const Spacer(),
            Text(
              "v1.0.0 (Build 42)",
              style: appStyles.body.copyWith(
                color: appColors.text.withAlpha(100),
              ),
            ),
            30.verticalSpacer,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    final appColors = AppColors.of(context);

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
          _settingsMenu(
            name: "Security",
            iconPath: Assets.icons.lock,
            description: "Biometrics, and other settings",
            callback: () => {},
          ),
          Divider(
            color: appColors.primary.withAlpha(60),
            thickness: 1.height,
            height: 40.height,
          ),
          _settingsMenu(
            name: "Backup",
            iconPath: Assets.icons.key,
            description: "Backup your private keys",
            callback: () => {},
          ),
          Divider(
            color: appColors.primary.withAlpha(60),
            thickness: 1.height,
            height: 40.height,
          ),
          _settingsMenu(
            name: "Support",
            iconPath: Assets.icons.helpCircle,
            description: "Get help and support",
            callback: () => {},
          ),
        ],
      ),
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

    return Row(
      mainAxisSize: .max,
      crossAxisAlignment: .center,
      children: [
        Container(
          padding: EdgeInsets.all(10.radius),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appColors.surfaceContainer,
          ),
          child: AppSvg(width: 24.width, height: 24.height, path: iconPath),
        ),
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
        20.horizontalSpacer,
        AppSvg(
          width: 16.width,
          height: 16.height,
          color: appColors.primary,
          path: Assets.icons.downArrow,
        ),
      ],
    );
  }

  Widget _buildLogout() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return AppInkWell(
      callback: () => ref.read(loadingProvider.notifier).wrap(() async {
        await Future.delayed(const Duration(seconds: 3));
        ref.read(tokenProvider.notifier).clearTokens();
      }),
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
}
