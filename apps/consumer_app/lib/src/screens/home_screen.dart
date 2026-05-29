import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_ui/flutter_ui.dart';

import '../state/app_state.dart';
import 'cart_screen.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.appState, required this.locale});

  final AppState appState;
  final Locale locale;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late Future<void> _homeFuture;
  late Future<OfferEvaluation> _offerFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadFeed();
    _offerFuture = widget.appState.evaluateOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    await widget.appState.loadHomeFeed();
    await _safeRun(widget.appState.fetchOrders, 'orders');
    await _safeRun(widget.appState.fetchWalletLedger, 'wallet');
    await _safeRun(widget.appState.fetchSupportThreads, 'support threads');
    await _safeRun(widget.appState.fetchSupportIssues, 'support issues');
    await _prefetchMealImages();
  }

  Future<void> _safeRun(Future<Object?> Function() task, String label) async {
    try {
      await task();
    } catch (error) {
      debugPrint('Home sync skipped ($label): $error');
    }
  }

  Future<void> _reloadAll() async {
    setState(() {
      _homeFuture = _loadFeed();
      _offerFuture = widget.appState.evaluateOffers();
    });
    await _homeFuture;
  }

  Future<void> _prefetchMealImages() async {
    if (!mounted) return;
    final mealsToPrefetch = widget.appState.visibleMeals.isNotEmpty
        ? widget.appState.visibleMeals
        : widget.appState.fallbackMeals();

    for (final meal in mealsToPrefetch.take(8)) {
      try {
        await precacheImage(NetworkImage(meal.imageUrl), context);
      } catch (_) {
        // Ignore image prefetch failures.
      }
    }
  }

  Future<void> _openFilters() async {
    final state = widget.appState;
    var draft = state.searchFilters;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  const Text(
                    'Advanced filters',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SearchSort>(
                    initialValue: draft.sort,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: const [
                      DropdownMenuItem(
                        value: SearchSort.relevance,
                        child: Text('Relevance'),
                      ),
                      DropdownMenuItem(
                        value: SearchSort.rating,
                        child: Text('Rating'),
                      ),
                      DropdownMenuItem(
                        value: SearchSort.eta,
                        child: Text('Delivery time'),
                      ),
                      DropdownMenuItem(
                        value: SearchSort.priceAsc,
                        child: Text('Price low to high'),
                      ),
                      DropdownMenuItem(
                        value: SearchSort.priceDesc,
                        child: Text('Price high to low'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() {
                        draft = draft.copyWith(sort: value);
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _RangeInput(
                    title: 'Calories',
                    min: draft.caloriesMin.toDouble(),
                    max: draft.caloriesMax.toDouble(),
                    minLimit: 0,
                    maxLimit: 1200,
                    onChanged: (range) {
                      setModalState(() {
                        draft = draft.copyWith(
                          caloriesMin: range.start.round(),
                          caloriesMax: range.end.round(),
                        );
                      });
                    },
                  ),
                  _RangeInput(
                    title: 'Prep time (minutes)',
                    min: draft.prepMin.toDouble(),
                    max: draft.prepMax.toDouble(),
                    minLimit: 0,
                    maxLimit: 90,
                    onChanged: (range) {
                      setModalState(() {
                        draft = draft.copyWith(
                          prepMin: range.start.round(),
                          prepMax: range.end.round(),
                        );
                      });
                    },
                  ),
                  _RangeInput(
                    title: 'Price',
                    min: draft.priceMin.toDouble(),
                    max: draft.priceMax.toDouble(),
                    minLimit: 0,
                    maxLimit: 500,
                    onChanged: (range) {
                      setModalState(() {
                        draft = draft.copyWith(
                          priceMin: range.start.round(),
                          priceMax: range.end.round(),
                        );
                      });
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Offers only'),
                    value: draft.offersOnly,
                    onChanged: (value) {
                      setModalState(() {
                        draft = draft.copyWith(offersOnly: value);
                      });
                    },
                  ),
                  Text('Minimum rating: ${draft.ratingMin.toStringAsFixed(1)}'),
                  Slider(
                    value: draft.ratingMin,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    onChanged: (value) {
                      setModalState(() {
                        draft = draft.copyWith(ratingMin: value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      state.setSearchFilters(draft);
                      Navigator.of(context).pop();
                      _reloadAll();
                    },
                    child: const Text('Apply filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCheckoutPreferences() async {
    final current = await widget.appState.fetchCheckoutPreferences();
    final smartAddress = await widget.appState.getSmartDefaultAddress();
    if (!mounted) return;

    var draft = current;

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
                  const Text(
                    'One-tap checkout preferences',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  if (smartAddress != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE3E9F4)),
                      ),
                      child: Text(
                        'Smart default: ${smartAddress.label} • ${smartAddress.addressLine}',
                      ),
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: draft.preferredWindow,
                    decoration: const InputDecoration(
                      labelText: 'Preferred delivery window',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '9:00 AM - 9:30 AM',
                        child: Text('9:00 AM - 9:30 AM'),
                      ),
                      DropdownMenuItem(
                        value: '1:00 PM - 1:30 PM',
                        child: Text('1:00 PM - 1:30 PM'),
                      ),
                      DropdownMenuItem(
                        value: '8:00 PM - 8:30 PM',
                        child: Text('8:00 PM - 8:30 PM'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        draft = draft.copyWith(preferredWindow: value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: draft.preferredPaymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment mode',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      DropdownMenuItem(value: 'Card', child: Text('Card')),
                      DropdownMenuItem(
                        value: 'Cash',
                        child: Text('Cash on delivery'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        draft = draft.copyWith(preferredPaymentMode: value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: draft.defaultCadence,
                    decoration: const InputDecoration(
                      labelText: 'Default cadence',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                        value: 'Monthly',
                        child: Text('Monthly'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        draft = draft.copyWith(defaultCadence: value);
                      });
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: draft.walletAutoApply,
                    onChanged: (value) {
                      setSheetState(() {
                        draft = draft.copyWith(walletAutoApply: value);
                      });
                    },
                    title: const Text('Auto-apply wallet credits'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await widget.appState.updateCheckoutPreferences(draft);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preferences updated.')),
                      );
                    },
                    child: const Text('Save preferences'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openMealReviews(Meal meal) async {
    final reviews = await widget.appState.fetchMealReviews(meal.id);
    final badges = await widget.appState.fetchMealBadges(meal.id);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: badges
                      .map(
                        (badge) => Chip(
                          label: Text(badge),
                          side: const BorderSide(color: Color(0xFFE3E9F4)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                if (reviews.isEmpty)
                  const Text('No reviews yet for this meal.')
                else
                  ...reviews.map(
                    (review) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${review.customerName} • ${review.rating}/5',
                      ),
                      subtitle: Text(review.comment),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCustomizeMeal(Meal meal) async {
    final noteController = TextEditingController(
      text: widget.appState.customMealNote(meal.id),
    );
    var schedule = widget.appState.checkoutPreferences.preferredWindow;

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
                    'Customize ${meal.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: schedule,
                    decoration: const InputDecoration(
                      labelText: 'Preferred delivery time',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '9:00 AM - 9:30 AM',
                        child: Text('9:00 AM - 9:30 AM'),
                      ),
                      DropdownMenuItem(
                        value: '1:00 PM - 1:30 PM',
                        child: Text('1:00 PM - 1:30 PM'),
                      ),
                      DropdownMenuItem(
                        value: '8:00 PM - 8:30 PM',
                        child: Text('8:00 PM - 8:30 PM'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        schedule = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Customization notes',
                      hintText: 'Less oil, extra salad, no onion, etc.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      widget.appState.setCustomMealNote(
                        meal.id,
                        noteController.text.trim(),
                      );
                      await widget.appState.updateCheckoutPreferences(
                        widget.appState.checkoutPreferences.copyWith(
                          preferredWindow: schedule,
                        ),
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meal customisation saved.'),
                        ),
                      );
                    },
                    child: const Text('Save customization'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    noteController.dispose();
  }

  Future<void> _openTrackingSnapshot(DemoOrder order) async {
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
                'Tracking • ${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              _MiniMapCard(snapshot: tracking),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(
                    'ETA ${tracking?.etaMinutes ?? order.etaMinutes} mins',
                  ),
                  subtitle: Text(
                    'Delay prediction: +${eta.predictedDelayMinutes} mins (${eta.reason})',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () async {
                  await widget.appState.reportDelay(
                    order.id,
                    'Customer reported delay',
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delay report submitted.')),
                  );
                },
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Report delay'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openOfferPreview() async {
    final offer = await widget.appState.evaluateOffers();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Offer evaluation',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text('Discount: ₹${offer.discount}'),
              Text('Final payable: ₹${offer.finalPayable}'),
              const SizedBox(height: 8),
              ...offer.messages.map((message) => Text('• $message')),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startSupportChat(DemoOrder order) async {
    final thread = await widget.appState.createSupportThread(order.id);
    await widget.appState.sendSupportMessage(
      threadId: thread.id,
      sender: 'customer',
      text: 'Need help with order ${order.id}.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Support thread ${thread.id} started.')),
    );
  }

  Future<void> _raiseIssue(DemoOrder order, IssueType type) async {
    final issue = await widget.appState.createSupportIssue(
      orderId: order.id,
      type: type,
      description: 'Issue raised from tracking shortcut.',
    );

    if (!mounted || issue == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Issue ${issue.id} created.')));
  }

  Future<void> _openPlaceConnectDialog(FoodPlace place) async {
    final session = await widget.appState.createMaskedCallSession(
      toNumber: place.contactNumber,
    );
    if (!mounted || session == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        var selected = widget.appState.deliveryChoiceForPlace(place.id);
        return AlertDialog(
          title: Text(place.name),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mask number: ${session.maskedNumber}\nExpires: ${session.expiresAt.hour}:${session.expiresAt.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Delivery fulfillment',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<DeliveryProviderOption>(
                    initialValue: selected,
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
                      setDialogState(() {
                        selected = value;
                      });
                      widget.appState.setDeliveryChoiceForPlace(
                        place.id,
                        value,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.acceptsScheduleOrders
                        ? 'This place supports scheduled meal timing.'
                        : 'Instant ordering only for this place.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                  Text(
                    place.acceptsCustomisations
                        ? 'Meal customization available.'
                        : 'Limited customization.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reorderFromRecent() async {
    final delivered = widget.appState.cachedOrders
        .where((order) => order.status == OrderStatus.delivered)
        .toList();

    if (delivered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No delivered orders to reorder.')),
      );
      return;
    }

    await widget.appState.reorderFromOrder(delivered.first.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reordered from ${delivered.first.id}.')),
    );
    setState(() {});
  }

  String _placeTypeLabel(FoodPlaceType type) {
    return switch (type) {
      FoodPlaceType.restaurant => 'Restaurant',
      FoodPlaceType.dhaba => 'Dhaba',
      FoodPlaceType.tiffin => 'Tiffin',
      FoodPlaceType.cloudKitchen => 'Kitchen',
    };
  }

  T? _safeDropdownValue<T>(T? value, List<T> options) {
    if (value == null) return null;
    if (options.isEmpty) return null;
    if (options.contains(value)) return value;
    return options.first;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(widget.locale);
    final state = widget.appState;

    final zoneCandidates = AppState.zonesForCity(state.selectedCity.id);
    final zones = zoneCandidates.isEmpty
        ? [state.selectedZone]
        : zoneCandidates;

    final customers = state.customersForCity(state.selectedCity.id).isEmpty
        ? [state.currentCustomer]
        : state.customersForCity(state.selectedCity.id);

    final cityPlaces = state.foodPlacesForCity(state.selectedCity.id);
    final discoverPlaces = cityPlaces.isNotEmpty
        ? cityPlaces
        : MockData.foodPlaces.take(8).toList(growable: false);
    final latestOrders = state.cachedOrders.take(3).toList();

    final selectedCity = _safeDropdownValue(
      state.selectedCity,
      MockData.cities,
    );

    final selectedZone = _safeDropdownValue(state.selectedZone, zones);

    final selectedCustomer = _safeDropdownValue(
      state.currentCustomer,
      customers,
    );

    final selectedPlace = _safeDropdownValue(
      state.selectedFoodPlace,
      discoverPlaces,
    );
    final customerInitial = state.currentCustomer.name.trim().isEmpty
        ? 'U'
        : state.currentCustomer.name.trim()[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodily'),
        actions: [
          _ModePill(isDemo: state.isDemoMode),
          const SizedBox(width: 6),
          _HealthPill(health: state.dataHealth),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFE7F0FF),
            child: Text(
              customerInitial,
              style: const TextStyle(
                color: FoodilyColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadAll,
        child: FutureBuilder<void>(
          future: _homeFuture,
          builder: (context, snapshot) {
            try {
              final baselineMeals = state.selectedFoodPlaceMenu(
                slot: state.selectedSlot,
                allSlotsIfEmpty: true,
              );
              final fallbackMeals = state.fallbackMeals();
              final displayMeals = state.visibleMeals.isNotEmpty
                  ? state.visibleMeals
                  : (baselineMeals.isNotEmpty ? baselineMeals : fallbackMeals);
              final hasFeedError =
                  snapshot.hasError || state.homeStatus == HomeFeedStatus.error;
              final errorMessage =
                  snapshot.error?.toString() ??
                  state.homeError ??
                  'Unexpected issue while loading feed.';
              final showLoadingBanner =
                  snapshot.connectionState == ConnectionState.waiting ||
                  state.homeStatus == HomeFeedStatus.loading;
              final showErrorBanner = hasFeedError;
              final showEmptyBanner = state.homeStatus == HomeFeedStatus.empty;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                children: [
                  if (showLoadingBanner) ...[
                    const _SkeletonBox(height: 36, radius: 12),
                    const SizedBox(height: 10),
                  ],
                  if (showErrorBanner) ...[
                    _FeedFallbackCard(
                      message: errorMessage.isNotEmpty
                          ? 'Feed error: $errorMessage'
                          : 'Live feed had an issue. Showing menu fallback.',
                      actionLabel: 'Retry feed',
                      onPressed: _reloadAll,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (showEmptyBanner) ...[
                    _FeedFallbackCard(
                      message: 'No meals matched filters for this restaurant.',
                      actionLabel: 'Open filters',
                      onPressed: _openFilters,
                    ),
                    const SizedBox(height: 10),
                  ],
                  _HeroBanner(state: state),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by meal, cuisine, diet...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              onPressed: _openFilters,
                              icon: const Icon(Icons.tune),
                            ),
                          ),
                          onSubmitted: (value) {
                            state.setSearchQuery(value);
                            _reloadAll();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          state.setSearchQuery(_searchController.text);
                          _reloadAll();
                        },
                        child: const Text('Go'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<City>(
                          initialValue: selectedCity,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.location_on_outlined),
                            labelText: 'City',
                          ),
                          items: MockData.cities
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              state.setCity(value);
                              _homeFuture = _loadFeed();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<Zone>(
                          initialValue: selectedZone,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.pin_drop_outlined),
                            labelText: 'Area',
                          ),
                          items: zones
                              .map(
                                (zone) => DropdownMenuItem(
                                  value: zone,
                                  child: Text(zone.name),
                                ),
                              )
                              .toList(),
                          onChanged: (zone) {
                            if (zone == null) return;
                            setState(() {
                              state.setZone(zone);
                              _homeFuture = _loadFeed();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<DemoCustomer>(
                    initialValue: selectedCustomer,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_pin_circle_outlined),
                      labelText: 'Demo customer account',
                    ),
                    items: customers
                        .map(
                          (customer) => DropdownMenuItem(
                            value: customer,
                            child: Text('${customer.name} • ${customer.tier}'),
                          ),
                        )
                        .toList(),
                    onChanged: (customer) {
                      if (customer == null) return;
                      setState(() {
                        state.setCustomer(customer);
                        _homeFuture = _loadFeed();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FoodPlace>(
                    initialValue: selectedPlace,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.storefront_outlined),
                      labelText: 'Food place',
                    ),
                    items: discoverPlaces
                        .map(
                          (place) => DropdownMenuItem(
                            value: place,
                            child: Text(
                              '${place.name} • ${_placeTypeLabel(place.type)} • ★${place.rating.toStringAsFixed(1)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (place) {
                      if (place == null) return;
                      setState(() {
                        state.setFoodPlace(place);
                        _homeFuture = _loadFeed();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (cityPlaces.isEmpty)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Showing global demo food places'),
                        subtitle: Text(
                          'No strict city/area match was found, so fallback demo places are shown.',
                        ),
                      ),
                    ),
                  if (selectedPlace != null)
                    Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            selectedPlace.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(
                                  color: Color(0xFFE2E8F0),
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Icon(Icons.store_outlined),
                                  ),
                                ),
                          ),
                        ),
                        title: Text(selectedPlace.name),
                        subtitle: Text(
                          '${_placeTypeLabel(selectedPlace.type)} • ${selectedPlace.avgDeliveryMinutes} mins • Min ₹${selectedPlace.minOrder}',
                        ),
                        trailing: TextButton(
                          onPressed: () =>
                              _openPlaceConnectDialog(selectedPlace),
                          child: const Text('Fulfillment'),
                        ),
                      ),
                    ),
                  if (discoverPlaces.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _SectionTitle(
                      title: 'Choose restaurant / dhaba / tiffin',
                      subtitle: 'Tap any place to load its menu instantly',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 148,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: discoverPlaces.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final place = discoverPlaces[index];
                          final selected = selectedPlace?.id == place.id;
                          return SizedBox(
                            width: 248,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                setState(() {
                                  state.setFoodPlace(place);
                                  _homeFuture = _loadFeed();
                                });
                              },
                              child: Card(
                                color: selected
                                    ? const Color(0xFFEAF2FF)
                                    : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          place.imageUrl,
                                          width: 74,
                                          height: 74,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const ColoredBox(
                                                    color: Color(0xFFE2E8F0),
                                                    child: SizedBox(
                                                      width: 74,
                                                      height: 74,
                                                      child: Icon(
                                                        Icons.store_outlined,
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_placeTypeLabel(place.type)} • ★${place.rating.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                color: Color(0xFF475569),
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Menu in ${place.avgDeliveryMinutes} mins',
                                              style: const TextStyle(
                                                color: Color(0xFF1E67D1),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: MealSlot.values
                          .map(
                            (slot) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SlotChip(
                                slot: slot,
                                selected: state.selectedSlot == slot,
                                onTap: () {
                                  setState(() {
                                    state.setSlot(slot);
                                    _homeFuture = _loadFeed();
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final diet = state.dietFilters[index];
                        final selected = diet == state.selectedDiet;
                        return ChoiceChip(
                          label: Text(diet),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              state.setDiet(diet);
                              _homeFuture = _loadFeed();
                            });
                          },
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemCount: state.dietFilters.length,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<OfferEvaluation>(
                    future: _offerFuture,
                    builder: (context, snapshot) {
                      final offer = snapshot.data;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.local_offer_outlined),
                          title: Text(
                            offer == null
                                ? 'Evaluating offers...'
                                : 'Potential savings ₹${offer.discount}',
                          ),
                          subtitle: Text(
                            offer == null
                                ? 'First order, streak and surge-safe checks'
                                : (offer.messages.isEmpty
                                      ? 'No active offers for this cart'
                                      : offer.messages.join(' • ')),
                          ),
                          trailing: TextButton(
                            onPressed: _openOfferPreview,
                            child: const Text('View'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SectionTitle(
                    title: strings.text('sameDay'),
                    subtitle: 'Advanced feed with fallback-safe rendering',
                  ),
                  const SizedBox(height: 10),
                  if (displayMeals.isEmpty)
                    _FeedFallbackCard(
                      message: 'No same-day meals for this filter.',
                      actionLabel: 'Retry',
                      onPressed: _reloadAll,
                    )
                  else
                    SizedBox(
                      height: 322,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final meal = displayMeals[index];
                          return Stack(
                            children: [
                              MealCard(
                                meal: meal,
                                onOrder: () {
                                  setState(() {
                                    state.addToCart(meal);
                                  });
                                },
                                onCustomize: meal.customisable
                                    ? () => _openCustomizeMeal(meal)
                                    : null,
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Wrap(
                                  spacing: 6,
                                  children: [
                                    if (meal.mostReorderedBadge)
                                      const _Badge(label: 'Most reordered'),
                                    if (meal.offerTag != null)
                                      _Badge(label: meal.offerTag!),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 8,
                                child: IconButton.filledTonal(
                                  onPressed: () => _openMealReviews(meal),
                                  icon: const Icon(
                                    Icons.reviews_outlined,
                                    size: 18,
                                  ),
                                  tooltip: 'Reviews',
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemCount: displayMeals.length,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: 'Again from last week',
                    subtitle: 'Quick reorder from recent patterns',
                  ),
                  const SizedBox(height: 8),
                  if (state.lastWeekMeals.isEmpty)
                    _FeedFallbackCard(
                      message: 'No last-week reorder items found.',
                      actionLabel: 'Reorder latest delivered',
                      onPressed: _reorderFromRecent,
                    )
                  else
                    _HorizontalMealStrip(
                      meals: state.lastWeekMeals.take(8).toList(),
                      onOrder: (meal) {
                        setState(() {
                          state.addToCart(meal);
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: 'Most reordered in your area',
                    subtitle: 'Local popularity ranking',
                  ),
                  const SizedBox(height: 8),
                  _HorizontalMealStrip(
                    meals: state.mostReorderedMeals.isEmpty
                        ? displayMeals.take(6).toList()
                        : state.mostReorderedMeals.take(6).toList(),
                    onOrder: (meal) {
                      setState(() {
                        state.addToCart(meal);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: 'Recommended for you',
                    subtitle:
                        'Heuristic ranker: affinity, rating, popularity, slot-fit, offer, ETA',
                  ),
                  const SizedBox(height: 8),
                  _HorizontalMealStrip(
                    meals: state.recommendedMeals.isEmpty
                        ? displayMeals.take(6).toList()
                        : state.recommendedMeals.take(6).toList(),
                    onOrder: (meal) {
                      setState(() {
                        state.addToCart(meal);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    title: strings.text('weeklyMenu'),
                    subtitle: 'Subscriptions + one-tap checkout defaults',
                  ),
                  const SizedBox(height: 10),
                  DaySelector(
                    days: _days,
                    selected: state.selectedDay,
                    onSelect: (day) {
                      setState(() {
                        state.setDay(day);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _openCheckoutPreferences,
                          icon: const Icon(Icons.tune_outlined, size: 16),
                          label: const Text('One-tap prefs'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SubscriptionScreen(appState: state),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                          ),
                          label: const Text('Order Full Week'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _SectionTitle(
                    title: 'Realtime tracking + support',
                    subtitle: 'Map ETA, delay prediction, issue workflows',
                  ),
                  const SizedBox(height: 8),
                  if (latestOrders.isEmpty)
                    _FeedFallbackCard(
                      message: 'No recent orders for tracking shortcuts.',
                      actionLabel: 'Sync orders',
                      onPressed: _reloadAll,
                    )
                  else
                    ...latestOrders.map(
                      (order) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${order.id} • ${order.deliveryWindow}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _StatusBadge(status: order.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(order.address),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _openTrackingSnapshot(order),
                                    icon: const Icon(
                                      Icons.map_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Realtime ETA'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _startSupportChat(order),
                                    icon: const Icon(
                                      Icons.chat_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Support chat'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _raiseIssue(
                                      order,
                                      IssueType.lateDelivery,
                                    ),
                                    icon: const Icon(
                                      Icons.report_problem_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Raise issue'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  const _SectionTitle(
                    title: 'Top food places near you',
                    subtitle:
                        'Restaurants, dhabhas, tiffin and kitchens with schedule/custom meal support',
                  ),
                  const SizedBox(height: 8),
                  if (discoverPlaces.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No food places mapped for this city/area.',
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: discoverPlaces
                          .map(
                            (place) => ActionChip(
                              avatar: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(0xFFE7F0FF),
                                child: Icon(
                                  Icons.storefront_outlined,
                                  size: 12,
                                  color: FoodilyColors.navy,
                                ),
                              ),
                              label: Text(
                                '${place.name} • ${_placeTypeLabel(place.type)} • ★${place.rating.toStringAsFixed(1)}',
                              ),
                              onPressed: () => _openPlaceConnectDialog(place),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reloadAll,
                          icon: const Icon(Icons.sync_outlined, size: 16),
                          label: const Text('Background sync'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _prefetchMealImages,
                          icon: const Icon(Icons.image_outlined, size: 16),
                          label: const Text('Prefetch images'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } catch (error, stack) {
              debugPrint(
                'HomeScreen build failed for feed section: $error\n$stack',
              );
              final fallbackMeals = state.fallbackMeals();
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                children: [
                  _FeedFallbackCard(
                    message:
                        'Could not render home feed. Showing fallback meals.',
                    actionLabel: 'Retry',
                    onPressed: _reloadAll,
                  ),
                  const SizedBox(height: 12),
                  _SectionTitle(
                    title: strings.text('sameDay'),
                    subtitle: 'Fallback rendering path active',
                  ),
                  const SizedBox(height: 8),
                  if (fallbackMeals.isEmpty)
                    const _FeedFallbackCard(
                      message: 'No fallback meals available right now.',
                      actionLabel: 'Refresh',
                      onPressed: null,
                    )
                  else
                    SizedBox(
                      height: 322,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 10),
                        itemCount: fallbackMeals.length,
                        itemBuilder: (context, index) {
                          final meal = fallbackMeals[index];
                          return MealCard(
                            meal: meal,
                            onOrder: () {
                              setState(() {
                                state.addToCart(meal);
                              });
                            },
                            onCustomize: meal.customisable
                                ? () => _openCustomizeMeal(meal)
                                : null,
                          );
                        },
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: StickyCheckoutBar(
        total: state.cartTotal,
        primaryLabel: state.hasItems
            ? 'Go to Cart (${state.cartCount})'
            : 'Select meals to continue',
        onPressed: () {
          if (!state.hasItems) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add at least one meal to continue.'),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CartScreen(appState: state)),
          );
        },
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.isDemo});

  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDemo
            ? const Color(0xFFF59E0B).withValues(alpha: 0.14)
            : const Color(0xFF1A8F46).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isDemo ? 'DEMO' : 'LIVE',
        style: TextStyle(
          color: isDemo ? const Color(0xFFB45309) : const Color(0xFF166534),
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _HealthPill extends StatelessWidget {
  const _HealthPill({required this.health});

  final DataHealthSnapshot health;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'M${health.meals} O${health.orders} F${health.partners}',
        style: const TextStyle(
          color: FoodilyColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final cityMeals = MockData.meals
        .where((meal) => meal.cityId == state.selectedCity.id)
        .toList();
    final imageUrl = cityMeals.isNotEmpty
        ? cityMeals.first.imageUrl
        : MockData.meals.first.imageUrl;

    final breakfast = _slotPrice(cityMeals, MealSlot.breakfast);
    final lunch = _slotPrice(cityMeals, MealSlot.lunch);
    final dinner = _slotPrice(cityMeals, MealSlot.dinner);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 236,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF0E3A6D),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FoodilyColors.navy.withValues(alpha: 0.25),
                    FoodilyColors.navy,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demo-first, live-ready',
                    style: TextStyle(
                      color: Color(0xFFD7EBFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily Meals in ${state.selectedCity.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _priceTag('Breakfast', breakfast),
                      const SizedBox(width: 8),
                      _priceTag('Lunch', lunch),
                      const SizedBox(width: 8),
                      _priceTag('Dinner', dinner),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _slotPrice(List<Meal> meals, MealSlot slot) {
    final slotMeals = meals.where((meal) => meal.slot == slot).toList();
    if (slotMeals.isEmpty) return 0;
    return slotMeals.fold(
      9999,
      (minPrice, meal) => math.min(minPrice, meal.price),
    );
  }

  Widget _priceTag(String slot, int price) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Column(
          children: [
            Text(
              '₹$price',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              slot,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      ],
    );
  }
}

class _HorizontalMealStrip extends StatelessWidget {
  const _HorizontalMealStrip({required this.meals, required this.onOrder});

  final List<Meal> meals;
  final ValueChanged<Meal> onOrder;

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('No meals available right now.'),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return SizedBox(
            width: 260,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        meal.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              width: 80,
                              height: 80,
                              child: ColoredBox(
                                color: Color(0xFFE2E8F0),
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${meal.price} • ${meal.calories} kcal • ${meal.prepTimeMin} min',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () => onOrder(meal),
                              child: const Text('Order now'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: meals.length,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.created => ('Created', const Color(0xFF475569)),
      OrderStatus.confirmed => ('Confirmed', const Color(0xFF334155)),
      OrderStatus.preparing => ('Preparing', const Color(0xFFD97706)),
      OrderStatus.outForDelivery => (
        'Out for delivery',
        const Color(0xFF1E67D1),
      ),
      OrderStatus.delivered => ('Delivered', const Color(0xFF1A8F46)),
      OrderStatus.cancelled => ('Cancelled', const Color(0xFFDB3A34)),
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

class _MiniMapCard extends StatelessWidget {
  const _MiniMapCard({required this.snapshot});

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
      final center = Offset(size.width / 2, size.height / 2);
      canvas.drawCircle(center, 8, Paint()..color = const Color(0xFF0E3A6D));
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
    final metrics = path.computeMetrics();
    if (metrics.isNotEmpty) {
      final position = metrics.first.getTangentForOffset(metrics.first.length);
      if (position != null) {
        canvas.drawCircle(
          position.position,
          7,
          Paint()..color = const Color(0xFF0F172A),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.route != route;
  }
}

class _FeedFallbackCard extends StatelessWidget {
  const _FeedFallbackCard({
    required this.message,
    required this.actionLabel,
    this.onPressed,
  });

  final String message;
  final String actionLabel;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onPressed == null ? null : () => onPressed!(),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeInput extends StatelessWidget {
  const _RangeInput({
    required this.title,
    required this.min,
    required this.max,
    required this.minLimit,
    required this.maxLimit,
    required this.onChanged,
  });

  final String title;
  final double min;
  final double max;
  final double minLimit;
  final double maxLimit;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${min.round()} - ${max.round()}'),
        RangeSlider(
          values: RangeValues(min, max),
          min: minLimit,
          max: maxLimit,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.radius = 12});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
