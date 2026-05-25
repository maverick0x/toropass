import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/utilities/animations.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_dialog.dart';
import '../../../../shared/app_icon.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/app_textfield.dart';
import '../../../../shared/field_status.dart';
import '../../../../shared/field_widget.dart';
import '../provider/auth_notifier.dart';
import 'dialog/password.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    final username = ref.watch(authProvider.select((s) => s.username));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.horizontalPadding,
          ),
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .center,
            mainAxisAlignment: .center,
            children: [
              20.verticalSpacer,
              Row(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  AppIcon(width: 40.width, height: 40.height),
                  10.horizontalSpacer,
                  Text(
                    'ToroPass',
                    style: appStyles.sectionTitle.copyWith(
                      color: appColors.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "Claim Your Identity",
                style: appStyles.pageTitle,
                textAlign: TextAlign.center,
              ),
              10.verticalSpacer,
              Text(
                "Protect your digital identity with a unique username and secure password. Your identity, your control.",
                style: appStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.height,
                  horizontal: 20.width,
                ),
                decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius: BorderRadius.circular(AppDimens.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.shadow.withAlpha(20),
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
                    TextfieldLabel(label: "Username"),
                    AppTextfield(
                      controller: _usernameController,
                      style: appStyles.cardTitle.copyWith(
                        fontFamily: FontFamily.interMedium,
                        letterSpacing: 1,
                        height: 1.2,
                      ),
                      onChanged: ref.read(authProvider.notifier).changeUsername,
                      prefix: FieldWidget(
                        child: AppSvg(
                          path: Assets.icons.at,
                          width: 20.width,
                          height: 20.height,
                        ),
                      ),
                      suffix: FieldWidget(
                        width: 70.width,
                        child: Text(
                          ".toro",
                          style: appStyles.cardTitle.copyWith(
                            fontFamily: FontFamily.plusJakartaSansBold,
                            color: appColors.primary,
                          ),
                        ),
                      ),
                      hint: "",
                    ),
                    10.verticalSpacer,
                    AnimatedSize(
                      duration: Animations.duration,
                      child: Visibility(
                        visible: username.length > 4,
                        child: FieldStatus(
                          success: true,
                          message: "Available!",
                        ),
                      ),
                    ),
                    40.verticalSpacer,
                    AppButton(
                      text: "Claim Identity",
                      color: username.length > 4
                          ? appColors.primary
                          : appColors.black.withAlpha(100),
                      callback: () async {
                        if (username.length <= 4) return;
                        await displayDialog(
                          context,
                          width: 350.width,
                          child: const PasswordDialog(),
                        );

                        final password = ref.read(
                          authProvider.select((s) => s.password),
                        );
                        if (password.isEmpty || password.length <= 7) return;
                        ref.read(loadingProvider.notifier).wrap(() async {
                          await Future.delayed(const Duration(seconds: 5));
                          ref.read(authProvider.notifier).login();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  AppSvg(
                    path: Assets.icons.lock,
                    width: 15.width,
                    height: 15.height,
                    color: appColors.text.withAlpha(150),
                  ),
                  10.horizontalSpacer,
                  Text(
                    "Secure & Decentralized",
                    style: appStyles.caption.copyWith(
                      color: appColors.text.withAlpha(150),
                    ),
                  ),
                ],
              ),
              15.verticalSpacer,
            ],
          ),
        ),
      ),
    );
  }
}
