// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Inter-Bold.ttf
  String get interBold => 'assets/fonts/Inter-Bold.ttf';

  /// File path: assets/fonts/Inter-Medium.ttf
  String get interMedium => 'assets/fonts/Inter-Medium.ttf';

  /// File path: assets/fonts/Inter-Regular.ttf
  String get interRegular => 'assets/fonts/Inter-Regular.ttf';

  /// File path: assets/fonts/Inter-SemiBold.ttf
  String get interSemiBold => 'assets/fonts/Inter-SemiBold.ttf';

  /// File path: assets/fonts/PlusJakartaSans-Bold.ttf
  String get plusJakartaSansBold => 'assets/fonts/PlusJakartaSans-Bold.ttf';

  /// File path: assets/fonts/PlusJakartaSans-Medium.ttf
  String get plusJakartaSansMedium => 'assets/fonts/PlusJakartaSans-Medium.ttf';

  /// File path: assets/fonts/PlusJakartaSans-Regular.ttf
  String get plusJakartaSansRegular =>
      'assets/fonts/PlusJakartaSans-Regular.ttf';

  /// File path: assets/fonts/PlusJakartaSans-SemiBold.ttf
  String get plusJakartaSansSemiBold =>
      'assets/fonts/PlusJakartaSans-SemiBold.ttf';

  /// List of all assets
  List<String> get values => [
    interBold,
    interMedium,
    interRegular,
    interSemiBold,
    plusJakartaSansBold,
    plusJakartaSansMedium,
    plusJakartaSansRegular,
    plusJakartaSansSemiBold,
  ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/arrow-right.svg
  String get arrowRight => 'assets/icons/arrow-right.svg';

  /// File path: assets/icons/at.svg
  String get at => 'assets/icons/at.svg';

  /// File path: assets/icons/cancel.svg
  String get cancel => 'assets/icons/cancel.svg';

  /// File path: assets/icons/checkmark-circle.svg
  String get checkmarkCircle => 'assets/icons/checkmark-circle.svg';

  /// File path: assets/icons/checkmark-outlined.svg
  String get checkmarkOutlined => 'assets/icons/checkmark-outlined.svg';

  /// File path: assets/icons/checkmark.svg
  String get checkmark => 'assets/icons/checkmark.svg';

  /// File path: assets/icons/clipboard.svg
  String get clipboard => 'assets/icons/clipboard.svg';

  /// File path: assets/icons/connection.svg
  String get connection => 'assets/icons/connection.svg';

  /// File path: assets/icons/down-arrow.svg
  String get downArrow => 'assets/icons/down-arrow.svg';

  /// File path: assets/icons/help-circle.svg
  String get helpCircle => 'assets/icons/help-circle.svg';

  /// File path: assets/icons/id-card.svg
  String get idCard => 'assets/icons/id-card.svg';

  /// File path: assets/icons/key.svg
  String get key => 'assets/icons/key.svg';

  /// File path: assets/icons/lock.svg
  String get lock => 'assets/icons/lock.svg';

  /// File path: assets/icons/marketplace.svg
  String get marketplace => 'assets/icons/marketplace.svg';

  /// File path: assets/icons/plus.svg
  String get plus => 'assets/icons/plus.svg';

  /// File path: assets/icons/privacy.svg
  String get privacy => 'assets/icons/privacy.svg';

  /// File path: assets/icons/refresh.svg
  String get refresh => 'assets/icons/refresh.svg';

  /// File path: assets/icons/settings.svg
  String get settings => 'assets/icons/settings.svg';

  /// File path: assets/icons/universal.svg
  String get universal => 'assets/icons/universal.svg';

  /// File path: assets/icons/verified.svg
  String get verified => 'assets/icons/verified.svg';

  /// File path: assets/icons/wallet.svg
  String get wallet => 'assets/icons/wallet.svg';

  /// List of all assets
  List<String> get values => [
    arrowRight,
    at,
    cancel,
    checkmarkCircle,
    checkmarkOutlined,
    checkmark,
    clipboard,
    connection,
    downArrow,
    helpCircle,
    idCard,
    key,
    lock,
    marketplace,
    plus,
    privacy,
    refresh,
    settings,
    universal,
    verified,
    wallet,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/ToroPass.png
  AssetGenImage get toroPass =>
      const AssetGenImage('assets/images/ToroPass.png');

  /// File path: assets/images/splash.png
  AssetGenImage get splash => const AssetGenImage('assets/images/splash.png');

  /// File path: assets/images/splash_android12.png
  AssetGenImage get splashAndroid12 =>
      const AssetGenImage('assets/images/splash_android12.png');

  /// List of all assets
  List<AssetGenImage> get values => [toroPass, splash, splashAndroid12];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
