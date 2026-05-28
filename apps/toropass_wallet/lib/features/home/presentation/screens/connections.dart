import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/scope_chip.dart';
import '../../domain/entities/scope_entity.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    final List<Widget> children = [
      20.verticalSpacer,
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.width),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Text("Active Connections", style: appStyles.cardTitle),
            5.verticalSpacer,
            Text(
              "Manage who has access to your verified status.",
              style: appStyles.caption.copyWith(
                color: appColors.text.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
      15.verticalSpacer,
      _buildConnectedApp(
        name: "ToroRealEstate",
        connectionDate: "Connected Oct 24, 2024",
        scopes: [
          ScopeEntity(
            name: "KYC Status",
            icon: Assets.icons.checkmarkOutlined,
            color: appColors.success,
          ),
          ScopeEntity(
            name: ".toro Name",
            icon: Assets.icons.idCard,
            color: appColors.primary,
          ),
        ],
      ),
      _buildConnectedApp(
        name: "ToroDeFi",
        connectionDate: "Connected Sep 12, 2024",
        scopes: [
          ScopeEntity(
            name: "KYC Status",
            icon: Assets.icons.checkmarkOutlined,
            color: appColors.success,
          ),
          ScopeEntity(
            name: "Address",
            icon: Assets.icons.idCard,
            color: appColors.secondary,
          ),
        ],
      ),
      _buildConnectedApp(
        name: "ToroMarket",
        connectionDate: "Connected Aug 05, 2024",
        scopes: [
          ScopeEntity(
            name: ".toro Name",
            icon: Assets.icons.checkmarkOutlined,
            color: appColors.primary,
          ),
        ],
      ),
      _buildConnectedApp(
        name: "ToroGames",
        connectionDate: "Connected Aug 05, 2024",
        scopes: [
          ScopeEntity(
            name: "Wallet Address",
            icon: Assets.icons.checkmarkOutlined,
            color: appColors.secondary,
          ),
        ],
      ),
      30.verticalSpacer,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              TopBar(title: "Connections"),
              Expanded(
                child: ListView.builder(
                  itemCount: children.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => children[index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedApp({
    required String name,
    required String connectionDate,
    required List<ScopeEntity> scopes,
  }) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
      ).add(EdgeInsetsGeometry.only(top: 15.height)),
      padding: EdgeInsets.symmetric(
        vertical: 20.height,
        horizontal: AppDimens.horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        border: Border.all(color: appColors.primary.withAlpha(30)),
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
            crossAxisAlignment: .start,
            children: [
              Container(
                padding: EdgeInsets.all(10.radius),
                decoration: BoxDecoration(
                  color: appColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppDimens.borderRadius),
                ),
                child: AppSvg(
                  width: 40.width,
                  height: 40.height,
                  color: appColors.secondary,
                  path: Assets.icons.marketplace,
                ),
              ),
              15.horizontalSpacer,
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(name, style: appStyles.cardTitle),
                    3.verticalSpacer,
                    Text(
                      connectionDate,
                      style: appStyles.caption.copyWith(
                        color: appColors.text.withAlpha(180),
                      ),
                    ),
                    10.verticalSpacer,
                    Text.rich(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      TextSpan(
                        children: scopes.map((scope) {
                          return WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 8.width,
                                bottom: 8.height,
                              ),
                              child: ScopeChip(
                                text: scope.name,
                                icon: scope.icon,
                                color: scope.color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.verticalSpacer,
          _buildRevokeAccess(),
        ],
      ),
    );
  }

  Widget _buildRevokeAccess() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return AppInkWell(
      callback: () {
        // TODO: Add Revoke Confirmation Dialog
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.horizontalPadding,
          vertical: 10.height,
        ),
        decoration: BoxDecoration(
          color: appColors.error.withAlpha(15),
          border: Border.all(width: 0.8, color: appColors.error.withAlpha(100)),
          borderRadius: BorderRadius.circular(25.radius),
        ),
        child: Text(
          "Revoke Access",
          style: appStyles.body.copyWith(
            color: appColors.error,
            fontFamily: FontFamily.interMedium,
          ),
        ),
      ),
    );
  }
}
