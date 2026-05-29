enum UserRole { customer, deliveryPartner, admin }

enum MealSlot { breakfast, lunch, dinner }

enum OrderType { oneTime, subscription }

enum OrderStatus {
  created,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

enum SubscriptionStatus { active, paused, cancelled, expired }

enum PaymentStatus { initiated, authorized, captured, failed, refunded }

enum WalletTxnType { referralCredit, orderDebit, adjustment }

enum FeedSectionType { againLastWeek, mostReordered, recommended, trending }

enum SearchSort { relevance, rating, eta, priceAsc, priceDesc }

enum IssueType { missingItem, lateDelivery, wrongOrder, refund }

enum IssueStatus { open, inProgress, resolved, escalated }

enum ModerationStatus { pending, approved, rejected }

enum OfferRuleType { firstOrder, streak, surgeSafe, slotBased, cartValue }

enum FoodPlaceType { restaurant, dhaba, tiffin, cloudKitchen }

enum DeliveryProviderOption { restaurantFleet, porter, customerPickup }
