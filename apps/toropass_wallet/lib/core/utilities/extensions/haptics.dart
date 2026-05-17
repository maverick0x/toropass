import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension HapticsExt on BuildContext {
  void viberateLight() => HapticFeedback.lightImpact();
  void viberateMedium() => HapticFeedback.mediumImpact();
}
