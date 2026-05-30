import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_id_provider.dart';

class HMAC {
  final String deviceId;
  final String timestamp;
  final String signature;

  HMAC({
    required this.deviceId,
    required this.timestamp,
    required this.signature,
  });
}

final hmacProvider = Provider<HMAC Function()>((ref) {
  return () {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();

    final deviceId = ref.read(deviceIdProvider);
    final secretKey = dotenv.env['APP_SECRET'] ?? "";
    final message = '$timestamp:$deviceId';

    final signature = Hmac(
      sha256,
      utf8.encode(secretKey),
    ).convert(utf8.encode(message)).toString();

    return HMAC(timestamp: timestamp, signature: signature, deviceId: deviceId);
  };
});
