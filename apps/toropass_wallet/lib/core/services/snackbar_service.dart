import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/router/router.dart';
import '../config/themes/colors.dart';
import '../config/themes/styles.dart';
import '../utilities/animations.dart';
import '../utilities/extensions/numbers.dart';

final snackbarProvider = Provider<TopSnackbarService>((ref) {
  final navKey = ref.read(navKeyProvider);
  return TopSnackbarService(navKey);
});

class TopSnackbarService {
  final GlobalKey<NavigatorState> navigatorKey;

  TopSnackbarService(this.navigatorKey);

  void display({String? title, required String message}) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        final appStyles = context.appStyles;
        final appColors = AppColors.of(context);

        final topPadding = MediaQuery.of(context).padding.top;

        return Positioned(
          top: topPadding + 20.height,
          left: 20.width,
          right: 20.width,
          child: Material(
            color: appColors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -100.0, end: 0.0),
              duration: Animations.duration,
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },

              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.width,
                  vertical: 15.height,
                ),
                decoration: BoxDecoration(
                  color: appColors.primary,
                  borderRadius: BorderRadius.circular(15.radius),
                  border: Border.all(color: appColors.primary, width: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.black.withAlpha(75),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    // Provide icon here
                    10.horizontalSpacer,
                    Expanded(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        children: [
                          if (title != null) ...[
                            Text(
                              title,
                              style: appStyles.sectionTitle.copyWith(
                                color: appColors.neutral,
                              ),
                            ),
                            4.verticalSpacer,
                          ],
                          Text(
                            message,
                            style: appStyles.body.copyWith(
                              color: appColors.neutral,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
