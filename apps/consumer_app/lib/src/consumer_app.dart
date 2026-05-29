import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';

class ConsumerApp extends StatelessWidget {
  const ConsumerApp({
    super.key,
    required this.onLocaleChanged,
    required this.locale,
  });

  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return AuthScreen(locale: locale, onLocaleChanged: onLocaleChanged);
  }
}
