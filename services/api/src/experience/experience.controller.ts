import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';

import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { RolesEnum } from '../common/enums/roles.enum';
import { RequestUser } from '../common/interfaces/request-user.interface';
import { MealSlot } from '../types/domain.types';
import { ExperienceService } from './experience.service';

@Controller()
export class ExperienceController {
  constructor(private readonly service: ExperienceService) {}

  @Get('feed/personalized')
  personalizedFeed(
    @CurrentUser() user: RequestUser,
    @Query('cityId') cityId: string,
    @Query('slot') slot = 'BREAKFAST',
    @Query('limit') limit = '6',
  ) {
    return this.service.getPersonalizedFeed({
      userId: user.id,
      cityId,
      slot: this.parseSlot(slot),
      limit: Number(limit) || 6,
    });
  }

  @Get('search/meals')
  searchMeals(
    @Query('cityId') cityId: string,
    @Query('slot') slot = 'BREAKFAST',
    @Query('q') q = '',
    @Query('diet') diet?: string,
    @Query('caloriesMin') caloriesMin?: string,
    @Query('caloriesMax') caloriesMax?: string,
    @Query('prepMin') prepMin?: string,
    @Query('prepMax') prepMax?: string,
    @Query('priceMin') priceMin?: string,
    @Query('priceMax') priceMax?: string,
    @Query('offersOnly') offersOnly?: string,
    @Query('ratingMin') ratingMin?: string,
    @Query('sort') sort?: 'RELEVANCE' | 'RATING' | 'ETA' | 'PRICE_ASC' | 'PRICE_DESC',
  ) {
    return this.service.searchMeals({
      cityId,
      slot: this.parseSlot(slot),
      q,
      diet,
      caloriesMin: Number(caloriesMin) || 0,
      caloriesMax: Number(caloriesMax) || 2000,
      prepMin: Number(prepMin) || 0,
      prepMax: Number(prepMax) || 180,
      priceMin: Number(priceMin) || 0,
      priceMax: Number(priceMax) || 9999,
      offersOnly: offersOnly === 'true',
      ratingMin: Number(ratingMin) || 0,
      sort,
    });
  }

  @Get('places')
  listPlaces(
    @Query('cityId') cityId: string,
    @Query('zoneId') zoneId?: string,
  ) {
    return this.service.listFoodPlaces({ cityId, zoneId });
  }

  @Get('partner/places/:id/menu')
  listPlaceMenu(
    @Param('id') id: string,
    @Query('slot') slot?: string,
  ) {
    return this.service.listPlaceMenu(id, slot ? this.parseSlot(slot) : undefined);
  }

  @Get('partner/places/:id/orders')
  listPlaceOrders(@Param('id') id: string) {
    return this.service.listPlaceOrders(id);
  }

  @Get('addresses/smart-default')
  smartDefaultAddress(
    @CurrentUser() user: RequestUser,
    @Query('slot') slot = 'BREAKFAST',
    @Query('day') day = 'Monday',
  ) {
    return this.service.getSmartDefaultAddress({
      userId: user.id,
      slot: this.parseSlot(slot),
      day,
    });
  }

  @Get('addresses')
  listAddresses(@CurrentUser() user: RequestUser) {
    return this.service.listAddresses(user.id);
  }

  @Get('checkout/preferences')
  getCheckoutPreferences(@CurrentUser() user: RequestUser) {
    return this.service.getCheckoutPreferences(user.id);
  }

  @Post('checkout/preferences')
  setCheckoutPreferences(
    @CurrentUser() user: RequestUser,
    @Body()
    payload: {
      preferredWindow?: string;
      preferredPaymentMode?: 'UPI' | 'Card' | 'Cash';
      walletAutoApply?: boolean;
      defaultCadence?: 'Weekly' | 'Monthly' | 'One-time';
    },
  ) {
    return this.service.setCheckoutPreferences(user.id, payload);
  }

  @Post('reviews')
  createReview(
    @CurrentUser() user: RequestUser,
    @Body() payload: { mealId: string; rating: number; comment: string },
  ) {
    return this.service.createReview({
      mealId: payload.mealId,
      rating: payload.rating,
      comment: payload.comment,
      userId: user.id,
      userName: `Customer ${user.id}`,
    });
  }

  @Post('reviews/:id/photos')
  addReviewPhoto(@Param('id') id: string, @Body() payload: { url: string }) {
    return this.service.addReviewPhoto(id, payload.url);
  }

  @Get('meals/:id/reviews')
  mealReviews(@Param('id') id: string) {
    return this.service.getMealReviews(id);
  }

  @Post('reviews/:id/report')
  reportReview(@Param('id') id: string, @Body() payload: { reason: string }) {
    return this.service.reportReview(id, payload.reason);
  }

  @Get('meals/:id/badges')
  mealBadges(@Param('id') id: string) {
    return {
      mealId: id,
      badges: this.service.getMealBadges(id),
    };
  }

  @Post('offers/evaluate')
  evaluateOffers(
    @CurrentUser() user: RequestUser,
    @Body()
    payload: {
      cityId: string;
      slot?: string;
      cartTotal: number;
      isFirstOrder?: boolean;
      streakDays?: number;
    },
  ) {
    return this.service.evaluateOffers({
      userId: user.id,
      cityId: payload.cityId,
      slot: this.parseSlot(payload.slot ?? 'BREAKFAST'),
      cartTotal: payload.cartTotal,
      isFirstOrder: payload.isFirstOrder ?? false,
      streakDays: payload.streakDays ?? 0,
    });
  }

  @Post('offers/apply')
  applyOffers(
    @CurrentUser() user: RequestUser,
    @Body()
    payload: {
      cityId: string;
      slot?: string;
      cartTotal: number;
      offerIds: string[];
    },
  ) {
    return this.service.applyOffers({
      userId: user.id,
      cityId: payload.cityId,
      slot: this.parseSlot(payload.slot ?? 'BREAKFAST'),
      cartTotal: payload.cartTotal,
      offerIds: payload.offerIds,
    });
  }

  @Get('offers/active')
  activeOffers(@Query('cityId') cityId: string, @Query('slot') slot = 'BREAKFAST') {
    return this.service.getActiveOffers(cityId, this.parseSlot(slot));
  }

  @Post('support/threads')
  createSupportThread(
    @CurrentUser() user: RequestUser,
    @Body() payload: { orderId: string },
  ) {
    return this.service.createSupportThread({ userId: user.id, orderId: payload.orderId });
  }

  @Get('support/threads')
  supportThreads(@CurrentUser() user: RequestUser) {
    return this.service.listSupportThreads(user.id);
  }

  @Post('support/threads/:id/messages')
  addSupportMessage(
    @CurrentUser() user: RequestUser,
    @Param('id') id: string,
    @Body() payload: { sender: string; text: string },
  ) {
    return this.service.addSupportMessage(user.id, id, payload);
  }

  @Post('support/issues')
  createSupportIssue(
    @CurrentUser() user: RequestUser,
    @Body() payload: { orderId: string; type: 'MISSING_ITEM' | 'LATE_DELIVERY' | 'WRONG_ORDER' | 'REFUND'; description: string },
  ) {
    return this.service.createSupportIssue({
      userId: user.id,
      orderId: payload.orderId,
      type: payload.type,
      description: payload.description,
    });
  }

  @Get('support/issues')
  supportIssues(@CurrentUser() user: RequestUser) {
    return this.service.listSupportIssues(user.id);
  }

  @Patch('support/issues/:id')
  updateSupportIssue(
    @CurrentUser() user: RequestUser,
    @Param('id') id: string,
    @Body() payload: { status: 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'ESCALATED' },
  ) {
    return this.service.updateSupportIssue(user.id, id, payload);
  }

  @Post('calls/masked/session')
  createMaskedCallSession(
    @Body() payload: { fromNumber: string; toNumber: string },
  ) {
    return this.service.createMaskedCallSession(payload);
  }

  private parseSlot(raw: string): MealSlot {
    const normalized = raw.toUpperCase();
    if (normalized === 'LUNCH') return 'LUNCH';
    if (normalized === 'DINNER') return 'DINNER';
    return 'BREAKFAST';
  }
}

@Controller('admin/offers')
@Roles(RolesEnum.ADMIN)
export class ExperienceAdminController {
  constructor(private readonly service: ExperienceService) {}

  @Get('rules')
  listRules() {
    return this.service.listOfferRules();
  }

  @Post('rules')
  createRule(
    @Body()
    payload: {
      type: 'FIRST_ORDER' | 'STREAK' | 'SURGE_SAFE' | 'SLOT_BASED' | 'CART_VALUE';
      title: string;
      description: string;
      cityId: string;
      slot?: MealSlot;
      active: boolean;
      value: number;
      minCartValue: number;
    },
  ) {
    return this.service.createOfferRule(payload);
  }

  @Patch('rules/:id')
  updateRule(
    @Param('id') id: string,
    @Body()
    payload: {
      type?: 'FIRST_ORDER' | 'STREAK' | 'SURGE_SAFE' | 'SLOT_BASED' | 'CART_VALUE';
      title?: string;
      description?: string;
      cityId?: string;
      slot?: MealSlot;
      active?: boolean;
      value?: number;
      minCartValue?: number;
    },
  ) {
    return this.service.updateOfferRule(id, payload);
  }
}
