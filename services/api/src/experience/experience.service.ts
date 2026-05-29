import { Injectable, NotFoundException } from '@nestjs/common';

import { InMemoryDb } from '../database/in-memory.db';
import { MealSlot } from '../types/domain.types';

export type FeedSectionType =
  | 'AGAIN_LAST_WEEK'
  | 'MOST_REORDERED'
  | 'RECOMMENDED'
  | 'TRENDING';

export type OfferRuleType =
  | 'FIRST_ORDER'
  | 'STREAK'
  | 'SURGE_SAFE'
  | 'SLOT_BASED'
  | 'CART_VALUE';

export type IssueType =
  | 'MISSING_ITEM'
  | 'LATE_DELIVERY'
  | 'WRONG_ORDER'
  | 'REFUND';

export type IssueStatus = 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'ESCALATED';

export type SortType =
  | 'RELEVANCE'
  | 'RATING'
  | 'ETA'
  | 'PRICE_ASC'
  | 'PRICE_DESC';

export interface CheckoutPreferenceRecord {
  userId: string;
  preferredWindow: string;
  preferredPaymentMode: 'UPI' | 'Card' | 'Cash';
  walletAutoApply: boolean;
  defaultCadence: 'Weekly' | 'Monthly' | 'One-time';
}

export interface AddressRecord {
  id: string;
  userId: string;
  label: string;
  addressLine: string;
  cityId: string;
  zoneId: string;
  serviceable: boolean;
  defaultForSlots: MealSlot[];
  lastUsedAt: string;
}

export interface TrackingSnapshot {
  orderId: string;
  partnerId: string;
  etaMinutes: number;
  route: Array<{ lat: number; lng: number; recordedAt: string }>;
  delay: {
    predictedDelayMinutes: number;
    reason: string;
    confidence: number;
  };
  updatedAt: string;
}

export interface ReviewRecord {
  id: string;
  mealId: string;
  userId: string;
  userName: string;
  rating: number;
  comment: string;
  photos: Array<{ id: string; url: string; status: 'PENDING' | 'APPROVED' | 'REJECTED' }>;
  createdAt: string;
}

export interface OfferRuleRecord {
  id: string;
  type: OfferRuleType;
  title: string;
  description: string;
  cityId: string;
  slot?: MealSlot;
  active: boolean;
  value: number;
  minCartValue: number;
}

export interface SupportThreadRecord {
  id: string;
  userId: string;
  orderId: string;
  messages: Array<{
    id: string;
    sender: string;
    text: string;
    createdAt: string;
  }>;
}

export interface SupportIssueRecord {
  id: string;
  userId: string;
  orderId: string;
  type: IssueType;
  status: IssueStatus;
  description: string;
  createdAt: string;
}

export interface FoodPlaceRecord {
  id: string;
  name: string;
  contactNumber: string;
  type: 'RESTAURANT' | 'DHABA' | 'TIFFIN' | 'CLOUD_KITCHEN';
  cityId: string;
  zoneIds: string[];
  rating: number;
  avgDeliveryMinutes: number;
  imageUrl: string;
  cuisineTags: string[];
  deliveryByRestaurant: boolean;
  deliveryByPorter: boolean;
  acceptsScheduleOrders: boolean;
  acceptsCustomisations: boolean;
  minOrder: number;
}

@Injectable()
export class ExperienceService {
  constructor(private readonly db: InMemoryDb) {}

  private readonly checkoutPrefs = new Map<string, CheckoutPreferenceRecord>();
  private readonly addresses = new Map<string, AddressRecord[]>();
  private readonly tracking = new Map<string, TrackingSnapshot>();
  private readonly reviews: ReviewRecord[] = [];
  private readonly offerRules: OfferRuleRecord[] = [
    {
      id: 'offer-first-1',
      type: 'FIRST_ORDER',
      title: 'First order ₹100 off',
      description: 'Valid once for new users',
      cityId: 'gurgaon',
      active: true,
      value: 100,
      minCartValue: 299,
    },
    {
      id: 'offer-streak-1',
      type: 'STREAK',
      title: 'Streak reward ₹60 off',
      description: 'For 3-day order streak',
      cityId: 'noida',
      active: true,
      value: 60,
      minCartValue: 200,
    },
    {
      id: 'offer-slot-breakfast',
      type: 'SLOT_BASED',
      title: 'Breakfast saver',
      description: 'Breakfast orders only',
      cityId: 'gurgaon',
      slot: 'BREAKFAST',
      active: true,
      value: 30,
      minCartValue: 120,
    },
  ];
  private readonly supportThreads = new Map<string, SupportThreadRecord[]>();
  private readonly supportIssues = new Map<string, SupportIssueRecord[]>();
  private readonly foodPlaces: FoodPlaceRecord[] = [
    {
      id: 'pl-gurgaon-1',
      name: 'Tandoori Junction',
      contactNumber: '+918800000101',
      type: 'RESTAURANT',
      cityId: 'gurgaon',
      zoneIds: ['z1', 'z2'],
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
    },
    {
      id: 'pl-gurgaon-2',
      name: 'Maa Ka Tiffin',
      contactNumber: '+918800000102',
      type: 'TIFFIN',
      cityId: 'gurgaon',
      zoneIds: ['z1', 'z2'],
      rating: 4.8,
      avgDeliveryMinutes: 24,
      imageUrl:
        'https://images.unsplash.com/photo-1613292443284-8d10ef9383fe?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['Home Style', 'Daily Meal'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 99,
    },
    {
      id: 'pl-noida-1',
      name: 'Noida Bento House',
      contactNumber: '+918800000201',
      type: 'CLOUD_KITCHEN',
      cityId: 'noida',
      zoneIds: ['z3'],
      rating: 4.6,
      avgDeliveryMinutes: 29,
      imageUrl:
        'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=900',
      cuisineTags: ['Bowl Meals', 'High Protein'],
      deliveryByRestaurant: false,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: true,
      minOrder: 180,
    },
    {
      id: 'pl-faridabad-1',
      name: 'Sector 14 Rasoi',
      contactNumber: '+918800000401',
      type: 'DHABA',
      cityId: 'faridabad',
      zoneIds: ['z4'],
      rating: 4.5,
      avgDeliveryMinutes: 27,
      imageUrl:
        'https://images.unsplash.com/photo-1626500155537-93690c24099e?auto=format&fit=crop&w=900&q=80',
      cuisineTags: ['Dhaba Style', 'Thali'],
      deliveryByRestaurant: true,
      deliveryByPorter: true,
      acceptsScheduleOrders: true,
      acceptsCustomisations: false,
      minOrder: 110,
    },
  ];
  private readonly placeMenuMap: Record<string, string[]> = {
    'pl-gurgaon-1': ['m1', 'm2'],
    'pl-gurgaon-2': ['m1', 'm2'],
    'pl-noida-1': ['m3'],
    'pl-faridabad-1': ['m4'],
  };

  listFoodPlaces(input: { cityId: string; zoneId?: string }) {
    return this.foodPlaces.filter((place) => {
      if (place.cityId !== input.cityId) return false;
      if (!input.zoneId) return true;
      return place.zoneIds.includes(input.zoneId);
    });
  }

  listPlaceMenu(placeId: string, slot?: MealSlot) {
    const place = this.foodPlaces.find((entry) => entry.id === placeId);
    if (!place) throw new NotFoundException(`Place ${placeId} not found`);

    const allowedMenuIds = this.placeMenuMap[place.id] ?? [];
    return this.db.menus
      .filter((menu) => allowedMenuIds.includes(menu.id))
      .filter((menu) => (!slot ? true : menu.slot === slot))
      .map((menu) => {
        const meal = this.mapMeal(menu);
        return {
          ...meal,
          placeId: place.id,
          placeName: place.name,
          customisable: place.acceptsCustomisations,
        };
      });
  }

  listPlaceOrders(placeId: string) {
    const place = this.foodPlaces.find((entry) => entry.id === placeId);
    if (!place) throw new NotFoundException(`Place ${placeId} not found`);

    const source = this.db.orders.filter((order) => order.cityId === place.cityId);
    if (source.length > 0) {
      return source.map((order) => ({
        id: order.id,
        customerId: order.userId,
        customerName: `Customer ${order.userId}`,
        cityId: order.cityId,
        zoneId: order.zoneId,
        address: 'Serviceable customer address',
        slot: this.db.menus.find((menu) => menu.cityId === order.cityId)?.slot ?? 'LUNCH',
        deliveryWindow: order.deliveryWindow,
        status: order.status,
        total: order.total,
        placedAt: order.createdAt,
        type: order.type,
        deliveryPartnerId: 'porter',
        subscriptionId: null,
        etaMinutes: 28,
      }));
    }

    return [
      {
        id: `ORD-${place.id}-1001`,
        customerId: 'u1',
        customerName: 'Demo Customer',
        cityId: place.cityId,
        zoneId: place.zoneIds[0] ?? 'z1',
        address: 'Demo customer location',
        slot: 'LUNCH',
        deliveryWindow: '1:00 PM - 1:30 PM',
        status: 'CONFIRMED',
        total: 260,
        placedAt: new Date(Date.now() - 35 * 60 * 1000).toISOString(),
        type: 'ONE_TIME',
        deliveryPartnerId: 'porter',
        subscriptionId: null,
        etaMinutes: place.avgDeliveryMinutes,
      },
      {
        id: `ORD-${place.id}-1002`,
        customerId: 'u1',
        customerName: 'Demo Customer',
        cityId: place.cityId,
        zoneId: place.zoneIds[0] ?? 'z1',
        address: 'Demo office location',
        slot: 'DINNER',
        deliveryWindow: '8:00 PM - 8:30 PM',
        status: 'OUT_FOR_DELIVERY',
        total: 340,
        placedAt: new Date(Date.now() - 90 * 60 * 1000).toISOString(),
        type: 'ONE_TIME',
        deliveryPartnerId: 'restaurant-fleet',
        subscriptionId: null,
        etaMinutes: place.avgDeliveryMinutes + 4,
      },
    ];
  }

  getPersonalizedFeed(input: {
    userId: string;
    cityId: string;
    slot: MealSlot;
    limit: number;
  }) {
    const meals = this.db.menus
      .filter((menu) => menu.cityId === input.cityId && menu.slot === input.slot)
      .map((menu) => this.mapMeal(menu));

    const sortedByReorder = [...meals].sort(
      (a, b) => b.reorderCount - a.reorderCount,
    );
    const sortedByRating = [...meals].sort((a, b) => b.rating - a.rating);

    const sections: Array<{
      type: FeedSectionType;
      title: string;
      subtitle: string;
      meals: ReturnType<ExperienceService['mapMeal']>[];
    }> = [
      {
        type: 'AGAIN_LAST_WEEK',
        title: 'Again from last week',
        subtitle: 'Quick reorder choices from your history',
        meals: this.getReorderSuggestions({ userId: input.userId, cityId: input.cityId }).slice(
          0,
          input.limit,
        ),
      },
      {
        type: 'MOST_REORDERED',
        title: 'Most reordered in your area',
        subtitle: 'Popular choices in your zone',
        meals: sortedByReorder.slice(0, input.limit),
      },
      {
        type: 'RECOMMENDED',
        title: 'Recommended for you',
        subtitle: 'Personalized ranker',
        meals: this.rankMeals(meals, input.slot).slice(0, input.limit),
      },
      {
        type: 'TRENDING',
        title: 'Trending now',
        subtitle: 'High rating + active offers',
        meals: sortedByRating.slice(0, input.limit),
      },
    ];

    return sections;
  }

  getReorderSuggestions(input: { userId: string; cityId?: string; window?: string }) {
    const userOrders = this.db.orders.filter((order) => order.userId === input.userId);
    const mealCounts = new Map<string, number>();

    for (const order of userOrders) {
      const mealId = this.db.menus.find((menu) => menu.cityId === order.cityId)?.id;
      if (!mealId) continue;
      mealCounts.set(mealId, (mealCounts.get(mealId) ?? 0) + 1);
    }

    const sortedMealIds = [...mealCounts.entries()].sort((a, b) => b[1] - a[1]);

    if (sortedMealIds.length === 0) {
      return this.db.menus
        .filter((menu) => !input.cityId || menu.cityId === input.cityId)
        .map((menu) => this.mapMeal(menu))
        .slice(0, 4);
    }

    return sortedMealIds
      .map(([mealId]) => this.db.menus.find((menu) => menu.id === mealId))
      .filter((menu): menu is NonNullable<typeof menu> => Boolean(menu))
      .map((menu) => this.mapMeal(menu));
  }

  reorderOrder(orderId: string, userId: string) {
    const source = this.db.orders.find((order) => order.id === orderId);
    if (!source) {
      throw new NotFoundException(`Order ${orderId} not found`);
    }

    const nextOrder = {
      id: this.db.nextOrderId(),
      userId,
      type: source.type,
      status: 'CREATED' as const,
      total: source.total,
      cityId: source.cityId,
      zoneId: source.zoneId,
      deliveryWindow: source.deliveryWindow,
      createdAt: new Date().toISOString(),
    };

    this.db.orders.push(nextOrder);
    this.db.orderStatusHistory.push({
      id: this.db.nextTimelineId(),
      orderId: nextOrder.id,
      status: 'CREATED',
      createdAt: nextOrder.createdAt,
    });

    return nextOrder;
  }

  searchMeals(input: {
    cityId: string;
    slot: MealSlot;
    q: string;
    diet?: string;
    caloriesMin?: number;
    caloriesMax?: number;
    prepMin?: number;
    prepMax?: number;
    priceMin?: number;
    priceMax?: number;
    offersOnly?: boolean;
    ratingMin?: number;
    sort?: SortType;
  }) {
    const query = input.q.trim().toLowerCase();

    let results = this.db.menus
      .filter((menu) => menu.cityId === input.cityId && menu.slot === input.slot)
      .map((menu) => this.mapMeal(menu))
      .filter((meal) => {
        if (query.length > 0 && !meal.name.toLowerCase().includes(query)) {
          return false;
        }

        if ((input.caloriesMin ?? 0) > meal.calories) return false;
        if ((input.caloriesMax ?? 2000) < meal.calories) return false;
        if ((input.prepMin ?? 0) > meal.prepTimeMin) return false;
        if ((input.prepMax ?? 180) < meal.prepTimeMin) return false;
        if ((input.priceMin ?? 0) > meal.price) return false;
        if ((input.priceMax ?? 9999) < meal.price) return false;
        if ((input.ratingMin ?? 0) > meal.rating) return false;
        if (input.offersOnly && !meal.offerTag) return false;

        if (input.diet && input.diet.toUpperCase() !== 'ALL') {
          const normalized = input.diet.toLowerCase();
          const hasDiet = meal.tags.some((tag) => tag.toLowerCase().includes(normalized));
          if (!hasDiet) return false;
        }

        return true;
      });

    switch (input.sort) {
      case 'RATING':
        results = [...results].sort((a, b) => b.rating - a.rating);
        break;
      case 'ETA':
        results = [...results].sort((a, b) => a.etaMinutes - b.etaMinutes);
        break;
      case 'PRICE_ASC':
        results = [...results].sort((a, b) => a.price - b.price);
        break;
      case 'PRICE_DESC':
        results = [...results].sort((a, b) => b.price - a.price);
        break;
      default:
        results = [...results].sort((a, b) => b.score - a.score);
    }

    return results;
  }

  getSmartDefaultAddress(input: { userId: string; slot: MealSlot; day: string }) {
    this.ensureAddressSeed(input.userId);
    const addresses = this.addresses.get(input.userId) ?? [];

    const slotAddress = addresses.find((address) =>
      address.defaultForSlots.includes(input.slot),
    );

    if (slotAddress) return slotAddress;
    if (input.day.toLowerCase().includes('sun')) return addresses[addresses.length - 1] ?? null;
    return addresses[0] ?? null;
  }

  listAddresses(userId: string) {
    this.ensureAddressSeed(userId);
    return this.addresses.get(userId) ?? [];
  }

  getCheckoutPreferences(userId: string) {
    this.ensureCheckoutSeed(userId);
    return this.checkoutPrefs.get(userId);
  }

  setCheckoutPreferences(
    userId: string,
    payload: Partial<CheckoutPreferenceRecord>,
  ) {
    this.ensureCheckoutSeed(userId);
    const current = this.checkoutPrefs.get(userId)!;
    const updated: CheckoutPreferenceRecord = {
      ...current,
      ...payload,
      userId,
    };

    this.checkoutPrefs.set(userId, updated);
    return updated;
  }

  getLiveTracking(orderId: string) {
    if (!this.tracking.has(orderId)) {
      this.tracking.set(orderId, this.seedTracking(orderId));
    }

    return this.tracking.get(orderId)!;
  }

  getEta(orderId: string) {
    const tracking = this.getLiveTracking(orderId);
    return tracking.delay;
  }

  reportDelay(orderId: string, reason: string) {
    const tracking = this.getLiveTracking(orderId);
    const updated: TrackingSnapshot = {
      ...tracking,
      etaMinutes: tracking.etaMinutes + 7,
      delay: {
        predictedDelayMinutes: tracking.delay.predictedDelayMinutes + 7,
        reason,
        confidence: 0.84,
      },
      updatedAt: new Date().toISOString(),
    };

    this.tracking.set(orderId, updated);
    return updated;
  }

  locationPing(input: {
    orderId: string;
    partnerId: string;
    lat: number;
    lng: number;
  }) {
    const current = this.getLiveTracking(input.orderId);
    const point = {
      lat: input.lat,
      lng: input.lng,
      recordedAt: new Date().toISOString(),
    };

    const updated: TrackingSnapshot = {
      ...current,
      partnerId: input.partnerId,
      route: [...current.route, point].slice(-12),
      updatedAt: new Date().toISOString(),
    };

    this.tracking.set(input.orderId, updated);
    return updated;
  }

  createReview(input: {
    mealId: string;
    userId: string;
    userName: string;
    rating: number;
    comment: string;
  }) {
    const review: ReviewRecord = {
      id: `rev-${Date.now()}`,
      mealId: input.mealId,
      userId: input.userId,
      userName: input.userName,
      rating: input.rating,
      comment: input.comment,
      photos: [],
      createdAt: new Date().toISOString(),
    };

    this.reviews.unshift(review);
    return review;
  }

  addReviewPhoto(reviewId: string, photoUrl: string) {
    const review = this.reviews.find((entry) => entry.id === reviewId);
    if (!review) {
      throw new NotFoundException(`Review ${reviewId} not found`);
    }

    const photo = {
      id: `media-${Date.now()}`,
      url: photoUrl,
      status: 'PENDING' as const,
    };
    review.photos.push(photo);
    return photo;
  }

  getMealReviews(mealId: string) {
    return this.reviews.filter((review) => review.mealId === mealId);
  }

  reportReview(reviewId: string, reason: string) {
    return {
      reviewId,
      reason,
      accepted: true,
      createdAt: new Date().toISOString(),
    };
  }

  getMealBadges(mealId: string) {
    const reviews = this.getMealReviews(mealId);
    const badges: string[] = [];

    if (reviews.length >= 3) badges.push('Most reordered');
    if (reviews.some((review) => review.rating >= 4)) badges.push('Top rated');

    return badges;
  }

  evaluateOffers(input: {
    userId: string;
    cityId: string;
    slot: MealSlot;
    cartTotal: number;
    isFirstOrder: boolean;
    streakDays: number;
  }) {
    const applicable = this.getActiveOffers(input.cityId, input.slot);
    const appliedOfferIds: string[] = [];
    const messages: string[] = [];
    let discount = 0;

    for (const offer of applicable) {
      if (input.cartTotal < offer.minCartValue) continue;

      let eligible = true;
      if (offer.type === 'FIRST_ORDER') eligible = input.isFirstOrder;
      if (offer.type === 'STREAK') eligible = input.streakDays >= 3;

      if (!eligible) continue;
      appliedOfferIds.push(offer.id);
      discount += offer.value;
      messages.push(`${offer.title} applied`);
    }

    const cap = Math.round(input.cartTotal * 0.35);
    if (discount > cap) {
      discount = cap;
      messages.push('Discount capped to 35% cart value');
    }

    return {
      appliedOfferIds,
      discount,
      finalPayable: Math.max(0, input.cartTotal - discount),
      messages,
    };
  }

  applyOffers(input: {
    userId: string;
    cityId: string;
    slot: MealSlot;
    cartTotal: number;
    offerIds: string[];
  }) {
    const active = this.getActiveOffers(input.cityId, input.slot)
      .filter((rule) => input.offerIds.includes(rule.id));

    const discount = active.reduce((sum, rule) => sum + rule.value, 0);
    return {
      appliedOfferIds: active.map((rule) => rule.id),
      discount,
      finalPayable: Math.max(0, input.cartTotal - discount),
    };
  }

  getActiveOffers(cityId: string, slot: MealSlot) {
    return this.offerRules.filter((rule) => {
      if (!rule.active || rule.cityId !== cityId) return false;
      if (!rule.slot) return true;
      return rule.slot === slot;
    });
  }

  listOfferRules() {
    return this.offerRules;
  }

  createOfferRule(payload: Omit<OfferRuleRecord, 'id'>) {
    const next: OfferRuleRecord = {
      id: `offer-${Date.now()}`,
      ...payload,
    };
    this.offerRules.unshift(next);
    return next;
  }

  updateOfferRule(ruleId: string, payload: Partial<OfferRuleRecord>) {
    const index = this.offerRules.findIndex((rule) => rule.id === ruleId);
    if (index < 0) {
      throw new NotFoundException(`Offer rule ${ruleId} not found`);
    }

    this.offerRules[index] = {
      ...this.offerRules[index],
      ...payload,
      id: ruleId,
    };

    return this.offerRules[index];
  }

  createSupportThread(input: { userId: string; orderId: string }) {
    const thread: SupportThreadRecord = {
      id: `thr-${Date.now()}`,
      userId: input.userId,
      orderId: input.orderId,
      messages: [],
    };

    const existing = this.supportThreads.get(input.userId) ?? [];
    this.supportThreads.set(input.userId, [thread, ...existing]);
    return thread;
  }

  listSupportThreads(userId: string) {
    return this.supportThreads.get(userId) ?? [];
  }

  addSupportMessage(
    userId: string,
    threadId: string,
    payload: { sender: string; text: string },
  ) {
    const threads = this.supportThreads.get(userId) ?? [];
    const target = threads.find((thread) => thread.id === threadId);
    if (!target) {
      throw new NotFoundException(`Support thread ${threadId} not found`);
    }

    target.messages.push({
      id: `msg-${Date.now()}`,
      sender: payload.sender,
      text: payload.text,
      createdAt: new Date().toISOString(),
    });

    return target;
  }

  createSupportIssue(input: {
    userId: string;
    orderId: string;
    type: IssueType;
    description: string;
  }) {
    const issue: SupportIssueRecord = {
      id: `iss-${Date.now()}`,
      userId: input.userId,
      orderId: input.orderId,
      type: input.type,
      status: 'OPEN',
      description: input.description,
      createdAt: new Date().toISOString(),
    };

    const existing = this.supportIssues.get(input.userId) ?? [];
    this.supportIssues.set(input.userId, [issue, ...existing]);
    return issue;
  }

  listSupportIssues(userId: string) {
    return this.supportIssues.get(userId) ?? [];
  }

  updateSupportIssue(
    userId: string,
    issueId: string,
    payload: { status: IssueStatus },
  ) {
    const issues = this.supportIssues.get(userId) ?? [];
    const issue = issues.find((entry) => entry.id === issueId);
    if (!issue) {
      throw new NotFoundException(`Support issue ${issueId} not found`);
    }

    issue.status = payload.status;
    return issue;
  }

  createMaskedCallSession(input: { fromNumber: string; toNumber: string }) {
    const suffix = new Date().getMilliseconds().toString().padStart(3, '0');
    return {
      id: `call-${Date.now()}`,
      fromNumber: input.fromNumber,
      toNumber: input.toNumber,
      maskedNumber: `+91888888${suffix}`,
      expiresAt: new Date(Date.now() + 45 * 60 * 1000).toISOString(),
    };
  }

  private mapMeal(menu: InMemoryDb['menus'][number]) {
    const numeric = Number(menu.id.replace(/\D/g, '') || '1');
    const rating = 4 + (numeric % 10) / 10;
    const reorderCount = 100 + numeric * 7;
    const calories = 280 + numeric * 15;
    const prepTimeMin = 15 + (numeric % 20);
    const etaMinutes = 18 + (numeric % 22);

    return {
      id: menu.id,
      name: menu.name,
      cityId: menu.cityId,
      slot: menu.slot,
      price: menu.price,
      rating,
      imageUrl:
        'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80',
      tags: ['veg', 'home-style'],
      available: true,
      calories,
      prepTimeMin,
      etaMinutes,
      reorderCount,
      offerTag: numeric % 3 === 0 ? '₹20 off' : null,
      mostReorderedBadge: reorderCount > 180,
      cuisine: numeric % 2 === 0 ? 'north' : 'home-style',
      score:
        0.30 * (reorderCount / 300) +
        0.20 * (rating / 5) +
        0.15 * (reorderCount / 350) +
        0.15 * 1 +
        0.10 * (numeric % 3 === 0 ? 1 : 0) -
        0.10 * (etaMinutes / 60),
    };
  }

  private rankMeals(meals: ReturnType<ExperienceService['mapMeal']>[], slot: MealSlot) {
    return [...meals].sort((a, b) => {
      const slotBoostA = a.slot === slot ? 0.18 : 0;
      const slotBoostB = b.slot === slot ? 0.18 : 0;
      return b.score + slotBoostB - (a.score + slotBoostA);
    });
  }

  private ensureCheckoutSeed(userId: string) {
    if (this.checkoutPrefs.has(userId)) return;

    this.checkoutPrefs.set(userId, {
      userId,
      preferredWindow: '1:00 PM - 1:30 PM',
      preferredPaymentMode: 'UPI',
      walletAutoApply: true,
      defaultCadence: 'Weekly',
    });
  }

  private ensureAddressSeed(userId: string) {
    if (this.addresses.has(userId)) return;

    this.addresses.set(userId, [
      {
        id: `addr-${userId}-1`,
        userId,
        label: 'Home',
        addressLine: 'DLF Phase 2, Gurugram',
        cityId: 'gurgaon',
        zoneId: 'z1',
        serviceable: true,
        defaultForSlots: ['BREAKFAST', 'DINNER'],
        lastUsedAt: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(),
      },
      {
        id: `addr-${userId}-2`,
        userId,
        label: 'Office',
        addressLine: 'Cyber Hub, Gurugram',
        cityId: 'gurgaon',
        zoneId: 'z2',
        serviceable: true,
        defaultForSlots: ['LUNCH'],
        lastUsedAt: new Date(Date.now() - 60 * 60 * 1000).toISOString(),
      },
    ]);
  }

  private seedTracking(orderId: string): TrackingSnapshot {
    const numeric = Number(orderId.replace(/\D/g, '') || '1');
    const now = new Date();

    const route = [0, 1, 2].map((offset) => ({
      lat: 28.45 + numeric * 0.0001 + offset * 0.0004,
      lng: 77.05 + numeric * 0.0001 + offset * 0.0004,
      recordedAt: new Date(now.getTime() - (2 - offset) * 5 * 60 * 1000).toISOString(),
    }));

    return {
      orderId,
      partnerId: 'dp1',
      etaMinutes: 18 + (numeric % 15),
      route,
      delay: {
        predictedDelayMinutes: numeric % 7,
        reason: numeric % 2 === 0 ? 'Traffic' : 'Kitchen prep lag',
        confidence: 0.78,
      },
      updatedAt: now.toISOString(),
    };
  }
}
