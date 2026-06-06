import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';
import '../../domain/entities/oauth_permission_request_entity.dart';
import '../provider/permission_notifier.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  final OAuthPermissionRequestEntity request;

  const PermissionScreen({super.key, required this.request});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);
    final permissionState = ref.watch(permissionProvider);
    final authorizeState = permissionState.authorizeState;
    final isLoading = authorizeState is DataLoading;
    final showSkeleton = !widget.request.isValid;
    final appName = widget.request.appName;
    final scopes = widget.request.scopes
        .map(_mapScope)
        .whereType<_PermissionScope>()
        .toList();
    final deniedItems = _buildDeniedItems(scopes);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _denyAndExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .start,
            children: [
              TopBar(
                title: "Permissions",
                action: AppInkWell(
                  callback: isLoading ? null : _denyAndExit,
                  child: Padding(
                    padding: EdgeInsets.only(left: 50.width),
                    child: Icon(
                      Icons.close,
                      size: 24.radius,
                      color: appColors.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Skeletonizer(
                  enabled: showSkeleton,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                      horizontal: AppDimens.horizontalPadding,
                    ).add(EdgeInsets.only(top: 50.height, bottom: 20.height)),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.horizontalPadding,
                      vertical: 20.height,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimens.dialogBorderRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow.withAlpha(10),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: .max,
                      crossAxisAlignment: .center,
                      children: [
                        15.verticalSpacer,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.width,
                            vertical: 8.height,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadius,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.width,
                              vertical: 6.height,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppDimens.borderRadius,
                              ),
                            ),
                            child: AppSvg(
                              path: Assets.icons.marketplace,
                              width: 28.width,
                              height: 28.height,
                              color: appColors.primary,
                            ),
                          ),
                        ),
                        20.verticalSpacer,
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: appStyles.cardTitle.copyWith(height: 1.5),
                            children: [
                              TextSpan(
                                text: appName,
                                style: const TextStyle(
                                  fontFamily: FontFamily.interBold,
                                ),
                              ),
                              const TextSpan(
                                text: " wants to verify\nyour identity",
                              ),
                            ],
                          ),
                        ),
                        10.verticalSpacer,
                        Text(
                          "Please review the information they are requesting access to.",
                          textAlign: TextAlign.center,
                          style: appStyles.body.copyWith(
                            color: appColors.text.withAlpha(150),
                          ),
                        ),
                        15.verticalSpacer,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.width,
                          ).add(EdgeInsets.only(bottom: 15.height)),
                          decoration: BoxDecoration(
                            color: appColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadius,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: .min,
                            crossAxisAlignment: .start,
                            children: [
                              ...scopes.map(
                                (scope) => _buildAccessItem(
                                  success: true,
                                  title: scope.title,
                                  description: scope.description,
                                ),
                              ),
                              if (deniedItems.isNotEmpty) ...[
                                20.verticalSpacer,
                                Divider(
                                  color: appColors.primary.withAlpha(60),
                                  thickness: 1.height,
                                ),
                                ...deniedItems.map(
                                  (scope) => _buildAccessItem(
                                    success: false,
                                    title: scope.title,
                                    description: scope.description,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AppButton(
                                text: "Deny",
                                hollow: true,
                                callback: isLoading ? null : _denyAndExit,
                              ),
                            ),
                            15.horizontalSpacer,
                            Expanded(
                              child: AppButton(
                                text: isLoading ? "Authorizing..." : "Allow",
                                callback: isLoading || !widget.request.isValid
                                    ? null
                                    : _authorize,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessItem({
    required bool success,
    required String title,
    required String description,
  }) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    final icon = success ? Assets.icons.checkmark : Assets.icons.cancel;
    final color = success ? appColors.success : appColors.error;
    final decor = success ? TextDecoration.none : TextDecoration.lineThrough;

    return Padding(
      padding: EdgeInsets.only(top: 15.height),
      child: Row(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 5.width,
              vertical: 5.height,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(35),
            ),
            child: AppSvg(
              path: icon,
              width: 16.width,
              height: 16.height,
              color: color,
            ),
          ),
          15.horizontalSpacer,
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: appStyles.body.copyWith(
                    fontFamily: FontFamily.interSemiBold,
                    decoration: decor,
                  ),
                ),
                2.verticalSpacer,
                Text(
                  description,
                  style: appStyles.caption.copyWith(
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _authorize() async {
    final success = await ref.read(permissionProvider.notifier).authorize(
          widget.request,
        );
    if (!mounted || !success) return;

    final callbackUri = ref.read(permissionProvider).callbackUri;
    if (callbackUri == null || callbackUri.isEmpty) {
      ref.read(snackbarProvider).display(
        message: "Unable to complete the callback for this app.",
      );
      return;
    }

    await _launchCallbackAndExit(callbackUri);
  }

  Future<void> _denyAndExit() async {
    final callbackUri = ref
        .read(permissionProvider.notifier)
        .buildDeniedCallbackUri(widget.request.redirectUri);
    await _launchCallbackAndExit(callbackUri);
  }

  Future<void> _launchCallbackAndExit(String callbackUri) async {
    final launched = await launchUrl(
      Uri.parse(callbackUri),
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      if (!mounted) return;
      ref.read(snackbarProvider).display(
        message: "Unable to open the callback URL for this app.",
      );
      return;
    }

    await SystemNavigator.pop();
  }

  List<_PermissionScope> _buildDeniedItems(List<_PermissionScope> allowedScopes) {
    const privateScopes = [
      _PermissionScope(
        key: 'real_name',
        title: 'Real Name',
        description: 'Private',
      ),
      _PermissionScope(
        key: 'bvn',
        title: 'BVN',
        description: 'Private',
      ),
    ];

    final allowedKeys = allowedScopes.map((scope) => scope.key).toSet();
    return privateScopes
        .where((scope) => !allowedKeys.contains(scope.key))
        .toList();
  }

  _PermissionScope? _mapScope(String scope) {
    switch (scope) {
      case 'kyc_status':
        return const _PermissionScope(
          key: 'kyc_status',
          title: 'Verification Status',
          description: 'They will know you are a verified user.',
        );
      case 'wallet':
        return const _PermissionScope(
          key: 'wallet',
          title: 'Toro Identity',
          description: 'Your public Toro handle and wallet identity.',
        );
      default:
        return _PermissionScope(
          key: scope,
          title: scope.replaceAll('_', ' '),
          description: 'Shared with this application.',
        );
    }
  }
}

class _PermissionScope {
  final String key;
  final String title;
  final String description;

  const _PermissionScope({
    required this.key,
    required this.title,
    required this.description,
  });
}
