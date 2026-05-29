import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/delivery_state.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.state, required this.order});

  final DeliveryState state;
  final DemoOrder order;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _delayController = TextEditingController(
    text: 'Traffic near customer lane',
  );

  LiveTrackingSnapshot? _tracking;
  DelayPrediction? _eta;

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  @override
  void dispose() {
    _delayController.dispose();
    super.dispose();
  }

  Future<void> _loadTracking() async {
    final tracking = await widget.state.fetchLiveTracking(widget.order.id);
    final eta = await widget.state.fetchEta(widget.order.id);
    if (!mounted) return;
    setState(() {
      _tracking = tracking;
      _eta = eta;
    });
  }

  Future<void> _pingLocation() async {
    final tracking = _tracking;
    final lat = tracking?.rider.lat ?? 28.61;
    final lng = tracking?.rider.lng ?? 77.23;

    await widget.state.pingLocation(
      orderId: widget.order.id,
      lat: lat + 0.0006,
      lng: lng + 0.0006,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fulfillment location update sent.')),
    );
  }

  Future<void> _reportDelay() async {
    await widget.state.reportDelay(
      orderId: widget.order.id,
      reason: _delayController.text.trim(),
    );

    await _loadTracking();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Delay report submitted.')));
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.state.statusOf(widget.order);
    final deliveryMode = widget.state.deliveryModeOf(widget.order);

    return Scaffold(
      appBar: AppBar(title: Text(widget.order.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(widget.order.customerName),
              subtitle: Text(widget.order.address),
              trailing: Text(
                'ETA ${_tracking?.etaMinutes ?? widget.order.etaMinutes}m',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery mode',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<DeliveryProviderOption>(
                    initialValue: deliveryMode,
                    items: const [
                      DropdownMenuItem(
                        value: DeliveryProviderOption.restaurantFleet,
                        child: Text('Restaurant delivery'),
                      ),
                      DropdownMenuItem(
                        value: DeliveryProviderOption.porter,
                        child: Text('Porter'),
                      ),
                      DropdownMenuItem(
                        value: DeliveryProviderOption.customerPickup,
                        child: Text('Self pickup'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      widget.state.setDeliveryMode(widget.order.id, value);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text('Delay +${_eta?.predictedDelayMinutes ?? 0} min'),
              subtitle: Text(_eta?.reason ?? 'No delay expected'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pingLocation,
                  icon: const Icon(Icons.my_location_outlined, size: 16),
                  label: const Text('Update location'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reportDelay,
                  icon: const Icon(Icons.report_problem_outlined, size: 16),
                  label: const Text('Report delay'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _delayController,
            decoration: const InputDecoration(
              labelText: 'Delay reason',
              hintText: 'Traffic / kitchen wait / weather',
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order status',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusButton(
                        label: 'Confirmed',
                        selected: status == OrderStatus.confirmed,
                        onTap: () {
                          _setStatus(OrderStatus.confirmed);
                        },
                      ),
                      _statusButton(
                        label: 'Preparing',
                        selected: status == OrderStatus.preparing,
                        onTap: () {
                          _setStatus(OrderStatus.preparing);
                        },
                      ),
                      _statusButton(
                        label: 'Out for delivery',
                        selected: status == OrderStatus.outForDelivery,
                        onTap: () {
                          _setStatus(OrderStatus.outForDelivery);
                        },
                      ),
                      _statusButton(
                        label: 'Delivered',
                        selected: status == OrderStatus.delivered,
                        onTap: () {
                          _setStatus(OrderStatus.delivered);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order items',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...widget.order.lineItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${item.mealName} x${item.qty}'),
                          ),
                          Text('₹${item.unitPrice * item.qty}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    if (selected) {
      return FilledButton(onPressed: onTap, child: Text(label));
    }
    return OutlinedButton(onPressed: onTap, child: Text(label));
  }

  Future<void> _setStatus(OrderStatus status) async {
    final synced = await widget.state.updateJobStatus(widget.order.id, status);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced
              ? 'Status updated to ${_readable(status)}'
              : 'Status saved locally as ${_readable(status)}. Sync pending.',
        ),
      ),
    );
  }

  String _readable(OrderStatus status) {
    return switch (status) {
      OrderStatus.created => 'Created',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.preparing => 'Preparing',
      OrderStatus.outForDelivery => 'Out for delivery',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };
  }
}
