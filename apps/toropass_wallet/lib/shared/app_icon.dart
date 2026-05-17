import 'package:flutter/material.dart';

import '../core/config/themes/colors.dart';
import '../core/utilities/animations.dart';
import '../core/utilities/extensions/numbers.dart';
import '../generated/assets.gen.dart';

class AppIcon extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showShadow;

  const AppIcon({super.key, this.width, this.height, this.showShadow = false});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Hero(
      tag: "APP-ICON",
      child: Material(
        color: appColors.transparent,
        child: AnimatedContainer(
          duration: Animations.duration,
          width: width ?? 200.width,
          height: height ?? 200.height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(Assets.images.splash.path),
              fit: BoxFit.contain,
            ),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: appColors.shadow.withAlpha(10),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
