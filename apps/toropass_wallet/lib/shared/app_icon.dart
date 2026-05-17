import 'package:flutter/material.dart';

import '../core/config/themes/colors.dart';
import '../core/utilities/extensions/numbers.dart';
import '../generated/assets.gen.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Hero(
      tag: "APP-ICON",
      child: Material(
        color: appColors.transparent,
        child: Container(
          width: 200.width,
          height: 200.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.splash.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
