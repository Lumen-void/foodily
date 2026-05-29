import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';

import { AdminModule } from './admin/admin.module';
import { AuthModule } from './auth/auth.module';
import { CartModule } from './cart/cart.module';
import { DatabaseModule } from './database/database.module';
import { DeliveryModule } from './delivery/delivery.module';
import { ExperienceModule } from './experience/experience.module';
import { LocationsModule } from './locations/locations.module';
import { MenusModule } from './menus/menus.module';
import { OrdersModule } from './orders/orders.module';
import { PaymentsModule } from './payments/payments.module';
import { ReferralsModule } from './referrals/referrals.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { WalletModule } from './wallet/wallet.module';
import { HealthController } from './health.controller';
import { AuthGuard } from './common/guards/auth.guard';
import { RolesGuard } from './common/guards/roles.guard';

@Module({
  controllers: [HealthController],
  providers: [
    { provide: APP_GUARD, useClass: AuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
  imports: [
    DatabaseModule,
    AuthModule,
    LocationsModule,
    MenusModule,
    CartModule,
    OrdersModule,
    SubscriptionsModule,
    PaymentsModule,
    ReferralsModule,
    WalletModule,
    DeliveryModule,
    AdminModule,
    ExperienceModule,
  ],
})
export class AppModule {}
