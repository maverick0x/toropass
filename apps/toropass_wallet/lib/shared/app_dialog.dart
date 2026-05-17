import 'package:flutter/material.dart';

import '../../core/config/themes/colors.dart';
import '../../core/config/themes/dimens.dart';

Future displayDialog(
  BuildContext context, {
  double width = 100,
  bool dismissible = true,
  String barrierLabel = "Dialog",
  Color barrierColor = const Color(0x80000000),
  required Widget child,
  Function(bool, Object?)? onPopInvokedWithResult,
}) async => await showGeneralDialog(
  context: context,
  barrierDismissible: dismissible,
  barrierLabel: barrierLabel,
  barrierColor: barrierColor,
  pageBuilder: (context, animation, secondaryAnimation) {
    final appColors = AppColors.of(context);
    final borderRadius = BorderRadius.circular(AppDimens.dialogBorderRadius);

    return PopScope(
      canPop: dismissible && onPopInvokedWithResult == null,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Center(
        child: Material(
          borderRadius: borderRadius,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: appColors.white,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: appColors.shadow.withAlpha(20),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  },
);
