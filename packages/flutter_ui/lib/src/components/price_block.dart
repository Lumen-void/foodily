import 'package:flutter/material.dart';

class PriceBlock extends StatelessWidget {
  const PriceBlock({
    super.key,
    required this.total,
    required this.walletApplied,
  });

  final int total;
  final int walletApplied;

  @override
  Widget build(BuildContext context) {
    final payable = total + walletApplied;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF7)),
      ),
      child: Column(
        children: [
          _row('Subtotal', '₹$total'),
          _row('Wallet', '-₹${walletApplied.abs()}'),
          const Divider(),
          _row('Payable', '₹$payable', strong: true),
        ],
      ),
    );
  }

  Widget _row(String left, String right, {bool strong = false}) {
    final style = TextStyle(
      fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(left, style: style),
          const Spacer(),
          Text(right, style: style),
        ],
      ),
    );
  }
}
