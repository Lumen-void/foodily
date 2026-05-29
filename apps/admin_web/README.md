# Foodily Admin Web

Next.js admin dashboard shell aligned with platform modules:

- Orders and subscriptions operations
- Menu and slot management
- Dispatch assignment
- City/zone/kitchen controls
- Payment reconciliation
- Analytics overview

Run (Node.js required):

```bash
npm install
npm run dev
```

Optional environment variables:

- `NEXT_PUBLIC_API_BASE_URL` (default: `http://localhost:8080/v1`)
- `NEXT_PUBLIC_ADMIN_TOKEN` (Bearer token for admin API calls in server components)
