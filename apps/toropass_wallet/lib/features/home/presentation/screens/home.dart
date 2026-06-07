import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/router/routes.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/animations.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/identity_card.dart';
import '../../domain/entities/profile_entity.dart';
import '../provider/user_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletState = ref.read(userProvider).walletState;
      if (walletState is DataSuccess || walletState is DataLoading) return;
      ref.read(userProvider.notifier).getWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final walletState = ref.watch(userProvider.select((s) => s.walletState));
    final consentState = ref.watch(userProvider.select((s) => s.consentState));
    final profile = walletState is DataSuccess ? walletState.data : null;
    final consentCount = consentState.data?.length ?? 0;
    final showSkeleton =
        walletState is DataLoading ||
        walletState is DataFailed ||
        consentState is DataLoading ||
        consentState is DataFailed;
    final showRefresh = walletState is DataFailed || consentState is DataFailed;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .center,
            children: [
              TopBar(
                title: 'ToroPass',
                action: AppInkWell(
                  callback: () => context.pushNamed(AppRoutes.SETTINGS_SCREEN),
                  child: Container(
                    padding: EdgeInsets.only(left: 50.width),
                    child: AppSvg(
                      path: Assets.icons.settings,
                      width: 24.width,
                      height: 24.height,
                      color: appColors.primary,
                    ),
                  ),
                ),
              ),
              10.verticalSpacer,
              Expanded(
                child: SingleChildScrollView(
                  child: Skeletonizer(
                    enabled: showSkeleton,
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .center,
                      children: [
                        15.verticalSpacer,
                        _buildRefresh(showRefresh),
                        IdentityCard(),
                        _secureAction(profile),
                        _buildVerificationLevel(profile),
                        _buildConnectionCard(consentCount),
                        30.verticalSpacer,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefresh(bool showRefresh) {
    final appColors = AppColors.of(context);

    return AnimatedSize(
      duration: Animations.shortDuration,
      child: Visibility(
        visible: showRefresh,
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.height,
              bottom: 10.height,
              right: AppDimens.horizontalPadding,
            ),
            child: AppInkWell(
              callback: ref.read(userProvider.notifier).refreshHomeData,
              child: Container(
                padding: EdgeInsets.all(10.radius),
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
                child: Icon(
                  Icons.refresh_rounded,
                  size: 22.width,
                  color: appColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secureAction(ProfileEntity? profile) {
    final appStyles = context.appStyles;
    final isVerified = profile?.kycVerified == true;
    final anchorHash = profile?.kycAnchorHash;
    final title = isVerified ? "Identity Verified" : "Secure Your Identity";
    final description = isVerified
        ? "Your Toro identity is verified and ready for partner app access."
        : "Complete your verification to unlock full network features and secure your .toro domain.";
    final buttonText = isVerified
        ? "View Verification Status"
        : "Complete Verification";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [
          30.verticalSpacer,
          Text(
            title,
            style: appStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          20.verticalSpacer,
          Text(description, style: appStyles.body, textAlign: TextAlign.center),
          if (isVerified && anchorHash != null && anchorHash.isNotEmpty) ...[
            15.verticalSpacer,
            Text(
              "Anchor Hash: ${_formatAnchorHash(anchorHash)}",
              style: appStyles.caption.copyWith(
                color: AppColors.of(context).text.withAlpha(170),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          AnimatedSize(
            duration: Animations.shortDuration,
            child: Visibility(
              visible: !isVerified,
              child: Column(
                children: [
                  20.verticalSpacer,
                  AppButton(
                    text: buttonText,
                    callback: () =>
                        context.pushNamed(AppRoutes.VERIFICATION_SCREEN),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAnchorHash(String value) {
    if (value.length <= 18) return value;
    return "${value.substring(0, 10)}...${value.substring(value.length - 8)}";
  }

  Widget _buildVerificationLevel(ProfileEntity? profile) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);
    final isVerified = profile?.kycVerified == true;
    final level = isVerified ? "Verified" : "Basic";
    final helperText = isVerified
        ? "Your identity is fully verified and partner-ready."
        : "Verification is pending. Complete KYC to reach full privacy coverage.";
    final progress = isVerified ? 1.0 : 0.5;

    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
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
            level,
            style: appStyles.cardTitle.copyWith(
              color: appColors.text,
              fontFamily: FontFamily.interSemiBold,
            ),
          ),
          5.verticalSpacer,
          Text(
            "Verification Level",
            style: appStyles.captionBold.copyWith(
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
                  width: constraints.maxWidth * progress,
                  height: 7.height,
                  decoration: BoxDecoration(
                    color: appColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.miniRadius),
                  ),
                );
              },
            ),
          ),
          10.verticalSpacer,
          Text(
            helperText,
            style: appStyles.caption.copyWith(
              color: appColors.text.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(int consentCount) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return AppInkWell(
      callback: () => context.pushNamed(AppRoutes.CONNECTION_SCREEN),
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
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
              consentCount.toString(),
              style: appStyles.cardTitle.copyWith(
                color: appColors.text,
                fontFamily: FontFamily.interSemiBold,
              ),
            ),
            5.verticalSpacer,
            Text(
              "Connected Apps",
              style: appStyles.captionBold.copyWith(
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
      ),
    );
  }
}
