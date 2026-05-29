import { Inject, Injectable } from '@nestjs/common';

import {
  CART_REPO,
  CartRepo,
} from '../database/repositories/repository.contracts';
import { AddCartItemDto } from './dto/add-cart-item.dto';

@Injectable()
export class CartService {
  constructor(@Inject(CART_REPO) private readonly cartRepo: CartRepo) {}

  async addItem(userId: string, payload: AddCartItemDto) {
    await this.cartRepo.addItem(userId, payload.mealId, payload.qty);
    return await this.cartRepo.getCart(userId);
  }

  async getCart(userId: string) {
    return await this.cartRepo.getCart(userId);
  }
}
