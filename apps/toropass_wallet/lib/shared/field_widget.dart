import 'package:flutter/material.dart';

import '../core/config/themes/colors.dart';
import '../core/config/themes/dimens.dart';
import '../core/utilities/animations.dart';

class FieldWidget extends StatelessWidget {
  final Color? color;
  final double? width;
  final Widget child;

  const FieldWidget({super.key, this.color, this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return AnimatedContainer(
      duration: Animations.duration,
      width: width ?? AppDimens.buttonWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? appColors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
      ),
      child: child,
    );
  }
}
