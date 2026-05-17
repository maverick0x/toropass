import 'package:flutter/material.dart';

import '../../../generated/fonts.gen.dart';
import 'colors.dart';

extension ThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
}

class AppThemes {
  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData get light => _buildTheme(appColors, Brightness.light);

  static ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: FontFamily.interRegular,
      scaffoldBackgroundColor: colors.surface,
      dividerColor: colors.neutral,

      // Inject the extension so context.colors works
      extensions: [colors],

      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        fillColor: colors.transparent,
        // Standard borders using the dynamic colors
        border: _border(colors.transparent, width: 0),
        disabledBorder: _border(colors.neutral.withAlpha(50)),
        enabledBorder: _border(colors.neutral),
        focusedBorder: _border(colors.primary),
        errorBorder: _border(colors.error),
        // Text styles from our app_styles
        labelStyle: TextStyle(color: colors.neutral.withAlpha(200)),
        hintStyle: TextStyle(color: colors.neutral.withAlpha(120)),
      ),
    );
  }
}
