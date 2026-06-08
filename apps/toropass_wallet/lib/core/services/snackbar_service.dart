import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/fonts.gen.dart';
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
  OverlayEntry? _activeOverlay;

  TopSnackbarService(this.navigatorKey);

  void display({String? title, required String message}) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _activeOverlay?.remove();

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        final appStyles = context.appStyles;
        final appColors = AppColors.of(context);
        final topPadding = MediaQuery.of(context).padding.top;
        final hasTitle = title != null && title.trim().isNotEmpty;

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
                padding: .symmetric(horizontal: 12.width, vertical: 12.height),
                decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius: .circular(12.radius),
                  border: .all(
                    color: appColors.primary.withAlpha(35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.shadow.withAlpha(18),
                      blurRadius: 24,
                      spreadRadius: 6,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    Container(
                      width: 32.width,
                      height: 32.width,
                      alignment: .center,
                      decoration: BoxDecoration(
                        color: appColors.primary.withAlpha(12),
                        borderRadius: .circular(14.radius),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: appColors.primary,
                        size: 20.width,
                      ),
                    ),
                    14.horizontalSpacer,
                    Expanded(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        children: [
                          if (hasTitle) ...[
                            Text(
                              title,
                              style: appStyles.body.copyWith(
                                color: appColors.header,
                                fontFamily: FontFamily.interSemiBold,
                              ),
                            ),
                            4.verticalSpacer,
                          ],
                          Text(
                            message,
                            style: appStyles.caption.copyWith(
                              color: appColors.text.withAlpha(220),
                              height: 1.3,
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
    _activeOverlay = overlayEntry;

    Future.delayed(const Duration(seconds: 3), () {
      if (identical(_activeOverlay, overlayEntry) && overlayEntry.mounted) {
        overlayEntry.remove();
        _activeOverlay = null;
      }
    });
  }
}
