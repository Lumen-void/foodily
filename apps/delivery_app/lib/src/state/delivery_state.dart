import 'dart:math' as math;

import 'package:flutter_core/flutter_core.dart';

enum DeliveryJobsStatus { loading, ready, empty, error }

class DeliveryState {
  DeliveryState({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient(baseUrl: 'http://localhost:8080/v1'),
      currentRestaurant = MockData.foodPlaces.first {
    orders.addAll(MockData.ordersForFoodPlace(currentRestaurant.id));
    menuItems.addAll(MockData.mealsForFoodPlace(placeId: currentRestaurant.id));
  }

  final ApiClient apiClient;
  FoodPlace currentRestaurant;
  final List<DemoOrder> orders = [];
  final List<Meal> menuItems = [];
  final Map<String, OrderStatus> _statusOverrides = {};
  final Map<String, DeliveryProviderOption> _deliveryModeOverrides = {};

  DeliveryJobsStatus status = DeliveryJobsStatus.loading;
  String? error;
  DateTime? lastSyncedAt;

  AppMode get mode => AppConfig.mode;

  bool get isDemoMode => AppConfig.isDemo;

  OrderStatus statusOf(DemoOrder order) {
    return _statusOverrides[order.id] ?? order.status;
  }

  DeliveryProviderOption deliveryModeOf(DemoOrder order) {
    return _deliveryModeOverrides[order.id] ?? defaultDeliveryModeForRestaurant;
  }

  DeliveryProviderOption get defaultDeliveryModeForRestaurant {
    if (currentRestaurant.deliveryByRestaurant) {
      return DeliveryProviderOption.restaurantFleet;
    }
    if (currentRestaurant.deliveryByPorter) {
      return DeliveryProviderOption.porter;
    }
    return DeliveryProviderOption.customerPickup;
  }

  List<DemoOrder> get activeOrders {
    return orders
        .where((order) => statusOf(order) != OrderStatus.delivered)
        .toList(growable: false);
  }

  List<DemoOrder> get completedOrders {
    return orders
        .where((order) => statusOf(order) == OrderStatus.delivered)
        .toList(growable: false);
  }

  int get assignedCount => activeOrders.length;

  int get completedCount => completedOrders.length;

  int get outForDeliveryCount {
    return orders
        .where((order) => statusOf(order) == OrderStatus.outForDelivery)
        .length;
  }

  int get todayEarnings => completedCount * 62;

  List<int> get weeklyEarningsTrend {
    final anchor = math.max(120, todayEarnings);
    return List<int>.generate(7, (index) {
      final distanceFromToday = (6 - index).abs();
      final curveFactor = math.max(0, 5 - distanceFromToday);
      final dynamicLift = completedCount * 6;
      final computed =
          anchor - (distanceFromToday * 24) + (curveFactor * 18) + dynamicLift;
      return math.max(0, computed);
    });
  }

  int get weeklyEarnings {
    return weeklyEarningsTrend.fold<int>(0, (sum, day) => sum + day);
  }

  int get incentiveTarget => 5200;

  int get incentiveRemaining => math.max(0, incentiveTarget - weeklyEarnings);

  double get incentiveProgress {
    if (incentiveTarget == 0) return 0;
    final progress = weeklyEarnings / incentiveTarget;
    return progress.clamp(0, 1).toDouble();
  }

  DataHealthSnapshot get dataHealth {
    return DataHealthSnapshot(
      meals: menuItems.length,
      orders: completedCount,
      partners: restaurantsForCity(currentRestaurant.cityId).length,
    );
  }

  List<FoodPlace> restaurantsForCity(String cityId) {
    return MockData.foodPlacesForCity(cityId);
  }

  Future<void> reloadJobs() async {
    status = DeliveryJobsStatus.loading;
    error = null;

    try {
      final fetchedOrders = await apiClient.getFoodPlaceOrders(
        placeId: currentRestaurant.id,
      );
      final fetchedMenu = await apiClient.getFoodPlaceMenu(
        placeId: currentRestaurant.id,
      );

      orders
        ..clear()
        ..addAll(fetchedOrders);
      menuItems
        ..clear()
        ..addAll(fetchedMenu);

      if (orders.isEmpty && isDemoMode) {
        orders.addAll(MockData.ordersForFoodPlace(currentRestaurant.id));
      }
      if (menuItems.isEmpty && isDemoMode) {
        menuItems.addAll(
          MockData.mealsForFoodPlace(placeId: currentRestaurant.id),
        );
      }

      status = orders.isEmpty
          ? DeliveryJobsStatus.empty
          : DeliveryJobsStatus.ready;
      lastSyncedAt = DateTime.now();
    } catch (e) {
      error = '$e';
      orders
        ..clear()
        ..addAll(MockData.ordersForFoodPlace(currentRestaurant.id));
      menuItems
        ..clear()
        ..addAll(MockData.mealsForFoodPlace(placeId: currentRestaurant.id));

      status = orders.isEmpty
          ? DeliveryJobsStatus.error
          : DeliveryJobsStatus.ready;
      lastSyncedAt = DateTime.now();
    }
  }

  Future<void> pingLocation({
    required String orderId,
    required double lat,
    required double lng,
  }) {
    return apiClient.pingDeliveryLocation(
      orderId: orderId,
      partnerId: currentRestaurant.id,
      lat: lat,
      lng: lng,
    );
  }

  Future<void> reportDelay({required String orderId, required String reason}) {
    return apiClient.reportDelay(orderId: orderId, reason: reason);
  }

  Future<LiveTrackingSnapshot?> fetchLiveTracking(String orderId) {
    return apiClient.getLiveTracking(orderId: orderId);
  }

  Future<DelayPrediction> fetchEta(String orderId) {
    return apiClient.getEta(orderId: orderId);
  }

  void switchMode(AppMode mode) {
    AppConfig.setMode(mode);
  }

  void setRestaurant(FoodPlace place) {
    currentRestaurant = place;
    orders
      ..clear()
      ..addAll(MockData.ordersForFoodPlace(place.id));
    menuItems
      ..clear()
      ..addAll(MockData.mealsForFoodPlace(placeId: place.id));
  }

  Future<bool> updateJobStatus(String orderId, OrderStatus status) async {
    _statusOverrides[orderId] = status;
    if (isDemoMode) return true;

    final synced = await apiClient.updateDeliveryJobStatus(
      partnerId: currentRestaurant.id,
      orderId: orderId,
      status: status,
    );
    if (synced) {
      _statusOverrides.remove(orderId);
      await reloadJobs();
    }
    return synced;
  }

  void setDeliveryMode(String orderId, DeliveryProviderOption option) {
    _deliveryModeOverrides[orderId] = option;
  }

  void updateMenuItem(Meal updated) {
    final index = menuItems.indexWhere((item) => item.id == updated.id);
    if (index < 0) return;
    menuItems[index] = updated;
  }

  void toggleMealAvailability(String mealId, bool available) {
    final index = menuItems.indexWhere((item) => item.id == mealId);
    if (index < 0) return;
    menuItems[index] = menuItems[index].copyWith(available: available);
  }

  void updateMealPrice(String mealId, int price) {
    final index = menuItems.indexWhere((item) => item.id == mealId);
    if (index < 0) return;
    menuItems[index] = menuItems[index].copyWith(price: price);
  }

  void updateMealImage(String mealId, String imageUrl) {
    final index = menuItems.indexWhere((item) => item.id == mealId);
    if (index < 0) return;
    menuItems[index] = menuItems[index].copyWith(imageUrl: imageUrl);
  }
}
