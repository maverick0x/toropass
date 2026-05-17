import 'package:flutter/widgets.dart';

import '../../core/config/themes/colors.dart';
import '../../core/config/themes/dimens.dart';
import '../../core/config/themes/styles.dart';
import '../../core/utilities/animations.dart';
import '../../core/utilities/extensions/numbers.dart';
import 'app_inkwell.dart';

class AppButton extends StatelessWidget {
  final bool hollow;
  final String text;
  final Color? color;
  final Color? textColor;
  final double? height;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? callback;
  final VoidCallback? doubleTapCallback;
  final List<BoxShadow>? shadows;

  const AppButton({
    super.key,
    this.prefix,
    this.suffix,
    this.color,
    this.height,
    this.textColor,
    this.hollow = false,
    this.shadows,
    this.callback,
    required this.text,
    this.doubleTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return AppInkWell(
      callback: callback,
      doubleTapCallback: doubleTapCallback,
      child: AnimatedContainer(
        duration: Animations.duration,
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 15.height),
        decoration: BoxDecoration(
          border: Border.all(
            color: appColors.primary.withAlpha(hollow ? 150 : 255),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          color: hollow ? appColors.transparent : color ?? appColors.primary,
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            ?prefix,
            AnimatedSwitcher(
              duration: Animations.duration,
              transitionBuilder: Animations.textTransition,
              child: Text(
                key: ValueKey<String>(text),
                text,
                style: context.appStyles.button.copyWith(
                  color:
                      textColor ??
                      (hollow ? appColors.primary : appColors.white),
                ),
              ),
            ),
            ?suffix,
          ],
        ),
      ),
    );
  }
}
