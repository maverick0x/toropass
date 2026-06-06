import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/router/routes.dart';
import '../../../../core/config/themes/colors.dart';
import '../../../../core/config/themes/dimens.dart';
import '../../../../core/config/themes/styles.dart';
import '../../../../core/utilities/extensions/numbers.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../shared/app_bar.dart';
import '../../../../shared/app_button.dart';
import '../../../../shared/app_svg.dart';
import '../../../../shared/app_textfield.dart';
import '../formatter/phone_number_formatter.dart';
import '../provider/kyc_notifier.dart';
import '../validator/kyc_validator.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bvnController;
  late final TextEditingController _currencyController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bvnController = TextEditingController();
    _currencyController = TextEditingController(text: "NGN");
    _phoneNumberController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _bvnController.dispose();
    _currencyController.dispose();
    _phoneNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);
    final kycState = ref.watch(kycProvider);
    final verifyKycState = kycState.verifyKycState;
    final isLoading = verifyKycState is DataLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              TopBar(title: "Verification"),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    20.verticalSpacer,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.width),
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        children: [
                          Text("Verify Identity", style: appStyles.cardTitle),
                          5.verticalSpacer,
                          Text(
                            "Your data is encrypted and never shared publicly.",
                            style: appStyles.caption.copyWith(
                              color: appColors.text.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.verticalSpacer,
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDimens.horizontalPadding,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 20.height,
                        horizontal: 20.width,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: appColors.shadow.withAlpha(20),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        children: [
                          TextfieldLabel(label: "First Name"),
                          AppTextfield(
                            hint: "John",
                            controller: _firstNameController,
                            error: kycState.firstNameError,
                            onChanged: (_) => ref
                                .read(kycProvider.notifier)
                                .clearFirstNameError(),
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Middle Name"),
                          AppTextfield(
                            hint: "James",
                            controller: _middleNameController,
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Last Name"),
                          AppTextfield(
                            hint: "Doe",
                            controller: _lastNameController,
                            error: kycState.lastNameError,
                            onChanged: (_) => ref
                                .read(kycProvider.notifier)
                                .clearLastNameError(),
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "BVN"),
                          AppTextfield(
                            hint: "1234567890",
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            controller: _bvnController,
                            error: kycState.bvnError,
                            onChanged: (_) =>
                                ref.read(kycProvider.notifier).clearBvnError(),
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Currency"),
                          AppTextfield(
                            hint: "NGN",
                            controller: _currencyController,
                            readOnly: true,
                            suffix: Icon(
                              Icons.lock_outline_rounded,
                              color: appColors.text.withAlpha(140),
                              size: 18.width,
                            ),
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Phone Number"),
                          AppTextfield(
                            hint: "801 234 5678",
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              PhoneNumberFormatter(),
                              LengthLimitingTextInputFormatter(12),
                            ],
                            controller: _phoneNumberController,
                            error: kycState.phoneNumberError,
                            prefix: Padding(
                              padding: EdgeInsets.only(
                                left: 16.width,
                                right: 10.width,
                              ),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  KycValidator.phoneCountryCode,
                                  style: appStyles.body.copyWith(
                                    color: appColors.text.withAlpha(180),
                                  ),
                                ),
                              ),
                            ),
                            onChanged: (_) => ref
                                .read(kycProvider.notifier)
                                .clearPhoneNumberError(),
                          ),
                          15.verticalSpacer,
                          TextfieldLabel(label: "Date of Birth"),
                          AppTextfield(
                            hint: "Select date of birth",
                            controller: _dobController,
                            readOnly: true,
                            error: kycState.dobError,
                            suffix: Icon(
                              Icons.calendar_month_rounded,
                              color: appColors.primary,
                              size: 20.width,
                            ),
                            onTap: _pickDateOfBirth,
                          ),
                          10.verticalSpacer,
                        ],
                      ),
                    ),
                    30.verticalSpacer,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.horizontalPadding,
                      ),
                      child: AppButton(
                        text: isLoading ? "Verifying..." : "Verify",
                        callback: isLoading ? null : _submitKyc,
                      ),
                    ),
                    30.verticalSpacer,
                    Align(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .center,
                        children: [
                          AppSvg(
                            path: Assets.icons.lock,
                            width: 15.width,
                            height: 15.height,
                            color: appColors.text.withAlpha(150),
                          ),
                          10.verticalSpacer,
                          Text(
                            "Powered by secure cryptographic protocols.\nThis"
                            " process usually takes less than\n60 seconds.",
                            textAlign: TextAlign.center,
                            style: appStyles.caption.copyWith(
                              color: appColors.text.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                    15.verticalSpacer,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitKyc() async {
    final success = await ref
        .read(kycProvider.notifier)
        .submitKyc(
          firstName: _firstNameController.text,
          middleName: _middleNameController.text,
          lastName: _lastNameController.text,
          bvn: _bvnController.text,
          phoneNumber: _phoneNumberController.text,
          dob: _dobController.text,
        );

    if (!mounted || !success) return;
    context.pushNamed(AppRoutes.SUCCESS_SCREEN);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate =
        DateTime.tryParse(_dobController.text) ??
        DateTime(now.year - 18, now.month, now.day);
    final appColors = AppColors.of(context);
    final appStyles = context.appStyles;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        final baseTheme = Theme.of(context);
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: ColorScheme.light(
              primary: appColors.primary,
              onPrimary: appColors.white,
              surface: appColors.white,
              onSurface: appColors.header,
              secondary: appColors.secondary,
              onSecondary: appColors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: appColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.dialogBorderRadius,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: appColors.primary,
                textStyle: appStyles.bodyMedium,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: appColors.surface,
              surfaceTintColor: appColors.transparent,
              headerBackgroundColor: appColors.primary,
              headerForegroundColor: appColors.white,
              weekdayStyle: appStyles.caption.copyWith(
                color: appColors.text.withAlpha(180),
              ),
              dayStyle: appStyles.body,
              yearStyle: appStyles.body,
              todayForegroundColor: WidgetStatePropertyAll(appColors.primary),
              todayBackgroundColor: WidgetStatePropertyAll(
                appColors.primary.withAlpha(20),
              ),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return appColors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return appColors.text.withAlpha(90);
                }
                return appColors.header;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return appColors.primary;
                }
                return null;
              }),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return appColors.white;
                }
                return appColors.header;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return appColors.primary;
                }
                return null;
              }),
              rangeSelectionBackgroundColor: appColors.primary.withAlpha(18),
              dividerColor: appColors.primary.withAlpha(30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.dialogBorderRadius,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    _dobController.text = '${picked.year}-$month-$day';
    ref.read(kycProvider.notifier).clearDobError();
  }
}
