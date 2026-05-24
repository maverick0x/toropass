import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../shared/app_bar.dart';

class DeveloperScreen extends ConsumerStatefulWidget {
  const DeveloperScreen({super.key});

  @override
  ConsumerState<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends ConsumerState<DeveloperScreen> {
  @override
  Widget build(BuildContext context) {
    final _ = context.appStyles;
    final _ = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: .max,
          crossAxisAlignment: .start,
          children: [TopBar(title: "Developers")],
        ),
      ),
    );
  }
}
