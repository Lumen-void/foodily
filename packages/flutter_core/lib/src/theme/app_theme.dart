import 'package:flutter/material.dart';

class FoodilyColors {
  // Brand tokens from Figma handoff.
  static const Color navy = Color(0xFF004274);
  static const Color blue = Color(0xFF2563EB);
  static const Color accentYellow = Color(0xFFFFCC4D);
  static const Color accentRed = Color(0xFFFF9B9B);

  static const Color surface = Color(0xFFF9FAFB);
  static const Color card = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textMuted = Color(0xFF4B5563);

  static const Color success = Color(0xFF1A8F46);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDB3A34);
}

class FoodilyRadii {
  static const double xl = 40;
  static const double lg = 32;
  static const double md = 24;
}

class FoodilyShadows {
  static const List<BoxShadow> premium = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 50,
      offset: Offset(0, 20),
    ),
  ];
}

class FoodilyTheme {
  static ThemeData light({Locale? locale}) {
    final useSystemFont = locale != null && locale.languageCode != 'en';
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: FoodilyColors.blue),
      scaffoldBackgroundColor: FoodilyColors.surface,
      fontFamily: useSystemFont ? null : 'Inter',
    );

    final textTheme = base.textTheme.apply(
      bodyColor: FoodilyColors.textPrimary,
      displayColor: FoodilyColors.textPrimary,
      fontFamily: useSystemFont ? null : 'Inter',
    );

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: FoodilyColors.blue,
        secondary: FoodilyColors.accentYellow,
        surface: FoodilyColors.card,
        error: FoodilyColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: FoodilyColors.card,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: FoodilyColors.navy,
        titleTextStyle: TextStyle(
          color: FoodilyColors.navy,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: FoodilyColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.lg),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: FoodilyColors.card,
        selectedColor: FoodilyColors.accentYellow.withValues(alpha: 0.35),
        pressElevation: 0,
        shadowColor: Colors.transparent,
        selectedShadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        checkmarkColor: FoodilyColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
          color: FoodilyColors.textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
          color: FoodilyColors.textPrimary,
        ),
      ),
      textTheme: textTheme.copyWith(
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w900,
          color: FoodilyColors.navy,
          letterSpacing: -0.8,
        ),
        headlineSmall: const TextStyle(
          fontWeight: FontWeight.w900,
          color: FoodilyColors.navy,
          letterSpacing: -0.8,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        bodyMedium: const TextStyle(
          color: FoodilyColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
        bodySmall: const TextStyle(
          color: FoodilyColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FoodilyColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
          borderSide: const BorderSide(color: FoodilyColors.blue, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FoodilyColors.blue,
          foregroundColor: Colors.white,
          overlayColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FoodilyRadii.lg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FoodilyColors.navy,
          overlayColor: Colors.transparent,
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FoodilyRadii.lg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: FoodilyColors.navy,
          overlayColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FoodilyRadii.lg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FoodilyColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(FoodilyRadii.xl),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FoodilyColors.card,
        elevation: 0,
        indicatorColor: const Color(0x1A2563EB),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: FoodilyColors.navy,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FoodilyColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: FoodilyColors.blue,
        selectionColor: Color(0x332563EB),
        selectionHandleColor: FoodilyColors.blue,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB)),
      iconTheme: const IconThemeData(color: FoodilyColors.navy),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FoodilySlideFadePageTransitionsBuilder(),
          TargetPlatform.iOS: FoodilySlideFadePageTransitionsBuilder(),
          TargetPlatform.macOS: FoodilySlideFadePageTransitionsBuilder(),
          TargetPlatform.linux: FoodilySlideFadePageTransitionsBuilder(),
          TargetPlatform.windows: FoodilySlideFadePageTransitionsBuilder(),
        },
      ),
    );
  }
}

class FoodilySlideFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FoodilySlideFadePageTransitionsBuilder();

  static const _curve = Cubic(0.16, 1.0, 0.3, 1.0);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: _curve);
    final offsetTween = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).chain(CurveTween(curve: _curve));

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: animation.drive(offsetTween),
        child: child,
      ),
    );
  }
}
