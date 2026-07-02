import 'package:flutter/material.dart';

class SettingsController {
  // Singleton
  static final SettingsController instance = SettingsController._internal();
  SettingsController._internal();

  // Settings state
  final ValueNotifier<bool> isRtlNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> textScaleNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<bool> isKiswahiliNotifier = ValueNotifier<bool>(false);

  void toggleRtl(bool value) {
    isRtlNotifier.value = value;
  }

  void updateTextScale(double scale) {
    textScaleNotifier.value = scale;
  }

  void toggleKiswahili(bool value) {
    isKiswahiliNotifier.value = value;
  }
}
