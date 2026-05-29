import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../data/mock_data.dart';
import '../models/domain_models.dart';
import '../models/enums.dart';

class ApiClient {
  ApiClient({required this.baseUrl, this.authToken});

  final String baseUrl;
  final String? authToken;

  Future<List<City>> getCities() async {
    if (AppConfig.isDemo) return MockData.cities;

    final payload = await _get('/cities');
    final list = _unwrapList(payload);
    return list
        .map(
          (item) => City(
            id: (item['id'] ?? '') as String,
            name: (item['name'] ?? '') as String,
          ),
        )
        .where((city) => city.id.isNotEmpty && city.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Zone>> getZones(String cityId) async {
    if (AppConfig.isDemo) {
      return MockData.zones
          .where((zone) => zone.cityId == cityId)
          .toList(growable: false);
    }

    final payload = await _get('/zones?cityId=$cityId');
    final list = _unwrapList(payload);
    return list
        .map(
          (item) => Zone(
            id: (item['id'] ?? '') as String,
            cityId: (item['cityId'] ?? cityId) as String,
            name: (item['name'] ?? '') as String,
          ),
        )
        .where((zone) => zone.id.isNotEmpty && zone.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Meal>> getSameDayMenu({
    required String cityId,
    MealSlot? slot,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.sameDayMeals(cityId: cityId, slot: slot);
    }

    final slotQuery = slot == null ? '' : '&slot=${slot.name.toUpperCase()}';
    final payload = await _get('/menus/same-day?cityId=$cityId$slotQuery');
    final list = _unwrapList(payload);
    return list.map(_mealFromMap).toList(growable: false);
  }

  Future<List<FoodPlace>> getFoodPlaces({
    required String cityId,
    String? zoneId,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.foodPlacesForCity(cityId, zoneId: zoneId);
    }

    final zoneQuery = zoneId == null ? '' : '&zoneId=$zoneId';
    final payload = await _get('/places?cityId=$cityId$zoneQuery');
    return _unwrapList(payload)
        .map((item) => _foodPlaceFromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<Meal>> getFoodPlaceMenu({
    required String placeId,
    MealSlot? slot,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.mealsForFoodPlace(placeId: placeId, slot: slot);
    }

    final slotQuery = slot == null ? '' : '?slot=${slot.name.toUpperCase()}';
    final payload = await _get('/partner/places/$placeId/menu$slotQuery');
    return _unwrapList(payload)
        .map((item) => _mealFromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<DemoOrder>> getFoodPlaceOrders({required String placeId}) async {
    if (AppConfig.isDemo) {
      return MockData.ordersForFoodPlace(placeId);
    }

    final payload = await _get('/partner/places/$placeId/orders');
    return _unwrapList(payload)
        .map((item) => _demoOrderFromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<PersonalizedFeedSection>> getPersonalizedFeed({
    required String customerId,
    required String cityId,
    required String zoneId,
    required MealSlot slot,
    int limit = 6,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.personalizedFeed(
        customerId: customerId,
        cityId: cityId,
        slot: slot,
        limit: limit,
      );
    }

    final payload = await _get(
      '/feed/personalized?customerId=$customerId&cityId=$cityId&zoneId=$zoneId&slot=${slot.name.toUpperCase()}&limit=$limit',
    );
    final list = _unwrapList(payload);
    return list
        .map((item) {
          final rawType = (item['type'] ?? 'RECOMMENDED') as String;
          final meals =
              (item['meals'] as List?)
                  ?.whereType<Map>()
                  .map((meal) => _mealFromMap(Map<String, dynamic>.from(meal)))
                  .toList(growable: false) ??
              const <Meal>[];
          return PersonalizedFeedSection(
            type: _feedTypeFromApi(rawType),
            title: (item['title'] ?? '') as String,
            subtitle: (item['subtitle'] ?? '') as String,
            meals: meals,
          );
        })
        .toList(growable: false);
  }

  Future<List<Meal>> getReorderSuggestions({
    required String customerId,
    required String cityId,
    String window = 'last_week',
  }) async {
    if (AppConfig.isDemo) {
      return MockData.reorderSuggestions(
        customerId: customerId,
        cityId: cityId,
      );
    }

    final payload = await _get(
      '/orders/reorder-suggestions?customerId=$customerId&cityId=$cityId&window=$window',
    );
    return _unwrapList(payload).map(_mealFromMap).toList(growable: false);
  }

  Future<DemoOrder?> reorderFromOrder({
    required String orderId,
    required String customerId,
  }) async {
    if (AppConfig.isDemo) {
      final source = MockData.demoOrders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => MockData.demoOrders.first,
      );
      return DemoOrder(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        customerName: source.customerName,
        cityId: source.cityId,
        zoneId: source.zoneId,
        address: source.address,
        slot: source.slot,
        deliveryWindow: source.deliveryWindow,
        status: OrderStatus.created,
        total: source.total,
        placedAt: DateTime.now(),
        lineItems: source.lineItems,
        timeline: [
          OrderTimelineEvent(
            status: OrderStatus.created,
            label: 'Reorder placed',
            at: DateTime.now(),
          ),
        ],
        type: source.type,
        deliveryPartnerId: source.deliveryPartnerId,
      );
    }

    final payload = await _post(
      '/orders/$orderId/reorder',
      body: {'customerId': customerId},
    );
    final map = _unwrapDataMap(payload);
    if (map == null) return null;
    return _demoOrderFromMap(map);
  }

  Future<List<Meal>> searchMeals({
    required String query,
    required String cityId,
    required String zoneId,
    required MealSlot slot,
    required SearchFilters filters,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.searchMeals(
        cityId: cityId,
        slot: slot,
        query: query,
        filters: filters,
      );
    }

    final params = {
      'q': query,
      'cityId': cityId,
      'zoneId': zoneId,
      'slot': slot.name.toUpperCase(),
      'diet': filters.diet,
      'caloriesMin': '${filters.caloriesMin}',
      'caloriesMax': '${filters.caloriesMax}',
      'prepMin': '${filters.prepMin}',
      'prepMax': '${filters.prepMax}',
      'priceMin': '${filters.priceMin}',
      'priceMax': '${filters.priceMax}',
      'offersOnly': '${filters.offersOnly}',
      'ratingMin': '${filters.ratingMin}',
      'sort': _searchSortToApi(filters.sort),
    };

    final queryString = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');

    final payload = await _get('/search/meals?$queryString');
    return _unwrapList(payload).map(_mealFromMap).toList(growable: false);
  }

  Future<AddressOption?> getSmartDefaultAddress({
    required String customerId,
    required MealSlot slot,
    required String day,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.smartDefaultAddress(
        customerId: customerId,
        slot: slot,
        day: day,
      );
    }

    final payload = await _get(
      '/addresses/smart-default?customerId=$customerId&slot=${slot.name.toUpperCase()}&day=${Uri.encodeQueryComponent(day)}',
    );
    final map = _unwrapDataMap(payload);
    if (map == null) return null;
    return _addressFromMap(map);
  }

  Future<List<AddressOption>> getAddresses({required String customerId}) async {
    if (AppConfig.isDemo) {
      return MockData.addressesForCustomer(customerId);
    }

    final payload = await _get('/addresses?customerId=$customerId');
    return _unwrapList(payload).map(_addressFromMap).toList(growable: false);
  }

  Future<CheckoutPreferences> getCheckoutPreferences({
    required String customerId,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.preferencesForCustomer(customerId);
    }

    final payload = await _get('/checkout/preferences?customerId=$customerId');
    final map = _unwrapDataMap(payload);
    if (map == null) {
      return CheckoutPreferences(
        customerId: customerId,
        preferredWindow: '1:00 PM - 1:30 PM',
        preferredPaymentMode: 'UPI',
        walletAutoApply: true,
        defaultCadence: 'Weekly',
      );
    }
    return _prefsFromMap(map);
  }

  Future<CheckoutPreferences> setCheckoutPreferences({
    required CheckoutPreferences preferences,
  }) async {
    if (AppConfig.isDemo) {
      MockData.updatePreferences(preferences);
      return preferences;
    }

    final payload = await _post(
      '/checkout/preferences',
      body: {
        'customerId': preferences.customerId,
        'preferredWindow': preferences.preferredWindow,
        'preferredPaymentMode': preferences.preferredPaymentMode,
        'walletAutoApply': preferences.walletAutoApply,
        'defaultCadence': preferences.defaultCadence,
      },
    );

    final map = _unwrapDataMap(payload);
    return map == null ? preferences : _prefsFromMap(map);
  }

  Future<List<DemoCustomer>> getCustomers({String? cityId}) async {
    if (AppConfig.isDemo) {
      return MockData.demoCustomers
          .where((customer) => cityId == null || customer.cityId == cityId)
          .toList(growable: false);
    }

    final query = cityId == null ? '' : '?cityId=$cityId';
    final payload = await _get('/customers$query');
    return _unwrapList(payload)
        .map(
          (item) => DemoCustomer(
            id: (item['id'] ?? '') as String,
            name: (item['name'] ?? '') as String,
            phone: (item['phone'] ?? '') as String,
            cityId: (item['cityId'] ?? '') as String,
            zoneId: (item['zoneId'] ?? '') as String,
            primaryAddress: (item['primaryAddress'] ?? '') as String,
            tier: (item['tier'] ?? 'Silver') as String,
            totalOrders: ((item['totalOrders'] ?? 0) as num).toInt(),
            referralCode: (item['referralCode'] ?? '') as String,
          ),
        )
        .where((customer) => customer.id.isNotEmpty && customer.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<DemoOrder>> getCustomerOrders({
    required String customerId,
  }) async {
    if (AppConfig.isDemo) return MockData.ordersForCustomer(customerId);

    final payload = await _get('/orders?customerId=$customerId');
    return _unwrapList(payload)
        .map(_demoOrderFromMap)
        .where((order) => order.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<WalletLedgerItem>> getWalletLedger({
    required String customerId,
  }) async {
    if (AppConfig.isDemo) return MockData.walletForCustomer(customerId);

    final payload = await _get('/wallet?customerId=$customerId');
    return _unwrapList(payload)
        .map(
          (item) => WalletLedgerItem(
            id: (item['id'] ?? '') as String,
            type: _walletTypeFromApi((item['type'] as String?) ?? 'ADJUSTMENT'),
            amount: ((item['amount'] ?? 0) as num).toInt(),
            description: (item['description'] ?? '') as String,
            createdAt:
                DateTime.tryParse('${item['createdAt']}') ?? DateTime.now(),
          ),
        )
        .where((entry) => entry.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<DeliveryJob>> getDeliveryJobs({required String partnerId}) async {
    if (AppConfig.isDemo) return MockData.jobsForPartner(partnerId);

    final payload = await _get('/delivery/jobs?partnerId=$partnerId');
    return _unwrapList(payload)
        .map(
          (item) => DeliveryJob(
            id: (item['id'] ?? '') as String,
            orderId: (item['orderId'] ?? '') as String,
            customerName: (item['customerName'] ?? '') as String,
            address: (item['address'] ?? '') as String,
            slotLabel: (item['slotLabel'] ?? '') as String,
            etaMinutes: ((item['etaMinutes'] ?? 35) as num).toInt(),
            riderLat: ((item['riderLat'] ?? 0) as num).toDouble(),
            riderLng: ((item['riderLng'] ?? 0) as num).toDouble(),
            status: _orderStatusFromApi(
              (item['status'] as String?) ?? 'CONFIRMED',
            ),
          ),
        )
        .where((job) => job.id.isNotEmpty && job.orderId.isNotEmpty)
        .toList(growable: false);
  }

  Future<bool> updateDeliveryJobStatus({
    required String partnerId,
    required String orderId,
    required OrderStatus status,
  }) async {
    if (AppConfig.isDemo) return true;

    final apiStatus = _deliveryStatusToApi(status);
    if (apiStatus == null) return false;

    final jobs = await getDeliveryJobs(partnerId: partnerId);
    DeliveryJob? target;
    for (final job in jobs) {
      if (job.orderId == orderId || job.id == orderId) {
        target = job;
        break;
      }
    }
    if (target == null) return false;

    final payload = await _post(
      '/delivery/jobs/${target.id}/status',
      body: {'status': apiStatus, 'handoffCode': _handoffCodeForOrder(orderId)},
    );
    return payload != null;
  }

  Future<bool> pingDeliveryLocation({
    required String orderId,
    required String partnerId,
    required double lat,
    required double lng,
  }) async {
    if (AppConfig.isDemo) {
      return true;
    }

    final payload = await _post(
      '/delivery/location-ping',
      body: {
        'orderId': orderId,
        'partnerId': partnerId,
        'lat': lat,
        'lng': lng,
      },
    );
    return payload != null;
  }

  Future<LiveTrackingSnapshot?> getLiveTracking({
    required String orderId,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.trackingForOrder(orderId);
    }

    final payload = await _get('/orders/$orderId/live-tracking');
    final map = _unwrapDataMap(payload);
    if (map == null) return null;

    final route =
        (map['route'] as List?)
            ?.whereType<Map>()
            .map(
              (point) => RiderLocation(
                lat: ((point['lat'] ?? 0) as num).toDouble(),
                lng: ((point['lng'] ?? 0) as num).toDouble(),
                recordedAt:
                    DateTime.tryParse('${point['recordedAt']}') ??
                    DateTime.now(),
              ),
            )
            .toList(growable: false) ??
        const <RiderLocation>[];

    final riderMap = map['rider'] as Map<String, dynamic>?;
    final rider = RiderLocation(
      lat: ((riderMap?['lat'] ?? 0) as num).toDouble(),
      lng: ((riderMap?['lng'] ?? 0) as num).toDouble(),
      recordedAt:
          DateTime.tryParse('${riderMap?['recordedAt']}') ?? DateTime.now(),
    );

    final delayMap = map['delay'] as Map<String, dynamic>?;
    final delay = DelayPrediction(
      predictedDelayMinutes: ((delayMap?['predictedDelayMinutes'] ?? 0) as num)
          .toInt(),
      reason: (delayMap?['reason'] ?? 'No delay') as String,
      confidence: ((delayMap?['confidence'] ?? 0.6) as num).toDouble(),
    );

    return LiveTrackingSnapshot(
      orderId: (map['orderId'] ?? orderId) as String,
      partnerId: (map['partnerId'] ?? '') as String,
      etaMinutes: ((map['etaMinutes'] ?? 35) as num).toInt(),
      rider: rider,
      route: route,
      delay: delay,
      updatedAt: DateTime.tryParse('${map['updatedAt']}') ?? DateTime.now(),
    );
  }

  Future<DelayPrediction> getEta({required String orderId}) async {
    if (AppConfig.isDemo) {
      return MockData.etaForOrder(orderId);
    }

    final payload = await _get('/orders/$orderId/eta');
    final map = _unwrapDataMap(payload);
    if (map == null) {
      return const DelayPrediction(
        predictedDelayMinutes: 0,
        reason: 'No delay',
        confidence: 0.6,
      );
    }

    return DelayPrediction(
      predictedDelayMinutes: ((map['predictedDelayMinutes'] ?? 0) as num)
          .toInt(),
      reason: (map['reason'] ?? 'No delay') as String,
      confidence: ((map['confidence'] ?? 0.6) as num).toDouble(),
    );
  }

  Future<void> reportDelay({
    required String orderId,
    required String reason,
  }) async {
    if (AppConfig.isDemo) {
      MockData.reportDelay(orderId: orderId, reason: reason);
      return;
    }

    await _post('/orders/$orderId/delay-report', body: {'reason': reason});
  }

  Future<List<MealReview>> getReviewsForMeal({required String mealId}) async {
    if (AppConfig.isDemo) return MockData.reviewsForMeal(mealId);

    final payload = await _get('/meals/$mealId/reviews');
    return _unwrapList(payload)
        .map(
          (item) => MealReview(
            id: (item['id'] ?? '') as String,
            mealId: (item['mealId'] ?? mealId) as String,
            customerId: (item['customerId'] ?? '') as String,
            customerName: (item['customerName'] ?? '') as String,
            rating: ((item['rating'] ?? 5) as num).toInt(),
            comment: (item['comment'] ?? '') as String,
            createdAt:
                DateTime.tryParse('${item['createdAt']}') ?? DateTime.now(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<String>> getMealBadges({required String mealId}) async {
    if (AppConfig.isDemo) return MockData.badgesForMeal(mealId);

    final payload = await _get('/meals/$mealId/badges');
    final map = _unwrapDataMap(payload);
    final raw = (map?['badges'] as List?) ?? const <dynamic>[];
    return raw.map((entry) => '$entry').toList(growable: false);
  }

  Future<List<OfferRule>> getActiveOffers({
    required String cityId,
    required MealSlot slot,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.activeOffers(cityId: cityId, slot: slot);
    }

    final payload = await _get(
      '/offers/active?cityId=$cityId&slot=${slot.name.toUpperCase()}',
    );
    return _unwrapList(payload)
        .map(
          (item) => OfferRule(
            id: (item['id'] ?? '') as String,
            type: _offerTypeFromApi((item['type'] ?? 'FIRST_ORDER') as String),
            title: (item['title'] ?? '') as String,
            description: (item['description'] ?? '') as String,
            cityId: (item['cityId'] ?? cityId) as String,
            active: (item['active'] as bool?) ?? true,
            value: ((item['value'] ?? 0) as num).toInt(),
            minCartValue: ((item['minCartValue'] ?? 0) as num).toInt(),
          ),
        )
        .toList(growable: false);
  }

  Future<OfferEvaluation> evaluateOffers({
    required String customerId,
    required String cityId,
    required MealSlot slot,
    required int cartTotal,
    required bool isFirstOrder,
    required int streakDays,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.evaluateOffers(
        customerId: customerId,
        cityId: cityId,
        slot: slot,
        cartTotal: cartTotal,
        isFirstOrder: isFirstOrder,
        streakDays: streakDays,
      );
    }

    final payload = await _post(
      '/offers/evaluate',
      body: {
        'customerId': customerId,
        'cityId': cityId,
        'slot': slot.name.toUpperCase(),
        'cartTotal': cartTotal,
        'isFirstOrder': isFirstOrder,
        'streakDays': streakDays,
      },
    );

    final map = _unwrapDataMap(payload);
    return OfferEvaluation(
      appliedOfferIds: ((map?['appliedOfferIds'] as List?) ?? const <dynamic>[])
          .map((entry) => '$entry')
          .toList(growable: false),
      discount: ((map?['discount'] ?? 0) as num).toInt(),
      finalPayable: ((map?['finalPayable'] ?? cartTotal) as num).toInt(),
      messages: ((map?['messages'] as List?) ?? const <dynamic>[])
          .map((entry) => '$entry')
          .toList(growable: false),
    );
  }

  Future<List<SupportThread>> getSupportThreads({
    required String customerId,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.threadsForCustomer(customerId);
    }

    final payload = await _get('/support/threads?customerId=$customerId');
    return _unwrapList(payload)
        .map(
          (item) => SupportThread(
            id: (item['id'] ?? '') as String,
            customerId: (item['customerId'] ?? customerId) as String,
            orderId: (item['orderId'] ?? '') as String,
            messages: const [],
          ),
        )
        .toList(growable: false);
  }

  Future<SupportThread> createSupportThread({
    required String customerId,
    required String orderId,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.createThread(customerId: customerId, orderId: orderId);
    }

    final payload = await _post(
      '/support/threads',
      body: {'customerId': customerId, 'orderId': orderId},
    );
    final map = _unwrapDataMap(payload) ?? const <String, dynamic>{};
    return SupportThread(
      id: (map['id'] ?? '') as String,
      customerId: (map['customerId'] ?? customerId) as String,
      orderId: (map['orderId'] ?? orderId) as String,
      messages: const [],
    );
  }

  Future<SupportThread?> sendSupportMessage({
    required String customerId,
    required String threadId,
    required String sender,
    required String text,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.appendThreadMessage(
        customerId: customerId,
        threadId: threadId,
        sender: sender,
        text: text,
      );
    }

    final payload = await _post(
      '/support/threads/$threadId/messages',
      body: {'sender': sender, 'text': text, 'customerId': customerId},
    );
    final map = _unwrapDataMap(payload);
    if (map == null) return null;

    return SupportThread(
      id: (map['id'] ?? threadId) as String,
      customerId: (map['customerId'] ?? customerId) as String,
      orderId: (map['orderId'] ?? '') as String,
      messages: const [],
    );
  }

  Future<List<SupportIssue>> getSupportIssues({
    required String customerId,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.issuesForCustomer(customerId);
    }

    final payload = await _get('/support/issues?customerId=$customerId');
    return _unwrapList(payload)
        .map(
          (item) => SupportIssue(
            id: (item['id'] ?? '') as String,
            customerId: (item['customerId'] ?? customerId) as String,
            orderId: (item['orderId'] ?? '') as String,
            type: _issueTypeFromApi(
              (item['type'] ?? 'LATE_DELIVERY') as String,
            ),
            status: _issueStatusFromApi((item['status'] ?? 'OPEN') as String),
            description: (item['description'] ?? '') as String,
            createdAt:
                DateTime.tryParse('${item['createdAt']}') ?? DateTime.now(),
          ),
        )
        .toList(growable: false);
  }

  Future<SupportIssue?> createSupportIssue({
    required String customerId,
    required String orderId,
    required IssueType type,
    required String description,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.createIssue(
        customerId: customerId,
        orderId: orderId,
        type: type,
        description: description,
      );
    }

    final payload = await _post(
      '/support/issues',
      body: {
        'customerId': customerId,
        'orderId': orderId,
        'type': _issueTypeToApi(type),
        'description': description,
      },
    );

    final map = _unwrapDataMap(payload);
    if (map == null) return null;

    return SupportIssue(
      id: (map['id'] ?? '') as String,
      customerId: (map['customerId'] ?? customerId) as String,
      orderId: (map['orderId'] ?? orderId) as String,
      type: _issueTypeFromApi((map['type'] ?? 'OPEN') as String),
      status: _issueStatusFromApi((map['status'] ?? 'OPEN') as String),
      description: (map['description'] ?? description) as String,
      createdAt: DateTime.tryParse('${map['createdAt']}') ?? DateTime.now(),
    );
  }

  Future<SupportIssue?> updateSupportIssue({
    required String customerId,
    required String issueId,
    required IssueStatus status,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.updateIssueStatus(
        customerId: customerId,
        issueId: issueId,
        status: status,
      );
    }

    final payload = await _patch(
      '/support/issues/$issueId',
      body: {'status': _issueStatusToApi(status), 'customerId': customerId},
    );

    final map = _unwrapDataMap(payload);
    if (map == null) return null;

    return SupportIssue(
      id: (map['id'] ?? issueId) as String,
      customerId: (map['customerId'] ?? customerId) as String,
      orderId: (map['orderId'] ?? '') as String,
      type: _issueTypeFromApi((map['type'] ?? 'LATE_DELIVERY') as String),
      status: _issueStatusFromApi((map['status'] ?? 'OPEN') as String),
      description: (map['description'] ?? '') as String,
      createdAt: DateTime.tryParse('${map['createdAt']}') ?? DateTime.now(),
    );
  }

  Future<MaskedCallSession?> createMaskedCallSession({
    required String fromNumber,
    required String toNumber,
  }) async {
    if (AppConfig.isDemo) {
      return MockData.createMaskedCallSession(
        fromNumber: fromNumber,
        toNumber: toNumber,
      );
    }

    final payload = await _post(
      '/calls/masked/session',
      body: {'fromNumber': fromNumber, 'toNumber': toNumber},
    );

    final map = _unwrapDataMap(payload);
    if (map == null) return null;
    return MaskedCallSession(
      id: (map['id'] ?? '') as String,
      fromNumber: (map['fromNumber'] ?? fromNumber) as String,
      toNumber: (map['toNumber'] ?? toNumber) as String,
      maskedNumber: (map['maskedNumber'] ?? '') as String,
      expiresAt:
          DateTime.tryParse('${map['expiresAt']}') ??
          DateTime.now().add(const Duration(minutes: 45)),
    );
  }

  Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode < 200 || response.statusCode > 299) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode < 200 || response.statusCode > 299) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _patch(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode < 200 || response.statusCode > 299) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _unwrapList(Map<String, dynamic>? payload) {
    if (payload == null) return const <Map<String, dynamic>>[];

    if (payload['success'] == true && payload['data'] is List) {
      return (payload['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    if (payload['data'] is Map<String, dynamic>) {
      final nested = payload['data'] as Map<String, dynamic>;
      if (nested['items'] is List) {
        return (nested['items'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _unwrapDataMap(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    if (payload['success'] == true && payload['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(payload['data'] as Map);
    }

    return null;
  }

  Meal _mealFromMap(Map<String, dynamic> item) {
    return Meal(
      id: (item['id'] ?? '') as String,
      name: (item['name'] ?? '') as String,
      slot: _slotFromApi((item['slot'] as String?) ?? 'BREAKFAST'),
      price: ((item['price'] ?? 0) as num).toInt(),
      rating: ((item['rating'] ?? 4.5) as num).toDouble(),
      imageUrl:
          (item['imageUrl'] as String?) ??
          'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80',
      cityId: (item['cityId'] ?? '') as String,
      tags: (item['tags'] as List?)?.map((tag) => '$tag').toList() ?? const [],
      available: (item['available'] as bool?) ?? true,
      calories: ((item['calories'] ?? 0) as num).toInt(),
      prepTimeMin: ((item['prepTimeMin'] ?? 0) as num).toInt(),
      etaMinutes: ((item['etaMinutes'] ?? 35) as num).toInt(),
      reorderCount: ((item['reorderCount'] ?? 0) as num).toInt(),
      cuisine: (item['cuisine'] ?? 'home-style') as String,
      mostReorderedBadge: (item['mostReorderedBadge'] as bool?) ?? false,
      offerTag: item['offerTag'] as String?,
      placeId: (item['placeId'] ?? '') as String,
      placeName: (item['placeName'] ?? '') as String,
      customisable: (item['customisable'] as bool?) ?? false,
    );
  }

  DemoOrder _demoOrderFromMap(Map<String, dynamic> item) {
    return DemoOrder(
      id: (item['id'] ?? '') as String,
      customerId: (item['customerId'] ?? '') as String,
      customerName: (item['customerName'] ?? '') as String,
      cityId: (item['cityId'] ?? '') as String,
      zoneId: (item['zoneId'] ?? '') as String,
      address: (item['address'] ?? '') as String,
      slot: _slotFromApi((item['slot'] as String?) ?? 'BREAKFAST'),
      deliveryWindow:
          (item['deliveryWindow'] as String?) ?? '1:00 PM - 1:30 PM',
      status: _orderStatusFromApi((item['status'] as String?) ?? 'CREATED'),
      total: ((item['total'] ?? 0) as num).toInt(),
      placedAt: DateTime.tryParse('${item['placedAt']}') ?? DateTime.now(),
      lineItems: const [],
      timeline: const [],
      type: _orderTypeFromApi((item['type'] as String?) ?? 'ONE_TIME'),
      deliveryPartnerId: item['deliveryPartnerId'] as String?,
      subscriptionId: item['subscriptionId'] as String?,
      etaMinutes: ((item['etaMinutes'] ?? 35) as num).toInt(),
      delayReason: item['delayReason'] as String?,
    );
  }

  AddressOption _addressFromMap(Map<String, dynamic> item) {
    return AddressOption(
      id: (item['id'] ?? '') as String,
      customerId: (item['customerId'] ?? '') as String,
      label: (item['label'] ?? '') as String,
      addressLine: (item['addressLine'] ?? '') as String,
      cityId: (item['cityId'] ?? '') as String,
      zoneId: (item['zoneId'] ?? '') as String,
      serviceable: (item['serviceable'] as bool?) ?? true,
      defaultForSlots:
          (item['defaultForSlots'] as List?)
              ?.map((entry) => _slotFromApi('$entry'))
              .toList(growable: false) ??
          const <MealSlot>[],
      lastUsedAt: DateTime.tryParse('${item['lastUsedAt']}'),
    );
  }

  FoodPlace _foodPlaceFromMap(Map<String, dynamic> item) {
    return FoodPlace(
      id: (item['id'] ?? '') as String,
      name: (item['name'] ?? '') as String,
      contactNumber: (item['contactNumber'] ?? '+919900000000') as String,
      type: _foodPlaceTypeFromApi((item['type'] ?? 'RESTAURANT') as String),
      cityId: (item['cityId'] ?? '') as String,
      zoneIds:
          (item['zoneIds'] as List?)?.map((entry) => '$entry').toList() ??
          const [],
      rating: ((item['rating'] ?? 4.5) as num).toDouble(),
      avgDeliveryMinutes: ((item['avgDeliveryMinutes'] ?? 30) as num).toInt(),
      imageUrl:
          (item['imageUrl'] as String?) ??
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80',
      cuisineTags:
          (item['cuisineTags'] as List?)?.map((entry) => '$entry').toList() ??
          const [],
      deliveryByRestaurant: (item['deliveryByRestaurant'] as bool?) ?? true,
      deliveryByPorter: (item['deliveryByPorter'] as bool?) ?? true,
      acceptsScheduleOrders: (item['acceptsScheduleOrders'] as bool?) ?? true,
      acceptsCustomisations: (item['acceptsCustomisations'] as bool?) ?? false,
      minOrder: ((item['minOrder'] ?? 0) as num).toInt(),
    );
  }

  CheckoutPreferences _prefsFromMap(Map<String, dynamic> map) {
    return CheckoutPreferences(
      customerId: (map['customerId'] ?? '') as String,
      preferredWindow:
          (map['preferredWindow'] ?? '1:00 PM - 1:30 PM') as String,
      preferredPaymentMode: (map['preferredPaymentMode'] ?? 'UPI') as String,
      walletAutoApply: (map['walletAutoApply'] as bool?) ?? true,
      defaultCadence: (map['defaultCadence'] ?? 'Weekly') as String,
    );
  }

  String _searchSortToApi(SearchSort value) {
    return switch (value) {
      SearchSort.relevance => 'RELEVANCE',
      SearchSort.rating => 'RATING',
      SearchSort.eta => 'ETA',
      SearchSort.priceAsc => 'PRICE_ASC',
      SearchSort.priceDesc => 'PRICE_DESC',
    };
  }

  FeedSectionType _feedTypeFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'AGAIN_LAST_WEEK':
        return FeedSectionType.againLastWeek;
      case 'MOST_REORDERED':
        return FeedSectionType.mostReordered;
      case 'TRENDING':
        return FeedSectionType.trending;
      default:
        return FeedSectionType.recommended;
    }
  }

  FoodPlaceType _foodPlaceTypeFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'DHABA':
        return FoodPlaceType.dhaba;
      case 'TIFFIN':
        return FoodPlaceType.tiffin;
      case 'CLOUD_KITCHEN':
      case 'CLOUDKITCHEN':
        return FoodPlaceType.cloudKitchen;
      default:
        return FoodPlaceType.restaurant;
    }
  }

  MealSlot _slotFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'LUNCH':
        return MealSlot.lunch;
      case 'DINNER':
        return MealSlot.dinner;
      default:
        return MealSlot.breakfast;
    }
  }

  OrderStatus _orderStatusFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.created;
    }
  }

  String? _deliveryStatusToApi(OrderStatus status) {
    return switch (status) {
      OrderStatus.created => 'CONFIRMED',
      OrderStatus.confirmed => 'CONFIRMED',
      OrderStatus.preparing => 'CONFIRMED',
      OrderStatus.outForDelivery => 'OUT_FOR_DELIVERY',
      OrderStatus.delivered => 'DELIVERED',
      OrderStatus.cancelled => null,
    };
  }

  String _handoffCodeForOrder(String orderId) {
    final digits = orderId.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      return digits.substring(digits.length - 4);
    }
    final fallback = ((orderId.hashCode & 0x7fffffff) % 9000) + 1000;
    return '$fallback';
  }

  OrderType _orderTypeFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'SUBSCRIPTION':
        return OrderType.subscription;
      default:
        return OrderType.oneTime;
    }
  }

  WalletTxnType _walletTypeFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'REFERRAL_CREDIT':
        return WalletTxnType.referralCredit;
      case 'ORDER_DEBIT':
        return WalletTxnType.orderDebit;
      default:
        return WalletTxnType.adjustment;
    }
  }

  OfferRuleType _offerTypeFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'STREAK':
        return OfferRuleType.streak;
      case 'SURGE_SAFE':
        return OfferRuleType.surgeSafe;
      case 'SLOT_BASED':
        return OfferRuleType.slotBased;
      case 'CART_VALUE':
        return OfferRuleType.cartValue;
      default:
        return OfferRuleType.firstOrder;
    }
  }

  IssueType _issueTypeFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'MISSING_ITEM':
        return IssueType.missingItem;
      case 'WRONG_ORDER':
        return IssueType.wrongOrder;
      case 'REFUND':
        return IssueType.refund;
      default:
        return IssueType.lateDelivery;
    }
  }

  String _issueTypeToApi(IssueType value) {
    return switch (value) {
      IssueType.missingItem => 'MISSING_ITEM',
      IssueType.lateDelivery => 'LATE_DELIVERY',
      IssueType.wrongOrder => 'WRONG_ORDER',
      IssueType.refund => 'REFUND',
    };
  }

  IssueStatus _issueStatusFromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'IN_PROGRESS':
        return IssueStatus.inProgress;
      case 'RESOLVED':
        return IssueStatus.resolved;
      case 'ESCALATED':
        return IssueStatus.escalated;
      default:
        return IssueStatus.open;
    }
  }

  String _issueStatusToApi(IssueStatus value) {
    return switch (value) {
      IssueStatus.open => 'OPEN',
      IssueStatus.inProgress => 'IN_PROGRESS',
      IssueStatus.resolved => 'RESOLVED',
      IssueStatus.escalated => 'ESCALATED',
    };
  }
}
