import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<DemoOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.appState.fetchOrders();
  }

  Future<void> _reload() async {
    setState(() {
      _future = widget.appState.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders available'.tr(context))),
      body: RefreshIndicator(
        onRefresh: () => _reload(),
        child: FutureBuilder<List<DemoOrder>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Unable to load orders'.tr(context)),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _reload,
                        child: Text('Retry'.tr(context)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final orders = snapshot.data ?? const <DemoOrder>[];
            if (orders.isEmpty) {
              return Center(
                child: Text('No orders available yet.'.tr(context)),
              );
            }

            return ListView.separated(
              itemBuilder: (context, index) {
                final order = orders[index];
                final linesText = order.lineItems
                    .map((line) => '${line.qty} x ${line.mealName}')
                    .join(', ');

                return ListTile(
                  title: Text(order.id),
                  subtitle: Text(
                    '${order.placedAt} • ${order.deliveryWindow} • ${order.status.name}\n$linesText',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text('₹${order.total}'),
                );
              },
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemCount: orders.length,
              padding: const EdgeInsets.only(top: 12, bottom: 24),
            );
          },
        ),
      ),
    );
  }
}
