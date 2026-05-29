import fs from 'fs';

const sqlPath = 'packages/contracts/schema/postgres.sql';
const prismaPath = 'services/api/prisma/schema.prisma';
const openapiPath = 'packages/contracts/openapi/foodily-v1.yaml';

const sql = fs.readFileSync(sqlPath, 'utf8');
const prisma = fs.readFileSync(prismaPath, 'utf8');
const openapi = fs.readFileSync(openapiPath, 'utf8');

const sqlTables = [...sql.matchAll(/create table if not exists\s+(\w+)/gi)].map(
  (match) => match[1],
);
const prismaModels = [...prisma.matchAll(/^model\s+(\w+)/gm)].map(
  (match) => match[1],
);

const requiredRoutePatterns = [
  '/orders/{id}/timeline:',
  '/subscriptions/{id}/pause:',
  '/subscriptions/{id}/resume:',
  '/delivery/jobs:',
  '/admin/metrics/overview:',
  '/auth/refresh:',
];

const requiredModelHints = {
  users: 'User',
  cities: 'City',
  zones: 'Zone',
  orders: 'Order',
  subscriptions: 'Subscription',
  payments: 'Payment',
  payment_events: 'PaymentEvent',
  wallet_transactions: 'WalletTransaction',
  delivery_jobs: 'DeliveryJob',
  audit_logs: 'AuditLog',
};

const missingModels = Object.entries(requiredModelHints)
  .filter(([table, model]) => sqlTables.includes(table) && !prismaModels.includes(model))
  .map(([table, model]) => ({ table, model }));

const missingRoutes = requiredRoutePatterns.filter(
  (pattern) => !openapi.includes(pattern),
);

if (missingModels.length > 0) {
  console.error('Schema drift check failed: missing Prisma models for SQL tables');
  for (const item of missingModels) {
    console.error(`- ${item.table} -> expected model ${item.model}`);
  }
  process.exit(1);
}

if (missingRoutes.length > 0) {
  console.error('OpenAPI drift check failed: missing required routes');
  for (const route of missingRoutes) {
    console.error(`- ${route}`);
  }
  process.exit(1);
}

console.log('Schema and contract drift checks passed.');
