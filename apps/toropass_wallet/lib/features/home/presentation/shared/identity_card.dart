import 'package:flutter/material.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../shared/app_svg.dart';

class IdentityCard extends StatelessWidget {
  const IdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Hero(
      tag: "IDENTITY-CARD",
      child: Material(
        color: appColors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
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
                    child: Text(
                      "alexander.toro",
                      style: appStyles.sectionTitle,
                    ),
                  ),
                  10.horizontalSpacer,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.width,
                      vertical: 2.height,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: appColors.error.withAlpha(60)),
                      color: appColors.error.withAlpha(15),
                      borderRadius: BorderRadius.circular(AppDimens.miniRadius),
                    ),
                    child: Text(
                      "UNVERIFIED",
                      style: appStyles.caption.copyWith(
                        color: appColors.error.withAlpha(150),
                      ),
                    ),
                  ),
                ],
              ),
              5.verticalSpacer,
              Text(
                "0xfg3kddsdnwdwkd9...f2a1",
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
                          "Testnet",
                          style: appStyles.body.copyWith(
                            color: appColors.text.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.horizontalSpacer,
                  AppSvg(
                    path: Assets.icons.universal,
                    width: 50.width,
                    height: 50.height,
                    color: appColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
