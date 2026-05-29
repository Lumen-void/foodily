import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const _all = 'all';
  static const _active = 'active';
  static const _completed = 'completed';

  late Future<List<DemoOrder>> _ordersFuture;
  String _filter = _all;

  @override
  void initState() {
    super.initState();
    _ordersFuture = widget.appState.fetchOrders();
  }

  Future<void> _reload() async {
    setState(() {
      _ordersFuture = widget.appState.fetchOrders();
    });
    await _ordersFuture;
  }

  Future<void> _openLiveTracking(DemoOrder order) async {
    final tracking = await widget.appState.fetchLiveTracking(order.id);
    final eta = await widget.appState.fetchEta(order.id);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                '${'Realtime ETA'.tr(context)} • ${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              _LiveMapCard(snapshot: tracking),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(
                    'ETA ${tracking?.etaMinutes ?? order.etaMinutes} mins',
                  ),
                  subtitle: Text(
                    '${'Delay prediction'.tr(context)} +${eta.predictedDelayMinutes} mins (${eta.reason})',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () async {
                  await widget.appState.reportDelay(
                    order.id,
                    'Customer marked late order',
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Delay signal sent to operations.'.tr(context),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem_outlined),
                label: Text('Report delay'.tr(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reorder(DemoOrder order) async {
    await widget.appState.reorderFromOrder(order.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${'Reordered from'.tr(context)} ${order.id} ${'and added to cart.'.tr(context)}',
        ),
      ),
    );
  }

  Future<void> _raiseIssue(DemoOrder order) async {
    final issue = await widget.appState.createSupportIssue(
      orderId: order.id,
      type: IssueType.lateDelivery,
      description: 'Issue raised from tracking screen',
    );
    if (!mounted || issue == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${'Issue'.tr(context)} ${issue.id} ${'created.'.tr(context)}',
        ),
      ),
    );
  }

  Future<void> _openSupport(DemoOrder order) async {
    final thread = await widget.appState.createSupportThread(order.id);
    await widget.appState.sendSupportMessage(
      threadId: thread.id,
      sender: 'customer',
      text: 'Please help with ${order.id}.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${'Support thread'.tr(context)} ${thread.id} ${'started.'.tr(context)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Tracking'.tr(context))),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<DemoOrder>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data ?? const <DemoOrder>[];
            final filtered = _applyFilter(orders);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _chip(label: 'All'.tr(context), value: _all),
                    const SizedBox(width: 8),
                    _chip(label: 'Active'.tr(context), value: _active),
                    const SizedBox(width: 8),
                    _chip(label: 'Completed'.tr(context), value: _completed),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'No orders found for this filter.'.tr(context),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OrderCard(
                        order: order,
                        onTrack: () => _openLiveTracking(order),
                        onReorder: () => _reorder(order),
                        onIssue: () => _raiseIssue(order),
                        onSupport: () => _openSupport(order),
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

  Widget _chip({required String label, required String value}) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
    );
  }

  List<DemoOrder> _applyFilter(List<DemoOrder> orders) {
    if (_filter == _all) return orders;
    if (_filter == _completed) {
      return orders
          .where(
            (order) =>
                order.status == OrderStatus.delivered ||
                order.status == OrderStatus.cancelled,
          )
          .toList();
    }
    return orders
        .where(
          (order) =>
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled,
        )
        .toList();
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onTrack,
    required this.onReorder,
    required this.onIssue,
    required this.onSupport,
  });

  final DemoOrder order;
  final VoidCallback onTrack;
  final VoidCallback onReorder;
  final VoidCallback onIssue;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Row(
          children: [
            Expanded(
              child: Text(
                order.id,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            _StatusBadge(status: order.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${_slot(order.slot)} • ${order.deliveryWindow}\n₹${order.total} • ETA ${order.etaMinutes} mins',
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              order.address,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...order.timeline.map(
            (event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    event.status.index <= order.status.index
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: event.status.index <= order.status.index
                        ? const Color(0xFF1A8F46)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    _time(event.at),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onTrack,
                icon: const Icon(Icons.map_outlined, size: 16),
                label: Text('Track ETA'.tr(context)),
              ),
              OutlinedButton.icon(
                onPressed: onReorder,
                icon: const Icon(Icons.replay_outlined, size: 16),
                label: Text('Reorder'.tr(context)),
              ),
              OutlinedButton.icon(
                onPressed: onSupport,
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: Text('Support'.tr(context)),
              ),
              OutlinedButton.icon(
                onPressed: onIssue,
                icon: const Icon(Icons.report_problem_outlined, size: 16),
                label: Text('Issue'.tr(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _slot(MealSlot slot) {
    return switch (slot) {
      MealSlot.breakfast => 'Breakfast',
      MealSlot.lunch => 'Lunch',
      MealSlot.dinner => 'Dinner',
    };
  }

  String _time(DateTime value) {
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $suffix';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.created => ('Created'.tr(context), const Color(0xFF475569)),
      OrderStatus.confirmed => (
        'Confirmed'.tr(context),
        const Color(0xFF334155),
      ),
      OrderStatus.preparing => (
        'Preparing'.tr(context),
        const Color(0xFFD97706),
      ),
      OrderStatus.outForDelivery => (
        'Out for delivery'.tr(context),
        const Color(0xFF1E67D1),
      ),
      OrderStatus.delivered => (
        'Delivered'.tr(context),
        const Color(0xFF1A8F46),
      ),
      OrderStatus.cancelled => (
        'Cancelled'.tr(context),
        const Color(0xFFDB3A34),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LiveMapCard extends StatelessWidget {
  const _LiveMapCard({required this.snapshot});

  final LiveTrackingSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final route = snapshot?.route ?? const <RiderLocation>[];

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFDCEBFF), Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: CustomPaint(
        painter: _MapPainter(route: route),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.route});

  final List<RiderLocation> route;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFCADBFA);
    final line = Paint()
      ..color = const Color(0xFF1E67D1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      bg,
    );

    if (route.length < 2) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        8,
        Paint()..color = const Color(0xFF0E3A6D),
      );
      return;
    }

    final path = Path();
    for (var i = 0; i < route.length; i++) {
      final point = route[i];
      final x = (i / (route.length - 1)) * (size.width - 24) + 12;
      final normalized = ((point.lat + point.lng).abs() % 1);
      final y = 20 + (1 - normalized) * (size.height - 40);
      final offset = Offset(x, y);
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }

    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.route != route;
  }
}
