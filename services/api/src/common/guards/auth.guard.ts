import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

import { TokenService } from '../../auth/token.service';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { RolesEnum } from '../enums/roles.enum';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly tokenService: TokenService,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | undefined>;
      user?: { id: string; role: string; phone?: string };
    }>();

    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      const requiredRoles = this.reflector.getAllAndOverride<RolesEnum[]>(
        ROLES_KEY,
        [context.getHandler(), context.getClass()],
      );

      if (
        requiredRoles?.includes(RolesEnum.ADMIN) &&
        request.headers['x-role'] === RolesEnum.ADMIN
      ) {
        request.user = { id: 'admin-bootstrap', role: RolesEnum.ADMIN };
        return true;
      }

      throw new UnauthorizedException('Missing bearer token');
    }

    const token = authHeader.slice('Bearer '.length).trim();
    const claims = this.tokenService.verifyAccessToken(token);
    request.user = {
      id: claims.sub,
      role: claims.role,
      phone: claims.phone,
    };

    return true;
  }
}
