import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/router/observer.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_svg.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(observerProvider).popToRoot(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .center,
            children: [
              TopBar(title: "ToroPass"),
              const Spacer(),
              Align(
                child: Container(
                  padding: EdgeInsets.all(15.radius),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: appColors.shadow.withAlpha(20),
                        blurRadius: 30,
                        spreadRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(15.radius),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [appColors.tertiary, appColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: appColors.surface,
                      size: 60.radius,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.horizontalPadding,
                ),
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .center,
                  children: [
                    Text("Identity Verified!", style: appStyles.pageTitle),
                    15.verticalSpacer,
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Your ",
                        style: appStyles.body.copyWith(height: 1.5),
                        children: [
                          TextSpan(
                            text: ".toro",
                            style: appStyles.body.copyWith(
                              color: appColors.primary,
                              fontFamily: FontFamily.plusJakartaSansMedium,
                            ),
                          ),
                          TextSpan(
                            text:
                                " identity is now fully verified. You've unlocked all "
                                "network features and secure access to partner apps.",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppDimens.horizontalPadding,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 20.height,
                  horizontal: AppDimens.horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius: BorderRadius.circular(10.radius),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.shadow.withAlpha(20),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: .max,
                  crossAxisAlignment: .center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.radius),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [appColors.tertiary, appColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: appColors.shadow.withAlpha(20),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        Assets.images.toroPass.path,
                        width: 40.width,
                        height: 40.height,
                        color: appColors.white,
                      ),
                    ),
                    20.horizontalSpacer,
                    Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          mainAxisSize: .min,
                          crossAxisAlignment: .center,
                          children: [
                            Text("alexander.toro", style: appStyles.cardTitle),
                            10.horizontalSpacer,
                            AppSvg(
                              path: Assets.icons.verified,
                              width: 16.width,
                              height: 16.height,
                              color: appColors.primary,
                            ),
                          ],
                        ),
                        10.verticalSpacer,
                        Row(
                          mainAxisSize: .min,
                          crossAxisAlignment: .center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5.radius),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appColors.success.withAlpha(35),
                              ),
                              child: Container(
                                width: 10.width,
                                height: 10.height,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: appColors.success,
                                ),
                              ),
                            ),
                            10.horizontalSpacer,
                            Text(
                              "Active DID",
                              style: appStyles.caption.copyWith(
                                fontFamily: FontFamily.interSemiBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.horizontalPadding,
                ),
                child: AppButton(
                  text: "Back to Dashboard",
                  callback: () => ref.read(observerProvider).popToRoot(context),
                ),
              ),
              20.verticalSpacer,
            ],
          ),
        ),
      ),
    );
  }
}
