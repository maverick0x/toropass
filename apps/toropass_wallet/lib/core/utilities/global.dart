import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Global {
  static Future<int?> getAndroidSdkInt() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      return androidInfo.version.sdkInt;
    }

    return null; // Not an Android device
  }
}
