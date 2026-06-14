import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../core/config/resource/data_state.dart';
import '../core/config/themes/colors.dart';
import '../core/config/themes/dimens.dart';
import '../core/config/themes/styles.dart';
import '../core/utilities/extensions/numbers.dart';
import '../features/home/domain/entities/profile_entity.dart';
import '../features/home/presentation/provider/user_notifier.dart';
import '../generated/assets.gen.dart';
import 'app_inkwell.dart';
import 'app_svg.dart';

class IdentityCard extends ConsumerWidget {
  const IdentityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);
    final walletState = ref.watch(userProvider.select((s) => s.walletState));
    final profile = walletState is DataSuccess ? walletState.data : null;

    final displayName = profile?.wallet?.tnsName?.isNotEmpty == true
        ? '${profile!.wallet!.tnsName}.toro'
        : 'ToroPass Identity';
    final isVerified = profile?.kycVerified == true;
    final verifiedColor = isVerified ? appColors.primary : appColors.error;
    final walletAddress = _formatWalletAddress(profile);
    final network = _formatNetwork(profile?.wallet?.network);
    final showSkeleton =
        walletState is DataLoading || walletState is DataFailed;
    final showRefresh = walletState is DataFailed;

    return Hero(
      tag: "IDENTITY-CARD",
      child: Material(
        color: appColors.transparent,
        child: Skeletonizer(
          enabled: showSkeleton,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppDimens.horizontalPadding,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.horizontalPadding,
              vertical: 20.height,
            ),
            decoration: BoxDecoration(
              color: appColors.white,
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
                Row(
                  mainAxisSize: .max,
                  crossAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: Text(displayName, style: appStyles.sectionTitle),
                    ),
                    10.horizontalSpacer,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.width,
                        vertical: 2.height,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: verifiedColor.withAlpha(60)),
                        color: verifiedColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(
                          AppDimens.miniRadius,
                        ),
                      ),
                      child: Text(
                        isVerified ? "VERIFIED" : "UNVERIFIED",
                        style: appStyles.caption.copyWith(
                          color: verifiedColor.withAlpha(160),
                        ),
                      ),
                    ),
                  ],
                ),
                5.verticalSpacer,
                Text(
                  walletAddress,
                  style: appStyles.body.copyWith(
                    color: appColors.text.withAlpha(150),
                  ),
                ),
                20.verticalSpacer,
                Row(
                  mainAxisSize: .max,
                  crossAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            "NETWORK",
                            style: appStyles.caption.copyWith(
                              color: appColors.text.withAlpha(80),
                            ),
                          ),
                          5.verticalSpacer,
                          Text(
                            network,
                            style: appStyles.body.copyWith(
                              color: appColors.text.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.horizontalSpacer,
                    AppInkWell(
                      callback: showRefresh
                          ? ref.read(userProvider.notifier).getWallet
                          : null,
                      child: AppSvg(
                        path: showRefresh
                            ? Assets.icons.refresh
                            : Assets.icons.universal,
                        width: 50.width,
                        height: 50.height,
                        color: appColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatWalletAddress(ProfileEntity? profile) {
    final address = profile?.wallet?.address;
    if (address == null || address.isEmpty) {
      return "Wallet address unavailable";
    }
    if (address.length <= 16) return address;
    return "${address.substring(0, 10)}...${address.substring(address.length - 6)}";
  }

  String _formatNetwork(String? network) {
    if (network == null || network.isEmpty) return "Unknown";
    final normalized = network.trim().toLowerCase();
    return "${normalized[0].toUpperCase()}${normalized.substring(1)}";
  }
}
