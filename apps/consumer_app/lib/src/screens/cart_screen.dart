import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final items = widget.appState.cartItems;

    return Scaffold(
      appBar: AppBar(title: Text('Cart Drawer'.tr(context))),
      body: items.isEmpty
          ? Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 38),
                      const SizedBox(height: 10),
                      Text(
                        'No items in cart'.tr(context),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add meals from home to continue checkout.'.tr(context),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = items[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: const Cubic(0.16, 1, 0.3, 1),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(FoodilyRadii.lg),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: isDark
                        ? const []
                        : const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.04),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        item.meal.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(
                              color: Color(0xFFE2E8F0),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.fastfood_outlined),
                              ),
                            ),
                      ),
                    ),
                    title: Text(
                      item.meal.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${'Qty'.tr(context)} ${item.qty} • ₹${item.meal.price}',
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.appState.removeFromCart(item.meal.id);
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: FoodilyColors.accentRed,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: items.length,
            ),
      bottomNavigationBar: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: isDark ? const [] : FoodilyShadows.premium,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total payable'.tr(context),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        '₹${widget.appState.cartTotal}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: items.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CheckoutScreen(appState: widget.appState),
                              ),
                            );
                          },
                    child: Text('Proceed to Checkout'.tr(context)),
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
