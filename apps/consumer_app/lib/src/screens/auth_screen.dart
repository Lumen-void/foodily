import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';
import 'home_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _controller = TextEditingController(text: '+91 ');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(widget.locale);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FoodilyColors.surface,
                    FoodilyColors.blue.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        final newLocale = widget.locale.languageCode == 'en'
                            ? const Locale('hi')
                            : const Locale('en');
                        widget.onLocaleChanged(newLocale);
                      },
                      child: Text(
                        widget.locale.languageCode == 'en'
                            ? 'हिंदी'
                            : 'English',
                      ),
                    ),
                  ),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FoodilyRadii.xl),
                      boxShadow: FoodilyShadows.premium,
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 270,
                          width: double.infinity,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(
                              color: FoodilyColors.navy,
                              child: Center(
                                child: Icon(
                                  Icons.restaurant_menu_outlined,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  FoodilyColors.navy.withValues(alpha: 0.92),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 18,
                          right: 18,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Foodily',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Restaurants, dhabhas and tiffin meals by your time slot',
                                style: TextStyle(color: Color(0xFFDDEBFF)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _LandingTag(label: 'STANDARD', color: FoodilyColors.accentYellow),
                      _LandingTag(label: 'FAST DELIVERY', color: Color(0xFFE8F0FF)),
                      _LandingTag(label: 'CUSTOM MEALS', color: Color(0xFFE8F0FF)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.text('otpTitle'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Use any 4-digit OTP in demo mode.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _controller,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => HomeShell(
                                      locale: widget.locale,
                                      onLocaleChanged: widget.onLocaleChanged,
                                      appState: AppState(),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.message_outlined),
                              label: Text(strings.text('sendOtp')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingTag extends StatelessWidget {
  const _LandingTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(FoodilyRadii.md),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
          color: FoodilyColors.navy,
          fontSize: 11,
        ),
      ),
    );
  }
}
