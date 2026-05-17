import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/network/token/token_notifier.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../shared/app_icon.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.horizontalPadding,
          ),
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .start,
            children: [
              15.verticalSpacer,
              Row(
                mainAxisSize: .max,
                crossAxisAlignment: .center,
                children: [
                  AppIcon(width: 40.width, height: 40.height),
                  10.horizontalSpacer,
                  Text(
                    'ToroPass',
                    style: appStyles.sectionTitle.copyWith(
                      color: appColors.primary,
                    ),
                  ),
                  const Spacer(),
                  AppInkWell(
                    callback: () =>
                        ref.read(tokenProvider.notifier).clearTokens(),
                    child: AppSvg(
                      path: Assets.icons.settings,
                      width: 30.width,
                      height: 30.height,
                      color: appColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
