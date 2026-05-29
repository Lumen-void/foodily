import { apiFetch } from '../../lib/api';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../../lib/filters';

type SubscriptionItem = {
  id: string;
  userId: string;
  cityId?: string;
  cadence: string;
  status: string;
  preferredWindow: string;
  fulfillmentModel?: string;
  preferredPartnerType?: string;
  date?: string;
};

type PaginatedSubscriptions = {
  items: SubscriptionItem[];
  total: number;
  page: number;
  limit: number;
};

const fallback: PaginatedSubscriptions = {
  items: [
    {
      id: 'SUB-201',
      userId: 'u1',
      cityId: 'gurgaon',
      cadence: 'WEEKLY',
      status: 'ACTIVE',
      preferredWindow: '1:00 PM - 1:30 PM',
      fulfillmentModel: 'PARTNER_SELF_DELIVERY',
      preferredPartnerType: 'DHABA',
      date: '2026-03-09',
    },
    {
      id: 'SUB-198',
      userId: 'u8',
      cityId: 'noida',
      cadence: 'DAILY',
      status: 'PAUSED',
      preferredWindow: '8:00 PM - 8:30 PM',
      fulfillmentModel: 'PARTNER_SELF_DELIVERY',
      preferredPartnerType: 'RESTAURANT',
      date: '2026-03-08',
    },
  ],
  total: 2,
  page: 1,
  limit: 20,
};

type PageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function SubscriptionsPage({ searchParams }: PageProps) {
  const search = await resolveSearch(searchParams);
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();
  const statusFilter = queryString(search.status).trim();
  const cadenceFilter = queryString(search.cadence).trim();
  const cadenceApiValue = ['WEEKLY', 'MONTHLY'].includes(cadenceFilter.toUpperCase())
    ? cadenceFilter.toUpperCase()
    : '';

  const apiParams = new URLSearchParams({
    page: '1',
    limit: '50',
  });
  if (selectedDate) apiParams.set('date', selectedDate);
  if (query) apiParams.set('q', query);
  if (statusFilter) apiParams.set('status', statusFilter.toUpperCase());
  if (cadenceApiValue) apiParams.set('cadence', cadenceApiValue);

  const data =
    (await apiFetch<PaginatedSubscriptions>(
      `/admin/subscriptions?${apiParams.toString()}`,
    )) ?? fallback;
  const rows = data.items.map((item) => ({
    ...item,
    cityId: item.cityId ?? 'unknown',
    date: item.date ?? selectedDate,
  }));
  const cityOptions = [...new Set(rows.map((item) => item.cityId?.toUpperCase() ?? 'UNKNOWN'))].sort();
  const statusOptions = [...new Set(rows.map((item) => item.status.toUpperCase()))].sort();
  const cadenceOptions = [...new Set(rows.map((item) => item.cadence.toUpperCase()))].sort();
  const filteredRows = rows.filter((item) => {
    const city = (item.cityId ?? 'unknown').toUpperCase();
    const status = item.status.toUpperCase();
    const cadence = item.cadence.toUpperCase();
    const haystack = `${item.id} ${item.userId} ${item.cityId ?? ''} ${item.status} ${item.cadence} ${item.preferredPartnerType ?? ''}`;

    if ((item.date ?? selectedDate) !== selectedDate) return false;
    if (cityFilter && city !== cityFilter.toUpperCase()) return false;
    if (statusFilter && status !== statusFilter.toUpperCase()) return false;
    if (cadenceFilter && cadence !== cadenceFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Subscriptions</h2>
          <p className="muted">Daily subscription records with search by user, city, and status.</p>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input className="input" type="search" name="q" defaultValue={query} placeholder="Subscription ID or user" />
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
          <span>Cadence</span>
          <select className="input" name="cadence" defaultValue={cadenceFilter}>
            <option value="">All cadence</option>
            {cadenceOptions.map((cadence) => (
              <option key={cadence} value={cadence}>
                {cadence}
              </option>
            ))}
          </select>
        </label>
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/subscriptions">
            Reset
          </a>
        </div>
      </form>
      <table className="table">
        <thead>
          <tr>
            <th>Subscription ID</th>
            <th>User</th>
            <th>Date</th>
            <th>City</th>
            <th>Cadence</th>
            <th>Status</th>
            <th>Window</th>
            <th>Fulfillment</th>
            <th>Partner type</th>
          </tr>
        </thead>
        <tbody>
          {filteredRows.map((item) => (
            <tr key={item.id}>
              <td>{item.id}</td>
              <td>{item.userId}</td>
              <td>{item.date ?? selectedDate}</td>
              <td>{item.cityId ?? 'unknown'}</td>
              <td>{item.cadence}</td>
              <td>{item.status}</td>
              <td>{item.preferredWindow}</td>
              <td>{item.fulfillmentModel ?? 'PARTNER_SELF_DELIVERY'}</td>
              <td>{item.preferredPartnerType ?? 'RESTAURANT / DHABA'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  );
}
