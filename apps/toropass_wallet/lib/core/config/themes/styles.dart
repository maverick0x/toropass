import 'package:flutter/material.dart' show TextStyle, BuildContext;

import '../../../generated/fonts.gen.dart';
import '../../utilities/extensions/numbers.dart';
import 'colors.dart';

extension AppStylesExtension on BuildContext {
  AppStyles get appStyles => AppStyles(this);
}

class AppStyles {
  final BuildContext context;
  AppStyles(this.context);

  // Helper to get the default text color based on theme
  AppColors get _appColors => AppColors.of(context);

  // H1
  TextStyle get pageTitle => TextStyle(
    fontSize: 28.font,
    fontFamily: FontFamily.plusJakartaSansBold,
    color: _appColors.header,
  );

  // H2
  TextStyle get sectionTitle => TextStyle(
    fontSize: 22.font,
    fontFamily: FontFamily.plusJakartaSansSemiBold,
    color: _appColors.header,
  );

  // H3
  TextStyle get cardTitle => TextStyle(
    fontSize: 18.font,
    fontFamily: FontFamily.plusJakartaSansMedium,
    color: _appColors.header,
  );

  // Body
  TextStyle get body => TextStyle(
    fontSize: 16.font,
    fontFamily: FontFamily.interRegular,
    color: _appColors.text,
  );

  TextStyle get bodyMedium => TextStyle(
    fontSize: 16.font,
    fontFamily: FontFamily.interMedium,
    color: _appColors.text,
  );

  // Button
  TextStyle get button => TextStyle(
    fontSize: 17.font,
    fontFamily: FontFamily.plusJakartaSansBold,
    color: _appColors.text,
  );

  // Caption / Label
  TextStyle get caption => TextStyle(
    fontSize: 12.font,
    fontFamily: FontFamily.interMedium,
    color: _appColors.text.withAlpha(200),
  );

  TextStyle get captionBold => TextStyle(
    fontSize: 12.font,
    fontFamily: FontFamily.interMedium,
    color: _appColors.text.withAlpha(200),
  );

  // Caption / Label
  TextStyle get caption2 => TextStyle(
    fontSize: 12.font,
    fontFamily: FontFamily.plusJakartaSansRegular,
    color: _appColors.text.withAlpha(150),
  );
}
