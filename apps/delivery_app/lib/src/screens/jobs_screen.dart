import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/delivery_state.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, required this.state});

  final DeliveryState state;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  int _index = 0;
  bool _showCompleted = false;
  bool _highValueOnly = false;
  bool _availableMenuOnly = false;
  final _orderSearchController = TextEditingController();
  final _menuSearchController = TextEditingController();
  late Future<void> _ordersFuture;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadData();
    _syncTimer = Timer.periodic(const Duration(seconds: 40), (_) async {
      await _refreshData(silent: true);
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _orderSearchController.dispose();
    _menuSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await widget.state.reloadJobs();
  }

  Future<void> _refreshData({bool silent = false}) async {
    await _loadData();
    if (!mounted) return;
    setState(() {});
    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant dashboard synced.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Partner Console')),
      body: switch (_index) {
        0 => _ordersView(),
        1 => _menuView(),
        _ => _insightsView(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Insights',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
      ),
    );
  }

  Widget _ordersView() {
    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: FutureBuilder<void>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              widget.state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = _showCompleted
              ? widget.state.completedOrders
              : widget.state.activeOrders;
          final searchQuery = _orderSearchController.text.trim().toLowerCase();
          final visibleOrders = orders
              .where((order) {
                if (_highValueOnly && order.total < 250) return false;
                if (searchQuery.isEmpty) return true;
                final haystack =
                    '${order.id} ${order.customerName} ${order.deliveryWindow}'
                        .toLowerCase();
                return haystack.contains(searchQuery);
              })
              .toList(growable: false);

          if (widget.state.status == DeliveryJobsStatus.error &&
              visibleOrders.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unable to load restaurant orders',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(widget.state.error ?? 'Unknown error'),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () => _refreshData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              _RestaurantCard(state: widget.state),
              const SizedBox(height: 12),
              _PanelCard(
                child: DropdownButtonFormField<FoodPlace>(
                  isExpanded: true,
                  menuMaxHeight: 320,
                  initialValue: widget.state.currentRestaurant,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant account',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  items: MockData.foodPlaces
                      .map(
                        (place) => DropdownMenuItem(
                          value: place,
                          child: Text(
                            '${place.name} (${place.cityId.toUpperCase()})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) => MockData.foodPlaces
                      .map(
                        (place) => Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (place) async {
                    if (place == null) return;
                    widget.state.setRestaurant(place);
                    await _refreshData(silent: true);
                  },
                ),
              ),
              const SizedBox(height: 12),
              _PanelCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _orderSearchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search by order ID, customer, or slot',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 360;
                        if (compact) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              FilterChip(
                                label: const Text('High value (₹250+)'),
                                selected: _highValueOnly,
                                onSelected: (value) {
                                  setState(() {
                                    _highValueOnly = value;
                                  });
                                },
                              ),
                              if (searchQuery.isNotEmpty || _highValueOnly)
                                TextButton(
                                  onPressed: () {
                                    _orderSearchController.clear();
                                    setState(() {
                                      _highValueOnly = false;
                                    });
                                  },
                                  child: const Text('Clear filters'),
                                ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            FilterChip(
                              label: const Text('High value (₹250+)'),
                              selected: _highValueOnly,
                              onSelected: (value) {
                                setState(() {
                                  _highValueOnly = value;
                                });
                              },
                            ),
                            const Spacer(),
                            if (searchQuery.isNotEmpty || _highValueOnly)
                              TextButton(
                                onPressed: () {
                                  _orderSearchController.clear();
                                  setState(() {
                                    _highValueOnly = false;
                                  });
                                },
                                child: const Text('Clear filters'),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _KpiCard(
                      label: 'Active',
                      value: '${widget.state.assignedCount}',
                      icon: Icons.pending_actions_outlined,
                    ),
                    _KpiCard(
                      label: 'Out for delivery',
                      value: '${widget.state.outForDeliveryCount}',
                      icon: Icons.local_shipping_outlined,
                    ),
                    _KpiCard(
                      label: 'Completed',
                      value: '${widget.state.completedCount}',
                      icon: Icons.check_circle_outline,
                    ),
                  ];
                  final cardWidth = constraints.maxWidth >= 600
                      ? (constraints.maxWidth - 16) / 3
                      : (constraints.maxWidth - 8) / 2;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cards
                        .map((card) => SizedBox(width: cardWidth, child: card))
                        .toList(growable: false),
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Active'),
                    selected: !_showCompleted,
                    onSelected: (_) => setState(() => _showCompleted = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Completed'),
                    selected: _showCompleted,
                    onSelected: (_) => setState(() => _showCompleted = true),
                  ),
                  IconButton(
                    onPressed: () => _refreshData(),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Sync now',
                  ),
                ],
              ),
              if (!_showCompleted) ...[
                const SizedBox(height: 8),
                Text(
                  'Swipe order cards: right = Out for delivery, left = Delivered',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (visibleOrders.isEmpty)
                _EmptyPanel(
                  message: searchQuery.isNotEmpty || _highValueOnly
                      ? 'No orders match current filters.'
                      : 'No orders in this queue right now.',
                )
              else
                ...visibleOrders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: ValueKey(
                        '${order.id}-${_showCompleted ? "done" : "live"}',
                      ),
                      direction: _showCompleted
                          ? DismissDirection.none
                          : DismissDirection.horizontal,
                      background: const _SwipeStatusBackground(
                        icon: Icons.local_shipping_outlined,
                        label: 'Mark out for delivery',
                        alignStart: true,
                      ),
                      secondaryBackground: const _SwipeStatusBackground(
                        icon: Icons.check_circle_outline,
                        label: 'Mark delivered',
                        alignStart: false,
                      ),
                      confirmDismiss: (direction) async {
                        final nextStatus =
                            direction == DismissDirection.startToEnd
                            ? OrderStatus.outForDelivery
                            : OrderStatus.delivered;
                        final synced = await widget.state.updateJobStatus(
                          order.id,
                          nextStatus,
                        );
                        setState(() {});
                        if (!context.mounted) return false;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              synced
                                  ? 'Status updated: ${nextStatus == OrderStatus.outForDelivery ? "Out for delivery" : "Delivered"}'
                                  : 'Status saved locally. Backend sync pending.',
                            ),
                          ),
                        );
                        return false;
                      },
                      child: _OrderCard(
                        order: order,
                        status: widget.state.statusOf(order),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => JobDetailScreen(
                                state: widget.state,
                                order: order,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuView() {
    final menuQuery = _menuSearchController.text.trim().toLowerCase();
    final filteredMenuItems = widget.state.menuItems
        .where((meal) {
          if (_availableMenuOnly && !meal.available) return false;
          if (menuQuery.isEmpty) return true;
          final haystack =
              '${meal.name} ${meal.cuisine} ${meal.tags.join(' ')}';
          return haystack.toLowerCase().contains(menuQuery);
        })
        .toList(growable: false);
    final availableCount = widget.state.menuItems
        .where((meal) => meal.available)
        .length;

    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _RestaurantCard(state: widget.state),
          const SizedBox(height: 10),
          _PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Menu management',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _addDemoMenuItem,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add item'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _menuSearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search by meal, cuisine, or tags',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterChip(
                      label: const Text('Available only'),
                      selected: _availableMenuOnly,
                      onSelected: (value) {
                        setState(() {
                          _availableMenuOnly = value;
                        });
                      },
                    ),
                    Text(
                      '$availableCount / ${widget.state.menuItems.length} items available',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (filteredMenuItems.isEmpty)
            const _EmptyPanel(message: 'No menu items yet for this partner.')
          else
            ...filteredMenuItems.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MenuItemCard(
                  meal: meal,
                  onEdit: () => _editMenuItem(meal),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _insightsView() {
    final health = widget.state.dataHealth;
    final place = widget.state.currentRestaurant;
    final weeklyTrend = widget.state.weeklyEarningsTrend;
    final score = _operationalScore();
    final scoreTone = score >= 90
        ? const Color(0xFF16A34A)
        : (score >= 75 ? const Color(0xFFD97706) : const Color(0xFFDC2626));
    final syncLabel = _lastSyncLabel(widget.state.lastSyncedAt);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.developer_mode_outlined),
          title: const Text('Demo mode'),
          subtitle: Text(
            widget.state.isDemoMode
                ? 'Using seeded restaurant orders and menu'
                : 'Using live API data',
          ),
          value: widget.state.isDemoMode,
          onChanged: (value) async {
            widget.state.switchMode(value ? AppMode.demo : AppMode.live);
            await _refreshData(silent: true);
          },
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.radar_outlined),
            title: const Text('Operational score'),
            subtitle: Text(
              'Live health score across orders, delivery and uptime',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: scoreTone.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$score',
                style: TextStyle(color: scoreTone, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sync_outlined),
            title: const Text('Sync status'),
            subtitle: Text(syncLabel),
            trailing: FilledButton.tonal(
              onPressed: () => _refreshData(),
              child: const Text('Sync now'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: const Text('Data health'),
            subtitle: Text(
              'Menu items: ${health.meals} • Completed: ${health.orders} • Nearby places: ${health.partners}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: const Text('Today earnings'),
            subtitle: const Text('Includes completed order payouts'),
            trailing: Text(
              '₹${widget.state.todayEarnings}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
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
                  'Weekly earnings',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.state.weeklyEarnings} total this week',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _WeeklyEarningsChart(values: weeklyTrend),
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
                  'Daily earnings drilldown',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _topEarningDayLabel(weeklyTrend),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _WeeklyEarningsBreakdown(values: weeklyTrend),
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
                  'Incentive progress',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: widget.state.incentiveProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.state.incentiveRemaining == 0
                      ? 'Target unlocked. Keep momentum high.'
                      : '₹${widget.state.incentiveRemaining} left to unlock weekly bonus',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
                  'Fulfillment capability',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  place.deliveryByRestaurant
                      ? 'Restaurant self-delivery: Enabled'
                      : 'Restaurant self-delivery: Disabled',
                ),
                Text(
                  place.deliveryByPorter
                      ? 'Porter integration: Enabled'
                      : 'Porter integration: Disabled',
                ),
                Text(
                  place.acceptsScheduleOrders
                      ? 'Scheduled orders: Enabled'
                      : 'Scheduled orders: Disabled',
                ),
                Text(
                  place.acceptsCustomisations
                      ? 'Meal customization: Enabled'
                      : 'Meal customization: Limited',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _operationalScore() {
    final progress = (widget.state.incentiveProgress * 100).round();
    final deliveryLift = (widget.state.outForDeliveryCount * 3).clamp(0, 18);
    final completionLift = (widget.state.completedCount * 2).clamp(0, 16);
    final idlePenalty = widget.state.assignedCount == 0 ? 8 : 0;
    final score = progress + deliveryLift + completionLift - idlePenalty;
    return score.clamp(42, 99);
  }

  String _lastSyncLabel(DateTime? value) {
    if (value == null) return 'No sync yet in this session';
    final diff = DateTime.now().difference(value);
    if (diff.inSeconds < 60) return 'Synced just now';
    if (diff.inMinutes < 60) return 'Synced ${diff.inMinutes} min ago';
    return 'Synced ${diff.inHours} hr ago';
  }

  String _topEarningDayLabel(List<int> trend) {
    if (trend.isEmpty) return 'No earnings data for this week';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    var bestIndex = 0;
    for (var i = 1; i < trend.length; i++) {
      if (trend[i] > trend[bestIndex]) bestIndex = i;
    }
    final day = bestIndex < days.length
        ? days[bestIndex]
        : 'Day ${bestIndex + 1}';
    return '$day is leading with ₹${trend[bestIndex]}';
  }

  Future<void> _editMenuItem(Meal meal) async {
    final priceController = TextEditingController(text: '${meal.price}');
    final imageController = TextEditingController(text: meal.imageUrl);
    var available = meal.available;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Edit ${meal.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Available'),
                    value: available,
                    onChanged: (value) {
                      setSheetState(() {
                        available = value;
                      });
                    },
                  ),
                  FilledButton(
                    onPressed: () {
                      final price = int.tryParse(priceController.text.trim());
                      if (price == null) return;
                      widget.state.updateMenuItem(
                        meal.copyWith(
                          price: price,
                          imageUrl: imageController.text.trim(),
                          available: available,
                        ),
                      );
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    priceController.dispose();
    imageController.dispose();
  }

  void _addDemoMenuItem() {
    final now = DateTime.now().millisecondsSinceEpoch;
    widget.state.menuItems.add(
      Meal(
        id: 'demo-$now',
        name: 'Chef Special Box',
        slot: MealSlot.lunch,
        price: 149,
        rating: 4.5,
        imageUrl:
            'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80',
        cityId: widget.state.currentRestaurant.cityId,
        tags: const ['chef-special'],
        calories: 530,
        prepTimeMin: 24,
        etaMinutes: 30,
        cuisine: 'home-style',
        placeId: widget.state.currentRestaurant.id,
        placeName: widget.state.currentRestaurant.name,
        customisable: widget.state.currentRestaurant.acceptsCustomisations,
      ),
    );
    setState(() {});
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.state});

  final DeliveryState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBackground = state.isDemoMode
        ? (isDark
              ? const Color(0xFF7C2D12)
              : const Color(0xFFF59E0B).withValues(alpha: 0.14))
        : (isDark
              ? const Color(0xFF14532D)
              : const Color(0xFF1A8F46).withValues(alpha: 0.14));
    final statusColor = state.isDemoMode
        ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309))
        : (isDark ? const Color(0xFFBBF7D0) : const Color(0xFF166534));

    return Card(
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF1B2636) : const Color(0xFFECF3FF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.storefront_outlined,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.currentRestaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.currentRestaurant.cityId.toUpperCase()} • ★${state.currentRestaurant.rating.toStringAsFixed(1)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                state.isDemoMode ? 'DEMO' : 'LIVE',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.status,
    required this.onTap,
  });

  final DemoOrder order;
  final OrderStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final orderSummary =
        '${order.customerName} • ₹${order.total} • ${order.deliveryWindow}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 220;
                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _StatusBadgeSmall(_statusText(status)),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadgeSmall(_statusText(status)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                orderSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusText(OrderStatus status) {
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: child,
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.meal, required this.onEdit});

  final Meal meal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            meal.imageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(Icons.image_outlined),
              ),
            ),
          ),
        ),
        title: Text(
          meal.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '₹${meal.price} • ${meal.prepTimeMin} min • ${meal.available ? "Available" : "Paused"}',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        trailing: IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}

class _StatusBadgeSmall extends StatelessWidget {
  const _StatusBadgeSmall(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 124),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeStatusBackground extends StatelessWidget {
  const _SwipeStatusBackground({
    required this.icon,
    required this.label,
    required this.alignStart,
  });

  final IconData icon;
  final String label;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!alignStart) ...[
            Text(
              label,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: scheme.primary),
          if (alignStart) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyEarningsChart extends StatelessWidget {
  const _WeeklyEarningsChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final sanitizedValues = values
        .map((value) => value < 0 ? 0 : value)
        .toList(growable: false);
    final maxValue = sanitizedValues.reduce((a, b) => a > b ? a : b).toDouble();
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 92,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const labelHeight = 18.0;
          const labelGap = 6.0;
          final barRegionHeight =
              (constraints.maxHeight - labelHeight - labelGap).clamp(
                30.0,
                72.0,
              );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < sanitizedValues.length; i++) ...[
                () {
                  final baseValue = sanitizedValues[i].toDouble();
                  var factor = maxValue == 0 ? 0.0 : baseValue / maxValue;
                  if (factor.isNaN || factor.isInfinite) {
                    factor = 0.0;
                  }
                  factor = factor.clamp(0.0, 1.0);
                  final barHeight = math.max(8.0, barRegionHeight * factor);

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: barRegionHeight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              width: 12,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: labelGap),
                        SizedBox(
                          height: labelHeight,
                          child: Text(
                            i < labels.length ? labels[i] : '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }(),
                if (i != sanitizedValues.length - 1) const SizedBox(width: 4),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WeeklyEarningsBreakdown extends StatelessWidget {
  const _WeeklyEarningsBreakdown({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final scheme = Theme.of(context).colorScheme;
    final sanitizedValues = values
        .map((value) => value < 0 ? 0 : value)
        .toList(growable: false);
    final maxValue = sanitizedValues.reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      children: [
        for (var i = 0; i < sanitizedValues.length; i++) ...[
          Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  i < days.length ? days[i] : 'D${i + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: maxValue == 0
                        ? 0
                        : (sanitizedValues[i] / maxValue).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 72,
                child: Text(
                  '₹${sanitizedValues[i]}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (i != sanitizedValues.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
