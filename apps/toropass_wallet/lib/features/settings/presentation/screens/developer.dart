import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/animations.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/app_textfield.dart';
import '../../../../shared/field_widget.dart';

class DeveloperScreen extends ConsumerStatefulWidget {
  const DeveloperScreen({super.key});

  @override
  ConsumerState<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends ConsumerState<DeveloperScreen> {
  late bool isGenerating;

  late final TextEditingController _nameController;
  late final TextEditingController _callbackController;

  @override
  void initState() {
    super.initState();
    isGenerating = false;
    _nameController = TextEditingController();
    _callbackController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _callbackController.dispose();
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
            mainAxisSize: .max,
            crossAxisAlignment: .start,
            children: [
              TopBar(title: "Developers"),

              // Empty State
              AnimatedSize(
                duration: Animations.duration,
                child: Visibility(
                  visible: !isGenerating,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.horizontalPadding,
                    ),
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .center,
                      children: [
                        50.verticalSpacer,
                        Text(
                          "Register Your First dApp",
                          style: appStyles.sectionTitle,
                          textAlign: TextAlign.center,
                        ),
                        20.verticalSpacer,
                        Text(
                          "Ready to offload your KYC liability? Create a new application to get your Client ID and start verifying users instantly with zero PII overhead",
                          style: appStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        40.verticalSpacer,
                        AppButton(
                          text: "Create Application",
                          callback: () => setState(() => isGenerating = true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              30.verticalSpacer,
              AnimatedSize(
                duration: Animations.duration,
                child: Visibility(
                  visible: isGenerating,
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
                      borderRadius: BorderRadius.circular(
                        AppDimens.dialogBorderRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow.withAlpha(10),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextfieldLabel(label: "App Name"),
                        AppTextfield(
                          hint: "Enter your app name",
                          controller: _nameController,
                        ),
                        15.verticalSpacer,
                        TextfieldLabel(label: "Callback/Redirect URI"),
                        AppTextfield(
                          hint: "https://yourapp.com/callback",
                          controller: _callbackController,
                        ),
                        30.verticalSpacer,
                        AppButton(
                          text: "Generate API Keys",
                          prefix: FieldWidget(
                            child: AppSvg(
                              path: Assets.icons.key,
                              width: 24.width,
                              height: 24.height,
                              color: appColors.white,
                            ),
                          ),
                          callback: () => setState(() => isGenerating = false),
                        ),
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
}
