import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<List<WalletLedgerItem>> _ledgerFuture;
  late Future<OfferEvaluation> _offerFuture;

  @override
  void initState() {
    super.initState();
    _ledgerFuture = widget.appState.fetchWalletLedger();
    _offerFuture = widget.appState.evaluateOffers();
  }

  Future<void> _reload() async {
    setState(() {
      _ledgerFuture = widget.appState.fetchWalletLedger();
      _offerFuture = widget.appState.evaluateOffers();
    });
    await _ledgerFuture;
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.appState.currentCustomer;
    final referred = MockData.demoCustomers
        .where((item) => item.id != customer.id)
        .take(3)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Wallet & Offers'.tr(context))),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<WalletLedgerItem>>(
          future: _ledgerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final ledger = snapshot.data ?? const <WalletLedgerItem>[];
            final balance = ledger.fold(0, (sum, item) => sum + item.amount);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Available balance'.tr(context)),
                    subtitle: Text(
                      '${'Wallet for'.tr(context)} ${customer.name}',
                    ),
                    trailing: Text(
                      '₹$balance',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<OfferEvaluation>(
                  future: _offerFuture,
                  builder: (context, offerSnapshot) {
                    final offer = offerSnapshot.data;
                    return Card(
                      color: const Color(0xFFF8FAFF),
                      child: ListTile(
                        leading: const Icon(Icons.local_offer_outlined),
                        title: Text(
                          offer == null
                              ? 'Offers loading...'.tr(context)
                              : '${'Eligible savings'.tr(context)}: ₹${offer.discount}',
                        ),
                        subtitle: Text(
                          offer == null
                              ? 'Checking first-order, streak and surge-safe rules'
                                    .tr(context)
                              : (offer.messages.isEmpty
                                    ? 'No applicable offers right now'.tr(
                                        context,
                                      )
                                    : offer.messages.join(' • ')),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Card(
                  color: const Color(0xFFF8FAFF),
                  child: ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: Text(
                      '${'Referral code'.tr(context)}: ${customer.referralCode}',
                    ),
                    subtitle: Text(
                      'Share and earn ₹100 per successful signup'.tr(context),
                    ),
                    trailing: TextButton(
                      onPressed: () {},
                      child: Text('Copy'.tr(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Apply referral code'.tr(context),
                    suffixIcon: TextButton(
                      onPressed: () {},
                      child: Text('Apply'.tr(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recent wallet activity'.tr(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (ledger.isEmpty)
                  ListTile(
                    title: Text('No wallet transactions yet'.tr(context)),
                  )
                else
                  ...ledger.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.description),
                      subtitle: Text(_time(item.createdAt)),
                      trailing: Text(
                        '${item.amount > 0 ? '+' : ''}${item.amount}',
                        style: TextStyle(
                          color: item.amount > 0
                              ? const Color(0xFF1A8F46)
                              : const Color(0xFFDB3A34),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  'Referred customers (demo)'.tr(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...referred.map(
                  (entry) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE7F0FF),
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(entry.name),
                      subtitle: Text(
                        '${entry.tier} • ${entry.totalOrders} ${'orders'.tr(context)}',
                      ),
                      trailing: const Text(
                        '+₹100',
                        style: TextStyle(
                          color: Color(0xFF1A8F46),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _time(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}
