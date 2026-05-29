import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class CartCtaBar extends StatelessWidget {
  const CartCtaBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  final int itemCount;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: FoodilyColors.navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined),
            const SizedBox(width: 10),
            Text(
              '${'View cart'.tr(context)} • $itemCount ${itemCount == 1 ? 'item'.tr(context) : 'items'.tr(context)}',
            ),
            const Spacer(),
            Text(
              '₹$total',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
