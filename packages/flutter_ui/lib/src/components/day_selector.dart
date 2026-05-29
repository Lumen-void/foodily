import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelect,
  });

  final List<String> days;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(FoodilyRadii.md),
            onTap: () => onSelect(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? FoodilyColors.accentYellow.withValues(alpha: 0.35) : Colors.white,
                borderRadius: BorderRadius.circular(FoodilyRadii.md),
                border: Border.all(
                  color: isSelected
                      ? FoodilyColors.blue
                      : const Color(0xFFE3E9F4),
                ),
              ),
              child: Text(
                _short(day),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? FoodilyColors.navy : const Color(0xFF334155),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemCount: days.length,
      ),
    );
  }

  String _short(String day) {
    if (day.length <= 3) return day;
    return day.substring(0, 3);
  }
}
