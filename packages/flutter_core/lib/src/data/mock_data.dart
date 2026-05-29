import 'dart:math' as math;

import '../models/domain_models.dart';
import '../models/enums.dart';

class MockData {
  static const cities = [
    City(id: 'gurgaon', name: 'Gurugram'),
    City(id: 'noida', name: 'Noida'),
    City(id: 'bengaluru', name: 'Bengaluru'),
  ];

  static const zones = [
    Zone(id: 'golf-course', cityId: 'gurgaon', name: 'Golf Course Road'),
    Zone(id: 'cyber-city', cityId: 'gurgaon', name: 'Cyber City'),
    Zone(id: 'sec-62', cityId: 'noida', name: 'Sector 62'),
    Zone(id: 'sec-137', cityId: 'noida', name: 'Sector 137'),
    Zone(id: 'indiranagar', cityId: 'bengaluru', name: 'Indiranagar'),
    Zone(id: 'hsr', cityId: 'bengaluru', name: 'HSR Layout'),
  ];

  static const meals = [
    Meal(
      id: 'm1',
      name: 'Classic Poha Bowl',
      slot: MealSlot.breakfast,
      price: 80,
      rating: 4.6,
      cityId: 'gurgaon',
      calories: 320,
      prepTimeMin: 18,
      etaMinutes: 24,
      reorderCount: 188,
      mostReorderedBadge: true,
      cuisine: 'north',
      imageUrl:
          'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=900',
      tags: ['veg', 'light', 'home-style'],
      offerTag: 'Breakfast saver',
    ),
    Meal(
      id: 'm2',
      name: 'Paneer Tikka Meal',
      slot: MealSlot.lunch,
      price: 120,
      rating: 4.8,
      cityId: 'gurgaon',
      calories: 540,
      prepTimeMin: 27,
      etaMinutes: 32,
      reorderCount: 262,
      mostReorderedBadge: true,
      cuisine: 'north',
      imageUrl:
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'high-protein', 'north'],
    ),
    Meal(
      id: 'm3',
      name: 'Roti Sabzi Dinner',
      slot: MealSlot.dinner,
      price: 120,
      rating: 4.5,
      cityId: 'gurgaon',
      calories: 490,
      prepTimeMin: 30,
      etaMinutes: 36,
      reorderCount: 224,
      cuisine: 'home-style',
      imageUrl:
          'https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg?auto=compress&cs=tinysrgb&w=900',
      tags: ['veg', 'home-style', 'thali'],
    ),
    Meal(
      id: 'm4',
      name: 'Rajma Chawal Box',
      slot: MealSlot.lunch,
      price: 110,
      rating: 4.5,
      cityId: 'gurgaon',
      calories: 510,
      prepTimeMin: 24,
      etaMinutes: 28,
      reorderCount: 207,
      cuisine: 'home-style',
      imageUrl:
          'https://images.unsplash.com/photo-1613292443284-8d10ef9383fe?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'home-style'],
      offerTag: '₹20 off',
    ),
    Meal(
      id: 'm5',
      name: 'Upma + Coconut Chutney',
      slot: MealSlot.breakfast,
      price: 75,
      rating: 4.3,
      cityId: 'gurgaon',
      calories: 290,
      prepTimeMin: 16,
      etaMinutes: 23,
      reorderCount: 142,
      cuisine: 'south',
      imageUrl:
          'https://images.unsplash.com/photo-1617093727343-374698b1b08d?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'light'],
    ),
    Meal(
      id: 'm6',
      name: 'Dal Rice Comfort Box',
      slot: MealSlot.dinner,
      price: 100,
      rating: 4.4,
      cityId: 'noida',
      calories: 470,
      prepTimeMin: 22,
      etaMinutes: 30,
      reorderCount: 176,
      cuisine: 'home-style',
      imageUrl:
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'home-style'],
    ),
    Meal(
      id: 'm7',
      name: 'High Protein Combo',
      slot: MealSlot.lunch,
      price: 150,
      rating: 4.8,
      cityId: 'noida',
      calories: 620,
      prepTimeMin: 28,
      etaMinutes: 34,
      reorderCount: 231,
      mostReorderedBadge: true,
      cuisine: 'fitness',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
      tags: ['high-protein', 'fitness'],
    ),
    Meal(
      id: 'm8',
      name: 'Idli Sambar Plate',
      slot: MealSlot.breakfast,
      price: 90,
      rating: 4.5,
      cityId: 'noida',
      calories: 350,
      prepTimeMin: 20,
      etaMinutes: 26,
      reorderCount: 164,
      cuisine: 'south',
      imageUrl:
          'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'light', 'south'],
      offerTag: 'Combo offer',
    ),
    Meal(
      id: 'm9',
      name: 'Chicken Rice Bowl',
      slot: MealSlot.dinner,
      price: 170,
      rating: 4.7,
      cityId: 'noida',
      calories: 690,
      prepTimeMin: 32,
      etaMinutes: 35,
      reorderCount: 152,
      cuisine: 'asian',
      imageUrl:
          'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=900',
      tags: ['non-veg', 'high-protein'],
    ),
    Meal(
      id: 'm10',
      name: 'Sprouts Salad Bowl',
      slot: MealSlot.breakfast,
      price: 95,
      rating: 4.2,
      cityId: 'noida',
      calories: 280,
      prepTimeMin: 12,
      etaMinutes: 21,
      reorderCount: 118,
      cuisine: 'healthy',
      imageUrl:
          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'light', 'healthy'],
    ),
    Meal(
      id: 'm11',
      name: 'Millet Power Bowl',
      slot: MealSlot.lunch,
      price: 160,
      rating: 4.7,
      cityId: 'bengaluru',
      calories: 560,
      prepTimeMin: 29,
      etaMinutes: 33,
      reorderCount: 195,
      cuisine: 'healthy',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'high-protein', 'healthy'],
    ),
    Meal(
      id: 'm12',
      name: 'Mini Thali Deluxe',
      slot: MealSlot.dinner,
      price: 140,
      rating: 4.6,
      cityId: 'bengaluru',
      calories: 610,
      prepTimeMin: 33,
      etaMinutes: 38,
      reorderCount: 214,
      mostReorderedBadge: true,
      cuisine: 'home-style',
      imageUrl:
          'https://images.unsplash.com/photo-1626500155537-93690c24099e?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'thali', 'home-style'],
    ),
    Meal(
      id: 'm13',
      name: 'Masala Oats Bowl',
      slot: MealSlot.breakfast,
      price: 85,
      rating: 4.3,
      cityId: 'bengaluru',
      calories: 300,
      prepTimeMin: 14,
      etaMinutes: 24,
      reorderCount: 141,
      cuisine: 'healthy',
      imageUrl:
          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'light', 'healthy'],
    ),
    Meal(
      id: 'm14',
      name: 'Tofu Teriyaki Bowl',
      slot: MealSlot.dinner,
      price: 180,
      rating: 4.8,
      cityId: 'bengaluru',
      calories: 640,
      prepTimeMin: 30,
      etaMinutes: 37,
      reorderCount: 167,
      cuisine: 'asian',
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'high-protein'],
      offerTag: 'Streak reward',
    ),
  ];

  static const demoCustomers = [
    DemoCustomer(
      id: 'cust-1',
      name: 'Riya Sharma',
      phone: '+919910000001',
      cityId: 'gurgaon',
      zoneId: 'golf-course',
      primaryAddress: 'DLF Phase 2, Gurugram',
      tier: 'Gold',
      totalOrders: 46,
      referralCode: 'RIYA46',
      preferredSlots: [MealSlot.lunch, MealSlot.dinner],
      preferredCuisines: ['north', 'home-style'],
      preferredPriceBand: 'mid',
    ),
    DemoCustomer(
      id: 'cust-2',
      name: 'Arjun Singh',
      phone: '+919910000002',
      cityId: 'noida',
      zoneId: 'sec-62',
      primaryAddress: 'Tower 5, Sector 62, Noida',
      tier: 'Silver',
      totalOrders: 23,
      referralCode: 'ARJUN23',
      preferredSlots: [MealSlot.dinner],
      preferredCuisines: ['asian', 'fitness'],
      preferredPriceBand: 'high',
    ),
    DemoCustomer(
      id: 'cust-3',
      name: 'Neha Verma',
      phone: '+919910000003',
      cityId: 'gurgaon',
      zoneId: 'cyber-city',
      primaryAddress: 'CyberHub Residency, Gurugram',
      tier: 'Platinum',
      totalOrders: 71,
      referralCode: 'NEHA71',
      preferredSlots: [MealSlot.breakfast, MealSlot.lunch],
      preferredCuisines: ['healthy', 'south'],
      preferredPriceBand: 'low',
    ),
    DemoCustomer(
      id: 'cust-4',
      name: 'Priya Nair',
      phone: '+919910000004',
      cityId: 'noida',
      zoneId: 'sec-137',
      primaryAddress: 'Paras Tierea, Sector 137, Noida',
      tier: 'Gold',
      totalOrders: 34,
      referralCode: 'PRIYA34',
      preferredSlots: [MealSlot.breakfast],
      preferredCuisines: ['south', 'home-style'],
      preferredPriceBand: 'mid',
    ),
    DemoCustomer(
      id: 'cust-5',
      name: 'Karthik Rao',
      phone: '+919910000005',
      cityId: 'bengaluru',
      zoneId: 'indiranagar',
      primaryAddress: '100 Ft Road, Indiranagar, Bengaluru',
      tier: 'Silver',
      totalOrders: 18,
      referralCode: 'KARTHIK18',
      preferredSlots: [MealSlot.lunch],
      preferredCuisines: ['healthy'],
      preferredPriceBand: 'high',
    ),
    DemoCustomer(
      id: 'cust-6',
      name: 'Sanya Gupta',
      phone: '+919910000006',
      cityId: 'bengaluru',
      zoneId: 'hsr',
      primaryAddress: 'HSR Sector 2, Bengaluru',
      tier: 'Gold',
      totalOrders: 39,
      referralCode: 'SANYA39',
      preferredSlots: [MealSlot.dinner],
      preferredCuisines: ['home-style', 'asian'],
      preferredPriceBand: 'mid',
    ),
  ];

  static const deliveryPartners = [
    DeliveryPartnerProfile(
      id: 'dp-1',
      name: 'Aman Yadav',
      phone: '+919920000001',
      cityId: 'gurgaon',
      vehicleType: 'Bike',
      rating: 4.8,
      lastKnownLat: 28.4677,
      lastKnownLng: 77.0818,
    ),
    DeliveryPartnerProfile(
      id: 'dp-2',
      name: 'Suresh Kumar',
      phone: '+919920000002',
      cityId: 'noida',
      vehicleType: 'Scooter',
      rating: 4.6,
      lastKnownLat: 28.6272,
      lastKnownLng: 77.3649,
    ),
    DeliveryPartnerProfile(
      id: 'dp-3',
      name: 'Meena Das',
      phone: '+919920000003',
      cityId: 'bengaluru',
      vehicleType: 'Bike',
      rating: 4.7,
      lastKnownLat: 12.9716,
      lastKnownLng: 77.5946,
    ),
    DeliveryPartnerProfile(
      id: 'dp-4',
      name: 'Rahul Jain',
      phone: '+919920000004',
      cityId: 'gurgaon',
      vehicleType: 'Bike',
      rating: 4.5,
      lastKnownLat: 28.4595,
      lastKnownLng: 77.0266,
    ),
  ];

  static const foodPlaces = [
    FoodPlace(
      id: 'pl-gurgaon-1',
      name: 'Tandoori Junction',
      contactNumber: '+918800000101',
      type: FoodPlaceType.restaurant,
      cityId: 'gurgaon',
      zoneIds: ['golf-course', 'cyber-city'],
      rating: 4.7,
      avgDeliveryMinutes: 28,
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['North Indian', 'Tandoor', 'Combo Meals'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 150,
    ),
    FoodPlace(
      id: 'pl-gurgaon-2',
      name: 'Maa Ka Tiffin',
      contactNumber: '+918800000102',
      type: FoodPlaceType.tiffin,
      cityId: 'gurgaon',
      zoneIds: ['golf-course', 'cyber-city'],
      rating: 4.8,
      avgDeliveryMinutes: 24,
      imageUrl:
          'https://images.unsplash.com/photo-1613292443284-8d10ef9383fe?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['Home Style', 'Daily Meal', 'Budget'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 99,
    ),
    FoodPlace(
      id: 'pl-gurgaon-3',
      name: 'Cyber Dhaba',
      contactNumber: '+918800000103',
      type: FoodPlaceType.dhaba,
      cityId: 'gurgaon',
      zoneIds: ['cyber-city'],
      rating: 4.5,
      avgDeliveryMinutes: 30,
      imageUrl:
          'https://images.unsplash.com/photo-1626500155537-93690c24099e?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['Dhaba Style', 'Thali', 'Punjabi'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: false,
      minOrder: 120,
    ),
    FoodPlace(
      id: 'pl-noida-1',
      name: 'Noida Bento House',
      contactNumber: '+918800000201',
      type: FoodPlaceType.cloudKitchen,
      cityId: 'noida',
      zoneIds: ['sec-62', 'sec-137'],
      rating: 4.6,
      avgDeliveryMinutes: 29,
      imageUrl:
          'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=900',
      cuisineTags: ['Bowl Meals', 'High Protein', 'Quick Prep'],
      deliveryByRestaurant: false,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 180,
    ),
    FoodPlace(
      id: 'pl-noida-2',
      name: 'Sector 62 Rasoi',
      contactNumber: '+918800000202',
      type: FoodPlaceType.tiffin,
      cityId: 'noida',
      zoneIds: ['sec-62'],
      rating: 4.7,
      avgDeliveryMinutes: 26,
      imageUrl:
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['Daily Tiffin', 'Veg', 'Office Lunch'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 110,
    ),
    FoodPlace(
      id: 'pl-noida-3',
      name: 'South Lite Noida',
      contactNumber: '+918800000203',
      type: FoodPlaceType.restaurant,
      cityId: 'noida',
      zoneIds: ['sec-137'],
      rating: 4.4,
      avgDeliveryMinutes: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['South Indian', 'Breakfast', 'Light Meals'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: false,
      minOrder: 90,
    ),
    FoodPlace(
      id: 'pl-blr-1',
      name: 'Indiranagar Millet Co.',
      contactNumber: '+918800000301',
      type: FoodPlaceType.cloudKitchen,
      cityId: 'bengaluru',
      zoneIds: ['indiranagar'],
      rating: 4.8,
      avgDeliveryMinutes: 31,
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['Healthy', 'Millets', 'Fitness'],
      deliveryByRestaurant: false,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 170,
    ),
    FoodPlace(
      id: 'pl-blr-2',
      name: 'HSR Home Plate',
      contactNumber: '+918800000302',
      type: FoodPlaceType.tiffin,
      cityId: 'bengaluru',
      zoneIds: ['hsr'],
      rating: 4.6,
      avgDeliveryMinutes: 27,
      imageUrl:
          'https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg?auto=compress&cs=tinysrgb&w=900',
      cuisineTags: ['Home Style', 'Dinner', 'Subscription'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 100,
    ),
  ];

  static const mealPlaceMapping = {
    'm1': 'pl-gurgaon-2',
    'm2': 'pl-gurgaon-1',
    'm3': 'pl-gurgaon-3',
    'm4': 'pl-gurgaon-2',
    'm5': 'pl-gurgaon-2',
    'm6': 'pl-noida-2',
    'm7': 'pl-noida-1',
    'm8': 'pl-noida-3',
    'm9': 'pl-noida-1',
    'm10': 'pl-noida-3',
    'm11': 'pl-blr-1',
    'm12': 'pl-blr-2',
    'm13': 'pl-blr-1',
    'm14': 'pl-blr-1',
  };

  static final Map<String, FoodPlace> _foodPlaceById = {
    for (final place in foodPlaces) place.id: place,
  };

  static final demoOrders = _buildDemoOrders();

  static final walletByCustomer = _buildWalletLedger();

  static final walletLedger =
      walletByCustomer[demoCustomers.first.id] ?? const <WalletLedgerItem>[];

  static final addressesByCustomer = _buildAddresses();

  static final checkoutPreferencesByCustomer = _buildCheckoutPreferences();

  static final trackingByOrder = _buildTracking();

  static final reviews = _buildReviews();

  static final offerRules = _buildOfferRules();

  static final supportThreadsByCustomer = _buildSupportThreads();

  static final supportIssuesByCustomer = _buildSupportIssues();

  static final deliveryJobs = jobsForPartner(deliveryPartners.first.id);

  static bool validateDemoSeed() {
    return cities.isNotEmpty &&
        zones.isNotEmpty &&
        meals.isNotEmpty &&
        foodPlaces.isNotEmpty &&
        demoCustomers.isNotEmpty &&
        deliveryPartners.isNotEmpty &&
        demoOrders.isNotEmpty;
  }

  static List<FoodPlace> foodPlacesForCity(String cityId, {String? zoneId}) {
    return foodPlaces.where((place) {
      if (place.cityId != cityId) return false;
      if (zoneId == null) return true;
      return place.zoneIds.contains(zoneId);
    }).toList(growable: false);
  }

  static FoodPlace? foodPlaceById(String placeId) {
    return _foodPlaceById[placeId];
  }

  static FoodPlace? foodPlaceForMeal(String mealId) {
    final placeId = mealPlaceMapping[mealId];
    if (placeId == null) return null;
    return _foodPlaceById[placeId];
  }

  static List<Meal> mealsForFoodPlace({
    required String placeId,
    MealSlot? slot,
  }) {
    final mealIds = mealPlaceMapping.entries
        .where((entry) => entry.value == placeId)
        .map((entry) => entry.key)
        .toSet();

    final list = meals.where((meal) {
      if (!mealIds.contains(meal.id)) return false;
      if (slot != null && meal.slot != slot) return false;
      return true;
    }).map(_withFoodPlaceMeta).toList(growable: false);
    return list;
  }

  static List<DemoOrder> ordersForFoodPlace(String placeId) {
    return demoOrders
        .where((order) => foodPlaceIdForOrder(order) == placeId)
        .toList(growable: false);
  }

  static String? foodPlaceIdForOrder(DemoOrder order) {
    if (order.lineItems.isEmpty) return null;
    return mealPlaceMapping[order.lineItems.first.mealId];
  }

  static List<DemoOrder> ordersForCustomer(String customerId) {
    return demoOrders
        .where((order) => order.customerId == customerId)
        .toList(growable: false);
  }

  static List<Meal> sameDayMeals({
    required String cityId,
    MealSlot? slot,
  }) {
    return meals
        .where(
          (meal) => meal.cityId == cityId && (slot == null || meal.slot == slot),
        )
        .map(_withFoodPlaceMeta)
        .toList(growable: false);
  }

  static List<DeliveryJob> jobsForPartner(String partnerId) {
    return demoOrders
        .where((order) => order.deliveryPartnerId == partnerId)
        .map((order) {
          final tracking = trackingByOrder[order.id];
          return DeliveryJob(
            id: 'job-${order.id}',
            orderId: order.id,
            customerName: order.customerName,
            address: order.address,
            slotLabel: '${_slotLabel(order.slot)} ${order.deliveryWindow}',
            status: order.status,
            etaMinutes: tracking?.etaMinutes ?? order.etaMinutes,
            riderLat: tracking?.rider.lat ?? 0,
            riderLng: tracking?.rider.lng ?? 0,
          );
        })
        .toList(growable: false);
  }

  static List<WalletLedgerItem> walletForCustomer(String customerId) {
    return walletByCustomer[customerId] ?? walletLedger;
  }

  static List<AddressOption> addressesForCustomer(String customerId) {
    return addressesByCustomer[customerId] ?? const <AddressOption>[];
  }

  static AddressOption? smartDefaultAddress({
    required String customerId,
    required MealSlot slot,
    required String day,
  }) {
    final addresses = addressesForCustomer(
      customerId,
    ).where((address) => address.serviceable).toList();
    if (addresses.isEmpty) return null;

    final slotMatch = addresses.where(
      (address) => address.defaultForSlots.contains(slot),
    );
    if (slotMatch.isNotEmpty) return slotMatch.first;

    addresses.sort((a, b) {
      final aTs = a.lastUsedAt?.millisecondsSinceEpoch ?? 0;
      final bTs = b.lastUsedAt?.millisecondsSinceEpoch ?? 0;
      return bTs.compareTo(aTs);
    });

    if (day.toLowerCase().contains('sun')) {
      return addresses.last;
    }
    return addresses.first;
  }

  static CheckoutPreferences preferencesForCustomer(String customerId) {
    return checkoutPreferencesByCustomer[customerId] ??
        CheckoutPreferences(
          customerId: customerId,
          preferredWindow: '1:00 PM - 1:30 PM',
          preferredPaymentMode: 'UPI',
          walletAutoApply: true,
          defaultCadence: 'Weekly',
        );
  }

  static void updatePreferences(CheckoutPreferences updated) {
    checkoutPreferencesByCustomer[updated.customerId] = updated;
  }

  static List<PersonalizedFeedSection> personalizedFeed({
    required String customerId,
    required String cityId,
    required MealSlot slot,
    int limit = 6,
  }) {
    final customer = demoCustomers.firstWhere(
      (entry) => entry.id == customerId,
      orElse: () => demoCustomers.first,
    );

    final cityMeals = meals
        .where((meal) => meal.cityId == cityId && meal.slot == slot)
        .map(_withFoodPlaceMeta)
        .toList();

    if (cityMeals.isEmpty) {
      return const <PersonalizedFeedSection>[];
    }

    final scored =
        cityMeals
            .map(
              (meal) => (meal: meal, score: _mealScore(meal, customer, slot)),
            )
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final reorder = reorderSuggestions(
      customerId: customerId,
      cityId: cityId,
    ).where((meal) => meal.slot == slot).toList();

    return [
      PersonalizedFeedSection(
        type: FeedSectionType.againLastWeek,
        title: 'Again from last week',
        subtitle: 'Quick one-tap reorder picks',
        meals: reorder.take(limit).toList(),
      ),
      PersonalizedFeedSection(
        type: FeedSectionType.mostReordered,
        title: 'Most reordered in your area',
        subtitle: 'Loved by customers near you',
        meals:
            (cityMeals.toList()
                  ..sort((a, b) => b.reorderCount.compareTo(a.reorderCount)))
                .take(limit)
                .toList(),
      ),
      PersonalizedFeedSection(
        type: FeedSectionType.recommended,
        title: 'Recommended for you',
        subtitle: 'Ranked by your taste profile',
        meals: scored.map((entry) => entry.meal).take(limit).toList(),
      ),
      PersonalizedFeedSection(
        type: FeedSectionType.trending,
        title: 'Trending now',
        subtitle: 'Best ratings + active offers',
        meals:
            (cityMeals.toList()..sort((a, b) {
                  final aScore = a.rating + (a.offerTag == null ? 0 : 0.4);
                  final bScore = b.rating + (b.offerTag == null ? 0 : 0.4);
                  return bScore.compareTo(aScore);
                }))
                .take(limit)
                .toList(),
      ),
    ];
  }

  static List<Meal> reorderSuggestions({
    required String customerId,
    required String cityId,
    int windowDays = 7,
  }) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: windowDays));
    final customerOrders = ordersForCustomer(customerId)
        .where(
          (order) =>
              order.cityId == cityId &&
              order.placedAt.isAfter(start) &&
              order.status != OrderStatus.cancelled,
        )
        .toList();

    final mealCount = <String, int>{};
    for (final order in customerOrders) {
      for (final item in order.lineItems) {
        mealCount[item.mealId] = (mealCount[item.mealId] ?? 0) + item.qty;
      }
    }

    final sortedIds = mealCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds
        .map(
          (entry) => meals.firstWhere(
            (meal) => meal.id == entry.key,
            orElse: () => meals.first,
          ),
        )
        .map(_withFoodPlaceMeta)
        .toList(growable: false);
  }

  static List<Meal> searchMeals({
    required String cityId,
    required MealSlot slot,
    required String query,
    required SearchFilters filters,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    final list = meals.where((meal) {
      if (meal.cityId != cityId || meal.slot != slot) return false;
      if (normalizedQuery.isNotEmpty &&
          !meal.name.toLowerCase().contains(normalizedQuery) &&
          !meal.tags.any(
            (tag) => tag.toLowerCase().contains(normalizedQuery),
          )) {
        return false;
      }
      if (filters.diet != 'All') {
        final expected = filters.diet.toLowerCase().replaceAll(' ', '-');
        final dietMatch = meal.tags
            .map((tag) => tag.toLowerCase())
            .any((tag) => tag.contains(expected) || expected.contains(tag));
        if (!dietMatch) return false;
      }
      if (meal.calories < filters.caloriesMin ||
          meal.calories > filters.caloriesMax) {
        return false;
      }
      if (meal.prepTimeMin < filters.prepMin ||
          meal.prepTimeMin > filters.prepMax) {
        return false;
      }
      if (meal.price < filters.priceMin || meal.price > filters.priceMax) {
        return false;
      }
      if (filters.offersOnly && meal.offerTag == null) return false;
      if (meal.rating < filters.ratingMin) return false;
      return true;
    }).toList();

    switch (filters.sort) {
      case SearchSort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SearchSort.eta:
        list.sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
      case SearchSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SearchSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SearchSort.relevance:
        list.sort((a, b) {
          final aScore = _relevanceScore(a, normalizedQuery);
          final bScore = _relevanceScore(b, normalizedQuery);
          return bScore.compareTo(aScore);
        });
    }

    return list.map(_withFoodPlaceMeta).toList(growable: false);
  }

  static LiveTrackingSnapshot? trackingForOrder(String orderId) {
    return trackingByOrder[orderId];
  }

  static DelayPrediction etaForOrder(String orderId) {
    final tracking = trackingByOrder[orderId];
    if (tracking == null) {
      return const DelayPrediction(
        predictedDelayMinutes: 0,
        reason: 'No delay',
        confidence: 0.6,
      );
    }
    return tracking.delay;
  }

  static void reportDelay({required String orderId, required String reason}) {
    final current = trackingByOrder[orderId];
    if (current == null) return;

    trackingByOrder[orderId] = LiveTrackingSnapshot(
      orderId: current.orderId,
      partnerId: current.partnerId,
      etaMinutes: current.etaMinutes + 8,
      rider: current.rider,
      route: current.route,
      delay: DelayPrediction(
        predictedDelayMinutes: current.delay.predictedDelayMinutes + 8,
        reason: reason,
        confidence: 0.84,
      ),
      updatedAt: DateTime.now(),
    );
  }

  static List<MealReview> reviewsForMeal(String mealId) {
    return reviews
        .where((review) => review.mealId == mealId)
        .toList(growable: false);
  }

  static List<String> badgesForMeal(String mealId) {
    final meal = meals.firstWhere(
      (entry) => entry.id == mealId,
      orElse: () => meals.first,
    );

    final badges = <String>[];
    if (meal.mostReorderedBadge) badges.add('Most reordered');
    if (meal.offerTag != null) badges.add('Offer live');
    if (meal.rating >= 4.7) badges.add('Top rated');
    return badges;
  }

  static List<OfferRule> activeOffers({
    required String cityId,
    required MealSlot slot,
  }) {
    return offerRules
        .where((rule) => rule.cityId == cityId && rule.active)
        .where((rule) {
          if (rule.type != OfferRuleType.slotBased) return true;
          final lowerTitle = rule.title.toLowerCase();
          return lowerTitle.contains(_slotLabel(slot).toLowerCase());
        })
        .toList(growable: false);
  }

  static OfferEvaluation evaluateOffers({
    required String customerId,
    required String cityId,
    required MealSlot slot,
    required int cartTotal,
    required bool isFirstOrder,
    required int streakDays,
  }) {
    final offers = activeOffers(cityId: cityId, slot: slot);
    final applied = <String>[];
    final messages = <String>[];
    var discount = 0;

    for (final offer in offers) {
      if (cartTotal < offer.minCartValue) continue;

      var eligible = true;
      switch (offer.type) {
        case OfferRuleType.firstOrder:
          eligible = isFirstOrder;
        case OfferRuleType.streak:
          eligible = streakDays >= 3;
        case OfferRuleType.surgeSafe:
          eligible = true;
        case OfferRuleType.slotBased:
          eligible = true;
        case OfferRuleType.cartValue:
          eligible = cartTotal >= offer.minCartValue;
      }

      if (!eligible) continue;
      applied.add(offer.id);
      discount += offer.value;
      messages.add('${offer.title} applied');
    }

    final maxDiscount = (cartTotal * 0.35).round();
    if (discount > maxDiscount) {
      discount = maxDiscount;
      messages.add('Discount capped at 35% of cart value');
    }

    return OfferEvaluation(
      appliedOfferIds: applied,
      discount: discount,
      finalPayable: math.max(0, cartTotal - discount),
      messages: messages,
    );
  }

  static List<SupportThread> threadsForCustomer(String customerId) {
    return supportThreadsByCustomer[customerId] ?? const <SupportThread>[];
  }

  static SupportThread createThread({
    required String customerId,
    required String orderId,
  }) {
    final thread = SupportThread(
      id: 'thr-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      orderId: orderId,
      messages: const <SupportMessage>[],
    );

    final list = List<SupportThread>.from(
      supportThreadsByCustomer[customerId] ?? const <SupportThread>[],
    );
    list.insert(0, thread);
    supportThreadsByCustomer[customerId] = list;
    return thread;
  }

  static SupportThread? appendThreadMessage({
    required String customerId,
    required String threadId,
    required String sender,
    required String text,
  }) {
    final threads = List<SupportThread>.from(
      supportThreadsByCustomer[customerId] ?? const <SupportThread>[],
    );

    final index = threads.indexWhere((thread) => thread.id == threadId);
    if (index < 0) return null;

    final existing = threads[index];
    final updated = SupportThread(
      id: existing.id,
      customerId: existing.customerId,
      orderId: existing.orderId,
      messages: [
        ...existing.messages,
        SupportMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          sender: sender,
          text: text,
          createdAt: DateTime.now(),
        ),
      ],
    );

    threads[index] = updated;
    supportThreadsByCustomer[customerId] = threads;
    return updated;
  }

  static List<SupportIssue> issuesForCustomer(String customerId) {
    return supportIssuesByCustomer[customerId] ?? const <SupportIssue>[];
  }

  static SupportIssue createIssue({
    required String customerId,
    required String orderId,
    required IssueType type,
    required String description,
  }) {
    final issue = SupportIssue(
      id: 'iss-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      orderId: orderId,
      type: type,
      status: IssueStatus.open,
      description: description,
      createdAt: DateTime.now(),
    );

    final list = List<SupportIssue>.from(
      supportIssuesByCustomer[customerId] ?? const <SupportIssue>[],
    )..insert(0, issue);
    supportIssuesByCustomer[customerId] = list;
    return issue;
  }

  static SupportIssue? updateIssueStatus({
    required String customerId,
    required String issueId,
    required IssueStatus status,
  }) {
    final list = List<SupportIssue>.from(
      supportIssuesByCustomer[customerId] ?? const <SupportIssue>[],
    );
    final index = list.indexWhere((entry) => entry.id == issueId);
    if (index < 0) return null;

    final existing = list[index];
    final updated = SupportIssue(
      id: existing.id,
      customerId: existing.customerId,
      orderId: existing.orderId,
      type: existing.type,
      status: status,
      description: existing.description,
      createdAt: existing.createdAt,
    );

    list[index] = updated;
    supportIssuesByCustomer[customerId] = list;
    return updated;
  }

  static MaskedCallSession createMaskedCallSession({
    required String fromNumber,
    required String toNumber,
  }) {
    final id = 'call-${DateTime.now().millisecondsSinceEpoch}';
    final suffix = DateTime.now().millisecond.toString().padLeft(3, '0');
    return MaskedCallSession(
      id: id,
      fromNumber: fromNumber,
      toNumber: toNumber,
      maskedNumber: '+91888888$suffix',
      expiresAt: DateTime.now().add(const Duration(minutes: 45)),
    );
  }

  static List<DemoOrder> _buildDemoOrders() {
    final now = DateTime.now();

    DemoOrder order({
      required String id,
      required String customerId,
      required String customerName,
      required String cityId,
      required String zoneId,
      required String address,
      required MealSlot slot,
      required String deliveryWindow,
      required OrderStatus status,
      required int total,
      required OrderType type,
      required String deliveryPartnerId,
      required List<OrderLineItem> lineItems,
      required DateTime placedAt,
      int etaMinutes = 32,
      String? delayReason,
      String? subscriptionId,
    }) {
      return DemoOrder(
        id: id,
        customerId: customerId,
        customerName: customerName,
        cityId: cityId,
        zoneId: zoneId,
        address: address,
        slot: slot,
        deliveryWindow: deliveryWindow,
        status: status,
        total: total,
        type: type,
        deliveryPartnerId: deliveryPartnerId,
        lineItems: lineItems,
        placedAt: placedAt,
        timeline: _timelineFor(status: status, placedAt: placedAt),
        subscriptionId: subscriptionId,
        etaMinutes: etaMinutes,
        delayReason: delayReason,
      );
    }

    return [
      order(
        id: 'ORD-2101',
        customerId: 'cust-1',
        customerName: 'Riya Sharma',
        cityId: 'gurgaon',
        zoneId: 'golf-course',
        address: 'DLF Phase 2, Gurugram',
        slot: MealSlot.lunch,
        deliveryWindow: '1:00 PM - 1:30 PM',
        status: OrderStatus.outForDelivery,
        total: 240,
        type: OrderType.oneTime,
        deliveryPartnerId: 'dp-1',
        lineItems: const [
          OrderLineItem(
            mealId: 'm2',
            mealName: 'Paneer Tikka Meal',
            qty: 1,
            unitPrice: 120,
          ),
          OrderLineItem(
            mealId: 'm4',
            mealName: 'Rajma Chawal Box',
            qty: 1,
            unitPrice: 110,
          ),
        ],
        placedAt: now.subtract(const Duration(hours: 2)),
        etaMinutes: 18,
      ),
      order(
        id: 'ORD-2102',
        customerId: 'cust-2',
        customerName: 'Arjun Singh',
        cityId: 'noida',
        zoneId: 'sec-62',
        address: 'Tower 5, Sector 62, Noida',
        slot: MealSlot.dinner,
        deliveryWindow: '8:00 PM - 8:30 PM',
        status: OrderStatus.confirmed,
        total: 170,
        type: OrderType.oneTime,
        deliveryPartnerId: 'dp-2',
        lineItems: const [
          OrderLineItem(
            mealId: 'm9',
            mealName: 'Chicken Rice Bowl',
            qty: 1,
            unitPrice: 170,
          ),
        ],
        placedAt: now.subtract(const Duration(minutes: 38)),
        etaMinutes: 33,
      ),
      order(
        id: 'ORD-2103',
        customerId: 'cust-3',
        customerName: 'Neha Verma',
        cityId: 'gurgaon',
        zoneId: 'cyber-city',
        address: 'CyberHub Residency, Gurugram',
        slot: MealSlot.dinner,
        deliveryWindow: '7:30 PM - 8:00 PM',
        status: OrderStatus.preparing,
        total: 260,
        type: OrderType.subscription,
        deliveryPartnerId: 'dp-4',
        lineItems: const [
          OrderLineItem(
            mealId: 'm3',
            mealName: 'Roti Sabzi Dinner',
            qty: 1,
            unitPrice: 120,
          ),
          OrderLineItem(
            mealId: 'm2',
            mealName: 'Paneer Tikka Meal',
            qty: 1,
            unitPrice: 120,
          ),
        ],
        placedAt: now.subtract(const Duration(hours: 1, minutes: 5)),
        subscriptionId: 'SUB-3102',
        etaMinutes: 36,
      ),
      order(
        id: 'ORD-2104',
        customerId: 'cust-4',
        customerName: 'Priya Nair',
        cityId: 'noida',
        zoneId: 'sec-137',
        address: 'Paras Tierea, Sector 137, Noida',
        slot: MealSlot.breakfast,
        deliveryWindow: '8:30 AM - 9:00 AM',
        status: OrderStatus.delivered,
        total: 180,
        type: OrderType.subscription,
        deliveryPartnerId: 'dp-2',
        lineItems: const [
          OrderLineItem(
            mealId: 'm8',
            mealName: 'Idli Sambar Plate',
            qty: 1,
            unitPrice: 90,
          ),
          OrderLineItem(
            mealId: 'm6',
            mealName: 'Dal Rice Comfort Box',
            qty: 1,
            unitPrice: 100,
          ),
        ],
        placedAt: now.subtract(const Duration(hours: 8)),
        subscriptionId: 'SUB-3103',
        etaMinutes: 0,
      ),
      order(
        id: 'ORD-2105',
        customerId: 'cust-5',
        customerName: 'Karthik Rao',
        cityId: 'bengaluru',
        zoneId: 'indiranagar',
        address: '100 Ft Road, Indiranagar, Bengaluru',
        slot: MealSlot.lunch,
        deliveryWindow: '12:30 PM - 1:00 PM',
        status: OrderStatus.outForDelivery,
        total: 320,
        type: OrderType.oneTime,
        deliveryPartnerId: 'dp-3',
        lineItems: const [
          OrderLineItem(
            mealId: 'm11',
            mealName: 'Millet Power Bowl',
            qty: 2,
            unitPrice: 160,
          ),
        ],
        placedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        etaMinutes: 20,
        delayReason: 'Traffic near Indiranagar 100ft road',
      ),
      order(
        id: 'ORD-2106',
        customerId: 'cust-6',
        customerName: 'Sanya Gupta',
        cityId: 'bengaluru',
        zoneId: 'hsr',
        address: 'HSR Sector 2, Bengaluru',
        slot: MealSlot.dinner,
        deliveryWindow: '8:00 PM - 8:30 PM',
        status: OrderStatus.confirmed,
        total: 280,
        type: OrderType.subscription,
        deliveryPartnerId: 'dp-3',
        lineItems: const [
          OrderLineItem(
            mealId: 'm12',
            mealName: 'Mini Thali Deluxe',
            qty: 2,
            unitPrice: 140,
          ),
        ],
        placedAt: now.subtract(const Duration(minutes: 50)),
        subscriptionId: 'SUB-3104',
        etaMinutes: 34,
      ),
      order(
        id: 'ORD-2107',
        customerId: 'cust-1',
        customerName: 'Riya Sharma',
        cityId: 'gurgaon',
        zoneId: 'golf-course',
        address: 'DLF Phase 2, Gurugram',
        slot: MealSlot.breakfast,
        deliveryWindow: '9:00 AM - 9:30 AM',
        status: OrderStatus.delivered,
        total: 155,
        type: OrderType.oneTime,
        deliveryPartnerId: 'dp-1',
        lineItems: const [
          OrderLineItem(
            mealId: 'm1',
            mealName: 'Classic Poha Bowl',
            qty: 1,
            unitPrice: 80,
          ),
          OrderLineItem(
            mealId: 'm5',
            mealName: 'Upma + Coconut Chutney',
            qty: 1,
            unitPrice: 75,
          ),
        ],
        placedAt: now.subtract(const Duration(days: 1, hours: 3)),
        etaMinutes: 0,
      ),
      order(
        id: 'ORD-2108',
        customerId: 'cust-2',
        customerName: 'Arjun Singh',
        cityId: 'noida',
        zoneId: 'sec-62',
        address: 'Tower 5, Sector 62, Noida',
        slot: MealSlot.lunch,
        deliveryWindow: '1:30 PM - 2:00 PM',
        status: OrderStatus.cancelled,
        total: 150,
        type: OrderType.oneTime,
        deliveryPartnerId: 'dp-2',
        lineItems: const [
          OrderLineItem(
            mealId: 'm7',
            mealName: 'High Protein Combo',
            qty: 1,
            unitPrice: 150,
          ),
        ],
        placedAt: now.subtract(const Duration(days: 2, hours: 1)),
        etaMinutes: 0,
      ),
    ];
  }

  static Map<String, List<WalletLedgerItem>> _buildWalletLedger() {
    final now = DateTime.now();
    return {
      'cust-1': [
        WalletLedgerItem(
          id: 'w-r1',
          type: WalletTxnType.referralCredit,
          amount: 150,
          description: 'Referral bonus from ARJUN23',
          createdAt: now.subtract(const Duration(days: 2, hours: 3)),
        ),
        WalletLedgerItem(
          id: 'w-r2',
          type: WalletTxnType.orderDebit,
          amount: -80,
          description: 'Applied to order ORD-2101',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        WalletLedgerItem(
          id: 'w-r3',
          type: WalletTxnType.adjustment,
          amount: 30,
          description: 'Late delivery goodwill credit',
          createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        ),
      ],
      'cust-2': [
        WalletLedgerItem(
          id: 'w-a1',
          type: WalletTxnType.referralCredit,
          amount: 100,
          description: 'Referral bonus credited',
          createdAt: now.subtract(const Duration(days: 6)),
        ),
        WalletLedgerItem(
          id: 'w-a2',
          type: WalletTxnType.orderDebit,
          amount: -50,
          description: 'Applied to order ORD-2102',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
      ],
      'cust-5': [
        WalletLedgerItem(
          id: 'w-k1',
          type: WalletTxnType.adjustment,
          amount: 120,
          description: 'Streak reward bonus',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ],
    };
  }

  static Map<String, List<AddressOption>> _buildAddresses() {
    final now = DateTime.now();
    return {
      'cust-1': [
        AddressOption(
          id: 'addr-1',
          customerId: 'cust-1',
          label: 'Home',
          addressLine: 'DLF Phase 2, Gurugram',
          cityId: 'gurgaon',
          zoneId: 'golf-course',
          serviceable: true,
          defaultForSlots: const [MealSlot.breakfast, MealSlot.dinner],
          lastUsedAt: now.subtract(const Duration(hours: 10)),
        ),
        AddressOption(
          id: 'addr-2',
          customerId: 'cust-1',
          label: 'Office',
          addressLine: 'Cyber Hub Tower B, Gurugram',
          cityId: 'gurgaon',
          zoneId: 'cyber-city',
          serviceable: true,
          defaultForSlots: const [MealSlot.lunch],
          lastUsedAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
      'cust-2': [
        AddressOption(
          id: 'addr-3',
          customerId: 'cust-2',
          label: 'Home',
          addressLine: 'Tower 5, Sector 62, Noida',
          cityId: 'noida',
          zoneId: 'sec-62',
          serviceable: true,
          defaultForSlots: const [MealSlot.dinner],
          lastUsedAt: now.subtract(const Duration(hours: 5)),
        ),
      ],
    };
  }

  static Map<String, CheckoutPreferences> _buildCheckoutPreferences() {
    return {
      'cust-1': const CheckoutPreferences(
        customerId: 'cust-1',
        preferredWindow: '1:00 PM - 1:30 PM',
        preferredPaymentMode: 'UPI',
        walletAutoApply: true,
        defaultCadence: 'Weekly',
      ),
      'cust-2': const CheckoutPreferences(
        customerId: 'cust-2',
        preferredWindow: '8:00 PM - 8:30 PM',
        preferredPaymentMode: 'Card',
        walletAutoApply: false,
        defaultCadence: 'Monthly',
      ),
    };
  }

  static Map<String, LiveTrackingSnapshot> _buildTracking() {
    final now = DateTime.now();

    LiveTrackingSnapshot snapshot({
      required String orderId,
      required String partnerId,
      required int eta,
      required List<RiderLocation> route,
      required DelayPrediction delay,
    }) {
      return LiveTrackingSnapshot(
        orderId: orderId,
        partnerId: partnerId,
        etaMinutes: eta,
        rider: route.isEmpty
            ? RiderLocation(lat: 0, lng: 0, recordedAt: now)
            : route.last,
        route: route,
        delay: delay,
        updatedAt: now,
      );
    }

    return {
      'ORD-2101': snapshot(
        orderId: 'ORD-2101',
        partnerId: 'dp-1',
        eta: 18,
        route: [
          RiderLocation(
            lat: 28.4701,
            lng: 77.0803,
            recordedAt: now.subtract(const Duration(minutes: 16)),
          ),
          RiderLocation(
            lat: 28.4691,
            lng: 77.0811,
            recordedAt: now.subtract(const Duration(minutes: 8)),
          ),
          RiderLocation(lat: 28.4680, lng: 77.0816, recordedAt: now),
        ],
        delay: const DelayPrediction(
          predictedDelayMinutes: 2,
          reason: 'Minor traffic',
          confidence: 0.81,
        ),
      ),
      'ORD-2105': snapshot(
        orderId: 'ORD-2105',
        partnerId: 'dp-3',
        eta: 24,
        route: [
          RiderLocation(
            lat: 12.9731,
            lng: 77.5992,
            recordedAt: now.subtract(const Duration(minutes: 14)),
          ),
          RiderLocation(
            lat: 12.9724,
            lng: 77.5978,
            recordedAt: now.subtract(const Duration(minutes: 7)),
          ),
          RiderLocation(lat: 12.9718, lng: 77.5962, recordedAt: now),
        ],
        delay: const DelayPrediction(
          predictedDelayMinutes: 9,
          reason: 'Traffic congestion',
          confidence: 0.89,
        ),
      ),
    };
  }

  static List<MealReview> _buildReviews() {
    final now = DateTime.now();
    return [
      MealReview(
        id: 'rev-1',
        mealId: 'm2',
        customerId: 'cust-1',
        customerName: 'Riya Sharma',
        rating: 5,
        comment: 'Super fresh and balanced spice.',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        photos: const [
          ReviewPhoto(
            id: 'media-1',
            url:
                'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80',
            status: ModerationStatus.approved,
          ),
        ],
      ),
      MealReview(
        id: 'rev-2',
        mealId: 'm12',
        customerId: 'cust-6',
        customerName: 'Sanya Gupta',
        rating: 4,
        comment: 'Nice home-style portion size.',
        createdAt: now.subtract(const Duration(days: 2, hours: 2)),
      ),
      MealReview(
        id: 'rev-3',
        mealId: 'm7',
        customerId: 'cust-2',
        customerName: 'Arjun Singh',
        rating: 5,
        comment: 'Perfect post-workout meal.',
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
    ];
  }

  static List<OfferRule> _buildOfferRules() {
    return const [
      OfferRule(
        id: 'offer-first-1',
        type: OfferRuleType.firstOrder,
        title: 'First order ₹100 off',
        description: 'Valid once per customer',
        cityId: 'gurgaon',
        active: true,
        value: 100,
        minCartValue: 299,
      ),
      OfferRule(
        id: 'offer-streak-1',
        type: OfferRuleType.streak,
        title: '3-day streak reward',
        description: 'For customers ordering 3 consecutive days',
        cityId: 'noida',
        active: true,
        value: 60,
        minCartValue: 199,
      ),
      OfferRule(
        id: 'offer-surge-safe-1',
        type: OfferRuleType.surgeSafe,
        title: 'Surge-safe pricing guard',
        description: 'Auto compensates surge spikes',
        cityId: 'bengaluru',
        active: true,
        value: 40,
        minCartValue: 150,
      ),
      OfferRule(
        id: 'offer-slot-breakfast',
        type: OfferRuleType.slotBased,
        title: 'Breakfast slot saver',
        description: 'Applicable for breakfast orders',
        cityId: 'gurgaon',
        active: true,
        value: 25,
        minCartValue: 120,
      ),
      OfferRule(
        id: 'offer-cart-1',
        type: OfferRuleType.cartValue,
        title: 'Cart value ₹500 saver',
        description: 'For larger baskets',
        cityId: 'noida',
        active: true,
        value: 90,
        minCartValue: 500,
      ),
    ];
  }

  static Map<String, List<SupportThread>> _buildSupportThreads() {
    final now = DateTime.now();
    return {
      'cust-1': [
        SupportThread(
          id: 'thr-1',
          customerId: 'cust-1',
          orderId: 'ORD-2101',
          messages: [
            SupportMessage(
              id: 'msg-1',
              sender: 'customer',
              text: 'ETA changed. Is rider nearby?',
              createdAt: now.subtract(const Duration(minutes: 25)),
            ),
            SupportMessage(
              id: 'msg-2',
              sender: 'agent',
              text: 'Yes, rider is 1.8km away. Updated ETA is 18 mins.',
              createdAt: now.subtract(const Duration(minutes: 21)),
            ),
          ],
        ),
      ],
    };
  }

  static Map<String, List<SupportIssue>> _buildSupportIssues() {
    final now = DateTime.now();
    return {
      'cust-1': [
        SupportIssue(
          id: 'iss-1',
          customerId: 'cust-1',
          orderId: 'ORD-2101',
          type: IssueType.lateDelivery,
          status: IssueStatus.inProgress,
          description: 'Delivery running late by 20 minutes',
          createdAt: now.subtract(const Duration(minutes: 28)),
        ),
      ],
    };
  }

  static List<OrderTimelineEvent> _timelineFor({
    required OrderStatus status,
    required DateTime placedAt,
  }) {
    final events = <OrderTimelineEvent>[
      OrderTimelineEvent(
        status: OrderStatus.created,
        label: 'Order placed',
        at: placedAt,
      ),
      OrderTimelineEvent(
        status: OrderStatus.confirmed,
        label: 'Order confirmed',
        at: placedAt.add(const Duration(minutes: 2)),
      ),
    ];

    if (status == OrderStatus.cancelled) {
      events.add(
        OrderTimelineEvent(
          status: OrderStatus.cancelled,
          label: 'Order cancelled',
          at: placedAt.add(const Duration(minutes: 18)),
          note: 'Customer requested cancellation',
        ),
      );
      return events;
    }

    if (status.index >= OrderStatus.preparing.index) {
      events.add(
        OrderTimelineEvent(
          status: OrderStatus.preparing,
          label: 'Preparing in kitchen',
          at: placedAt.add(const Duration(minutes: 18)),
        ),
      );
    }
    if (status.index >= OrderStatus.outForDelivery.index) {
      events.add(
        OrderTimelineEvent(
          status: OrderStatus.outForDelivery,
          label: 'Out for delivery',
          at: placedAt.add(const Duration(minutes: 40)),
        ),
      );
    }
    if (status.index >= OrderStatus.delivered.index) {
      events.add(
        OrderTimelineEvent(
          status: OrderStatus.delivered,
          label: 'Delivered to customer',
          at: placedAt.add(const Duration(minutes: 70)),
        ),
      );
    }

    return events;
  }

  static double _mealScore(Meal meal, DemoCustomer customer, MealSlot slot) {
    final reorderAffinity = meal.reorderCount / 300;
    final rating = meal.rating / 5;
    final cityPopularity = meal.reorderCount / 350;
    final slotFit = customer.preferredSlots.contains(slot) ? 1.0 : 0.4;
    final offerBoost = meal.offerTag == null ? 0.0 : 1.0;
    final etaPenalty = meal.etaMinutes / 60;

    return (0.30 * reorderAffinity) +
        (0.20 * rating) +
        (0.15 * cityPopularity) +
        (0.15 * slotFit) +
        (0.10 * offerBoost) -
        (0.10 * etaPenalty);
  }

  static Meal _withFoodPlaceMeta(Meal meal) {
    final place = foodPlaceForMeal(meal.id);
    if (place == null) return meal;
    return meal.copyWith(
      placeId: place.id,
      placeName: place.name,
      customisable: place.acceptsCustomisations,
    );
  }

  static double _relevanceScore(Meal meal, String query) {
    if (query.isEmpty) {
      return (meal.rating * 2) + meal.reorderCount / 100;
    }

    var score = 0.0;
    if (meal.name.toLowerCase().contains(query)) score += 2.0;
    if (meal.tags.any((tag) => tag.toLowerCase().contains(query))) score += 1.5;
    score += meal.rating / 2;
    score += meal.reorderCount / 200;
    return score;
  }

  static String _slotLabel(MealSlot slot) {
    return switch (slot) {
      MealSlot.breakfast => 'Breakfast',
      MealSlot.lunch => 'Lunch',
      MealSlot.dinner => 'Dinner',
    };
  }
}
