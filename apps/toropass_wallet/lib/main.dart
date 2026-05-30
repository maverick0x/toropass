import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/device_id_provider.dart';
import 'core/services/storage_service.dart';
import 'core/utilities/logger.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      await dotenv.load(fileName: ".env");
      final storageInstance = await StorageService.getInstance();
      final String deviceId = await getDeviceId();

      runApp(
        ProviderScope(
          overrides: [
            deviceIdProvider.overrideWithValue(deviceId),
            storageServiceProvider.overrideWithValue(storageInstance),
          ],
          child: const ToroPassApp(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.log(
        error.toString(),
        name: "ERROR",
        error: error,
        trace: stackTrace,
      );
    },
  );
}
