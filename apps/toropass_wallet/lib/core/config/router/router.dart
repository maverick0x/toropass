import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toropass_wallet/core/config/router/observer.dart';
import 'package:toropass_wallet/core/network/token/token_notifier.dart';

import '../../../views/modules/splash.dart';
import 'routes.dart';

final navKeyProvider = Provider((ref) {
  ref.watch(tokenProvider.select((m) => m.value?.refreshToken?.isNotEmpty));
  return GlobalKey<NavigatorState>();
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(
    tokenProvider.select((m) => (m.value?.ready, m.value?.refreshToken)),
    (_, _) => refreshNotifier.value++,
  );

  final observer = ref.read(observerProvider);
  final navigatorKey = ref.watch(navKeyProvider);

  final authRoutes = [];

  final router = GoRouter(
    observers: [observer],
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.SPLASH_SCREEN,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final model = ref.read(tokenProvider);
      final isGoingToAuth = authRoutes.contains(state.matchedLocation);

      return model.when(
        loading: () => null,
        error: (err, stack) => AppRoutes.SPLASH_SCREEN,
        data: (m) {
          if (!m.ready) {
            final isOnSplash = state.matchedLocation == AppRoutes.SPLASH_SCREEN;
            if (isOnSplash) return null;
            return AppRoutes.SPLASH_SCREEN;
          }

          final isLoggedIn = m.refreshToken?.isNotEmpty ?? false;
          if (state.matchedLocation == AppRoutes.SPLASH_SCREEN) {
            // Auto redirect from splash based when ready is true
            // final route = isLoggedIn
            //     ? AppRoutes.HOME_SCREEN
            //     : AppRoutes.INTRO_SCREEN;

            return AppRoutes.SPLASH_SCREEN; // route;
          }

          /// AUTH GUARD LOGIC
          // User is not logged in and trying to access a protected route
          // if (!isLoggedIn && !isGoingToAuth) {
          //   return AppRoutes.INTRO_SCREEN; // Redirect to intro
          // }
          // // User is logged in and trying to access an auth route
          // if (isLoggedIn && isGoingToAuth) {
          //   return AppRoutes.HOME_SCREEN; // Redirect to home
          // }

          return null; // Allow navigation to pass normally
        },
      );
    },
    routes: [
      GoRoute(
        name: AppRoutes.SPLASH_SCREEN,
        path: AppRoutes.SPLASH_SCREEN,
        builder: ((context, state) => SplashScreen()),
      ),
    ],
  );

  ref.onDispose(() {
    refreshNotifier.dispose();
    router.dispose();
  });

  return router;
});
