import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/routes.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_icon.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.width),
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .center,
            mainAxisAlignment: .center,
            children: [
              const Spacer(),
              Text(
                "ToroPass",
                style: appStyles.pageTitle.copyWith(
                  color: appColors.primary,
                  fontFamily: FontFamily.plusJakartaSansBold,
                ),
              ),
              20.verticalSpacer,
              AppIcon(width: 250.width, height: 250.height, showShadow: true),
              const Spacer(flex: 2),
              Text(
                "Your Digital Self",
                style: appStyles.pageTitle,
                textAlign: TextAlign.center,
              ),
              10.verticalSpacer,
              Text(
                "Experience the future of Web3 identity. Secure, private, and beautifully simple to manage.",
                style: appStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                text: "Continue",
                callback: () => context.pushNamed(AppRoutes.SIGNIN_SCREEN),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
