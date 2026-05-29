# Foodily Monorepo

Foodily is a multi-city tiffin ordering platform with:
- `apps/consumer_app` (Flutter iOS/Android customer app)
- `apps/delivery_app` (Flutter iOS/Android delivery partner app)
- `apps/admin_web` (Next.js admin dashboard)
- `services/api` (NestJS API service)
- `packages/flutter_core` (shared app core, models, theme, localization)
- `packages/flutter_ui` (shared UI components)
- `packages/contracts` (OpenAPI + API contracts)

## Repository Layout

```text
apps/
  consumer_app/
  delivery_app/
  admin_web/
services/
  api/
packages/
  flutter_core/
  flutter_ui/
  contracts/
docs/
```

## Flutter Quick Start

```bash
cd apps/consumer_app
flutter pub get
flutter run
```

```bash
cd apps/delivery_app
flutter pub get
flutter run
```

## Demo vs Live Mode

Both Flutter apps default to `DEMO` mode with seeded customers, partners, meals, wallets, and orders.

Run in demo mode:
```bash
flutter run --dart-define=APP_MODE=demo
```

Run in live mode:
```bash
flutter run --dart-define=APP_MODE=live
```

You can also toggle mode from the app profile/insights screens for local testing.

## API Quick Start (requires Node.js 20+)

```bash
cd services/api
npm install
npm run prisma:generate
npm run start:dev
```

## Admin Quick Start (requires Node.js 20+)

```bash
cd apps/admin_web
npm install
npm run dev
```

## Delivery Scope Implemented In This Commit

- Flutter monorepo scaffolding with shared packages.
- Customer app UI and key flows: OTP login, menus, cart, checkout, subscription, wallet, tracking.
- Delivery app UI flows: assigned jobs, status transitions, handoff verification.
- NestJS modular service skeleton with endpoints from the product plan.
- Repository abstraction and Prisma schema for production data-layer migration.
- OpenAPI v1 baseline and SQL schema for major entities.
- Next.js admin dashboard shell with operational modules.

See [Architecture](docs/architecture.md), [API Contracts](docs/api-contracts.md), and [Engineering Conventions](docs/engineering-conventions.md).
