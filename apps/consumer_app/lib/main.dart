import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/consumer_app.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };
      ErrorWidget.builder = (details) {
        return Material(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 44),
                  const SizedBox(height: 10),
                  const Text(
                    'Something went wrong while rendering this screen.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exceptionAsString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        );
      };
      runApp(const ConsumerBootstrap());
    },
    (error, stack) {
      debugPrint('Consumer app uncaught error: $error');
      debugPrint('$stack');
    },
  );
}

class ConsumerBootstrap extends StatefulWidget {
  const ConsumerBootstrap({super.key});

  @override
  State<ConsumerBootstrap> createState() => _ConsumerBootstrapState();
}

class _ConsumerBootstrapState extends State<ConsumerBootstrap> {
  Locale _locale = const Locale('en');
  static const _localePreferenceKey = 'consumer.locale_code';

  static const List<Locale> _frameworkSupportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  Locale _frameworkLocaleFor(Locale locale) {
    if (locale.languageCode == 'en') return const Locale('en');
    return const Locale('hi');
  }

  Locale _resolveFrameworkLocale(
    Locale? requested,
    Iterable<Locale> supported,
  ) {
    final fallback = _frameworkLocaleFor(_locale);
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
  void initState() {
    super.initState();
    unawaited(_restoreLocalePreference());
  }

  void _switchLocale(Locale locale) {
    if (_locale.languageCode == locale.languageCode) return;
    AppLiveTranslator.instance.updateLocale(locale);
    setState(() {
      _locale = locale;
    });
    unawaited(_persistLocalePreference(locale));
  }

  Future<void> _restoreLocalePreference() async {
    final restored = await _readLocalePreference();
    if (!mounted) return;
    final nextLocale = restored ?? _locale;
    AppLiveTranslator.instance.updateLocale(nextLocale);
    if (restored != null && restored.languageCode != _locale.languageCode) {
      setState(() {
        _locale = restored;
      });
    }
  }

  Future<Locale?> _readLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localePreferenceKey);
      if (code == null || code.isEmpty) return null;
      return Locale(code.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistLocalePreference(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePreferenceKey, locale.languageCode);
    } catch (_) {
      // Keep UI responsive even if persistence is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLiveTranslator.instance,
      builder: (context, _) {
        final frameworkLocale = _frameworkLocaleFor(_locale);
        final lightTheme = FoodilyTheme.light(locale: _locale);
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
              borderSide: const BorderSide(
                color: FoodilyColors.blue,
                width: 1.4,
              ),
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
          iconTheme: const IconThemeData(color: Color(0xFFE5E7EB)),
          dividerTheme: const DividerThemeData(color: Color(0xFF1F2937)),
        );
        return MaterialApp(
          title: 'Foodily',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          locale: frameworkLocale,
          supportedLocales: _frameworkSupportedLocales,
          localeResolutionCallback: (locale, supportedLocales) {
            return _resolveFrameworkLocale(locale, supportedLocales);
          },
          localeListResolutionCallback: (locales, supportedLocales) {
            if (locales == null || locales.isEmpty) {
              return _resolveFrameworkLocale(_locale, supportedLocales);
            }
            for (final locale in locales) {
              final resolved = _resolveFrameworkLocale(
                locale,
                supportedLocales,
              );
              if (supportedLocales.any(
                (candidate) => candidate.languageCode == resolved.languageCode,
              )) {
                return resolved;
              }
            }
            return _resolveFrameworkLocale(_locale, supportedLocales);
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ConsumerApp(onLocaleChanged: _switchLocale, locale: _locale),
        );
      },
    );
  }
}
