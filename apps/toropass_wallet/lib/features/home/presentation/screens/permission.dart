import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_svg.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .start,
            children: [
              TopBar(title: "Permissions"),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                    horizontal: AppDimens.horizontalPadding,
                  ).add(EdgeInsets.only(top: 50.height, bottom: 20.height)),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.horizontalPadding,
                    vertical: 20.height,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimens.dialogBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.shadow.withAlpha(10),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: .max,
                    crossAxisAlignment: .center,
                    children: [
                      15.verticalSpacer,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.width,
                          vertical: 8.height,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            AppDimens.borderRadius,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.width,
                            vertical: 6.height,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadius,
                            ),
                          ),
                          child: AppSvg(
                            path: Assets.icons.marketplace,
                            width: 28.width,
                            height: 28.height,
                            color: appColors.primary,
                          ),
                        ),
                      ),
                      20.verticalSpacer,
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: appStyles.cardTitle.copyWith(height: 1.5),
                          children: [
                            TextSpan(
                              text: "Marketplace",
                              style: TextStyle(
                                fontFamily: FontFamily.interBold,
                              ),
                            ),
                            TextSpan(text: " wants to verify\nyour identity"),
                          ],
                        ),
                      ),
                      10.verticalSpacer,
                      Text(
                        "Please review the information they are requesting access to.",
                        textAlign: TextAlign.center,
                        style: appStyles.body.copyWith(
                          color: appColors.text.withAlpha(150),
                        ),
                      ),
                      15.verticalSpacer,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.width,
                        ).add(EdgeInsets.only(bottom: 15.height)),
                        decoration: BoxDecoration(
                          color: appColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppDimens.borderRadius,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: [
                            _buildAccessItem(
                              success: true,
                              title: "Verification Status",
                              description:
                                  "They will know you are a verified user.",
                            ),
                            _buildAccessItem(
                              success: true,
                              title: "TNS Name",
                              description: "Your public ToroID handle.",
                            ),
                            20.verticalSpacer,
                            Divider(
                              color: appColors.primary.withAlpha(60),
                              thickness: 1.height,
                            ),
                            _buildAccessItem(
                              success: false,
                              title: "Real Name",
                              description: "Private",
                            ),
                            _buildAccessItem(
                              success: false,
                              title: "BVN",
                              description: "Private",
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AppButton(
                              text: "Deny",
                              hollow: true,
                              callback: () => context.pop(),
                            ),
                          ),
                          15.horizontalSpacer,
                          Expanded(
                            child: AppButton(
                              text: "Allow",
                              callback: () => ref
                                  .read(loadingProvider.notifier)
                                  .wrap(() async {
                                    await Future.delayed(
                                      const Duration(seconds: 3),
                                    );
                                    if (!mounted || !context.mounted) return;
                                    context.pop();
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessItem({
    required bool success,
    required String title,
    required String description,
  }) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    final icon = success ? Assets.icons.checkmark : Assets.icons.cancel;
    final color = success ? appColors.success : appColors.error;
    final decor = success ? TextDecoration.none : TextDecoration.lineThrough;

    return Padding(
      padding: EdgeInsets.only(top: 15.height),
      child: Row(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 5.width,
              vertical: 5.height,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(35),
            ),
            child: AppSvg(
              path: icon,
              width: 16.width,
              height: 16.height,
              color: color,
            ),
          ),
          15.horizontalSpacer,
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: appStyles.body.copyWith(
                    fontFamily: FontFamily.interSemiBold,
                    decoration: decor,
                  ),
                ),
                2.verticalSpacer,
                Text(
                  description,
                  style: appStyles.caption.copyWith(
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
