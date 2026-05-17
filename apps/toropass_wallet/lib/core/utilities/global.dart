import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Global {
  static Future<int?> getAndroidSdkInt() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      return androidInfo.version.sdkInt;
    }

    return null; // Not an Android device
  }

  static Future<void> precacheAssets(
    BuildContext context,
    List<String> paths,
  ) async {
    for (final path in paths) {
      if (path.endsWith('.svg')) {
        final SvgAssetLoader loader = SvgAssetLoader(path);

        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        );
      } else {
        await precacheImage(AssetImage(path), context);
      }
    }
  }
}
