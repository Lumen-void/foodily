import 'enums.dart';

class City {
  const City({required this.id, required this.name});

  final String id;
  final String name;
}

class Zone {
  const Zone({required this.id, required this.cityId, required this.name});

  final String id;
  final String cityId;
  final String name;
}

class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.slot,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.cityId,
    this.tags = const [],
    this.available = true,
    this.calories = 0,
    this.prepTimeMin = 0,
    this.etaMinutes = 35,
    this.reorderCount = 0,
    this.cuisine = 'home-style',
    this.mostReorderedBadge = false,
    this.offerTag,
    this.placeId = '',
    this.placeName = '',
    this.customisable = false,
  });

  final String id;
  final String name;
  final MealSlot slot;
  final int price;
  final double rating;
  final String imageUrl;
  final String cityId;
  final List<String> tags;
  final bool available;
  final int calories;
  final int prepTimeMin;
  final int etaMinutes;
  final int reorderCount;
  final String cuisine;
  final bool mostReorderedBadge;
  final String? offerTag;
  final String placeId;
  final String placeName;
  final bool customisable;

  Meal copyWith({
    String? id,
    String? name,
    MealSlot? slot,
    int? price,
    double? rating,
    String? imageUrl,
    String? cityId,
    List<String>? tags,
    bool? available,
    int? calories,
    int? prepTimeMin,
    int? etaMinutes,
    int? reorderCount,
    String? cuisine,
    bool? mostReorderedBadge,
    String? offerTag,
    String? placeId,
    String? placeName,
    bool? customisable,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      cityId: cityId ?? this.cityId,
      tags: tags ?? this.tags,
      available: available ?? this.available,
      calories: calories ?? this.calories,
      prepTimeMin: prepTimeMin ?? this.prepTimeMin,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      reorderCount: reorderCount ?? this.reorderCount,
      cuisine: cuisine ?? this.cuisine,
      mostReorderedBadge: mostReorderedBadge ?? this.mostReorderedBadge,
      offerTag: offerTag ?? this.offerTag,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      customisable: customisable ?? this.customisable,
    );
  }
}

class FoodPlace {
  const FoodPlace({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.type,
    required this.cityId,
    required this.zoneIds,
    required this.rating,
    required this.avgDeliveryMinutes,
    required this.imageUrl,
    required this.cuisineTags,
    required this.deliveryByRestaurant,
    required this.deliveryByPorter,
    required this.acceptsScheduleOrders,
    required this.acceptsCustomisations,
    this.minOrder = 0,
  });

  final String id;
  final String name;
  final String contactNumber;
  final FoodPlaceType type;
  final String cityId;
  final List<String> zoneIds;
  final double rating;
  final int avgDeliveryMinutes;
  final String imageUrl;
  final List<String> cuisineTags;
  final bool deliveryByRestaurant;
  final bool deliveryByPorter;
  final bool acceptsScheduleOrders;
  final bool acceptsCustomisations;
  final int minOrder;
}

class CartItem {
  const CartItem({required this.meal, this.qty = 1});

  final Meal meal;
  final int qty;

  int get total => meal.price * qty;
}

class DemoCustomer {
  const DemoCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.cityId,
    required this.zoneId,
    required this.primaryAddress,
    this.tier = 'Silver',
    this.totalOrders = 0,
    this.referralCode = '',
    this.preferredSlots = const [MealSlot.lunch],
    this.preferredCuisines = const ['home-style'],
    this.preferredPriceBand = 'mid',
  });

  final String id;
  final String name;
  final String phone;
  final String cityId;
  final String zoneId;
  final String primaryAddress;
  final String tier;
  final int totalOrders;
  final String referralCode;
  final List<MealSlot> preferredSlots;
  final List<String> preferredCuisines;
  final String preferredPriceBand;
}

class DeliveryPartnerProfile {
  const DeliveryPartnerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.cityId,
    required this.vehicleType,
    this.rating = 4.6,
    this.active = true,
    this.lastKnownLat = 0,
    this.lastKnownLng = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String cityId;
  final String vehicleType;
  final double rating;
  final bool active;
  final double lastKnownLat;
  final double lastKnownLng;
}

class OrderLineItem {
  const OrderLineItem({
    required this.mealId,
    required this.mealName,
    required this.qty,
    required this.unitPrice,
    this.imageUrl,
  });

  final String mealId;
  final String mealName;
  final int qty;
  final int unitPrice;
  final String? imageUrl;
}

class OrderTimelineEvent {
  const OrderTimelineEvent({
    required this.status,
    required this.label,
    required this.at,
    this.note,
  });

  final OrderStatus status;
  final String label;
  final DateTime at;
  final String? note;
}

class DemoOrder {
  const DemoOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.cityId,
    required this.zoneId,
    required this.address,
    required this.slot,
    required this.deliveryWindow,
    required this.status,
    required this.total,
    required this.placedAt,
    required this.lineItems,
    required this.timeline,
    this.type = OrderType.oneTime,
    this.deliveryPartnerId,
    this.subscriptionId,
    this.etaMinutes = 35,
    this.delayReason,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String cityId;
  final String zoneId;
  final String address;
  final MealSlot slot;
  final String deliveryWindow;
  final OrderStatus status;
  final int total;
  final DateTime placedAt;
  final List<OrderLineItem> lineItems;
  final List<OrderTimelineEvent> timeline;
  final OrderType type;
  final String? deliveryPartnerId;
  final String? subscriptionId;
  final int etaMinutes;
  final String? delayReason;
}

class DeliveryJob {
  const DeliveryJob({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.address,
    required this.slotLabel,
    this.status = OrderStatus.outForDelivery,
    this.etaMinutes = 35,
    this.riderLat = 0,
    this.riderLng = 0,
  });

  final String id;
  final String orderId;
  final String customerName;
  final String address;
  final String slotLabel;
  final OrderStatus status;
  final int etaMinutes;
  final double riderLat;
  final double riderLng;
}

class WalletLedgerItem {
  const WalletLedgerItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final WalletTxnType type;
  final int amount;
  final String description;
  final DateTime createdAt;
}

class SearchFilters {
  const SearchFilters({
    this.diet = 'All',
    this.caloriesMin = 0,
    this.caloriesMax = 1500,
    this.prepMin = 0,
    this.prepMax = 120,
    this.priceMin = 0,
    this.priceMax = 1000,
    this.offersOnly = false,
    this.ratingMin = 0,
    this.sort = SearchSort.relevance,
  });

  final String diet;
  final int caloriesMin;
  final int caloriesMax;
  final int prepMin;
  final int prepMax;
  final int priceMin;
  final int priceMax;
  final bool offersOnly;
  final double ratingMin;
  final SearchSort sort;

  SearchFilters copyWith({
    String? diet,
    int? caloriesMin,
    int? caloriesMax,
    int? prepMin,
    int? prepMax,
    int? priceMin,
    int? priceMax,
    bool? offersOnly,
    double? ratingMin,
    SearchSort? sort,
  }) {
    return SearchFilters(
      diet: diet ?? this.diet,
      caloriesMin: caloriesMin ?? this.caloriesMin,
      caloriesMax: caloriesMax ?? this.caloriesMax,
      prepMin: prepMin ?? this.prepMin,
      prepMax: prepMax ?? this.prepMax,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      offersOnly: offersOnly ?? this.offersOnly,
      ratingMin: ratingMin ?? this.ratingMin,
      sort: sort ?? this.sort,
    );
  }
}

class AddressOption {
  const AddressOption({
    required this.id,
    required this.customerId,
    required this.label,
    required this.addressLine,
    required this.cityId,
    required this.zoneId,
    required this.serviceable,
    this.defaultForSlots = const [],
    this.lastUsedAt,
  });

  final String id;
  final String customerId;
  final String label;
  final String addressLine;
  final String cityId;
  final String zoneId;
  final bool serviceable;
  final List<MealSlot> defaultForSlots;
  final DateTime? lastUsedAt;
}

class CheckoutPreferences {
  const CheckoutPreferences({
    required this.customerId,
    required this.preferredWindow,
    required this.preferredPaymentMode,
    required this.walletAutoApply,
    required this.defaultCadence,
  });

  final String customerId;
  final String preferredWindow;
  final String preferredPaymentMode;
  final bool walletAutoApply;
  final String defaultCadence;

  CheckoutPreferences copyWith({
    String? preferredWindow,
    String? preferredPaymentMode,
    bool? walletAutoApply,
    String? defaultCadence,
  }) {
    return CheckoutPreferences(
      customerId: customerId,
      preferredWindow: preferredWindow ?? this.preferredWindow,
      preferredPaymentMode: preferredPaymentMode ?? this.preferredPaymentMode,
      walletAutoApply: walletAutoApply ?? this.walletAutoApply,
      defaultCadence: defaultCadence ?? this.defaultCadence,
    );
  }
}

class PersonalizedFeedSection {
  const PersonalizedFeedSection({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.meals,
  });

  final FeedSectionType type;
  final String title;
  final String subtitle;
  final List<Meal> meals;
}

class RiderLocation {
  const RiderLocation({
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });

  final double lat;
  final double lng;
  final DateTime recordedAt;
}

class DelayPrediction {
  const DelayPrediction({
    required this.predictedDelayMinutes,
    required this.reason,
    required this.confidence,
  });

  final int predictedDelayMinutes;
  final String reason;
  final double confidence;
}

class LiveTrackingSnapshot {
  const LiveTrackingSnapshot({
    required this.orderId,
    required this.partnerId,
    required this.etaMinutes,
    required this.rider,
    required this.route,
    required this.delay,
    required this.updatedAt,
  });

  final String orderId;
  final String partnerId;
  final int etaMinutes;
  final RiderLocation rider;
  final List<RiderLocation> route;
  final DelayPrediction delay;
  final DateTime updatedAt;
}

class ReviewPhoto {
  const ReviewPhoto({
    required this.id,
    required this.url,
    this.status = ModerationStatus.pending,
  });

  final String id;
  final String url;
  final ModerationStatus status;
}

class MealReview {
  const MealReview({
    required this.id,
    required this.mealId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.photos = const [],
  });

  final String id;
  final String mealId;
  final String customerId;
  final String customerName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final List<ReviewPhoto> photos;
}

class OfferRule {
  const OfferRule({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.cityId,
    required this.active,
    required this.value,
    this.minCartValue = 0,
  });

  final String id;
  final OfferRuleType type;
  final String title;
  final String description;
  final String cityId;
  final bool active;
  final int value;
  final int minCartValue;
}

class OfferEvaluation {
  const OfferEvaluation({
    required this.appliedOfferIds,
    required this.discount,
    required this.finalPayable,
    required this.messages,
  });

  final List<String> appliedOfferIds;
  final int discount;
  final int finalPayable;
  final List<String> messages;
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String sender;
  final String text;
  final DateTime createdAt;
}

class SupportThread {
  const SupportThread({
    required this.id,
    required this.customerId,
    required this.orderId,
    required this.messages,
  });

  final String id;
  final String customerId;
  final String orderId;
  final List<SupportMessage> messages;
}

class SupportIssue {
  const SupportIssue({
    required this.id,
    required this.customerId,
    required this.orderId,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final String orderId;
  final IssueType type;
  final IssueStatus status;
  final String description;
  final DateTime createdAt;
}

class MaskedCallSession {
  const MaskedCallSession({
    required this.id,
    required this.fromNumber,
    required this.toNumber,
    required this.maskedNumber,
    required this.expiresAt,
  });

  final String id;
  final String fromNumber;
  final String toNumber;
  final String maskedNumber;
  final DateTime expiresAt;
}

class DataHealthSnapshot {
  const DataHealthSnapshot({
    required this.meals,
    required this.orders,
    required this.partners,
  });

  final int meals;
  final int orders;
  final int partners;
}
