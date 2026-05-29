import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class StickyCheckoutBar extends StatelessWidget {
  const StickyCheckoutBar({
    super.key,
    required this.total,
    required this.primaryLabel,
    required this.onPressed,
  });

  final int total;
  final String primaryLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        color: Colors.white,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 84, maxHeight: 104),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8EDF7))),
              boxShadow: FoodilyShadows.premium,
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.black54)),
                    Text(
                      '₹$total',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: FoodilyColors.navy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FoodilyRadii.lg),
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
