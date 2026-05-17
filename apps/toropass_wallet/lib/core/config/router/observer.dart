import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../network/token/token_notifier.dart';
import '../../utilities/logger.dart';

final observerProvider = Provider((ref) {
  ref.watch(tokenProvider.select((m) => m.value?.refreshToken?.isNotEmpty));
  return Observer();
});

class Observer extends NavigatorObserver {
  final List<String?> routeStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final String? name = route.settings.name ?? _getRoutePath(route);
    if (name != null) {
      routeStack.add(name);
    } else {
      routeStack.add("Shell_Internal");
    }

    AppLogger.log('Stack after Push: $routeStack', name: 'STACK_OBSERVER');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.removeLast();
    AppLogger.log('Stack after Pop: $routeStack', name: 'STACK_OBSERVER');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.removeWhere((name) => name == route.settings.name);
    AppLogger.log('Stack after Remove: $routeStack', name: 'STACK_OBSERVER');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      final index = routeStack.lastIndexOf(oldRoute.settings.name);
      if (index != -1) {
        routeStack[index] = newRoute?.settings.name;
      }
    }
    AppLogger.log('Stack after Replace: $routeStack', name: 'STACK_OBSERVER');
  }

  bool isScreenInStack(String screenName) => routeStack.contains(screenName);

  void popUntil(BuildContext context, String targetName) {
    if (!isScreenInStack(targetName)) {
      AppLogger.log('Target $targetName not in stack.', name: 'STACK_OBSERVER');
      return;
    }

    Navigator.of(context).popUntil((route) {
      return route.settings.name == targetName;
    });
  }

  void popToRoot(BuildContext context) {
    if (routeStack.isEmpty) {
      AppLogger.log('Stack is empty.', name: 'STACK_OBSERVER');
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String? _getRoutePath(Route<dynamic> route) {
    if (route.settings.arguments is GoRouterState) {
      return (route.settings.arguments as GoRouterState).uri.path;
    }
    return null;
  }
}
