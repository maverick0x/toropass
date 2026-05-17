import 'package:flutter/material.dart';

import '../../core/config/themes/colors.dart';
import '../../core/config/themes/dimens.dart';

class AppInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? callback;
  final VoidCallback? longPressCallback;
  final VoidCallback? doubleTapCallback;

  const AppInkWell({
    super.key,
    this.callback,
    this.longPressCallback,
    this.doubleTapCallback,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: appColors.transparent,
      hoverColor: appColors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.borderRadius),
      onTap: callback,
      onLongPress: () {
        if (longPressCallback != null) longPressCallback?.call();
      },
      onDoubleTap: () {
        if (doubleTapCallback != null) doubleTapCallback?.call();
      },
      child: child,
    );
  }
}
