import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/screens/intro.dart';
import '../../../features/auth/presentation/screens/signin.dart';
import '../../../features/home/data/models/oauth_permission_request_model.dart';
import '../../../features/home/presentation/screens/connections.dart';
import '../../../features/home/presentation/screens/home.dart';
import '../../../features/home/presentation/screens/permission.dart';
import '../../../features/home/presentation/screens/success.dart';
import '../../../features/home/presentation/screens/verification.dart';
import '../../../features/settings/presentation/screens/developer.dart';
import '../../../features/settings/presentation/screens/settings.dart';
import '../../../features/splash/presentation/screens/splash.dart';
import '../../network/token/token_notifier.dart';
import 'observer.dart';
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

  final authRoutes = [AppRoutes.INTRO_SCREEN, AppRoutes.SIGNIN_SCREEN];

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
          final isPermissionRoute =
              state.matchedLocation == AppRoutes.PERMISSION_SCREEN;
          final permissionQuery = state.uri.queryParameters;
          final hasPermissionPayload =
              permissionQuery['client_id']?.isNotEmpty == true &&
              permissionQuery['redirect_uri']?.isNotEmpty == true;

          if (!m.ready) {
            if (isPermissionRoute && hasPermissionPayload) {
              return null;
            }
            final isOnSplash = state.matchedLocation == AppRoutes.SPLASH_SCREEN;
            if (isOnSplash) return null;
            return AppRoutes.SPLASH_SCREEN;
          }

          final isLoggedIn = m.refreshToken?.isNotEmpty ?? false;
          if (state.matchedLocation == AppRoutes.SPLASH_SCREEN) {
            // Auto redirect from splash based when ready is true
            final route = isLoggedIn
                ? AppRoutes.HOME_SCREEN
                : AppRoutes.INTRO_SCREEN;

            return route;
          }

          /// AUTH GUARD LOGIC
          // User is not logged in and trying to access a protected route
          if (!isLoggedIn && !isGoingToAuth) {
            if (isPermissionRoute && hasPermissionPayload) {
              return Uri(
                path: AppRoutes.SIGNIN_SCREEN,
                queryParameters: permissionQuery,
              ).toString();
            }
            return AppRoutes.INTRO_SCREEN; // Redirect to intro
          }
          // User is logged in and trying to access an auth route
          if (isLoggedIn && isGoingToAuth) {
            if (hasPermissionPayload) {
              return Uri(
                path: AppRoutes.PERMISSION_SCREEN,
                queryParameters: permissionQuery,
              ).toString();
            }
            return AppRoutes.HOME_SCREEN; // Redirect to home
          }

          return null; // Allow navigation to pass normally
        },
      );
    },
    routes: [
      GoRoute(
        name: AppRoutes.SPLASH_SCREEN,
        path: AppRoutes.SPLASH_SCREEN,
        builder: ((context, state) => const SplashScreen()),
      ),
      GoRoute(
        name: AppRoutes.INTRO_SCREEN,
        path: AppRoutes.INTRO_SCREEN,
        builder: ((context, state) => const IntroScreen()),
      ),
      GoRoute(
        name: AppRoutes.SIGNIN_SCREEN,
        path: AppRoutes.SIGNIN_SCREEN,
        builder: ((context, state) => const SigninScreen()),
      ),
      GoRoute(
        name: AppRoutes.HOME_SCREEN,
        path: AppRoutes.HOME_SCREEN,
        builder: ((context, state) => const HomeScreen()),
      ),

      GoRoute(
        name: AppRoutes.CONNECTION_SCREEN,
        path: AppRoutes.CONNECTION_SCREEN,
        builder: (context, state) => const ConnectionsScreen(),
      ),
      GoRoute(
        name: AppRoutes.VERIFICATION_SCREEN,
        path: AppRoutes.VERIFICATION_SCREEN,
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        name: AppRoutes.SUCCESS_SCREEN,
        path: AppRoutes.SUCCESS_SCREEN,
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        name: AppRoutes.PERMISSION_SCREEN,
        path: AppRoutes.PERMISSION_SCREEN,
        builder: (context, state) => PermissionScreen(
          request: OAuthPermissionRequestModel.fromUri(state.uri),
        ),
      ),
      GoRoute(
        name: AppRoutes.SETTINGS_SCREEN,
        path: AppRoutes.SETTINGS_SCREEN,
        builder: ((context, state) => const SettingsScreen()),
      ),
      GoRoute(
        name: AppRoutes.DEVELOPER_SCREEN,
        path: AppRoutes.DEVELOPER_SCREEN,
        builder: ((context, state) => const DeveloperScreen()),
      ),
    ],
  );

  ref.onDispose(() {
    refreshNotifier.dispose();
    router.dispose();
  });

  return router;
});
