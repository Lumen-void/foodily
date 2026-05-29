import 'package:flutter/foundation.dart';

enum AppMode { demo, live }

class AppConfig {
  AppConfig._();

  static final ValueNotifier<AppMode> modeNotifier = ValueNotifier<AppMode>(
    _initialMode(),
  );

  static AppMode get mode => modeNotifier.value;

  static bool get isDemo => mode == AppMode.demo;

  static bool get isLive => mode == AppMode.live;

  static void setMode(AppMode mode) {
    if (modeNotifier.value == mode) return;
    modeNotifier.value = mode;
  }

  static AppMode _initialMode() {
    const mode = String.fromEnvironment('APP_MODE', defaultValue: 'demo');
    return mode.toLowerCase() == 'live' ? AppMode.live : AppMode.demo;
  }
}
