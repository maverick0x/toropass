import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config/themes/colors.dart';
import '../core/config/themes/dimens.dart';
import '../core/config/themes/styles.dart';
import '../core/utilities/extensions/numbers.dart';
import 'app_icon.dart';
import 'app_inkwell.dart';

class TopBar extends StatelessWidget {
  final String title;
  final Widget? action;

  const TopBar({super.key, this.action, required this.title});

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.height,
        horizontal: AppDimens.horizontalPadding,
      ),
      child: Row(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          AppIcon(width: 40.width, height: 40.height),
          5.horizontalSpacer,
          Text(
            title,
            style: appStyles.sectionTitle.copyWith(color: appColors.primary),
          ),
          const Spacer(),
          action ??
              AppInkWell(
                callback: () => context.pop(),
                child: Container(
                  padding: EdgeInsets.only(left: 50.width),
                  child: Icon(
                    Icons.close,
                    size: 24.radius,
                    color: appColors.primary,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
