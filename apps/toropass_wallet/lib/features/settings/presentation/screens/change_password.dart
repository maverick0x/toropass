import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/app_textfield.dart';
import '../provider/settings_notifier.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);
    final settingsState = ref.watch(settingsProvider);
    final isLoading = settingsState.changePasswordState is DataLoading;

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
              TopBar(title: 'Change Password'),
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
                          Text('Update Password', style: appStyles.cardTitle),
                          5.verticalSpacer,
                          Text(
                            'Choose a new password to keep your Toro identity secure.',
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
                          TextfieldLabel(label: 'Current Password'),
                          AppTextfield(
                            hint: 'Enter current password',
                            controller: _currentPasswordController,
                            obscureText: true,
                            error: settingsState.currentPasswordError.isEmpty
                                ? null
                                : settingsState.currentPasswordError,
                            onChanged: (_) => ref
                                .read(settingsProvider.notifier)
                                .clearCurrentPasswordError(),
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: 'New Password'),
                          AppTextfield(
                            hint: 'Enter new password',
                            controller: _newPasswordController,
                            obscureText: true,
                            error: settingsState.newPasswordError.isEmpty
                                ? null
                                : settingsState.newPasswordError,
                            onChanged: (_) => ref
                                .read(settingsProvider.notifier)
                                .clearNewPasswordError(),
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: 'Confirm Password'),
                          AppTextfield(
                            hint: 'Confirm new password',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            error: settingsState.confirmPasswordError.isEmpty
                                ? null
                                : settingsState.confirmPasswordError,
                            onChanged: (_) => ref
                                .read(settingsProvider.notifier)
                                .clearConfirmPasswordError(),
                          ),
                          10.verticalSpacer,
                        ],
                      ),
                    ),
                    30.verticalSpacer,
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.horizontalPadding,
                      ),
                      child: AppButton(
                        text: isLoading ? 'Updating...' : 'Change Password',
                        callback: isLoading ? null : _submitChangePassword,
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
                            'Your password is updated over a secure connection\nand takes effect immediately.',
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

  Future<void> _submitChangePassword() async {
    final success = await ref
        .read(settingsProvider.notifier)
        .submitChangePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (!mounted || !success) return;
    context.pop();
  }
}
