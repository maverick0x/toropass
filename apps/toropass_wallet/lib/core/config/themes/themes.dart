import 'package:flutter/material.dart';

import '../../../generated/fonts.gen.dart';
import 'colors.dart';
import 'dimens.dart';

extension ThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
}

class AppThemes {
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
        fillColor: colors.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
