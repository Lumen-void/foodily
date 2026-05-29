import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';
import 'cart_screen.dart';
import 'widgets/cart_cta_bar.dart';

enum _MenuSortMode { top, priceLow, priceHigh, fastest, rating }

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({
    super.key,
    required this.appState,
    required this.place,
  });

  final AppState appState;
  final FoodPlace place;

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final _searchController = TextEditingController();
  MealSlot? _selectedSlot;
  bool _vegOnly = false;
  _MenuSortMode _sortMode = _MenuSortMode.top;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ThemeData _noOverlayTheme(BuildContext context) {
    final base = Theme.of(context);
    const transparent = WidgetStatePropertyAll<Color?>(Colors.transparent);

    ButtonStyle noOverlay(ButtonStyle? style) {
      return (style ?? const ButtonStyle()).copyWith(
        overlayColor: transparent,
        splashFactory: NoSplash.splashFactory,
      );
    }

    return base.copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      filledButtonTheme: FilledButtonThemeData(
        style: noOverlay(base.filledButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: noOverlay(base.textButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: noOverlay(base.elevatedButtonTheme.style),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: noOverlay(base.iconButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: noOverlay(base.outlinedButtonTheme.style),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final allMeals = MockData.mealsForFoodPlace(
      placeId: widget.place.id,
    ).where((meal) => meal.available).toList(growable: false);

    final query = _searchController.text.trim().toLowerCase();
    final matchingMeals = allMeals
        .where((meal) {
          final slotMatches =
              _selectedSlot == null || meal.slot == _selectedSlot;
          if (!slotMatches) return false;
          if (_vegOnly && !_isVegMeal(meal)) return false;
          if (query.isEmpty) return true;
          final tags = meal.tags.join(' ').toLowerCase();
          return meal.name.toLowerCase().contains(query) ||
              tags.contains(query) ||
              meal.cuisine.toLowerCase().contains(query);
        })
        .toList(growable: false);

    final topDishes = [...matchingMeals]
      ..sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        if (byRating != 0) return byRating;
        return b.reorderCount.compareTo(a.reorderCount);
      });

    final fullMenu = [...matchingMeals];
    switch (_sortMode) {
      case _MenuSortMode.priceLow:
        fullMenu.sort((a, b) => a.price.compareTo(b.price));
      case _MenuSortMode.priceHigh:
        fullMenu.sort((a, b) => b.price.compareTo(a.price));
      case _MenuSortMode.fastest:
        fullMenu.sort((a, b) => a.prepTimeMin.compareTo(b.prepTimeMin));
      case _MenuSortMode.rating:
        fullMenu.sort((a, b) => b.rating.compareTo(a.rating));
      case _MenuSortMode.top:
        break;
    }

    return Theme(
      data: _noOverlayTheme(context),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 12,
          scrolledUnderElevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_placeTypeLabel(widget.place.type).tr(context)} • '
                '${widget.place.avgDeliveryMinutes} mins • Min ₹${widget.place.minOrder}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                widget.appState.togglePlaceFavorite(widget.place.id);
                setState(() {});
              },
              icon: Icon(
                widget.appState.isPlaceFavorite(widget.place.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: widget.appState.isPlaceFavorite(widget.place.id)
                    ? const Color(0xFFEF4444)
                    : colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Favorite'.tr(context),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search meals'.tr(context),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      fillColor: colorScheme.surfaceContainerHighest,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MealFilterChip(
                        label: 'All'.tr(context),
                        selected: _selectedSlot == null,
                        onTap: () => setState(() => _selectedSlot = null),
                      ),
                      _MealFilterChip(
                        label: 'Breakfast'.tr(context),
                        selected: _selectedSlot == MealSlot.breakfast,
                        onTap: () =>
                            setState(() => _selectedSlot = MealSlot.breakfast),
                      ),
                      _MealFilterChip(
                        label: 'Lunch'.tr(context),
                        selected: _selectedSlot == MealSlot.lunch,
                        onTap: () =>
                            setState(() => _selectedSlot = MealSlot.lunch),
                      ),
                      _MealFilterChip(
                        label: 'Dinner'.tr(context),
                        selected: _selectedSlot == MealSlot.dinner,
                        onTap: () =>
                            setState(() => _selectedSlot = MealSlot.dinner),
                      ),
                      _MealFilterChip(
                        label: 'Veg only'.tr(context),
                        selected: _vegOnly,
                        onTap: () => setState(() => _vegOnly = !_vegOnly),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${'Showing'.tr(context)} ${fullMenu.length}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                      const Spacer(),
                      if (query.isNotEmpty || _selectedSlot != null || _vegOnly)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _selectedSlot = null;
                              _vegOnly = false;
                            });
                          },
                          child: Text('Clear'.tr(context)),
                        ),
                      const SizedBox(width: 4),
                      PopupMenuButton<_MenuSortMode>(
                        tooltip: 'Sort'.tr(context),
                        icon: Icon(
                          Icons.tune_rounded,
                          color: colorScheme.primary,
                        ),
                        onSelected: (value) =>
                            setState(() => _sortMode = value),
                        itemBuilder: (context) => [
                          for (final mode in _MenuSortMode.values)
                            PopupMenuItem<_MenuSortMode>(
                              value: mode,
                              child: Text(_sortModeLabel(mode).tr(context)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                children: [
                  if (topDishes.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Top dishes'.tr(context),
                      trailing: Text(
                        '₹${topDishes.map((meal) => meal.price).reduce((a, b) => a < b ? a : b)} • ${topDishes.length} ${'items'.tr(context)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 262,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: topDishes.take(8).length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final meal = topDishes[index];
                          return _TopDishCard(
                            meal: meal,
                            isFavorite: widget.appState.isMealFavorite(meal.id),
                            onToggleFavorite: () {
                              widget.appState.toggleMealFavorite(meal.id);
                              setState(() {});
                            },
                            onAdd: () {
                              widget.appState.addToCart(meal);
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (fullMenu.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text('No meals match this filter.'.tr(context)),
                      ),
                    )
                  else
                    _SectionHeader(
                      label: 'Full menu'.tr(context),
                      trailing: Text(
                        _sortModeLabel(_sortMode).tr(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (fullMenu.isNotEmpty) const SizedBox(height: 8),
                  if (fullMenu.isNotEmpty)
                    ...fullMenu.indexed.map((entry) {
                      final meal = entry.$2;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.$1 == fullMenu.length - 1 ? 0 : 10,
                        ),
                        child: _MenuRowCard(
                          meal: meal,
                          isFavorite: widget.appState.isMealFavorite(meal.id),
                          onAdd: () {
                            widget.appState.addToCart(meal);
                            setState(() {});
                          },
                          onToggleFavorite: () {
                            widget.appState.toggleMealFavorite(meal.id);
                            setState(() {});
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
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

  String _sortModeLabel(_MenuSortMode mode) {
    return switch (mode) {
      _MenuSortMode.top => 'Top',
      _MenuSortMode.priceLow => 'Price: Low',
      _MenuSortMode.priceHigh => 'Price: High',
      _MenuSortMode.fastest => 'Fastest',
      _MenuSortMode.rating => 'Rating',
    };
  }

  bool _isVegMeal(Meal meal) {
    final signature = '${meal.name} ${meal.tags.join(' ')} ${meal.cuisine}'
        .toLowerCase();
    return signature.contains('veg') ||
        signature.contains('paneer') ||
        signature.contains('salad') ||
        signature.contains('dal');
  }

  String _placeTypeLabel(FoodPlaceType type) {
    return switch (type) {
      FoodPlaceType.restaurant => 'Restaurant',
      FoodPlaceType.dhaba => 'Dhaba',
      FoodPlaceType.tiffin => 'Tiffin / Rasoi',
      FoodPlaceType.cloudKitchen => 'Cloud Kitchen',
    };
  }
}

class _MealFilterChip extends StatelessWidget {
  const _MealFilterChip({
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

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      avatar: selected
          ? Icon(Icons.check_rounded, size: 14, color: colorScheme.onSecondary)
          : null,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      side: selected
          ? BorderSide(color: colorScheme.primary)
          : BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              trailing,
            ],
          );
        }

        return Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        );
      },
    );
  }
}

class _MenuRowCard extends StatelessWidget {
  const _MenuRowCard({
    required this.meal,
    required this.isFavorite,
    required this.onAdd,
    required this.onToggleFavorite,
  });

  final Meal meal;
  final bool isFavorite;
  final VoidCallback onAdd;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                meal.imageUrl,
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: SizedBox(
                    width: 82,
                    height: 82,
                    child: Icon(
                      Icons.fastfood_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meal.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? const Color(0xFFEF4444)
                              : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_slotLabel(meal.slot).tr(context)} • ${meal.calories} kcal • ${meal.prepTimeMin} mins',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 190;
                      final amount = Text(
                        '₹${meal.price}',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                      final rating = Text(
                        '★${meal.rating.toStringAsFixed(1)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );

                      final addButton = FilledButton(
                        onPressed: onAdd,
                        style: FilledButton.styleFrom(
                          minimumSize: Size(compact ? double.infinity : 72, 34),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          overlayColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Add'.tr(context)),
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                amount,
                                const SizedBox(width: 8),
                                rating,
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(width: double.infinity, child: addButton),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          amount,
                          const SizedBox(width: 8),
                          rating,
                          const Spacer(),
                          addButton,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _slotLabel(MealSlot slot) {
    return switch (slot) {
      MealSlot.breakfast => 'Breakfast',
      MealSlot.lunch => 'Lunch',
      MealSlot.dinner => 'Dinner',
    };
  }
}

class _TopDishCard extends StatelessWidget {
  const _TopDishCard({
    required this.meal,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAdd,
  });

  final Meal meal;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 198,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = (constraints.maxHeight * 0.33).clamp(
              72.0,
              90.0,
            );

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              meal.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  ColoredBox(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Center(
                                      child: Icon(
                                        Icons.fastfood_outlined,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            onPressed: onToggleFavorite,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? const Color(0xFFEF4444)
                                  : colorScheme.onSurfaceVariant,
                              size: 18,
                            ),
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints.tightFor(
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, details) {
                        final compact = details.maxHeight < 116;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    meal.name,
                                    maxLines: compact ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${meal.price} • ★${meal.rating.toStringAsFixed(1)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                onPressed: onAdd,
                                style: FilledButton.styleFrom(
                                  minimumSize: Size(64, compact ? 28 : 30),
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  overlayColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text('Add'.tr(context)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
