import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { createHmac, randomUUID } from 'crypto';

import { UserRole } from '../types/domain.types';

interface TokenClaims {
  sub: string;
  role: UserRole;
  phone?: string;
  typ: 'access' | 'refresh';
  iat: number;
  exp: number;
  jti: string;
}

@Injectable()
export class TokenService {
  private readonly secret = process.env.JWT_SECRET ?? 'foodily-local-dev-secret';

  issueAccessToken(input: {
    userId: string;
    role: UserRole;
    phone?: string;
  }): string {
    return this.sign({ ...input, typ: 'access', ttlSeconds: 60 * 60 });
  }

  issueRefreshToken(input: {
    userId: string;
    role: UserRole;
    phone?: string;
  }): string {
    return this.sign({ ...input, typ: 'refresh', ttlSeconds: 60 * 60 * 24 * 14 });
  }

  verifyAccessToken(token: string): TokenClaims {
    const claims = this.verify(token);
    if (claims.typ !== 'access') {
      throw new UnauthorizedException('Invalid access token type');
    }
    return claims;
  }

  verifyRefreshToken(token: string): TokenClaims {
    const claims = this.verify(token);
    if (claims.typ !== 'refresh') {
      throw new UnauthorizedException('Invalid refresh token type');
    }
    return claims;
  }

  private sign(input: {
    userId: string;
    role: UserRole;
    phone?: string;
    typ: 'access' | 'refresh';
    ttlSeconds: number;
  }): string {
    const now = Math.floor(Date.now() / 1000);
    const claims: TokenClaims = {
      sub: input.userId,
      role: input.role,
      phone: input.phone,
      typ: input.typ,
      iat: now,
      exp: now + input.ttlSeconds,
      jti: randomUUID(),
    };

    const encodedPayload = this.base64UrlEncode(JSON.stringify(claims));
    const signature = this.signPayload(encodedPayload);

    return `foodily.${encodedPayload}.${signature}`;
  }

  private verify(token: string): TokenClaims {
    const parts = token.split('.');
    if (parts.length !== 3 || parts[0] !== 'foodily') {
      throw new UnauthorizedException('Malformed token');
    }

    const payload = parts[1];
    const signature = parts[2];

    if (this.signPayload(payload) !== signature) {
      throw new UnauthorizedException('Invalid token signature');
    }

    const claims = JSON.parse(
      this.base64UrlDecode(payload),
    ) as TokenClaims;

    const now = Math.floor(Date.now() / 1000);
    if (claims.exp <= now) {
      throw new UnauthorizedException('Token expired');
    }

    return claims;
  }

  private signPayload(payload: string): string {
    return this.base64UrlEncode(
      createHmac('sha256', this.secret).update(payload).digest('base64'),
    );
  }

  private base64UrlEncode(value: string): string {
    return Buffer.from(value)
      .toString('base64')
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/g, '');
  }

  private base64UrlDecode(value: string): string {
    const pad = value.length % 4;
    const normalized =
      value.replace(/-/g, '+').replace(/_/g, '/') + (pad ? '='.repeat(4 - pad) : '');
    return Buffer.from(normalized, 'base64').toString();
  }
}
