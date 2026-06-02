import 'package:flutter/material.dart';

import '../core/config/themes/colors.dart';
import '../core/config/themes/dimens.dart';
import '../core/config/themes/styles.dart';
import '../core/utilities/animations.dart';
import '../core/utilities/extensions/numbers.dart';
import '../generated/assets.gen.dart';
import 'app_svg.dart';

class FieldStatus extends StatelessWidget {
  final bool loading;
  final bool success;
  final String message;

  const FieldStatus({
    super.key,
    this.loading = false,
    required this.success,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return AnimatedContainer(
      duration: Animations.duration,
      padding: EdgeInsets.symmetric(vertical: 4.height, horizontal: 10.width),
      decoration: BoxDecoration(
        color: loading
            ? appColors.primary.withAlpha(20)
            : success
            ? appColors.success.withAlpha(20)
            : appColors.error.withAlpha(20),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
      ),
      child: Row(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [
          AnimatedSize(
            duration: Animations.duration,
            child: Visibility(
              visible: loading,
              child: SizedBox(
                width: 12.width,
                height: 12.height,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(appColors.primary),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: Animations.duration,
            child: Visibility(
              visible: !loading,
              child: Row(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  AppSvg(
                    path: Assets.icons.checkmarkCircle,
                    width: 14.width,
                    height: 14.height,
                    color: success ? appColors.success : appColors.error,
                  ),
                  5.horizontalSpacer,
                  AnimatedSwitcher(
                    duration: Animations.shortDuration,
                    child: Text(
                      key: ValueKey(message),
                      message,
                      style: appStyles.caption.copyWith(
                        color: success ? appColors.success : appColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
