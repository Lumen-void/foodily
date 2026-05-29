import 'dart:async';

import 'package:delivery_app/src/delivery_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() => runApp(const DeliveryBootstrap()), (error, stack) {
    debugPrint('Delivery app uncaught error: $error');
    debugPrint('$stack');
  });
}

class DeliveryBootstrap extends StatelessWidget {
  const DeliveryBootstrap({super.key});

  static const List<Locale> _frameworkSupportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  static Locale _frameworkLocaleFor(Locale locale) {
    if (locale.languageCode == 'en') return const Locale('en');
    return const Locale('hi');
  }

  static Locale _resolveFrameworkLocale(
    Locale? requested,
    Iterable<Locale> supported,
  ) {
    final fallback = const Locale('en');
    if (requested == null) return fallback;
    final mapped = _frameworkLocaleFor(requested);
    for (final candidate in supported) {
      if (candidate.languageCode == mapped.languageCode) {
        return candidate;
      }
    }
    return supported.isEmpty ? fallback : supported.first;
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = FoodilyTheme.light().copyWith(
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(overlayColor: Colors.transparent),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      chipTheme: FoodilyTheme.light().chipTheme.copyWith(
        pressElevation: 0,
        shadowColor: Colors.transparent,
        selectedShadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
    final darkBase = ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FoodilyColors.navy,
        brightness: Brightness.dark,
      ),
    );
    final darkText = darkBase.textTheme.apply(
      bodyColor: const Color(0xFFE5E7EB),
      displayColor: const Color(0xFFE5E7EB),
    );
    final darkTheme = darkBase.copyWith(
      textTheme: darkText,
      scaffoldBackgroundColor: const Color(0xFF0B1017),
      appBarTheme: darkBase.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: const Color(0xFFE5E7EB),
        titleTextStyle: darkText.titleLarge?.copyWith(
          color: const Color(0xFFE5E7EB),
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: darkBase.cardTheme.copyWith(
        color: const Color(0xFF111827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.lg),
          side: const BorderSide(color: Color(0xFF1F2937)),
        ),
      ),
      inputDecorationTheme: darkBase.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF111827),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        labelStyle: const TextStyle(color: Color(0xFFD1D5DB)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
          borderSide: const BorderSide(color: FoodilyColors.blue, width: 1.4),
        ),
      ),
      navigationBarTheme: darkBase.navigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0x332563EB),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Color(0xFFE5E7EB),
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFE5E7EB),
          overlayColor: Colors.transparent,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(Color(0xFFE5E7EB)),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(overlayColor: Colors.transparent),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(overlayColor: Colors.transparent),
      ),
      chipTheme: darkBase.chipTheme.copyWith(
        backgroundColor: const Color(0xFF111827),
        selectedColor: const Color(0xFF1E3A8A),
        secondarySelectedColor: const Color(0xFF1E3A8A),
        side: const BorderSide(color: Color(0xFF374151)),
        checkmarkColor: const Color(0xFFE5E7EB),
        labelStyle: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontWeight: FontWeight.w700,
        ),
        pressElevation: 0,
        shadowColor: Colors.transparent,
        selectedShadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE5E7EB)),
      dividerTheme: const DividerThemeData(color: Color(0xFF1F2937)),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodily Restaurant Partner',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      supportedLocales: _frameworkSupportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        return _resolveFrameworkLocale(locale, supportedLocales);
      },
      localeListResolutionCallback: (locales, supportedLocales) {
        if (locales == null || locales.isEmpty) {
          return _resolveFrameworkLocale(null, supportedLocales);
        }
        for (final locale in locales) {
          final resolved = _resolveFrameworkLocale(locale, supportedLocales);
          if (supportedLocales.any(
            (candidate) => candidate.languageCode == resolved.languageCode,
          )) {
            return resolved;
          }
        }
        return _resolveFrameworkLocale(null, supportedLocales);
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DeliveryApp(),
    );
  }
}
