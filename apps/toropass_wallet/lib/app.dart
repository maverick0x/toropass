import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/config/router/router.dart';
import 'core/config/themes/themes.dart';
import 'shared/app_wrapper.dart';

class ToroPassApp extends ConsumerWidget {
  const ToroPassApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 884),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        title: 'ToroPass',
        theme: AppThemes.light,
        themeMode: ThemeMode.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        builder: (_, child) => AppWrapper(child: child!),
      ),
    );
  }
}
