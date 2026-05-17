import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/utilities/logger.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      // Ensure that bindings are initialized inside the same zone
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Set up your services and dependencies inside the Zone
      // await dotenv.load();
      final storageInstance = await StorageService.getInstance();

      runApp(
        ProviderScope(
          overrides: [
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
