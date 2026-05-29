# Foodily API (NestJS)

Foodily API now includes production-oriented scaffolding:

- Bearer-token authentication guard (with public route controls)
- Role-based admin authorization
- Deterministic success/error response envelopes
- Idempotency-key support for order and payment creation
- Operational endpoints for order timelines, delivery job listing, subscription pause/resume, and admin KPI overview
- Repository abstraction layer to swap in Prisma-backed implementations

## Route Groups

- Auth + OTP + Refresh
- Locations + menus
- Cart + orders + timeline
- Subscriptions + pause/resume
- Payments + webhook
- Referrals + wallet
- Delivery jobs + status updates
- Admin lists + dispatch + metrics

## Local Run

Requires Node.js 20+.

```bash
npm install
npm run start:dev
```

API base: `http://localhost:8080/v1`

### Data Provider

- `DATA_STORE_PROVIDER=memory` (default): in-memory demo repository
- `DATA_STORE_PROVIDER=prisma`: PostgreSQL/Prisma repository implementation

For Prisma mode, set `DATABASE_URL` and run:

```bash
npm run prisma:generate
npm run prisma:migrate:dev
npm run prisma:seed
```

## Prisma

```bash
npm run prisma:generate
npm run prisma:migrate:dev
npm run prisma:seed
```

## Auth and Headers

- User routes: `Authorization: Bearer <token>`
- Admin routes: token with `ADMIN` role claim (or `x-role: ADMIN` bootstrap fallback)
- Idempotent routes support `idempotency-key` header:
  - `POST /v1/orders`
  - `POST /v1/payments/create-order`
- Razorpay webhook requires `x-razorpay-signature` when `RAZORPAY_WEBHOOK_SECRET` is set.
