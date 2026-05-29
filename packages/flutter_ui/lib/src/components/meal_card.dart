import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    required this.onOrder,
    this.onCustomize,
  });

  final Meal meal;
  final VoidCallback onOrder;
  final VoidCallback? onCustomize;

  @override
  Widget build(BuildContext context) {
    final statusLabel = meal.available ? 'Available' : 'Sold out';
    final statusColor = meal.available
        ? FoodilyColors.success
        : FoodilyColors.danger;
    final slotLabel = switch (meal.slot) {
      MealSlot.breakfast => 'Breakfast',
      MealSlot.lunch => 'Lunch',
      MealSlot.dinner => 'Dinner',
    };
    final slotTime = switch (meal.slot) {
      MealSlot.breakfast => '7-9 AM',
      MealSlot.lunch => '12-2 PM',
      MealSlot.dinner => '7-9 PM',
    };

    return SizedBox(
      width: 256,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(FoodilyRadii.md),
                    child: AspectRatio(
                      aspectRatio: 1.45,
                      child: Image.network(
                        meal.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const ColoredBox(
                            color: Color(0xFFE2E8F0),
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFE2E8F0),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(FoodilyRadii.md),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                meal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (meal.placeName.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  meal.placeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 3),
              Text(
                '$slotLabel ($slotTime)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                '${meal.calories} kcal • ${meal.prepTimeMin} min prep',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    meal.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${meal.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FoodilyColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: meal.tags
                          .take(2)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(FoodilyRadii.md),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: meal.available ? onOrder : null,
                    child: const Text('Order now'),
                  ),
                  if (meal.customisable && onCustomize != null)
                    IconButton(
                      onPressed: onCustomize,
                      icon: const Icon(Icons.tune_outlined, size: 18),
                      tooltip: 'Customize',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
