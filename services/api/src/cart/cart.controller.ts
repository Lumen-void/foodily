import { Body, Controller, Get, Post } from '@nestjs/common';

import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequestUser } from '../common/interfaces/request-user.interface';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { CartService } from './cart.service';

@Controller('cart')
export class CartController {
  constructor(private readonly service: CartService) {}

  @Post('items')
  addItem(@CurrentUser() user: RequestUser, @Body() payload: AddCartItemDto) {
    return this.service.addItem(user.id, payload);
  }

  @Get()
  getCart(@CurrentUser() user: RequestUser) {
    return this.service.getCart(user.id);
  }
}
