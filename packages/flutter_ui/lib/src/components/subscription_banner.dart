import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key, required this.onSubscribe});

  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FoodilyColors.blue, FoodilyColors.navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FoodilyRadii.xl),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Week Plans from ₹699',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Breakfast, lunch and dinner with custom delivery slots.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _Pill(text: 'Pause anytime'),
                    SizedBox(width: 6),
                    _Pill(text: 'Wallet cashback'),
                  ],
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onSubscribe,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: FoodilyColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FoodilyRadii.lg),
              ),
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
