import 'package:flutter/material.dart';

import '../core/config/themes/dimens.dart';
import '../core/config/themes/styles.dart';
import '../core/utilities/extensions/numbers.dart';
import 'app_svg.dart';

class ScopeChip extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;

  const ScopeChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 5.height),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
      ),
      child: Row(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [
          AppSvg(path: icon, color: color, width: 14.width, height: 14.height),
          5.horizontalSpacer,
          Text(text, style: appStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
