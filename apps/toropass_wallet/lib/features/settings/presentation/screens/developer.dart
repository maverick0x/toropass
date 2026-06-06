import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/animations.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_inkwell.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/app_textfield.dart';
import '../../../../shared/field_widget.dart';
import '../../data/models/developer_state_model.dart';
import '../../domain/entities/developer_app_entity.dart';
import '../provider/developer_notifier.dart';

class DeveloperScreen extends ConsumerStatefulWidget {
  const DeveloperScreen({super.key});

  @override
  ConsumerState<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends ConsumerState<DeveloperScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _callbackController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _callbackController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(developerProvider.notifier).getApps();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _callbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final developerState = ref.watch(developerProvider);
    final appsState = developerState.appsState;
    final apps = appsState.data ?? const <DeveloperAppEntity>[];
    final isLoadingApps = appsState is DataLoading;
    final showSkeleton = isLoadingApps || appsState is DataFailed;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .start,
            children: [
              TopBar(title: "Developers"),
              Expanded(
                child: Skeletonizer(
                  enabled: showSkeleton,
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(developerProvider.notifier).getApps(),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 30.height),
                      children: [
                        20.verticalSpacer,
                        _buildHeader(),
                        if (developerState.latestCreatedApp != null) ...[
                          20.verticalSpacer,
                          _buildSecretCard(developerState.latestCreatedApp!),
                        ],
                        20.verticalSpacer,
                        _buildCreateSection(developerState),
                        20.verticalSpacer,
                        if (apps.isEmpty && !developerState.isCreating)
                          _buildEmptyState()
                        else ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimens.horizontalPadding,
                            ),
                            child: Text(
                              "Registered Apps",
                              style: appStyles.cardTitle,
                            ),
                          ),
                          15.verticalSpacer,
                          ...apps.map(_buildAppCard),
                        ],
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

  Widget _buildHeader() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Developer Dashboard", style: appStyles.sectionTitle),
          8.verticalSpacer,
          Text(
            "Register OAuth apps, review issued client IDs, and manage access from your ToroPass wallet.",
            style: appStyles.body.copyWith(
              color: appColors.text.withAlpha(190),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateSection(DeveloperStateModel state) {
    final appColors = AppColors.of(context);

    return AnimatedSize(
      duration: Animations.duration,
      child: state.isCreating
          ? Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppDimens.horizontalPadding,
              ),
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
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextfieldLabel(label: "App Name"),
                  AppTextfield(
                    hint: "Enter your app name",
                    controller: _nameController,
                    error: state.nameError,
                    onChanged: (_) =>
                        ref.read(developerProvider.notifier).clearNameError(),
                  ),
                  15.verticalSpacer,
                  TextfieldLabel(label: "Callback/Redirect URI"),
                  AppTextfield(
                    hint: "https://yourapp.com/callback",
                    controller: _callbackController,
                    error: state.redirectUriError,
                    onChanged: (_) => ref
                        .read(developerProvider.notifier)
                        .clearRedirectUriError(),
                  ),
                  20.verticalSpacer,
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Cancel",
                          hollow: true,
                          callback: _cancelCreate,
                        ),
                      ),
                      12.horizontalSpacer,
                      Expanded(
                        child: AppButton(
                          text: "Generate API Keys",
                          prefix: FieldWidget(
                            child: AppSvg(
                              path: Assets.icons.key,
                              width: 24.width,
                              height: 24.height,
                              color: appColors.white,
                            ),
                          ),
                          callback: _registerApp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.horizontalPadding,
              ),
              child: AppButton(
                text: "Create Application",
                callback: () =>
                    ref.read(developerProvider.notifier).showCreateForm(),
              ),
            ),
    );
  }

  Widget _buildSecretCard(DeveloperAppEntity app) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
        vertical: 20.height,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(AppDimens.dialogBorderRadius),
        border: Border.all(color: appColors.primary.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withAlpha(10),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.radius),
                decoration: BoxDecoration(
                  color: appColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: appColors.primary,
                  size: 22.width,
                ),
              ),
              12.horizontalSpacer,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Save Your Client Secret", style: appStyles.cardTitle),
                    6.verticalSpacer,
                    Text(
                      "This is the only time the plain client secret will be shown. Copy it now and store it safely.",
                      style: appStyles.caption.copyWith(
                        color: appColors.text.withAlpha(190),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          18.verticalSpacer,
          _buildSecretField("App Name", app.name ?? 'Unknown App'),
          12.verticalSpacer,
          _buildSecretField("Client ID", app.clientId ?? ''),
          12.verticalSpacer,
          _buildSecretField(
            "Client Secret",
            app.clientSecret ?? '',
            sensitive: true,
          ),
          12.verticalSpacer,
          _buildSecretField("Redirect URI", app.redirectUri ?? ''),
          18.verticalSpacer,
          AppButton(
            text: "I've Saved It",
            callback: () =>
                ref.read(developerProvider.notifier).dismissLatestCreatedApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretField(
    String label,
    String value, {
    bool sensitive = false,
  }) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 12.height),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        border: Border.all(color: appColors.primary.withAlpha(25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: appStyles.captionBold.copyWith(
                    color: appColors.text.withAlpha(150),
                  ),
                ),
                6.verticalSpacer,
                Text(
                  value,
                  style: appStyles.body.copyWith(
                    color: sensitive ? appColors.header : appColors.text,
                    fontFamily: sensitive
                        ? FontFamily.interMedium
                        : FontFamily.interRegular,
                  ),
                ),
              ],
            ),
          ),
          12.horizontalSpacer,
          AppInkWell(
            callback: () => _copyToClipboard(label, value),
            child: Icon(
              Icons.content_copy_rounded,
              color: appColors.primary,
              size: 20.width,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppCard(DeveloperAppEntity app) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
      ).add(EdgeInsets.only(bottom: 15.height)),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
        vertical: 18.height,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(AppDimens.dialogBorderRadius),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withAlpha(10),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.name ?? 'Unknown App', style: appStyles.cardTitle),
                    6.verticalSpacer,
                    Text(
                      _formatCreatedAt(app.createdAt),
                      style: appStyles.caption.copyWith(
                        color: appColors.text.withAlpha(170),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.width,
                  vertical: 4.height,
                ),
                decoration: BoxDecoration(
                  color:
                      (app.isActive == true
                              ? appColors.success
                              : appColors.error)
                          .withAlpha(18),
                  borderRadius: BorderRadius.circular(AppDimens.miniRadius),
                ),
                child: Text(
                  app.isActive == true ? 'ACTIVE' : 'INACTIVE',
                  style: appStyles.caption.copyWith(
                    color: app.isActive == true
                        ? appColors.success
                        : appColors.error,
                  ),
                ),
              ),
            ],
          ),
          14.verticalSpacer,
          _buildAppDetail("Client ID", app.clientId ?? ''),
          10.verticalSpacer,
          _buildAppDetail("Redirect URI", app.redirectUri ?? ''),
          18.verticalSpacer,
          Align(
            alignment: Alignment.centerRight,
            child: AppInkWell(
              callback: () {
                final appId = app.id;
                if (appId == null || appId.isEmpty) return;
                ref.read(developerProvider.notifier).deleteApp(appId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.width,
                  vertical: 9.height,
                ),
                decoration: BoxDecoration(
                  color: appColors.error.withAlpha(12),
                  borderRadius: BorderRadius.circular(24.radius),
                  border: Border.all(color: appColors.error.withAlpha(70)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: appColors.error,
                      size: 18.width,
                    ),
                    8.horizontalSpacer,
                    Text(
                      "Delete App",
                      style: appStyles.caption.copyWith(
                        color: appColors.error,
                        fontFamily: FontFamily.interSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDetail(String label, String value) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appStyles.captionBold.copyWith(
            color: appColors.text.withAlpha(150),
          ),
        ),
        4.verticalSpacer,
        Text(
          value,
          style: appStyles.body.copyWith(color: appColors.text.withAlpha(210)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
        vertical: 26.height,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(AppDimens.dialogBorderRadius),
        border: Border.all(color: appColors.primary.withAlpha(30)),
      ),
      child: Column(
        children: [
          AppSvg(
            path: Assets.icons.key,
            width: 28.width,
            height: 28.height,
            color: appColors.primary,
          ),
          14.verticalSpacer,
          Text("Register Your First dApp", style: appStyles.cardTitle),
          8.verticalSpacer,
          Text(
            "Create an application to receive your client credentials and start using ToroPass verification in your product.",
            textAlign: TextAlign.center,
            style: appStyles.caption.copyWith(
              color: appColors.text.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerApp() async {
    final success = await ref
        .read(developerProvider.notifier)
        .registerApp(
          name: _nameController.text,
          redirectUri: _callbackController.text,
        );

    if (!mounted || !success) return;
    _nameController.clear();
    _callbackController.clear();
  }

  void _cancelCreate() {
    _nameController.clear();
    _callbackController.clear();
    ref.read(developerProvider.notifier).hideCreateForm();
  }

  Future<void> _copyToClipboard(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ref.read(snackbarProvider).display(message: "$label copied to clipboard.");
  }

  String _formatCreatedAt(DateTime? createdAt) {
    if (createdAt == null) return "Created recently";
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "Created ${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}";
  }
}
