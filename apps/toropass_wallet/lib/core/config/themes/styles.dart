import 'package:flutter/material.dart'
    show TextStyle, BuildContext, Color, Theme, Colors;

import '../../../generated/fonts.gen.dart';
import '../../utilities/extensions/numbers.dart';

extension AppStylesExtension on BuildContext {
  AppStyles get appStyles => AppStyles(this);
}

class AppStyles {
  final BuildContext context;
  AppStyles(this.context);

  // Helper to get the default text color based on theme
  Color get _defaultColor =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  // H1
  TextStyle get pageTitle => TextStyle(
    fontSize: 28.font,
    fontFamily: FontFamily.plusJakartaSansBold,
    color: _defaultColor,
  );

  // H2
  TextStyle get sectionTitle => TextStyle(
    fontSize: 22.font,
    fontFamily: FontFamily.plusJakartaSansSemiBold,
    color: _defaultColor,
  );

  // H3
  TextStyle get cardTitle => TextStyle(
    fontSize: 18.font,
    fontFamily: FontFamily.plusJakartaSansMedium,
    color: _defaultColor,
  );

  // Body
  TextStyle get body => TextStyle(
    fontSize: 16.font,
    fontFamily: FontFamily.interRegular,
    color: _defaultColor,
  );

  TextStyle get bodyMedium => TextStyle(
    fontSize: 16.font,
    fontFamily: FontFamily.interMedium,
    color: _defaultColor,
  );

  // Button
  TextStyle get button => TextStyle(
    fontSize: 16.font,
    fontFamily: FontFamily.plusJakartaSansSemiBold,
    color: _defaultColor,
  );

  // Caption / Label
  TextStyle get caption => TextStyle(
    fontSize: 12.font,
    fontFamily: FontFamily.interMedium,
    color: _defaultColor.withAlpha(200),
  );

  TextStyle get captionBold => TextStyle(
    fontSize: 12.font,
    fontFamily: FontFamily.interMedium,
    color: _defaultColor.withAlpha(200),
  );

  // Caption / Label
  TextStyle get caption2 => TextStyle(
    fontSize: 12.font,
    fontFamily: FontFamily.plusJakartaSansRegular,
    color: _defaultColor.withAlpha(150),
  );
}
