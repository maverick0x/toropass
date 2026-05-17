import 'package:flutter/material.dart';

import '../../core/config/themes/colors.dart';
import '../../core/utilities/extensions/numbers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Template')),
      body: Center(
        child: Text(
          'SPLASH SCREEN',
          style: TextStyle(
            color: appColors.primary,
            fontSize: 24.font,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
