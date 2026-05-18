import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/routes.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/animations.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_icon.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';
import '../shared/identity_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

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
                  'ToroPass',
                  style: appStyles.sectionTitle.copyWith(
                    color: appColors.primary,
                  ),
                ),
                const Spacer(),
                AppInkWell(
                  callback: () => context.pushNamed(AppRoutes.SETTINGS_SCREEN),
                  child: AppSvg(
                    path: Assets.icons.settings,
                    width: 30.width,
                    height: 30.height,
                    color: appColors.primary,
                  ),
                ),
                20.horizontalSpacer,
              ],
            ),
            30.verticalSpacer,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .center,
                  children: [
                    IdentityCard(),
                    _buildVerificationAction(),
                    _buildPrivacyCard(),
                    _buildConnectionCard(),
                    30.verticalSpacer,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationAction() {
    final appStyles = context.appStyles;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [
          30.verticalSpacer,
          Text(
            "Secure Your Identity",
            style: appStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          20.verticalSpacer,
          Text(
            "Complete your verification to unlock full network features and secure your .toro domain.",
            style: appStyles.body,
            textAlign: TextAlign.center,
          ),
          20.verticalSpacer,
          AppButton(text: "Complete Verification", callback: () {}),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
      ).add(EdgeInsetsGeometry.only(top: 20.height)),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
        vertical: 20.height,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        border: Border.all(color: appColors.primary.withAlpha(60)),
        borderRadius: BorderRadius.circular(AppDimens.dialogBorderRadius),
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
          Container(
            padding: EdgeInsets.all(10.radius),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appColors.surfaceContainer,
            ),
            child: AppSvg(
              path: Assets.icons.privacy,
              width: 24.width,
              height: 24.height,
              color: appColors.primary,
            ),
          ),
          10.verticalSpacer,
          Text(
            "Privacy Level",
            style: appStyles.captionBold.copyWith(
              color: appColors.text,
              fontFamily: FontFamily.interSemiBold,
            ),
          ),
          5.verticalSpacer,
          Text(
            "Basic",
            style: appStyles.cardTitle.copyWith(
              color: appColors.text,
              fontFamily: FontFamily.interSemiBold,
            ),
          ),
          10.verticalSpacer,
          Container(
            width: double.infinity,
            height: 7.height,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: appColors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(AppDimens.miniRadius),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: Animations.shortDuration,
                  width: constraints.maxWidth * 0.35,
                  height: 7.height,
                  decoration: BoxDecoration(
                    color: appColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.miniRadius),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
      ).add(EdgeInsetsGeometry.only(top: 20.height)),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
        vertical: 20.height,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        border: Border.all(color: appColors.primary.withAlpha(60)),
        borderRadius: BorderRadius.circular(AppDimens.dialogBorderRadius),
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
          Container(
            padding: EdgeInsets.all(10.radius),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appColors.surfaceContainer,
            ),
            child: AppSvg(
              path: Assets.icons.connection,
              width: 24.width,
              height: 24.height,
              color: appColors.primary,
            ),
          ),
          10.verticalSpacer,
          Text(
            "Connected Apps",
            style: appStyles.captionBold.copyWith(
              color: appColors.text,
              fontFamily: FontFamily.interSemiBold,
            ),
          ),
          5.verticalSpacer,
          Text(
            "5",
            style: appStyles.cardTitle.copyWith(
              color: appColors.text,
              fontFamily: FontFamily.interSemiBold,
            ),
          ),
          10.verticalSpacer,
          Text(
            "You can manage permissions and revoke access at any time.",
            style: appStyles.captionBold.copyWith(
              color: appColors.text.withAlpha(150),
              fontFamily: FontFamily.interSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
