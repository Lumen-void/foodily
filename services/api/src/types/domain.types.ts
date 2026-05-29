export type UserRole = 'CUSTOMER' | 'DELIVERY_PARTNER' | 'ADMIN';
export type MealSlot = 'BREAKFAST' | 'LUNCH' | 'DINNER';
export type OrderType = 'ONE_TIME' | 'SUBSCRIPTION';
export type OrderStatus =
  | 'CREATED'
  | 'CONFIRMED'
  | 'PREPARING'
  | 'OUT_FOR_DELIVERY'
  | 'DELIVERED'
  | 'CANCELLED';
export type SubscriptionStatus = 'ACTIVE' | 'PAUSED' | 'CANCELLED' | 'EXPIRED';
export type PaymentStatus =
  | 'INITIATED'
  | 'AUTHORIZED'
  | 'CAPTURED'
  | 'FAILED'
  | 'REFUNDED';
export type WalletTxnType = 'REFERRAL_CREDIT' | 'ORDER_DEBIT' | 'ADJUSTMENT';
