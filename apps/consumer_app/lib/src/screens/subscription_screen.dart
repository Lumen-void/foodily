import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';
import 'cart_screen.dart';
import 'restaurant_menu_screen.dart';
import 'widgets/cart_cta_bar.dart';
import 'widgets/discovery_header.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String planType = 'Weekly';
  String startDate = 'Next Monday';
  MealSlot selectedSlot = MealSlot.lunch;
  bool includeCustomisation = true;
  bool autoRenew = true;

  ThemeData _noOverlayTheme(BuildContext context) {
    final base = Theme.of(context);
    const transparentOverlay = WidgetStatePropertyAll<Color?>(
      Colors.transparent,
    );

    ButtonStyle clearOverlay([ButtonStyle? style]) {
      return (style ?? const ButtonStyle()).copyWith(
        overlayColor: transparentOverlay,
      );
    }

    return base.copyWith(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      filledButtonTheme: FilledButtonThemeData(
        style: clearOverlay(base.filledButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: clearOverlay(base.textButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: clearOverlay(base.outlinedButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: clearOverlay(base.elevatedButtonTheme.style),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: clearOverlay(base.iconButtonTheme.style),
      ),
    );
  }

  final _customNoteController = TextEditingController(
    text: 'Less oil, low spice, extra salad.',
  );
  final _searchController = TextEditingController();
  final Map<String, int> _customMealQty = {};
  late FoodPlace _selectedPlace;

  List<FoodPlace> get _places {
    final scoped = widget.appState.foodPlacesForCity(
      widget.appState.selectedCity.id,
    );
    return scoped.isNotEmpty ? scoped : MockData.foodPlaces;
  }

  List<Meal> get _selectedPlaceMeals {
    final all = MockData.mealsForFoodPlace(
      placeId: _selectedPlace.id,
    ).where((meal) => meal.available).toList(growable: false);
    return all.isNotEmpty ? all : widget.appState.fallbackMeals();
  }

  @override
  void initState() {
    super.initState();
    _selectedPlace = _places.first;
  }

  @override
  void dispose() {
    _customNoteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FoodPlace> _filteredPlaces(String query) {
    if (query.isEmpty) return _places;
    return _places
        .where((place) {
          final cuisines = place.cuisineTags.join(' ').toLowerCase();
          return place.name.toLowerCase().contains(query) ||
              cuisines.contains(query);
        })
        .toList(growable: false);
  }

  void _syncPlaceSelection(List<FoodPlace> places) {
    if (places.isEmpty) return;
    if (!places.any((place) => place.id == _selectedPlace.id)) {
      _selectedPlace = places.first;
      widget.appState.setFoodPlace(_selectedPlace);
    }
  }

  int _baseSlotPrice() {
    final slotMeals = _selectedPlaceMeals
        .where((meal) => meal.slot == selectedSlot)
        .toList(growable: false);
    final list = slotMeals.isNotEmpty ? slotMeals : _selectedPlaceMeals;
    if (list.isEmpty) return 0;
    final total = list.fold<int>(0, (sum, meal) => sum + meal.price);
    return (total / list.length).round();
  }

  double _monthlyDiscount() {
    return switch (_selectedPlace.type) {
      FoodPlaceType.restaurant => 0.08,
      FoodPlaceType.dhaba => 0.12,
      FoodPlaceType.tiffin => 0.15,
      FoodPlaceType.cloudKitchen => 0.10,
    };
  }

  int _weeklyPrice() {
    final base = _baseSlotPrice();
    return base * 7;
  }

  int _monthlyPrice() {
    final weekly = _weeklyPrice();
    final discounted = (weekly * 4) * (1 - _monthlyDiscount());
    return discounted.round();
  }

  int _customPrice() {
    if (_customMealQty.isEmpty) {
      return (_baseSlotPrice() * 3).round();
    }
    final mealsById = {for (final meal in _selectedPlaceMeals) meal.id: meal};
    var total = 0;
    _customMealQty.forEach((mealId, qty) {
      final meal = mealsById[mealId];
      if (meal == null) return;
      total += meal.price * qty;
    });
    return total;
  }

  int _planPrice() {
    return switch (planType) {
      'Weekly' => _weeklyPrice(),
      'Monthly' => _monthlyPrice(),
      _ => _customPrice(),
    };
  }

  Future<void> _applyPlan() async {
    final window = switch (selectedSlot) {
      MealSlot.breakfast => '9:00 AM - 9:30 AM',
      MealSlot.lunch => '1:00 PM - 1:30 PM',
      MealSlot.dinner => '8:00 PM - 8:30 PM',
    };

    await widget.appState.updateCheckoutPreferences(
      widget.appState.checkoutPreferences.copyWith(
        preferredWindow: window,
        defaultCadence: planType,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${planType.tr(context)} ${'plan'.tr(context)} ${'Save'.tr(context).toLowerCase()} • ${_selectedPlace.name} • ₹${_planPrice()}',
        ),
      ),
    );
  }

  String _placeTypeLabel(FoodPlaceType type) {
    return switch (type) {
      FoodPlaceType.restaurant => 'Restaurant',
      FoodPlaceType.dhaba => 'Dhaba',
      FoodPlaceType.tiffin => 'Tiffin / Rasoi',
      FoodPlaceType.cloudKitchen => 'Cloud Kitchen',
    };
  }

  String _slotLabel(MealSlot slot) {
    return switch (slot) {
      MealSlot.breakfast => 'Breakfast',
      MealSlot.lunch => 'Lunch',
      MealSlot.dinner => 'Dinner',
    };
  }

  void _applyPreset(String presetId) {
    final suggestedPlace = widget.appState.suggestedPlaceForNow();
    setState(() {
      switch (presetId) {
        case 'weeklyVeg':
          planType = 'Weekly';
          selectedSlot = MealSlot.lunch;
          includeCustomisation = true;
          autoRenew = true;
          _customNoteController.text = 'Pure veg, less oil, home-style.';
          break;
        case 'monthlyFamily':
          planType = 'Monthly';
          selectedSlot = MealSlot.dinner;
          includeCustomisation = true;
          autoRenew = true;
          _customNoteController.text = 'Family portions, balanced meals.';
          break;
        case 'custom':
          planType = 'Custom';
          includeCustomisation = true;
          autoRenew = false;
          break;
        case 'auto':
          planType = widget.appState.suggestedPlanType();
          selectedSlot = widget.appState.suggestedSlotForNow();
          _selectedPlace = suggestedPlace;
          includeCustomisation = true;
          autoRenew = true;
          _customNoteController.text = 'Auto-applied smart plan.';
          break;
      }
    });
    widget.appState.setFoodPlace(_selectedPlace);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final places = _filteredPlaces(query);
    _syncPlaceSelection(places.isNotEmpty ? places : _places);

    final meals = _selectedPlaceMeals
        .where((meal) {
          if (query.isEmpty) return true;
          final tags = meal.tags.join(' ').toLowerCase();
          return meal.name.toLowerCase().contains(query) ||
              tags.contains(query);
        })
        .toList(growable: false);

    final mealById = {for (final meal in meals) meal.id: meal};
    final planTypes = const ['Weekly', 'Monthly', 'Custom'];
    final baseTheme = _noOverlayTheme(context);
    final colorScheme = baseTheme.colorScheme;
    final readableChipTheme = baseTheme.chipTheme.copyWith(
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      side: BorderSide(color: colorScheme.outlineVariant),
      labelStyle: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
      secondaryLabelStyle: TextStyle(
        color: colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w800,
      ),
    );

    return Theme(
      data: baseTheme.copyWith(chipTheme: readableChipTheme),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: colorScheme.onSurface),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 124),
              children: [
                DiscoveryHeader(
                  title: 'Meals'.tr(context),
                  locationLabel:
                      '${widget.appState.selectedZone.name}, ${widget.appState.selectedCity.name}',
                  searchController: _searchController,
                  searchHint: 'Search restaurants, meals, plans'.tr(context),
                  onSearchChanged: (_) => setState(() {}),
                  trailing: IconButton.filledTonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestaurantMenuScreen(
                            appState: widget.appState,
                            place: _selectedPlace,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.storefront_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Meal presets'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: Text('Weekly Veg'.tr(context)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      onPressed: () => _applyPreset('weeklyVeg'),
                    ),
                    ActionChip(
                      label: Text('Monthly Family'.tr(context)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      onPressed: () => _applyPreset('monthlyFamily'),
                    ),
                    ActionChip(
                      label: Text('Custom'.tr(context)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      onPressed: () => _applyPreset('custom'),
                    ),
                    ActionChip(
                      label: Text('Auto'.tr(context)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      onPressed: () => _applyPreset('auto'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Choose Restaurant'.tr(context),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                if (places.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'No restaurants found for this search.'.tr(context),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 152,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: places.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final place = places[index];
                        final selected = place.id == _selectedPlace.id;
                        return SizedBox(
                          width: 266,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            overlayColor: const WidgetStatePropertyAll<Color?>(
                              Colors.transparent,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedPlace = place;
                                _customMealQty.clear();
                              });
                              widget.appState.setFoodPlace(place);
                            },
                            child: Card(
                              color: selected
                                  ? colorScheme.primaryContainer.withValues(
                                      alpha: 0.55,
                                    )
                                  : colorScheme.surface,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        place.imageUrl,
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox(
                                                  width: 72,
                                                  height: 72,
                                                  child: ColoredBox(
                                                    color: Color(0xFFE2E8F0),
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
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_placeTypeLabel(place.type).tr(context)} • ★${place.rating.toStringAsFixed(1)}',
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${'From'.tr(context)} ₹${_priceFloorForPlace(place.id)}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color:
                                                        colorScheme.onSurface,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  widget.appState
                                                      .togglePlaceFavorite(
                                                        place.id,
                                                      );
                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  widget.appState
                                                          .isPlaceFavorite(
                                                            place.id,
                                                          )
                                                      ? Icons.favorite_rounded
                                                      : Icons
                                                            .favorite_border_rounded,
                                                  color:
                                                      widget.appState
                                                          .isPlaceFavorite(
                                                            place.id,
                                                          )
                                                      ? const Color(0xFFEF4444)
                                                      : colorScheme
                                                            .onSurfaceVariant,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          RestaurantMenuScreen(
                                                            appState:
                                                                widget.appState,
                                                            place: place,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.chevron_right,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
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
                const SizedBox(height: 14),
                Text(
                  'Plan Type'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: planTypes
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item.tr(context)),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                          selected: planType == item,
                          onSelected: (_) {
                            setState(() {
                              planType = item;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: startDate,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Start'.tr(context),
                    prefixIcon: const Icon(Icons.event_outlined),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Next Monday',
                      child: Text('Next Monday'.tr(context)),
                    ),
                    DropdownMenuItem(
                      value: 'Tomorrow',
                      child: Text('Tomorrow'.tr(context)),
                    ),
                    DropdownMenuItem(
                      value: 'Next Week',
                      child: Text('Next Week'.tr(context)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      startDate = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Breakfast'.tr(context)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      selected: selectedSlot == MealSlot.breakfast,
                      onSelected: (_) {
                        setState(() {
                          selectedSlot = MealSlot.breakfast;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text('Lunch'.tr(context)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      selected: selectedSlot == MealSlot.lunch,
                      onSelected: (_) {
                        setState(() {
                          selectedSlot = MealSlot.lunch;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text('Dinner'.tr(context)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                      selected: selectedSlot == MealSlot.dinner,
                      onSelected: (_) {
                        setState(() {
                          selectedSlot = MealSlot.dinner;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Pricing'.tr(context),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _PriceTile(
                                title: 'Weekly'.tr(context),
                                value: _weeklyPrice(),
                                active: planType == 'Weekly',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PriceTile(
                                title: 'Monthly'.tr(context),
                                value: _monthlyPrice(),
                                active: planType == 'Monthly',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PriceTile(
                                title: 'Custom'.tr(context),
                                value: _customPrice(),
                                active: planType == 'Custom',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${'Selected'.tr(context)}: ${_selectedPlace.name} • ${_slotLabel(selectedSlot).tr(context)} • ${'Starts'.tr(context)} ${startDate.tr(context)}',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Menu Items & Prices'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (meals.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'No meals available for this place right now.'.tr(
                          context,
                        ),
                      ),
                    ),
                  )
                else
                  ...meals.map((meal) {
                    final qty = _customMealQty[meal.id] ?? 0;
                    final selected = qty > 0;
                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            meal.imageUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: ColoredBox(
                                    color: Color(0xFFE2E8F0),
                                    child: Icon(Icons.fastfood_outlined),
                                  ),
                                ),
                          ),
                        ),
                        title: Text(
                          '${meal.name} • ₹${meal.price}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${_slotLabel(meal.slot).tr(context)} • ${meal.calories} kcal • ${meal.prepTimeMin} min',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: planType == 'Custom'
                            ? SizedBox(
                                width: 120,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: qty > 0
                                          ? () {
                                              setState(() {
                                                if (qty <= 1) {
                                                  _customMealQty.remove(
                                                    meal.id,
                                                  );
                                                } else {
                                                  _customMealQty[meal.id] =
                                                      qty - 1;
                                                }
                                              });
                                            }
                                          : null,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$qty',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _customMealQty[meal.id] = qty + 1;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              )
                            : Chip(
                                label: Text(
                                  selected
                                      ? 'Selected'.tr(context)
                                      : 'Available'.tr(context),
                                ),
                              ),
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                TextField(
                  controller: _customNoteController,
                  minLines: 2,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Customization notes'.tr(context),
                    prefixIcon: const Icon(Icons.tune_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: includeCustomisation,
                  onChanged: (value) {
                    setState(() {
                      includeCustomisation = value;
                    });
                  },
                  title: Text('Include custom preferences'.tr(context)),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: autoRenew,
                  onChanged: (value) {
                    setState(() {
                      autoRenew = value;
                    });
                  },
                  title: Text('Auto-renew plan'.tr(context)),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _applyPlan,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    '${'Save'.tr(context)} ${planType.tr(context).toLowerCase()} ${'plan'.tr(context)} • ₹${_planPrice()}',
                  ),
                ),
                const SizedBox(height: 8),
                if (_customMealQty.isNotEmpty)
                  Text(
                    '${'Custom basket'.tr(context)}: ${_customMealQty.entries.map((entry) => "${mealById[entry.key]?.name ?? "Item"} x${entry.value}").join(", ")}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CartCtaBar(
          itemCount: widget.appState.cartCount,
          total: widget.appState.cartTotal,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CartScreen(appState: widget.appState),
              ),
            );
          },
        ),
      ),
    );
  }

  int _priceFloorForPlace(String placeId) {
    final meals = MockData.mealsForFoodPlace(placeId: placeId);
    if (meals.isEmpty) return 0;
    return meals
        .map((meal) => meal.price)
        .reduce((current, next) => current < next ? current : next);
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({
    required this.title,
    required this.value,
    required this.active,
  });

  final String title;
  final int value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? colorScheme.primaryContainer.withValues(alpha: 0.65)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: active
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '₹$value',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: active ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
