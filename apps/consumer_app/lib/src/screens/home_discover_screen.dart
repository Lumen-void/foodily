import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';
import 'cart_screen.dart';
import 'restaurant_menu_screen.dart';
import 'widgets/cart_cta_bar.dart';

class HomeDiscoverScreen extends StatefulWidget {
  const HomeDiscoverScreen({
    super.key,
    required this.appState,
    required this.locale,
  });

  final AppState appState;
  final Locale locale;

  @override
  State<HomeDiscoverScreen> createState() => _HomeDiscoverScreenState();
}

enum _HomeQuickFilter { all, favorites, fast, budget, veg, protein }

class _HomeDiscoverScreenState extends State<HomeDiscoverScreen> {
  final _searchController = TextEditingController();
  bool _loading = false;
  _HomeQuickFilter _quickFilter = _HomeQuickFilter.all;
  String _selectedCuisine = 'All';

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

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _loading = true;
    });
    try {
      await widget.appState.backgroundSync();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _placeMatchesQuickFilter(FoodPlace place) {
    final placeMeals = MockData.mealsForFoodPlace(placeId: place.id);
    if (_quickFilter == _HomeQuickFilter.all) return true;
    if (_quickFilter == _HomeQuickFilter.favorites) {
      return widget.appState.isPlaceFavorite(place.id);
    }
    if (_quickFilter == _HomeQuickFilter.fast) {
      return place.avgDeliveryMinutes <= 30;
    }
    if (_quickFilter == _HomeQuickFilter.budget) {
      return placeMeals.any((meal) => meal.price <= 120);
    }
    if (_quickFilter == _HomeQuickFilter.veg) {
      return placeMeals.any(_isVegMeal);
    }
    return placeMeals.any(_isProteinMeal);
  }

  bool _isVegMeal(Meal meal) {
    final signature = '${meal.name} ${meal.tags.join(' ')} ${meal.cuisine}'
        .toLowerCase();
    return signature.contains('veg') ||
        signature.contains('paneer') ||
        signature.contains('salad') ||
        signature.contains('dal');
  }

  bool _isProteinMeal(Meal meal) {
    final signature = '${meal.name} ${meal.tags.join(' ')} ${meal.cuisine}'
        .toLowerCase();
    return signature.contains('protein') ||
        signature.contains('egg') ||
        signature.contains('chicken') ||
        signature.contains('high protein');
  }

  List<String> _cuisineTabs(List<FoodPlace> places) {
    final values = <String>{'All'};
    for (final place in places) {
      for (final tag in place.cuisineTags) {
        final lower = tag.toLowerCase();
        if (lower.contains('pizza')) values.add('Pizza');
        if (lower.contains('burger')) values.add('Burger');
        if (lower.contains('roll')) values.add('Rolls');
        if (lower.contains('thali') || lower.contains('rasoi')) {
          values.add('Thali');
        }
      }
    }
    for (final label in const ['Pizza', 'Burger', 'Rolls']) {
      values.add(label);
    }
    return values.toList(growable: false);
  }

  bool _matchesCuisine(FoodPlace place) {
    if (_selectedCuisine == 'All') return true;
    final query = _selectedCuisine.toLowerCase();
    final corpus = '${place.name} ${place.cuisineTags.join(' ')}'.toLowerCase();
    return corpus.contains(query);
  }

  String _heroImageForCuisine(String cuisine, List<FoodPlace> places) {
    if (places.isEmpty) return '';
    if (cuisine == 'All') return places.first.imageUrl;
    final query = cuisine.toLowerCase();
    final matched = places.firstWhere(
      (place) =>
          place.name.toLowerCase().contains(query) ||
          place.cuisineTags.join(' ').toLowerCase().contains(query),
      orElse: () => places.first,
    );
    return matched.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cityPlaces = state.foodPlacesForCity(state.selectedCity.id);
    final places = cityPlaces.isNotEmpty ? cityPlaces : MockData.foodPlaces;
    final query = _searchController.text.trim().toLowerCase();

    final cuisineTabs = _cuisineTabs(places);
    if (!cuisineTabs.contains(_selectedCuisine)) {
      _selectedCuisine = 'All';
    }

    final filteredPlaces = places
        .where((place) {
          if (query.isEmpty) return true;
          final cuisines = place.cuisineTags.join(' ').toLowerCase();
          return place.name.toLowerCase().contains(query) ||
              cuisines.contains(query);
        })
        .where(_placeMatchesQuickFilter)
        .where(_matchesCuisine)
        .toList(growable: false);

    final visiblePlaces = filteredPlaces.isNotEmpty ? filteredPlaces : places;
    final headlineCount = math.max(visiblePlaces.length, 1);

    return Theme(
      data: _noOverlayTheme(context),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1118) : colorScheme.surface,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: FoodilyColors.accentYellow,
            backgroundColor: isDark
                ? const Color(0xFF1A1F2B)
                : colorScheme.surfaceContainerHighest,
            onRefresh: _refreshFeed,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 124),
              children: [
                _HomeSearchPanel(
                  controller: _searchController,
                  locationLabel:
                      '${state.selectedZone.name}, ${state.selectedCity.name}',
                  loading: _loading,
                  vegOnly: _quickFilter == _HomeQuickFilter.veg,
                  onSearchChanged: (_) => setState(() {}),
                  onRefresh: _refreshFeed,
                  onVoiceTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Voice search is coming soon'.tr(context),
                        ),
                      ),
                    );
                  },
                  onToggleVeg: (value) {
                    setState(() {
                      _quickFilter = value
                          ? _HomeQuickFilter.veg
                          : _HomeQuickFilter.all;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF223A7B), Color(0xFF385DA8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'FINAL PRICE, BEST OFFER APPLIED'.tr(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _quickFilter = _HomeQuickFilter.budget;
                            _selectedCuisine = 'All';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Applied budget meals filter'.tr(context),
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          overlayColor: Colors.transparent,
                          minimumSize: const Size(96, 34),
                        ),
                        child: Text('Order now'.tr(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _PromoCuisineTile(
                          onTap: () {
                            setState(() {
                              _quickFilter = _HomeQuickFilter.budget;
                              _selectedCuisine = 'All';
                            });
                          },
                        );
                      }
                      final cuisine = cuisineTabs[index - 1];
                      final selected = _selectedCuisine == cuisine;
                      return _CuisineBubble(
                        title: cuisine.tr(context),
                        selected: selected,
                        imageUrl: _heroImageForCuisine(cuisine, places),
                        onTap: () {
                          setState(() {
                            _selectedCuisine = cuisine;
                          });
                        },
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemCount: cuisineTabs.length + 1,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickFilterPill(
                        label: 'Filters'.tr(context),
                        selected: _quickFilter == _HomeQuickFilter.all,
                        onTap: () =>
                            setState(() => _quickFilter = _HomeQuickFilter.all),
                      ),
                      _QuickFilterPill(
                        label: 'New to you'.tr(context),
                        selected: _quickFilter == _HomeQuickFilter.fast,
                        onTap: () => setState(
                          () => _quickFilter = _HomeQuickFilter.fast,
                        ),
                      ),
                      _QuickFilterPill(
                        label: 'Loved by friends'.tr(context),
                        selected: _quickFilter == _HomeQuickFilter.favorites,
                        onTap: () => setState(
                          () => _quickFilter = _HomeQuickFilter.favorites,
                        ),
                      ),
                      _QuickFilterPill(
                        label: 'Under ₹120'.tr(context),
                        selected: _quickFilter == _HomeQuickFilter.budget,
                        onTap: () => setState(
                          () => _quickFilter = _HomeQuickFilter.budget,
                        ),
                      ),
                      _QuickFilterPill(
                        label: 'High Protein'.tr(context),
                        selected: _quickFilter == _HomeQuickFilter.protein,
                        onTap: () => setState(
                          () => _quickFilter = _HomeQuickFilter.protein,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '$headlineCount ${'RESTAURANTS DELIVERING TO YOU'.tr(context)}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Recommended for you'.tr(context),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (visiblePlaces.isEmpty)
                  _AdaptiveEmptyCard(
                    message: 'No restaurants found'.tr(context),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final compact = width < 360;
                      final textScale = MediaQuery.textScalerOf(
                        context,
                      ).scale(1);
                      final columns = compact ? 1 : 2;
                      final ratio = compact
                          ? (textScale > 1.05 ? 1.32 : 1.45)
                          : width < 420
                          ? (textScale > 1.05 ? 0.52 : 0.58)
                          : (textScale > 1.05 ? 0.58 : 0.64);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: math.min(visiblePlaces.length, 6),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: ratio,
                        ),
                        itemBuilder: (context, index) {
                          final place = visiblePlaces[index];
                          return _RecommendedRestaurantCard(
                            place: place,
                            imageUrl: place.imageUrl,
                            isFavorite: state.isPlaceFavorite(place.id),
                            onTap: () {
                              state.setFoodPlace(place);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RestaurantMenuScreen(
                                    appState: state,
                                    place: place,
                                  ),
                                ),
                              );
                            },
                            onToggleFavorite: () {
                              state.togglePlaceFavorite(place.id);
                              setState(() {});
                            },
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 18),
                Text(
                  'EXPLORE MORE'.tr(context),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.0,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 122,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ExploreCard(
                        icon: Icons.local_offer_outlined,
                        title: 'Offers',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Offers opened'.tr(context)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ExploreCard(
                        icon: Icons.train_outlined,
                        title: 'Food on train',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Food on train'.tr(context)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ExploreCard(
                        icon: Icons.celebration_outlined,
                        title: 'Plan a party',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Plan a party'.tr(context))),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ExploreCard(
                        icon: Icons.collections_bookmark_outlined,
                        title: 'Collections',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Collections opened'.tr(context)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CartCtaBar(
          itemCount: state.cartCount,
          total: state.cartTotal,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CartScreen(appState: state)),
            );
          },
        ),
      ),
    );
  }
}

class _HomeSearchPanel extends StatelessWidget {
  const _HomeSearchPanel({
    required this.controller,
    required this.locationLabel,
    required this.loading,
    required this.vegOnly,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onVoiceTap,
    required this.onToggleVeg,
  });

  final TextEditingController controller;
  final String locationLabel;
  final bool loading;
  final bool vegOnly;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onVoiceTap;
  final ValueChanged<bool> onToggleVeg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final panelColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.04),
      isDark ? const Color(0xFF0F1624) : colorScheme.surfaceContainerHighest,
    );
    final panelBorderColor = isDark
        ? const Color(0xFF2A3345)
        : colorScheme.outlineVariant.withValues(alpha: 0.72);
    final searchColor = isDark ? const Color(0xFF131B2B) : colorScheme.surface;
    final searchBorderColor = isDark
        ? const Color(0xFF303B4F)
        : colorScheme.outlineVariant.withValues(alpha: 0.88);
    final primaryText = colorScheme.onSurface;
    final mutedText = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: panelBorderColor),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 388;

              final searchField = Container(
                height: 54,
                decoration: BoxDecoration(
                  color: searchColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: searchBorderColor),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.search,
                      size: 24,
                      color: mutedText.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onSearchChanged,
                        style: TextStyle(color: primaryText),
                        decoration: InputDecoration(
                          hintText: 'Search "burger"'.tr(context),
                          hintStyle: TextStyle(
                            color: mutedText.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (controller.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          controller.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: mutedText.withValues(alpha: 0.9),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    const SizedBox(width: 4),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: searchBorderColor,
                    ),
                    IconButton(
                      onPressed: onVoiceTap,
                      icon: const Icon(Icons.mic_none_rounded),
                      color: mutedText.withValues(alpha: 0.9),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                  ],
                ),
              );

              final vegToggle = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'VEG',
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 50,
                    child: Switch(
                      value: vegOnly,
                      onChanged: onToggleVeg,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF00C26E),
                      inactiveTrackColor: colorScheme.outline.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: vegToggle),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 10),
                  vegToggle,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: mutedText.withValues(alpha: 0.88),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mutedText.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.sync),
                  color: mutedText.withValues(alpha: 0.9),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoCuisineTile extends StatelessWidget {
  const _PromoCuisineTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF3968CE), Color(0xFF57A4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MEALS UNDER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '₹250',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            Text(
              'Explore >',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuisineBubble extends StatelessWidget {
  const _CuisineBubble({
    required this.title,
    required this.selected,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF22C55E)
                      : colorScheme.outlineVariant.withValues(alpha: 0.9),
                  width: selected ? 2.4 : 1.1,
                ),
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            ColoredBox(
                              color: isDark
                                  ? const Color(0xFF1A1F2B)
                                  : colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.fastfood_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                      )
                    : ColoredBox(
                        color: isDark
                            ? const Color(0xFF1A1F2B)
                            : colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.fastfood_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF22C55E) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFilterPill extends StatelessWidget {
  const _QuickFilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer.withValues(alpha: 0.65)
                : (isDark
                      ? const Color(0xFF151A27)
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.48,
                        )),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdaptiveEmptyCard extends StatelessWidget {
  const _AdaptiveEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151A27) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RecommendedRestaurantCard extends StatelessWidget {
  const _RecommendedRestaurantCard({
    required this.place,
    required this.imageUrl,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final FoodPlace place;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151A27) : colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            ColoredBox(
                              color: isDark
                                  ? const Color(0xFF202739)
                                  : colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  Icons.restaurant,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FLAT ₹125 OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? const Color(0xFFEF4444)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '★${place.rating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${place.avgDeliveryMinutes - 4}-${place.avgDeliveryMinutes + 1} mins',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
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

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF171D2C) : colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
