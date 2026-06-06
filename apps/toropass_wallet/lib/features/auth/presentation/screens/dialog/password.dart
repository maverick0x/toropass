import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/resource/data_state.dart';
import '../../../../../core/config/themes/colors.dart';
import '../../../../../core/config/themes/dimens.dart';
import '../../../../../core/config/themes/styles.dart';
import '../../../../../core/utilities/animations.dart';
import '../../../../../core/utilities/extensions/numbers.dart';
import '../../../../../generated/fonts.gen.dart';
import '../../../../../shared/app_button.dart';
import '../../../../../shared/app_inkwell.dart';
import '../../../../../shared/app_textfield.dart';
import '../../../../../shared/field_status.dart';
import '../../../../../shared/field_widget.dart';
import '../../provider/auth_notifier.dart';

class PasswordDialog extends ConsumerStatefulWidget {
  const PasswordDialog({super.key});

  @override
  ConsumerState<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends ConsumerState<PasswordDialog> {
  late bool hidePassword;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    hidePassword = true;
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).changePassword("");
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    final password = ref.watch(authProvider.select((s) => s.password));
    final tnsState = ref.watch(authProvider.select((s) => s.tnsState));
    final isExistingWallet =
        tnsState is DataSuccess && tnsState.data?.isAvailable == false;
    final title = isExistingWallet ? "Verify Password" : "Create Password";
    final description = isExistingWallet
        ? "Enter the password linked to this Toro identity to verify ownership and continue."
        : "Create a strong password to secure your new Toro identity.";
    final helperText = isExistingWallet
        ? "Use the password for this existing wallet."
        : "Use at least 8 characters to protect this wallet.";
    final actionText = isExistingWallet ? "Verify Wallet" : "Create Wallet";

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
        vertical: 30.height,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisSize: .max,
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(title, style: appStyles.sectionTitle),
                    10.verticalSpacer,
                    Text(
                      description,
                      style: appStyles.bodyMedium,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              20.horizontalSpacer,
              AppInkWell(
                callback: context.pop,
                child: Icon(Icons.close, color: appColors.header),
              ),
            ],
          ),
          40.verticalSpacer,
          AppTextfield(
            obscureText: hidePassword,
            controller: _passwordController,
            style: appStyles.cardTitle.copyWith(
              fontFamily: FontFamily.interMedium,
              letterSpacing: 1,
              height: 1.2,
            ),
            onChanged: ref.read(authProvider.notifier).changePassword,
            suffix: AppInkWell(
              callback: () => setState(() => hidePassword = !hidePassword),
              child: FieldWidget(
                width: 70.width,
                child: AnimatedSwitcher(
                  duration: Animations.shortDuration,
                  transitionBuilder: Animations.iconTransition,
                  child: Text(
                    key: ValueKey(hidePassword),
                    hidePassword ? "Show" : "Hide",
                    style: appStyles.caption.copyWith(
                      fontFamily: FontFamily.plusJakartaSansBold,
                      color: appColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            hint: "",
          ),
          10.verticalSpacer,
          AnimatedSize(
            duration: Animations.duration,
            child: Visibility(
              visible: password.isNotEmpty,
              child: FieldStatus(
                success: password.length > 7,
                message: password.length <= 7 ? helperText : actionText,
              ),
            ),
          ),
          40.verticalSpacer,
          AppButton(
            text: actionText,
            color: password.length > 7
                ? appColors.primary
                : appColors.black.withAlpha(100),
            callback: () {
              if (password.length <= 7) return;
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
