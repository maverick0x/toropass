import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utilities/logger.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      // Ensure that bindings are initialized inside the same zone
      WidgetsFlutterBinding.ensureInitialized();

      // Set up your services and dependencies inside the Zone
      await dotenv.load();
      runApp(ProviderScope(child: ToroPassApp()));
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
