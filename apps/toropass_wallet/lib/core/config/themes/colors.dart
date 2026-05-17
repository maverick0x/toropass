import 'package:flutter/material.dart';

// --- Palettes ---
final appColors = AppColors(
  primary: Color(0xFF0052FF),
  secondary: Color(0xFF9D4EDD),
  tertiary: Color(0xFF00F5FF),
  neutral: Color(0xFF0A0B0D),
  error: Color(0xFF93000A),
  success: Color(0xFF2E7D32),
  surface: Color(0xFFFBF9FB),
  surfaceDim: Color(0xFFDBD9DC),
  surfaceContainer: Color(0xFFEFEDF0),
);

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color neutral;
  final Color transparent;
  final Color barrier;
  final Color white;
  final Color black;
  final Color error;
  final Color success;
  final Color surface;
  final Color surfaceDim;
  final Color surfaceContainer;

  AppColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.neutral,
    required this.error,
    required this.success,
    required this.surface,
    required this.surfaceDim,
    required this.surfaceContainer,
    this.barrier = const Color(0x80000000), // 50% opacity black
    this.white = const Color(0xFFFFFFFF),
    this.black = const Color(0xFF000000),
    this.transparent = Colors.transparent,
  });

  // Access helper: context.colors
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? neutral,
    Color? transparent,
    Color? barrier,
    Color? white,
    Color? black,
    Color? error,
    Color? success,
    Color? surface,
    Color? surfaceDim,
    Color? surfaceContainer,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      neutral: neutral ?? this.neutral,
      transparent: transparent ?? this.transparent,
      barrier: barrier ?? this.barrier,
      white: white ?? this.white,
      black: black ?? this.black,
      error: error ?? this.error,
      success: success ?? this.success,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
      barrier: Color.lerp(barrier, other.barrier, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
    );
  }
}
