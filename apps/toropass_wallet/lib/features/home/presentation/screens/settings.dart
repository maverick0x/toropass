import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../shared/app_icon.dart';
import '../../../../shared/app_inkwell.dart';
import '../shared/identity_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: .max,
          crossAxisAlignment: .center,
          children: [
            15.verticalSpacer,
            Row(
              mainAxisSize: .max,
              crossAxisAlignment: .center,
              children: [
                20.horizontalSpacer,
                AppIcon(width: 40.width, height: 40.height),
                5.horizontalSpacer,
                Text(
                  'Settings',
                  style: appStyles.sectionTitle.copyWith(
                    color: appColors.primary,
                  ),
                ),
                const Spacer(),
                AppInkWell(
                  callback: () => context.pop(),
                  child: Icon(
                    Icons.close,
                    size: 30.width,
                    color: appColors.primary,
                  ),
                ),
                20.horizontalSpacer,
              ],
            ),
            30.verticalSpacer,
            IdentityCard(),
            Container(),
            const Spacer(),
            Text(
              "v1.0.0 (Build 42)",
              style: appStyles.body.copyWith(
                color: appColors.text.withAlpha(100),
              ),
            ),
            30.verticalSpacer,
          ],
        ),
      ),
    );
  }
}
