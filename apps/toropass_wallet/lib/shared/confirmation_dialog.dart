import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config/themes/colors.dart';
import '../core/config/themes/dimens.dart';
import '../core/config/themes/styles.dart';
import '../core/utilities/extensions/numbers.dart';
import 'app_button.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      destructive: destructive,
    ),
  );

  return confirmed ?? false;
}

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool destructive;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.destructive,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appStyles = context.appStyles;

    return Dialog(
      backgroundColor: appColors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.width),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.horizontalPadding,
          vertical: 24.height,
        ),
        decoration: BoxDecoration(
          color: appColors.white,
          borderRadius: BorderRadius.circular(AppDimens.dialogBorderRadius),
          boxShadow: [
            BoxShadow(
              color: appColors.shadow.withAlpha(18),
              blurRadius: 24,
              spreadRadius: 8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: appStyles.cardTitle),
            15.verticalSpacer,
            Text(
              message,
              style: appStyles.body.copyWith(
                color: appColors.text.withAlpha(150),
              ),
            ),
            35.verticalSpacer,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: cancelText,
                    hollow: true,
                    callback: () => context.pop(false),
                  ),
                ),
                12.horizontalSpacer,
                Expanded(
                  child: AppButton(
                    text: confirmText,
                    color: destructive ? appColors.error : null,
                    callback: () => context.pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
