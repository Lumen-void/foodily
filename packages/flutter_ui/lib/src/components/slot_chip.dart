import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class SlotChip extends StatelessWidget {
  const SlotChip({
    super.key,
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final MealSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, timeRange) = switch (slot) {
      MealSlot.breakfast => ('Breakfast', '7-9 AM'),
      MealSlot.lunch => ('Lunch', '12-2 PM'),
      MealSlot.dinner => ('Dinner', '7-9 PM'),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(FoodilyRadii.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1A2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
          border: Border.all(
            color: selected ? FoodilyColors.blue : const Color(0xFFE3E9F4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? FoodilyColors.blue : const Color(0xFF334155),
              ),
            ),
            Text(
              timeRange,
              style: TextStyle(
                fontSize: 11,
                color: selected ? FoodilyColors.blue : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
