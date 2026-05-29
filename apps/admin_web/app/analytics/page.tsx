import { apiFetch } from '../../lib/api';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../../lib/filters';

type Metrics = {
  totalOrders: number;
  activeSubscriptions: number;
  paymentSuccessRate: number;
  onTimeDeliveryRate?: number;
  onTimeFulfillmentRate?: number;
  averageOrderValue: number;
};

type DailySnapshot = {
  date: string;
  city: string;
  totalOrders: number;
  activeSubscriptions: number;
  paymentSuccessRate: number;
  onTimeFulfillmentRate: number;
  averageOrderValue: number;
};

const fallback: Metrics = {
  totalOrders: 842,
  activeSubscriptions: 1284,
  paymentSuccessRate: 98.1,
  onTimeDeliveryRate: 96.2,
  averageOrderValue: 211,
};

const snapshots: DailySnapshot[] = [
  {
    date: '2026-03-09',
    city: 'GURGAON',
    totalOrders: 842,
    activeSubscriptions: 1284,
    paymentSuccessRate: 98.1,
    onTimeFulfillmentRate: 96.2,
    averageOrderValue: 211,
  },
  {
    date: '2026-03-09',
    city: 'NOIDA',
    totalOrders: 533,
    activeSubscriptions: 944,
    paymentSuccessRate: 97.5,
    onTimeFulfillmentRate: 95.1,
    averageOrderValue: 203,
  },
  {
    date: '2026-03-08',
    city: 'DELHI',
    totalOrders: 601,
    activeSubscriptions: 1018,
    paymentSuccessRate: 96.9,
    onTimeFulfillmentRate: 93.8,
    averageOrderValue: 198,
  },
];

type PageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function AnalyticsPage({ searchParams }: PageProps) {
  const search = await resolveSearch(searchParams);
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();

  const apiParams = new URLSearchParams();
  if (selectedDate) apiParams.set('date', selectedDate);
  if (query) apiParams.set('q', query);
  if (cityFilter) apiParams.set('cityId', cityFilter);

  const metrics =
    (await apiFetch<Metrics>(`/admin/metrics/overview?${apiParams.toString()}`)) ?? fallback;
  const filteredSnapshots = snapshots.filter((item) => {
    const haystack = `${item.city} ${item.date} ${item.totalOrders} ${item.activeSubscriptions}`;
    if (item.date !== selectedDate) return false;
    if (cityFilter && item.city !== cityFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });
  const cityOptions = [...new Set(snapshots.map((item) => item.city))].sort();
  const aggregate = filteredSnapshots.reduce(
    (acc, item) => ({
      totalOrders: acc.totalOrders + item.totalOrders,
      activeSubscriptions: acc.activeSubscriptions + item.activeSubscriptions,
      paymentSuccessRate: acc.paymentSuccessRate + item.paymentSuccessRate,
      onTimeFulfillmentRate: acc.onTimeFulfillmentRate + item.onTimeFulfillmentRate,
      averageOrderValue: acc.averageOrderValue + item.averageOrderValue,
      count: acc.count + 1,
    }),
    {
      totalOrders: 0,
      activeSubscriptions: 0,
      paymentSuccessRate: 0,
      onTimeFulfillmentRate: 0,
      averageOrderValue: 0,
      count: 0,
    },
  );
  const summary =
    aggregate.count > 0
      ? {
          totalOrders: aggregate.totalOrders,
          activeSubscriptions: aggregate.activeSubscriptions,
          paymentSuccessRate: Number((aggregate.paymentSuccessRate / aggregate.count).toFixed(1)),
          onTimeFulfillmentRate: Number((aggregate.onTimeFulfillmentRate / aggregate.count).toFixed(1)),
          averageOrderValue: Number((aggregate.averageOrderValue / aggregate.count).toFixed(0)),
        }
      : {
          totalOrders: metrics.totalOrders,
          activeSubscriptions: metrics.activeSubscriptions,
          paymentSuccessRate: metrics.paymentSuccessRate,
          onTimeFulfillmentRate: metrics.onTimeFulfillmentRate ?? metrics.onTimeDeliveryRate ?? fallback.onTimeDeliveryRate ?? 0,
          averageOrderValue: metrics.averageOrderValue,
        };

  const cards = [
    { title: 'Total Orders', value: `${summary.totalOrders}` },
    { title: 'Active Subscriptions', value: `${summary.activeSubscriptions}` },
    { title: 'Payment Success', value: `${summary.paymentSuccessRate}%` },
    { title: 'On-time Fulfillment', value: `${summary.onTimeFulfillmentRate}%` },
    { title: 'Average Order Value', value: `₹${summary.averageOrderValue}` },
  ];

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Analytics</h2>
          <p className="muted">Daily analytics rollups with date, city, and search filters.</p>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input className="input" type="search" name="q" defaultValue={query} placeholder="City or volume" />
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
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/analytics">
            Reset
          </a>
        </div>
      </form>
      <div className="grid">
        {cards.map((metric) => (
          <article className="card" key={metric.title}>
            <p>{metric.title}</p>
            <h3>{metric.value}</h3>
          </article>
        ))}
      </div>
      <article className="card section-gap">
        <h3>Daily city snapshot</h3>
        <table className="table">
          <thead>
            <tr>
              <th>Date</th>
              <th>City</th>
              <th>Orders</th>
              <th>Subscriptions</th>
              <th>Payment success</th>
              <th>On-time fulfillment</th>
              <th>AOV</th>
            </tr>
          </thead>
          <tbody>
            {filteredSnapshots.map((item) => (
              <tr key={`${item.date}-${item.city}`}>
                <td>{item.date}</td>
                <td>{item.city}</td>
                <td>{item.totalOrders}</td>
                <td>{item.activeSubscriptions}</td>
                <td>{item.paymentSuccessRate}%</td>
                <td>{item.onTimeFulfillmentRate}%</td>
                <td>₹{item.averageOrderValue}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}
