import { apiFetch } from '../../lib/api';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../../lib/filters';

type PaymentItem = {
  id: string;
  orderId: string;
  cityId?: string;
  status: string;
  amount: number;
  partnerSettlement?: string;
  createdAt?: string;
};

type PaginatedPayments = {
  items: PaymentItem[];
  total: number;
  page: number;
  limit: number;
};

const fallback: PaginatedPayments = {
  items: [
    {
      id: 'PAY-501',
      orderId: 'ORD-1101',
      cityId: 'gurgaon',
      status: 'CAPTURED',
      amount: 205,
      partnerSettlement: 'PENDING',
      createdAt: '2026-03-09T09:15:00.000Z',
    },
    {
      id: 'PAY-502',
      orderId: 'ORD-1102',
      cityId: 'noida',
      status: 'CAPTURED',
      amount: 699,
      partnerSettlement: 'SCHEDULED',
      createdAt: '2026-03-09T08:45:00.000Z',
    },
    {
      id: 'PAY-503',
      orderId: 'ORD-1103',
      cityId: 'delhi',
      status: 'FAILED',
      amount: 145,
      partnerSettlement: 'BLOCKED',
      createdAt: '2026-03-08T12:05:00.000Z',
    },
    {
      id: 'PAY-504',
      orderId: 'ORD-1104',
      cityId: 'gurgaon',
      status: 'CAPTURED',
      amount: 490,
      partnerSettlement: 'SETTLED',
      createdAt: '2026-03-08T18:30:00.000Z',
    },
  ],
  total: 4,
  page: 1,
  limit: 20,
};

function settlementFromStatus(status: string): string {
  const upper = status.toUpperCase();
  if (upper === 'CAPTURED') return 'SCHEDULED';
  if (upper === 'FAILED') return 'BLOCKED';
  if (upper === 'REFUNDED') return 'SETTLED';
  return 'PENDING';
}

export default async function PaymentsPage() {
  const search: Record<string, string | string[] | undefined> = {};
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();
  const statusFilter = queryString(search.status).trim();
  const settlementFilter = queryString(search.settlement).trim();

  const apiParams = new URLSearchParams({
    page: '1',
    limit: '50',
  });
  if (selectedDate) apiParams.set('date', selectedDate);
  if (query) apiParams.set('q', query);
  if (cityFilter) apiParams.set('cityId', cityFilter);
  if (statusFilter) apiParams.set('status', statusFilter.toUpperCase());

  const data =
    (await apiFetch<PaginatedPayments>(`/admin/payments?${apiParams.toString()}`)) ?? fallback;

  const rows = data.items.map((payment) => ({
    ...payment,
    cityId: payment.cityId ?? 'unknown',
    partnerSettlement: payment.partnerSettlement ?? settlementFromStatus(payment.status),
    date: payment.createdAt?.slice(0, 10) ?? selectedDate,
  }));

  const cityOptions = [...new Set(rows.map((item) => item.cityId.toUpperCase()))].sort();
  const statusOptions = [...new Set(rows.map((item) => item.status.toUpperCase()))].sort();
  const settlementOptions = [
    ...new Set(rows.map((item) => item.partnerSettlement.toUpperCase())),
  ].sort();

  const filteredRows = rows.filter((payment) => {
    const city = payment.cityId.toUpperCase();
    const status = payment.status.toUpperCase();
    const settlement = payment.partnerSettlement.toUpperCase();
    const haystack =
      `${payment.id} ${payment.orderId} ${payment.cityId} ${payment.status} ${payment.partnerSettlement}`
        .toLowerCase();

    if (selectedDate && payment.date !== selectedDate) return false;
    if (cityFilter && city !== cityFilter.toUpperCase()) return false;
    if (statusFilter && status !== statusFilter.toUpperCase()) return false;
    if (settlementFilter && settlement !== settlementFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Payment Reconciliation</h2>
          <p className="muted">Daily payment and partner settlement records with search and filters.</p>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input className="input" type="search" name="q" defaultValue={query} placeholder="Payment ID or order ID" />
        </label>
        <label className="filter-field">
          <span>City</span>
          <select className="input" name="city" defaultValue={cityFilter}>
            <option value="">All cities</option>
            {cityOptions.map((city) => (
              <option key={city} value={city}>
                {city}
              </option>
            ))}
          </select>
        </label>
        <label className="filter-field">
          <span>Status</span>
          <select className="input" name="status" defaultValue={statusFilter}>
            <option value="">All status</option>
            {statusOptions.map((status) => (
              <option key={status} value={status}>
                {status}
              </option>
            ))}
          </select>
        </label>
        <label className="filter-field">
          <span>Settlement</span>
          <select className="input" name="settlement" defaultValue={settlementFilter}>
            <option value="">All settlement</option>
            {settlementOptions.map((status) => (
              <option key={status} value={status}>
                {status}
              </option>
            ))}
          </select>
        </label>
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/payments">
            Reset
          </a>
        </div>
      </form>
      <p>
        Showing {filteredRows.length} of {rows.length} records for {selectedDate}
      </p>
      <table className="table">
        <thead>
          <tr>
            <th>Payment ID</th>
            <th>Order</th>
            <th>Date</th>
            <th>City</th>
            <th>Status</th>
            <th>Partner settlement</th>
            <th>Amount</th>
          </tr>
        </thead>
        <tbody>
          {filteredRows.map((payment) => (
            <tr key={payment.id}>
              <td>{payment.id}</td>
              <td>{payment.orderId}</td>
              <td>{payment.date}</td>
              <td>{payment.cityId}</td>
              <td>{payment.status}</td>
              <td>{payment.partnerSettlement}</td>
              <td>₹{payment.amount}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  );
}
