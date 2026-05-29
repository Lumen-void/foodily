import { apiFetch } from '../../lib/api';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../../lib/filters';

type OrderItem = {
  id: string;
  cityId: string;
  type: string;
  status: string;
  total: number;
  fulfillmentModel?: string;
  date?: string;
};

type PaginatedOrders = {
  items: OrderItem[];
  total: number;
  page: number;
  limit: number;
};

const fallback: PaginatedOrders = {
  items: [
    {
      id: 'ORD-1101',
      cityId: 'gurgaon',
      type: 'ONE_TIME',
      status: 'CONFIRMED',
      total: 205,
      fulfillmentModel: 'PARTNER_SELF_DELIVERY',
      date: '2026-03-09',
    },
    {
      id: 'ORD-1102',
      cityId: 'noida',
      type: 'SUBSCRIPTION',
      status: 'PREPARING',
      total: 699,
      fulfillmentModel: 'PARTNER_SELF_DELIVERY',
      date: '2026-03-09',
    },
    {
      id: 'ORD-1099',
      cityId: 'gurgaon',
      type: 'ONE_TIME',
      status: 'OUT_FOR_DELIVERY',
      total: 260,
      fulfillmentModel: 'PARTNER_SELF_DELIVERY',
      date: '2026-03-08',
    },
    {
      id: 'ORD-1098',
      cityId: 'delhi',
      type: 'ONE_TIME',
      status: 'DELIVERED',
      total: 185,
      fulfillmentModel: 'PARTNER_SELF_DELIVERY',
      date: '2026-03-08',
    },
  ],
  total: 4,
  page: 1,
  limit: 20,
};

type PageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function OrdersPage({ searchParams }: PageProps) {
  const search = await resolveSearch(searchParams);
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();
  const statusFilter = queryString(search.status).trim();

  const apiParams = new URLSearchParams({
    page: '1',
    limit: '50',
  });
  if (selectedDate) apiParams.set('date', selectedDate);
  if (query) apiParams.set('q', query);
  if (cityFilter) apiParams.set('cityId', cityFilter);
  if (statusFilter) apiParams.set('status', statusFilter.toUpperCase());

  const data = (await apiFetch<PaginatedOrders>(`/admin/orders?${apiParams.toString()}`)) ?? fallback;
  const rows = data.items.map((item) => ({
    ...item,
    date: item.date ?? selectedDate,
  }));

  const cityOptions = [...new Set(rows.map((item) => item.cityId.toUpperCase()))].sort();
  const statusOptions = [...new Set(rows.map((item) => item.status.toUpperCase()))].sort();
  const filteredRows = rows.filter((item) => {
    const itemDate = item.date ?? selectedDate;
    const city = item.cityId.toUpperCase();
    const status = item.status.toUpperCase();
    const haystack = `${item.id} ${item.cityId} ${item.type} ${item.status} ${item.fulfillmentModel ?? ''}`;

    if (selectedDate && itemDate !== selectedDate) return false;
    if (cityFilter && city !== cityFilter.toUpperCase()) return false;
    if (statusFilter && status !== statusFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Orders</h2>
          <p className="muted">Daily order operations with search and city/status filters.</p>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input className="input" type="search" name="q" defaultValue={query} placeholder="Order ID, city, status" />
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
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/orders">
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
            <th>Order ID</th>
            <th>Date</th>
            <th>City</th>
            <th>Type</th>
            <th>Fulfillment</th>
            <th>Status</th>
            <th>Amount</th>
          </tr>
        </thead>
        <tbody>
          {filteredRows.map((order) => (
            <tr key={order.id}>
              <td>{order.id}</td>
              <td>{order.date ?? selectedDate}</td>
              <td>{order.cityId}</td>
              <td>{order.type}</td>
              <td>{order.fulfillmentModel ?? 'PARTNER_SELF_DELIVERY'}</td>
              <td>
                <span className="badge">{order.status}</span>
              </td>
              <td>₹{order.total}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  );
}
