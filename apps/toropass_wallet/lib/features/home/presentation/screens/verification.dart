import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/routes.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/app_textfield.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bvnController;
  late final TextEditingController _currencyController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bvnController = TextEditingController();
    _currencyController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _bvnController.dispose();
    _currencyController.dispose();
    _phoneNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

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
              TopBar(title: "Verification"),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    20.verticalSpacer,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.width),
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        children: [
                          Text("Verify Identity", style: appStyles.cardTitle),
                          5.verticalSpacer,
                          Text(
                            "Your data is encrypted and never shared publicly.",
                            style: appStyles.caption.copyWith(
                              color: appColors.text.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.verticalSpacer,
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDimens.horizontalPadding,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 20.height,
                        horizontal: 20.width,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadius,
                        ),
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
                          TextfieldLabel(label: "First Name"),
                          AppTextfield(
                            hint: "John",
                            controller: _firstNameController,
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Middle Name"),
                          AppTextfield(
                            hint: "James",
                            controller: _middleNameController,
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Last Name"),
                          AppTextfield(
                            hint: "Doe",
                            controller: _lastNameController,
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "BVN"),
                          AppTextfield(
                            hint: "1234567890",
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            controller: _bvnController,
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Currency"),
                          AppTextfield(
                            hint: "NGN",
                            controller: _currencyController,
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Phone Number"),
                          AppTextfield(
                            hint: "1234567890",
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            controller: _phoneNumberController,
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Date of Birth"),
                          AppTextfield(
                            hint: "01/01/1990",
                            controller: _dobController,
                          ),
                          10.verticalSpacer,
                        ],
                      ),
                    ),
                    30.verticalSpacer,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.horizontalPadding,
                      ),
                      child: AppButton(
                        text: "Verify",
                        callback: () =>
                            context.pushNamed(AppRoutes.SUCCESS_SCREEN),
                      ),
                    ),
                    30.verticalSpacer,
                    Align(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .center,
                        children: [
                          AppSvg(
                            path: Assets.icons.lock,
                            width: 15.width,
                            height: 15.height,
                            color: appColors.text.withAlpha(150),
                          ),
                          10.verticalSpacer,
                          Text(
                            "Powered by secure cryptographic protocols.\nThis"
                            " process usually takes less than\n60 seconds.",
                            textAlign: TextAlign.center,
                            style: appStyles.caption.copyWith(
                              color: appColors.text.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                    15.verticalSpacer,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
