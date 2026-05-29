import 'package:flutter_core/flutter_core.dart';

enum HomeFeedStatus { loading, ready, empty, error }

class AppState {
  AppState({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient(baseUrl: 'http://localhost:8080/v1') {
    if (AppConfig.isDemo && !MockData.validateDemoSeed()) {
      homeStatus = HomeFeedStatus.error;
      homeError = 'Demo seed validation failed. Please reseed mock data.';
    }
    selectedZone = zonesForCity(selectedCity.id).isNotEmpty
        ? zonesForCity(selectedCity.id).first
        : MockData.zones.first;
    currentCustomer = _defaultCustomerForCity(selectedCity.id);
    selectedFoodPlace = _defaultFoodPlaceForLocation(
      selectedCity.id,
      zoneId: selectedZone.id,
    );
    _normalizeSelection();
  }

  final ApiClient apiClient;

  City selectedCity = MockData.cities.first;
  late Zone selectedZone;
  late DemoCustomer currentCustomer;
  late FoodPlace selectedFoodPlace;
  String selectedDay = 'Monday';
  MealSlot selectedSlot = MealSlot.breakfast;
  String selectedDiet = 'All';
  String searchQuery = '';
  SearchFilters searchFilters = const SearchFilters();

  HomeFeedStatus homeStatus = HomeFeedStatus.loading;
  String? homeError;
  List<Meal> visibleMeals = const <Meal>[];
  List<PersonalizedFeedSection> feedSections =
      const <PersonalizedFeedSection>[];
  List<Meal> lastWeekMeals = const <Meal>[];
  List<Meal> mostReorderedMeals = const <Meal>[];
  List<Meal> recommendedMeals = const <Meal>[];

  final List<CartItem> cartItems = [];
  int walletApplied = -50;

  List<DemoOrder> _orders = const <DemoOrder>[];
  List<WalletLedgerItem> _walletLedger = const <WalletLedgerItem>[];
  List<AddressOption> _addresses = const <AddressOption>[];
  CheckoutPreferences? _checkoutPreferences;
  List<SupportThread> _supportThreads = const <SupportThread>[];
  List<SupportIssue> _supportIssues = const <SupportIssue>[];
  final Map<String, DeliveryProviderOption> _deliveryChoiceByPlace = {};
  final Map<String, String> _customNotesByMeal = {};
  final Set<String> _favoritePlaceIds = <String>{};
  final Set<String> _favoriteMealIds = <String>{};

  AppMode get mode => AppConfig.mode;

  bool get isDemoMode => AppConfig.isDemo;

  DeliveryProviderOption deliveryChoiceForPlace(String placeId) {
    return _deliveryChoiceByPlace[placeId] ?? DeliveryProviderOption.porter;
  }

  void setDeliveryChoiceForPlace(
    String placeId,
    DeliveryProviderOption option,
  ) {
    _deliveryChoiceByPlace[placeId] = option;
  }

  void setCustomMealNote(String mealId, String note) {
    _customNotesByMeal[mealId] = note;
  }

  String customMealNote(String mealId) {
    return _customNotesByMeal[mealId] ?? '';
  }

  bool isPlaceFavorite(String placeId) => _favoritePlaceIds.contains(placeId);

  bool isMealFavorite(String mealId) => _favoriteMealIds.contains(mealId);

  void togglePlaceFavorite(String placeId) {
    if (_favoritePlaceIds.contains(placeId)) {
      _favoritePlaceIds.remove(placeId);
      return;
    }
    _favoritePlaceIds.add(placeId);
  }

  void toggleMealFavorite(String mealId) {
    if (_favoriteMealIds.contains(mealId)) {
      _favoriteMealIds.remove(mealId);
      return;
    }
    _favoriteMealIds.add(mealId);
  }

  List<String> get dietFilters => const [
    'All',
    'Veg',
    'High Protein',
    'Home Style',
    'Non Veg',
  ];

  static List<Zone> zonesForCity(String cityId) {
    return MockData.zones.where((zone) => zone.cityId == cityId).toList();
  }

  static DemoCustomer _defaultCustomerForCity(String cityId) {
    return MockData.demoCustomers.firstWhere(
      (customer) => customer.cityId == cityId,
      orElse: () => MockData.demoCustomers.first,
    );
  }

  static FoodPlace _defaultFoodPlaceForLocation(
    String cityId, {
    String? zoneId,
  }) {
    final scoped = MockData.foodPlacesForCity(cityId, zoneId: zoneId);
    if (scoped.isNotEmpty) return scoped.first;
    final cityScoped = MockData.foodPlacesForCity(cityId);
    if (cityScoped.isNotEmpty) return cityScoped.first;
    return MockData.foodPlaces.first;
  }

  void _normalizeSelection() {
    final cityZones = zonesForCity(selectedCity.id);
    if (cityZones.isNotEmpty &&
        !cityZones.any((zone) => zone.id == selectedZone.id)) {
      selectedZone = cityZones.first;
    }

    if (currentCustomer.cityId != selectedCity.id) {
      currentCustomer = _defaultCustomerForCity(selectedCity.id);
    }

    final zoneScopedPlaces = MockData.foodPlacesForCity(
      selectedCity.id,
      zoneId: selectedZone.id,
    );
    final cityScopedPlaces = MockData.foodPlacesForCity(selectedCity.id);
    final candidates = zoneScopedPlaces.isNotEmpty
        ? zoneScopedPlaces
        : cityScopedPlaces;

    if (candidates.isEmpty) {
      if (MockData.foodPlaces.isNotEmpty) {
        selectedFoodPlace = MockData.foodPlaces.first;
      }
      return;
    }

    if (!candidates.any((place) => place.id == selectedFoodPlace.id)) {
      selectedFoodPlace = candidates.first;
    }
  }

  Future<void> loadHomeFeed() async {
    _normalizeSelection();
    homeStatus = HomeFeedStatus.loading;
    homeError = null;

    try {
      final searchedMeals = await apiClient.searchMeals(
        query: searchQuery,
        cityId: selectedCity.id,
        zoneId: selectedZone.id,
        slot: selectedSlot,
        filters: searchFilters.copyWith(diet: selectedDiet),
      );

      final personalized = await apiClient.getPersonalizedFeed(
        customerId: currentCustomer.id,
        cityId: selectedCity.id,
        zoneId: selectedZone.id,
        slot: selectedSlot,
        limit: 6,
      );

      final reorder = await apiClient.getReorderSuggestions(
        customerId: currentCustomer.id,
        cityId: selectedCity.id,
      );

      final selectedPlaceId = selectedFoodPlace.id;
      bool belongsToSelectedPlace(Meal meal) {
        final direct = meal.placeId;
        if (direct.isNotEmpty) return direct == selectedPlaceId;
        final place = MockData.foodPlaceForMeal(meal.id);
        return place?.id == selectedPlaceId;
      }

      visibleMeals = searchedMeals.where(belongsToSelectedPlace).toList();
      feedSections = personalized
          .map(
            (section) => PersonalizedFeedSection(
              type: section.type,
              title: section.title,
              subtitle: section.subtitle,
              meals: section.meals.where(belongsToSelectedPlace).toList(),
            ),
          )
          .toList();
      lastWeekMeals = reorder.where(belongsToSelectedPlace).toList();
      mostReorderedMeals = _sectionMeals(FeedSectionType.mostReordered);
      recommendedMeals = _sectionMeals(FeedSectionType.recommended);

      if (visibleMeals.isNotEmpty ||
          feedSections.any((section) => section.meals.isNotEmpty)) {
        homeStatus = HomeFeedStatus.ready;
        return;
      }

      final fallback = _placeholderMealsForCity();
      if (fallback.isNotEmpty) {
        visibleMeals = fallback;
        if (feedSections.isEmpty) {
          feedSections = [
            PersonalizedFeedSection(
              type: FeedSectionType.trending,
              title: 'Featured for you',
              subtitle: 'Showing fallback meals while we refresh your feed',
              meals: fallback,
            ),
          ];
        }
        homeStatus = HomeFeedStatus.ready;
      } else {
        homeStatus = HomeFeedStatus.empty;
      }
    } catch (error) {
      homeError = '$error';

      if (visibleMeals.isNotEmpty ||
          feedSections.any((section) => section.meals.isNotEmpty)) {
        homeStatus = HomeFeedStatus.ready;
        return;
      }

      if (isDemoMode) {
        final fallback = _placeholderMealsForCity();
        if (fallback.isNotEmpty) {
          visibleMeals = fallback;
          feedSections = [
            PersonalizedFeedSection(
              type: FeedSectionType.trending,
              title: 'Featured for you',
              subtitle: 'Recovered from demo fallback data',
              meals: fallback,
            ),
          ];
          homeStatus = HomeFeedStatus.ready;
          return;
        }
      }

      homeStatus = HomeFeedStatus.error;
    }
  }

  Future<List<Meal>> fetchVisibleMeals() async {
    if (homeStatus == HomeFeedStatus.loading || visibleMeals.isEmpty) {
      await loadHomeFeed();
    }
    return visibleMeals;
  }

  List<Meal> _sectionMeals(FeedSectionType type) {
    return feedSections
        .firstWhere(
          (section) => section.type == type,
          orElse: () => const PersonalizedFeedSection(
            type: FeedSectionType.trending,
            title: '',
            subtitle: '',
            meals: <Meal>[],
          ),
        )
        .meals;
  }

  List<Meal> _placeholderMealsForCity() {
    final placeMeals = selectedFoodPlaceMenu(allSlotsIfEmpty: true);
    if (placeMeals.isNotEmpty) {
      return placeMeals
          .where((meal) => meal.available)
          .take(6)
          .toList(growable: false);
    }

    final cityMeals = MockData.sameDayMeals(
      cityId: selectedCity.id,
    ).where((meal) => meal.available).toList(growable: false);
    if (cityMeals.isNotEmpty) {
      return cityMeals.take(6).toList(growable: false);
    }

    return MockData.meals
        .where((meal) => meal.available)
        .take(6)
        .toList(growable: false);
  }

  List<Meal> fallbackMeals() {
    final fallback = _placeholderMealsForCity();
    if (fallback.isNotEmpty) return fallback;
    return MockData.meals.take(6).toList(growable: false);
  }

  void setCity(City city) {
    selectedCity = city;

    final zoneCandidates = zonesForCity(city.id);
    selectedZone = zoneCandidates.isNotEmpty
        ? zoneCandidates.first
        : MockData.zones.first;

    currentCustomer = _defaultCustomerForCity(city.id);
    selectedFoodPlace = _defaultFoodPlaceForLocation(
      city.id,
      zoneId: selectedZone.id,
    );
    _normalizeSelection();
  }

  void setZone(Zone zone) {
    selectedZone = zone;
    _normalizeSelection();
  }

  void setFoodPlace(FoodPlace place) {
    selectedFoodPlace = place;
  }

  void setSlot(MealSlot slot) {
    selectedSlot = slot;
  }

  void setDay(String day) {
    selectedDay = day;
  }

  void setDiet(String diet) {
    selectedDiet = diet;
  }

  void setSearchQuery(String query) {
    searchQuery = query.trim();
  }

  void setSearchFilters(SearchFilters filters) {
    searchFilters = filters;
  }

  void setCustomer(DemoCustomer customer) {
    currentCustomer = customer;

    selectedCity = MockData.cities.firstWhere(
      (city) => city.id == customer.cityId,
      orElse: () => selectedCity,
    );

    selectedZone = MockData.zones.firstWhere(
      (zone) => zone.id == customer.zoneId,
      orElse: () => selectedZone,
    );

    selectedFoodPlace = _defaultFoodPlaceForLocation(
      selectedCity.id,
      zoneId: selectedZone.id,
    );
    _normalizeSelection();
  }

  void updateCurrentCustomerProfile({
    required String name,
    required String phone,
    required String cityId,
    required String zoneId,
    required String tier,
    required String primaryAddress,
    required String preferredPriceBand,
  }) {
    final resolvedCity = MockData.cities.firstWhere(
      (city) => city.id == cityId,
      orElse: () => selectedCity,
    );

    final zones = zonesForCity(resolvedCity.id);
    final resolvedZone = zones.firstWhere(
      (zone) => zone.id == zoneId,
      orElse: () => zones.isNotEmpty ? zones.first : selectedZone,
    );

    selectedCity = resolvedCity;
    selectedZone = resolvedZone;
    currentCustomer = DemoCustomer(
      id: currentCustomer.id,
      name: name.trim(),
      phone: phone.trim(),
      cityId: resolvedCity.id,
      zoneId: resolvedZone.id,
      primaryAddress: primaryAddress.trim(),
      tier: tier,
      totalOrders: currentCustomer.totalOrders,
      referralCode: currentCustomer.referralCode,
      preferredSlots: currentCustomer.preferredSlots,
      preferredCuisines: currentCustomer.preferredCuisines,
      preferredPriceBand: preferredPriceBand,
    );

    _normalizeSelection();
  }

  void switchMode(AppMode mode) {
    AppConfig.setMode(mode);
  }

  List<DemoCustomer> customersForCity(String cityId) {
    final scoped = MockData.demoCustomers
        .where((customer) => customer.cityId == cityId)
        .toList(growable: true);

    if (currentCustomer.cityId == cityId) {
      final currentIndex = scoped.indexWhere(
        (customer) => customer.id == currentCustomer.id,
      );
      if (currentIndex >= 0) {
        scoped[currentIndex] = currentCustomer;
      } else {
        scoped.insert(0, currentCustomer);
      }
    }

    return scoped;
  }

  List<FoodPlace> foodPlacesForCity(String cityId) {
    final zoneScopedPlaces = selectedZone.cityId == cityId
        ? MockData.foodPlacesForCity(cityId, zoneId: selectedZone.id)
        : const <FoodPlace>[];
    if (zoneScopedPlaces.isNotEmpty) {
      return zoneScopedPlaces;
    }
    final cityScopedPlaces = MockData.foodPlacesForCity(cityId);
    if (cityScopedPlaces.isNotEmpty) {
      return cityScopedPlaces;
    }
    if (cityId == selectedCity.id && MockData.foodPlaces.isNotEmpty) {
      return MockData.foodPlaces.take(6).toList(growable: false);
    }
    return const <FoodPlace>[];
  }

  MealSlot suggestedSlotForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealSlot.breakfast;
    if (hour < 17) return MealSlot.lunch;
    return MealSlot.dinner;
  }

  String suggestedPlanType() {
    if (currentCustomer.totalOrders >= 20) return 'Monthly';
    if (currentCustomer.totalOrders >= 8) return 'Weekly';
    return 'Custom';
  }

  FoodPlace suggestedPlaceForNow() {
    final cityPlaces = foodPlacesForCity(selectedCity.id);
    final pool = cityPlaces.isNotEmpty ? cityPlaces : MockData.foodPlaces;
    if (pool.isEmpty) return selectedFoodPlace;

    final favoriteInPool = pool.firstWhere(
      (place) => _favoritePlaceIds.contains(place.id),
      orElse: () => pool.first,
    );

    if (_favoritePlaceIds.contains(favoriteInPool.id)) {
      return favoriteInPool;
    }

    final sorted = [...pool]
      ..sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        if (byRating != 0) return byRating;
        return a.avgDeliveryMinutes.compareTo(b.avgDeliveryMinutes);
      });
    return sorted.first;
  }

  List<Meal> selectedFoodPlaceMenu({
    MealSlot? slot,
    bool allSlotsIfEmpty = false,
  }) {
    final scoped = MockData.mealsForFoodPlace(
      placeId: selectedFoodPlace.id,
      slot: slot ?? selectedSlot,
    );
    if (allSlotsIfEmpty && scoped.isEmpty) {
      return MockData.mealsForFoodPlace(placeId: selectedFoodPlace.id);
    }
    return scoped;
  }

  DataHealthSnapshot get dataHealth {
    return DataHealthSnapshot(
      meals: visibleMeals.length,
      orders: _orders.length,
      partners: foodPlacesForCity(selectedCity.id).length,
    );
  }

  int get cartTotal => cartItems.fold(0, (sum, item) => sum + item.total);
  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.qty);
  bool get hasItems => cartItems.isNotEmpty;

  Future<List<DemoOrder>> fetchOrders() async {
    _orders = await apiClient.getCustomerOrders(customerId: currentCustomer.id);
    return _orders;
  }

  List<DemoOrder> get cachedOrders => _orders;

  Future<DemoOrder?> reorderFromOrder(String orderId) async {
    final order = await apiClient.reorderFromOrder(
      orderId: orderId,
      customerId: currentCustomer.id,
    );
    if (order == null) return null;

    for (final line in order.lineItems) {
      final meal = MockData.meals.firstWhere(
        (entry) => entry.id == line.mealId,
        orElse: () => MockData.meals.first,
      );
      final existing = cartItems.indexWhere((item) => item.meal.id == meal.id);
      if (existing >= 0) {
        final prev = cartItems[existing];
        cartItems[existing] = CartItem(
          meal: prev.meal,
          qty: prev.qty + line.qty,
        );
      } else {
        cartItems.add(CartItem(meal: meal, qty: line.qty));
      }
    }

    return order;
  }

  Future<DemoOrder?> reorderLatestDelivered() async {
    if (_orders.isEmpty) {
      await fetchOrders();
    }
    final delivered = _orders
        .where((order) => order.status == OrderStatus.delivered)
        .toList(growable: false);
    if (delivered.isEmpty) return null;
    return reorderFromOrder(delivered.first.id);
  }

  Future<List<WalletLedgerItem>> fetchWalletLedger() async {
    _walletLedger = await apiClient.getWalletLedger(
      customerId: currentCustomer.id,
    );
    return _walletLedger;
  }

  List<WalletLedgerItem> get cachedWalletLedger => _walletLedger;

  int get walletBalance =>
      _walletLedger.fold(0, (sum, item) => sum + item.amount);

  Future<List<AddressOption>> fetchAddresses() async {
    _addresses = await apiClient.getAddresses(customerId: currentCustomer.id);
    return _addresses;
  }

  List<AddressOption> get cachedAddresses => _addresses;

  Future<AddressOption?> getSmartDefaultAddress() async {
    return apiClient.getSmartDefaultAddress(
      customerId: currentCustomer.id,
      slot: selectedSlot,
      day: selectedDay,
    );
  }

  Future<CheckoutPreferences> fetchCheckoutPreferences() async {
    _checkoutPreferences = await apiClient.getCheckoutPreferences(
      customerId: currentCustomer.id,
    );
    return _checkoutPreferences!;
  }

  CheckoutPreferences get checkoutPreferences =>
      _checkoutPreferences ??
      CheckoutPreferences(
        customerId: currentCustomer.id,
        preferredWindow: '1:00 PM - 1:30 PM',
        preferredPaymentMode: 'UPI',
        walletAutoApply: true,
        defaultCadence: 'Weekly',
      );

  Future<void> updateCheckoutPreferences(
    CheckoutPreferences preferences,
  ) async {
    _checkoutPreferences = await apiClient.setCheckoutPreferences(
      preferences: preferences,
    );
  }

  Future<LiveTrackingSnapshot?> fetchLiveTracking(String orderId) async {
    return apiClient.getLiveTracking(orderId: orderId);
  }

  Future<DelayPrediction> fetchEta(String orderId) async {
    return apiClient.getEta(orderId: orderId);
  }

  Future<void> reportDelay(String orderId, String reason) async {
    await apiClient.reportDelay(orderId: orderId, reason: reason);
  }

  Future<List<MealReview>> fetchMealReviews(String mealId) async {
    return apiClient.getReviewsForMeal(mealId: mealId);
  }

  Future<List<String>> fetchMealBadges(String mealId) async {
    return apiClient.getMealBadges(mealId: mealId);
  }

  Future<OfferEvaluation> evaluateOffers() {
    return apiClient.evaluateOffers(
      customerId: currentCustomer.id,
      cityId: selectedCity.id,
      slot: selectedSlot,
      cartTotal: cartTotal,
      isFirstOrder: currentCustomer.totalOrders == 0,
      streakDays: 3,
    );
  }

  Future<List<SupportThread>> fetchSupportThreads() async {
    _supportThreads = await apiClient.getSupportThreads(
      customerId: currentCustomer.id,
    );
    return _supportThreads;
  }

  List<SupportThread> get cachedSupportThreads => _supportThreads;

  Future<SupportThread> createSupportThread(String orderId) {
    return apiClient.createSupportThread(
      customerId: currentCustomer.id,
      orderId: orderId,
    );
  }

  Future<SupportThread?> sendSupportMessage({
    required String threadId,
    required String sender,
    required String text,
  }) {
    return apiClient.sendSupportMessage(
      customerId: currentCustomer.id,
      threadId: threadId,
      sender: sender,
      text: text,
    );
  }

  Future<List<SupportIssue>> fetchSupportIssues() async {
    _supportIssues = await apiClient.getSupportIssues(
      customerId: currentCustomer.id,
    );
    return _supportIssues;
  }

  List<SupportIssue> get cachedSupportIssues => _supportIssues;

  Future<SupportIssue?> createSupportIssue({
    required String orderId,
    required IssueType type,
    required String description,
  }) {
    return apiClient.createSupportIssue(
      customerId: currentCustomer.id,
      orderId: orderId,
      type: type,
      description: description,
    );
  }

  Future<SupportIssue?> updateSupportIssue({
    required String issueId,
    required IssueStatus status,
  }) {
    return apiClient.updateSupportIssue(
      customerId: currentCustomer.id,
      issueId: issueId,
      status: status,
    );
  }

  Future<MaskedCallSession?> createMaskedCallSession({
    required String toNumber,
  }) {
    return apiClient.createMaskedCallSession(
      fromNumber: currentCustomer.phone,
      toNumber: toNumber,
    );
  }

  void addToCart(Meal meal) {
    final index = cartItems.indexWhere((item) => item.meal.id == meal.id);
    if (index >= 0) {
      final existing = cartItems[index];
      cartItems[index] = CartItem(meal: existing.meal, qty: existing.qty + 1);
      return;
    }
    cartItems.add(CartItem(meal: meal));
  }

  void removeFromCart(String mealId) {
    cartItems.removeWhere((item) => item.meal.id == mealId);
  }

  Future<void> backgroundSync() async {
    await loadHomeFeed();
    await fetchOrders();
  }
}
